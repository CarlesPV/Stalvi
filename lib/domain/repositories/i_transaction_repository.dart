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

// ─── Repository interface ──────────────────────────────────────────────────────

abstract class ITransactionRepository {
  Future<Transaction> createTransaction(Transaction transaction);
  Future<Transaction?> getTransactionById(String id);
  Future<List<Transaction>> getTransactionsByAccountId(String accountId);
  Future<Transaction> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Stream<List<Transaction>> watchAllTransactions();

  /// Streams transactions matching all non-null filter dimensions concurrently.
  /// An empty / all-null [filter] is equivalent to [watchAllTransactions].
  Stream<List<Transaction>> watchFilteredTransactions(
    TransactionQueryFilter filter,
  );
}
