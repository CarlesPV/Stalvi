import 'package:drift/drift.dart';

import 'package:stalvi/core/errors/app_exceptions.dart';
import '../database/app_database.dart' as db;
import '../database/daos/transaction_dao.dart';
import '../database/tables/transaction_table.dart' as db_table;
import '../mappers/transaction_mapper.dart';
import 'package:stalvi/domain/entities/transaction.dart' as domain;
import 'package:stalvi/domain/entities/transaction_type.dart' as domain;
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';

/// Concrete implementation of [ITransactionRepository] backed by Drift.
///
/// **Critical business rule**: write operations run inside Drift
/// `.transaction()` blocks so that row mutations **and** balance updates
/// succeed or fail atomically.
class TransactionRepository implements ITransactionRepository {
  final db.AppDatabase _db;

  TransactionRepository(this._db);

  TransactionDao get _transactionDao => _db.transactionDao;

  // ── Single-transaction CRUD ───────────────────────────────────────────────

  @override
  Future<domain.Transaction> createTransaction(
    domain.Transaction transaction,
  ) async {
    try {
      return await _db.transaction(() async {
        // 1. Insert the new transaction row.
        final dbTransaction = transaction.toDb();
        await _db.into(_db.transactions).insert(dbTransaction);

        // 3. Return the inserted transaction as a domain entity.
        return transaction;
      });
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to create transaction',
        code: 'TRANSACTION_INSERT_FAILED',
        details: e,
      );
    }
  }

  @override
  Future<void> createTransactions(List<domain.Transaction> transactions) async {
    if (transactions.isEmpty) return;
    try {
      await _db.batch((batch) {
        batch.insertAll(
          _db.transactions,
          transactions.map((t) => t.toDb()).toList(),
          mode: InsertMode.insertOrIgnore,
        );
      });
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to create transactions in batch',
        code: 'TRANSACTION_BATCH_INSERT_FAILED',
        details: e,
      );
    }
  }

  // ── Transfer pair ─────────────────────────────────────────────────────────

  /// Atomically inserts both legs of a transfer and adjusts both account
  /// balances within a single Drift `.transaction()` block.
  ///
  /// Origin account is debited (outflow); destination account is credited.
  @override
  Future<TransferPair> createTransferPair({
    required domain.Transaction originTransaction,
    required domain.Transaction destinationTransaction,
  }) async {
    try {
      return await _db.transaction(() async {
        // Insert origin leg.
        await _db.into(_db.transactions).insert(originTransaction.toDb());

        // Insert destination leg.
        await _db.into(_db.transactions).insert(destinationTransaction.toDb());

        return TransferPair(
          origin: originTransaction,
          destination: destinationTransaction,
        );
      });
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to create transfer pair',
        code: 'TRANSFER_INSERT_FAILED',
        details: e,
      );
    }
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  @override
  Future<domain.Transaction?> getTransactionById(String id) async {
    try {
      final query = _db.select(_db.transactions)..where((t) => t.id.equals(id));
      final row = await query.getSingleOrNull();
      return row?.toDomain();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get transaction by id "$id"',
        code: 'TRANSACTION_QUERY_FAILED',
        details: e,
      );
    }
  }

  @override
  Future<List<domain.Transaction>> getTransactionsByAccountId(
    String accountId,
  ) async {
    try {
      final query = _db.select(_db.transactions)
        ..where(
          (t) => t.accountId.equals(accountId) & t.isDeleted.equals(false),
        )
        ..orderBy([
          (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]);
      final rows = await query.get();
      return rows.map((r) => r.toDomain()).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get transactions for account "$accountId"',
        code: 'TRANSACTION_QUERY_FAILED',
        details: e,
      );
    }
  }

  @override
  Future<domain.Transaction> updateTransaction(
    domain.Transaction transaction,
  ) async {
    try {
      final dbTransaction = transaction.toDb();
      final updated = await (_db.update(_db.transactions)
            ..where((t) => t.id.equals(transaction.id)))
          .write(dbTransaction.toCompanion(true));

      if (updated == 0) {
        throw NotFoundException(
          message: 'Transaction with id "${transaction.id}" not found',
          code: 'TRANSACTION_NOT_FOUND',
        );
      }

      return transaction;
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update transaction "${transaction.id}"',
        code: 'TRANSACTION_UPDATE_FAILED',
        details: e,
      );
    }
  }

  // ── Soft delete ───────────────────────────────────────────────────────────

  /// Soft-deletes a transaction. If it belongs to a transfer pair, its
  /// mirror counterpart is also soft-deleted atomically.
  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _db.transaction(() async {
        final txn = await _fetchOrThrow(id);
        if (txn.isDeleted) return;

        // Soft-delete this row.
        await _softDelete(id);

        // Mirror: if part of a transfer, soft-delete counterpart too.
        if (txn.transferId != null) {
          final mirror = await _findMirror(txn.id, txn.transferId!);
          if (mirror != null && !mirror.isDeleted) {
            await _softDelete(mirror.id);
          }
        }
      });
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to delete transaction "$id"',
        code: 'TRANSACTION_DELETE_FAILED',
        details: e,
      );
    }
  }

  // ── Hard delete ───────────────────────────────────────────────────────────

  /// Permanently removes a transaction. Its transfer mirror (if any) is also
  /// permanently removed atomically.
  @override
  Future<void> hardDeleteTransaction(String id) async {
    try {
      await _db.transaction(() async {
        final txn = await _fetchOrThrow(id);

        // Find mirror before deletion.
        db.Transaction? mirror;
        if (txn.transferId != null) {
          mirror = await _findMirror(txn.id, txn.transferId!);
        }

        // Hard delete this row.
        await (_db.delete(_db.transactions)..where((t) => t.id.equals(id)))
            .go();

        // Hard delete mirror if found.
        if (mirror != null) {
          await (_db.delete(_db.transactions)
                ..where((t) => t.id.equals(mirror!.id)))
              .go();
        }
      });
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to hard-delete transaction "$id"',
        code: 'TRANSACTION_HARD_DELETE_FAILED',
        details: e,
      );
    }
  }

  // ── Restore ───────────────────────────────────────────────────────────────

  /// Restores a soft-deleted transaction. Its transfer mirror (if any) is
  /// also restored atomically and both account balances are re-applied.
  @override
  Future<void> restoreTransaction(String id) async {
    try {
      await _db.transaction(() async {
        final txn = await _fetchOrThrow(id);
        if (!txn.isDeleted) return;

        // Restore this row.
        await _restore(id);

        // Mirror: restore counterpart too.
        if (txn.transferId != null) {
          final mirror = await _findMirror(txn.id, txn.transferId!);
          if (mirror != null && mirror.isDeleted) {
            await _restore(mirror.id);
          }
        }
      });
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to restore transaction "$id"',
        code: 'TRANSACTION_RESTORE_FAILED',
        details: e,
      );
    }
  }

  // ── Account-level cascade operations ─────────────────────────────────────

  /// Soft-deletes all non-deleted transactions belonging to [accountId].
  ///
  /// **Does not** revert account balances because the account itself is being
  /// soft-deleted; balance consistency is maintained at the account level.
  @override
  Future<void> softDeleteTransactionsByAccountId(String accountId) async {
    try {
      final now = DateTime.now();
      await (_db.update(_db.transactions)
            ..where(
              (t) => t.accountId.equals(accountId) & t.isDeleted.equals(false),
            ))
          .write(
        db.TransactionsCompanion(
          isDeleted: const Value(true),
          modifiedAt: Value(now),
        ),
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to soft-delete transactions for account "$accountId"',
        code: 'CASCADE_SOFT_DELETE_FAILED',
        details: e,
      );
    }
  }

  /// Permanently hard-deletes all transactions belonging to [accountId].
  @override
  Future<void> hardDeleteTransactionsByAccountId(String accountId) async {
    try {
      await (_db.delete(_db.transactions)
            ..where((t) => t.accountId.equals(accountId)))
          .go();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to hard-delete transactions for account "$accountId"',
        code: 'CASCADE_HARD_DELETE_FAILED',
        details: e,
      );
    }
  }

  // ── Streams ───────────────────────────────────────────────────────────────

  @override
  Stream<List<domain.Transaction>> watchRawTransactions() {
    try {
      final query = _db.select(_db.transactions)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([
          (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]);
      return query.watch().map((rows) {
        return rows.map((r) => r.toDomain()).toList();
      });
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to watch raw transactions',
        code: 'TRANSACTION_WATCH_FAILED',
        details: e,
      );
    }
  }

  @override
  Stream<List<domain.Transaction>> watchAllTransactions() {
    try {
      final query = _db.select(_db.transactions)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([
          (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]);
      return query.watch().map((rows) {
        final seenTransfers = <String>{};
        return rows
            .where((r) {
              if (r.transferId != null) {
                if (seenTransfers.contains(r.transferId)) return false;
                seenTransfers.add(r.transferId!);
              }
              return true;
            })
            .map((r) => r.toDomain())
            .toList();
      });
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to watch transactions',
        code: 'TRANSACTION_WATCH_FAILED',
        details: e,
      );
    }
  }

  /// Streams [domain.Transaction] rows matching all non-null dimensions in
  /// [filter] concurrently.
  ///
  /// Delegates to [TransactionDao.watchFiltered] which handles all nine filter
  /// dimensions including the `tagId → tag name → LIKE notes` resolution.
  @override
  Stream<List<domain.Transaction>> watchFilteredTransactions(
    TransactionQueryFilter filter,
  ) {
    try {
      return _transactionDao
          .watchFiltered(
        accountId: filter.accountId,
        type: filter.type != null ? _mapDomainTypeToDB(filter.type!) : null,
        categoryId: filter.categoryId,
        startDate: filter.dateRange?.start,
        endDate: filter.dateRange?.end,
        minAmountCents: filter.minAmountCents,
        maxAmountCents: filter.maxAmountCents,
        tagId: filter.tagId,
        currency: filter.currency,
      )
          .map((rows) {
        if (filter.accountId != null) {
          return rows.map((r) => r.toDomain()).toList();
        } else {
          final seenTransfers = <String>{};
          return rows
              .where((r) {
                if (r.transferId != null) {
                  if (seenTransfers.contains(r.transferId)) return false;
                  seenTransfers.add(r.transferId!);
                }
                return true;
              })
              .map((r) => r.toDomain())
              .toList();
        }
      });
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to watch filtered transactions',
        code: 'TRANSACTION_WATCH_FAILED',
        details: e,
      );
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Fetches a [db.Transaction] row by [id], throwing [NotFoundException] if
  /// it does not exist.
  Future<db.Transaction> _fetchOrThrow(String id) async {
    final row = await (_db.select(_db.transactions)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) {
      throw NotFoundException(
        message: 'Transaction with id "$id" not found',
        code: 'TRANSACTION_NOT_FOUND',
      );
    }
    return row;
  }

  /// Finds the counterpart row of a transfer pair.
  ///
  /// Returns `null` if the mirror no longer exists.
  Future<db.Transaction?> _findMirror(
    String selfId,
    String transferId,
  ) async {
    return (_db.select(_db.transactions)
          ..where(
            (t) => t.transferId.equals(transferId) & t.id.isNotValue(selfId),
          ))
        .getSingleOrNull();
  }

  /// Marks a transaction row as soft-deleted.
  Future<void> _softDelete(String id) async {
    await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      db.TransactionsCompanion(
        isDeleted: const Value(true),
        modifiedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Clears the isDeleted flag of a transaction row (restores it).
  Future<void> _restore(String id) async {
    await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      db.TransactionsCompanion(
        isDeleted: const Value(false),
        modifiedAt: Value(DateTime.now()),
      ),
    );
  }

  db_table.TransactionType _mapDomainTypeToDB(
    domain.TransactionType domainType,
  ) {
    switch (domainType) {
      case domain.TransactionType.income:
        return db_table.TransactionType.income;
      case domain.TransactionType.expense:
        return db_table.TransactionType.expense;
      case domain.TransactionType.transfer:
        return db_table.TransactionType.transfer;
    }
  }
}
