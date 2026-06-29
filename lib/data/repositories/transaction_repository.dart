import 'package:drift/drift.dart';

import 'package:stalvi/core/errors/app_exceptions.dart';
import '../database/app_database.dart' as db;
import '../database/daos/transaction_dao.dart';
import '../database/tables/transaction_table.dart' as db_table;
import '../mappers/transaction_mapper.dart';
import 'package:stalvi/domain/entities/transaction.dart' as domain;
import 'package:stalvi/domain/entities/transaction_type.dart' as domain;
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/core/utils/currency_converter.dart';

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

        // 2. Adjust account balance.
        await _adjustBalance(
          dbTransaction,
          _BalanceOp.add,
        );

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
        // Debit origin account.
        await _adjustBalance(
          originTransaction.toDb(),
          _BalanceOp.add,
        );

        // Insert destination leg.
        await _db.into(_db.transactions).insert(destinationTransaction.toDb());
        // Credit destination account.
        await _adjustBalance(
          destinationTransaction.toDb(),
          _BalanceOp.add,
        );

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

        // Revert balance for this leg.
        await _revertBalance(txn);

        // Soft-delete this row.
        await _softDelete(id);

        // Mirror: if part of a transfer, soft-delete counterpart too.
        if (txn.transferId != null) {
          final mirror = await _findMirror(txn.id, txn.transferId!);
          if (mirror != null && !mirror.isDeleted) {
            await _revertBalance(mirror);
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

        // Re-apply balance for this leg.
        await _applyBalance(txn);

        // Restore this row.
        await _restore(id);

        // Mirror: restore counterpart too.
        if (txn.transferId != null) {
          final mirror = await _findMirror(txn.id, txn.transferId!);
          if (mirror != null && mirror.isDeleted) {
            await _applyBalance(mirror);
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

  /// Adjusts the balance of [accountId] by [amountCents] according to [type].
  ///
  /// [op] controls the direction: [_BalanceOp.add] applies the transaction
  /// (income → +, expense/transfer-out → −), [_BalanceOp.revert] undoes it.
  Future<void> _adjustBalance(
    db.Transaction transaction,
    _BalanceOp op,
  ) async {
    final accountRow = await (_db.select(_db.accounts)
          ..where((a) => a.id.equals(transaction.accountId)))
        .getSingleOrNull();
    if (accountRow == null) {
      throw NotFoundException(
        message: 'Account with id "${transaction.accountId}" not found',
        code: 'ACCOUNT_NOT_FOUND',
      );
    }

    final domain.Transaction domainTxn = transaction.toDomain();
    final double convertedAmount = CurrencyConverter.convertAmount(
      domainTxn,
      accountRow.currency,
      null,
    );

    final double delta = convertedAmount / 100.0;
    final bool applying = op == _BalanceOp.add;
    double newBalance;

    switch (_mapDbTypeToDomain(transaction.type)) {
      case domain.TransactionType.income:
        newBalance = applying
            ? accountRow.initialBalance + delta
            : accountRow.initialBalance - delta;
        break;
      case domain.TransactionType.expense:
        newBalance = applying
            ? accountRow.initialBalance - delta
            : accountRow.initialBalance + delta;
        break;
      case domain.TransactionType.transfer:
        bool isOrigin = true;
        if (transaction.transferId != null) {
          final mirror =
              await _findMirror(transaction.id, transaction.transferId!);
          isOrigin = transaction.id.endsWith('_dst')
              ? false
              : (mirror != null
                  ? (transaction.createdAt.isBefore(mirror.createdAt) ||
                      (transaction.createdAt
                              .isAtSameMomentAs(mirror.createdAt) &&
                          transaction.id.compareTo(mirror.id) < 0))
                  : true);
        }

        if (isOrigin) {
          // Origin deducts the amount
          newBalance = applying
              ? accountRow.initialBalance - delta
              : accountRow.initialBalance + delta;
        } else {
          // Destination adds the amount
          newBalance = applying
              ? accountRow.initialBalance + delta
              : accountRow.initialBalance - delta;
        }
        break;
    }

    await (_db.update(_db.accounts)
          ..where((a) => a.id.equals(transaction.accountId)))
        .write(
      db.AccountsCompanion(
        initialBalance: Value(newBalance),
        modifiedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Reverts the balance impact of [txn] based on its type.
  Future<void> _revertBalance(db.Transaction txn) async {
    // For a transfer-destination leg the amount was credited (income direction),
    // so reverting it uses expense direction — but we stored it with the
    // income sign convention. We detect destination legs by checking whether
    // another row with the same transferId debited a different account.
    // Simpler approach: origin leg behaves as expense on delete, destination
    // as income on delete. We rely on how createTransferPair recorded the
    // balance adjustments.
    // Since transfer origin was debited and destination credited, we just
    // re-route via domain type which is always `transfer` for both legs.
    // The repo used `expense` direction for origin and `income` for destination
    // when creating. We need to mirror that here.
    if (txn.type == db_table.TransactionType.transfer &&
        txn.transferId != null) {
      // Determine leg direction by checking if this account was debited or
      // credited. We do this by finding the mirror row.
      final mirror = await _findMirror(txn.id, txn.transferId!);
      final isOrigin = txn.id.endsWith('_dst')
          ? false
          : (mirror != null
              ? (txn.createdAt.isBefore(mirror.createdAt) ||
                  (txn.createdAt.isAtSameMomentAs(mirror.createdAt) &&
                      txn.id.compareTo(mirror.id) < 0))
              : true);

      if (isOrigin) {
        // Was debited; revert by adding back (income direction).
        // Since we pass db.Transaction to _adjustBalance, we need to temporarily
        // change its type to income for the revert operation to add the balance back.
        await _adjustBalance(
          txn.copyWith(type: db_table.TransactionType.income),
          _BalanceOp.add,
        );
      } else {
        // Was credited; revert by subtracting (expense direction).
        await _adjustBalance(
          txn.copyWith(type: db_table.TransactionType.expense),
          _BalanceOp.add,
        );
      }
      return;
    }

    await _adjustBalance(
      txn,
      _BalanceOp.revert,
    );
  }

  /// Re-applies the balance impact of [txn] based on its type (used in restore).
  Future<void> _applyBalance(db.Transaction txn) async {
    if (txn.type == db_table.TransactionType.transfer &&
        txn.transferId != null) {
      final mirror = await _findMirror(txn.id, txn.transferId!);
      final isOrigin = txn.id.endsWith('_dst')
          ? false
          : (mirror != null
              ? (txn.createdAt.isBefore(mirror.createdAt) ||
                  (txn.createdAt.isAtSameMomentAs(mirror.createdAt) &&
                      txn.id.compareTo(mirror.id) < 0))
              : true);

      if (isOrigin) {
        await _adjustBalance(
          txn.copyWith(type: db_table.TransactionType.expense),
          _BalanceOp.add,
        );
      } else {
        await _adjustBalance(
          txn.copyWith(type: db_table.TransactionType.income),
          _BalanceOp.add,
        );
      }
      return;
    }

    await _adjustBalance(txn, _BalanceOp.add);
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

  domain.TransactionType _mapDbTypeToDomain(
    db_table.TransactionType dbType,
  ) {
    switch (dbType) {
      case db_table.TransactionType.income:
        return domain.TransactionType.income;
      case db_table.TransactionType.expense:
        return domain.TransactionType.expense;
      case db_table.TransactionType.transfer:
        return domain.TransactionType.transfer;
    }
  }
}

/// Internal enum to express whether a balance adjustment should apply
/// ([_BalanceOp.add]) or revert ([_BalanceOp.revert]) a transaction's effect.
enum _BalanceOp { add, revert }
