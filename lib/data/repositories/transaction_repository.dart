import 'package:drift/drift.dart';

import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/data/database/app_database.dart' as db;
import 'package:konta/data/mappers/transaction_mapper.dart';
import 'package:konta/domain/entities/transaction.dart' as domain;
import 'package:konta/domain/entities/transaction_type.dart' as domain;
import 'package:konta/domain/repositories/i_transaction_repository.dart';

/// Concrete implementation of [ITransactionRepository] backed by Drift.
///
/// **Critical business rule**: [createTransaction] runs inside a Drift
/// `.transaction()` block so that inserting the transaction row **and**
/// updating the associated account balance succeed or fail atomically.
class TransactionRepository implements ITransactionRepository {
  final db.AppDatabase _db;

  TransactionRepository(this._db);

  @override
  Future<domain.Transaction> createTransaction(
    domain.Transaction transaction,
  ) async {
    try {
      return await _db.transaction(() async {
        // 1. Insert the new transaction row.
        final dbTransaction = transaction.toDb();
        await _db.into(_db.transactions).insert(dbTransaction);

        // 2. Fetch the associated account to read its current balance.
        final accountQuery = _db.select(_db.accounts)
          ..where((a) => a.id.equals(transaction.accountId));
        final accountRow = await accountQuery.getSingleOrNull();

        if (accountRow == null) {
          throw NotFoundException(
            message:
                'Account with id "${transaction.accountId}" not found',
            code: 'ACCOUNT_NOT_FOUND',
          );
        }

        // 3. Calculate the new balance based on transaction type.
        //    Transaction.amount is stored in cents (int).
        //    Account.initialBalance is stored as a double.
        final double delta = transaction.amount / 100.0;
        final double newBalance;

        switch (transaction.type) {
          case domain.TransactionType.income:
            newBalance = accountRow.initialBalance + delta;
            break;
          case domain.TransactionType.expense:
            newBalance = accountRow.initialBalance - delta;
            break;
          case domain.TransactionType.transfer:
            // Transfers are handled by a dedicated use case that creates
            // two paired transactions. A single transfer transaction
            // behaves as an expense (outflow) from this account.
            newBalance = accountRow.initialBalance - delta;
            break;
        }

        // 4. Update the account balance atomically.
        await (_db.update(_db.accounts)
              ..where((a) => a.id.equals(transaction.accountId)))
            .write(
          db.AccountsCompanion(
            initialBalance: Value(newBalance),
            modifiedAt: Value(DateTime.now()),
          ),
        );

        // 5. Return the inserted transaction as a domain entity.
        return transaction;
      });
    } on AppException {
      // Re-throw our own exceptions without wrapping.
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
  Future<domain.Transaction?> getTransactionById(String id) async {
    try {
      final query = _db.select(_db.transactions)
        ..where((t) => t.id.equals(id));
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
        ..where((t) => t.accountId.equals(accountId))
        ..orderBy([
          (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
        ]);
      final rows = await query.get();
      return rows.map((r) => r.toDomain()).toList();
    } catch (e) {
      throw DatabaseException(
        message:
            'Failed to get transactions for account "$accountId"',
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

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      final deleted = await (_db.delete(_db.transactions)
            ..where((t) => t.id.equals(id)))
          .go();

      if (deleted == 0) {
        throw NotFoundException(
          message: 'Transaction with id "$id" not found',
          code: 'TRANSACTION_NOT_FOUND',
        );
      }
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
}
