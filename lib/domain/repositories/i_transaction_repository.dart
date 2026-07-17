import 'package:flutter/material.dart' show DateTimeRange;
import '../entities/transaction.dart';
import '../entities/transaction_type.dart';

// ─── Filter value object ───────────────────────────────────────────────────────

/// Thin value object used by the domain / repository layer to express
/// concurrent transaction filters. All fields are optional; `null` means
/// "no constraint on this dimension".
class TransactionQueryFilter {
  final String? accountId;
  final TransactionType? type;
  final String? categoryId;
  final DateTimeRange? dateRange;
  final int? minAmountCents;
  final int? maxAmountCents;

  /// ID of a [Tag] entity. The DAO resolves this to the tag's name and
  /// matches it as a substring of the transaction's `notes` field.
  final String? tagId;
  final String? currency;

  const TransactionQueryFilter({
    this.accountId,
    this.type,
    this.categoryId,
    this.dateRange,
    this.minAmountCents,
    this.maxAmountCents,
    this.tagId,
    this.currency,
  });
}

// ─── Transfer result value object ─────────────────────────────────────────────

/// Holds the two mirrored transactions produced by a transfer operation.
class TransferPair {
  /// The outflow leg (origin account, negative amount).
  final Transaction origin;

  /// The inflow leg (destination account, positive amount).
  final Transaction destination;

  const TransferPair({required this.origin, required this.destination});
}

// ─── Repository interface ──────────────────────────────────────────────────────
// Domain Layer: Abstract definition of data operations for Transactions.
// Implementation is provided in the Data layer (e.g. TransactionRepositoryImpl)
// to enforce Clean Architecture boundaries.

abstract class ITransactionRepository {
  Future<Transaction> createTransaction(Transaction transaction);

  /// Atomically creates both legs of a transfer and updates both account
  /// balances inside a single Drift `transaction()` block.
  Future<TransferPair> createTransferPair({
    required Transaction originTransaction,
    required Transaction destinationTransaction,
  });

  Future<Transaction?> getTransactionById(String id);
  Future<List<Transaction>> getTransactionsByAccountId(String accountId);
  Future<Transaction> updateTransaction(Transaction transaction);

  /// Soft-deletes a single transaction.
  ///
  /// If the transaction belongs to a transfer pair, this method also
  /// soft-deletes its mirrored counterpart atomically.
  Future<void> deleteTransaction(String id);

  /// Permanently hard-deletes a transaction row from the database.
  ///
  /// If the transaction belongs to a transfer pair, its mirror is also
  /// permanently deleted atomically.
  Future<void> hardDeleteTransaction(String id);

  /// Restores a soft-deleted transaction (sets isDeleted = false).
  ///
  /// If the transaction belongs to a transfer pair, its mirror is also
  /// restored atomically.
  Future<void> restoreTransaction(String id);

  /// Soft-deletes all non-deleted transactions belonging to [accountId].
  Future<void> softDeleteTransactionsByAccountId(String accountId);

  /// Permanently hard-deletes all transactions belonging to [accountId].
  Future<void> hardDeleteTransactionsByAccountId(String accountId);

  /// Emits a list of all transactions, including both legs of a transfer.
  Stream<List<Transaction>> watchRawTransactions();

  /// Emits a list of all transactions.
  Stream<List<Transaction>> watchAllTransactions();

  /// Streams transactions matching all non-null filter dimensions concurrently.
  /// An empty / all-null [filter] is equivalent to [watchAllTransactions].
  Stream<List<Transaction>> watchFilteredTransactions(
    TransactionQueryFilter filter,
  );
}
