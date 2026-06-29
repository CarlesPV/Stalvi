import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'repository_providers.dart';

// ─── Presentation-layer Filter Model ─────────────────────────────────────────

/// Immutable value object capturing all concurrent filter dimensions for the
/// transaction list. Every field is optional – `null` means "no filter on
/// this dimension".
///
/// This is the **presentation-layer** state class. It maps to the
/// domain-layer [TransactionQueryFilter] (used by the repository) via
/// [toQueryFilter].
class TransactionFilter {
  /// Limit to a specific account by ID.
  final String? accountId;

  /// Limit to a specific transaction type (income / expense / transfer).
  final TransactionType? type;

  /// Limit to a specific category by ID.
  final String? categoryId;

  /// Only include transactions whose date falls within this range (inclusive).
  final DateTimeRange? dateRange;

  /// Minimum amount in **cents** (minor units). Transactions below this are excluded.
  final int? minAmountCents;

  /// Maximum amount in **cents** (minor units). Transactions above this are excluded.
  final int? maxAmountCents;

  /// Limit to a specific tag by its ID. The repository resolves this to the
  /// tag's name and applies a substring match against the transaction's notes.
  final String? tagId;

  /// Limit to a specific ISO-4217 currency code (e.g. "EUR", "USD").
  final String? currency;

  const TransactionFilter({
    this.accountId,
    this.type,
    this.categoryId,
    this.dateRange,
    this.minAmountCents,
    this.maxAmountCents,
    this.tagId,
    this.currency,
  });

  /// Returns `true` when every dimension is `null` (no active filters).
  bool get isEmpty =>
      accountId == null &&
      type == null &&
      categoryId == null &&
      dateRange == null &&
      minAmountCents == null &&
      maxAmountCents == null &&
      tagId == null &&
      currency == null;

  /// Returns `true` when at least one filter dimension is active.
  bool get isNotEmpty => !isEmpty;

  /// Maps to the domain-layer [TransactionQueryFilter] consumed by the repository.
  TransactionQueryFilter toQueryFilter() => TransactionQueryFilter(
        accountId: accountId,
        type: type,
        categoryId: categoryId,
        dateRange: dateRange,
        minAmountCents: minAmountCents,
        maxAmountCents: maxAmountCents,
        tagId: tagId,
        currency: currency,
      );

  TransactionFilter copyWith({
    String? Function()? accountIdFn,
    TransactionType? Function()? typeFn,
    String? Function()? categoryIdFn,
    DateTimeRange? Function()? dateRangeFn,
    int? Function()? minAmountCentsFn,
    int? Function()? maxAmountCentsFn,
    String? Function()? tagIdFn,
    String? Function()? currencyFn,
  }) {
    return TransactionFilter(
      accountId: accountIdFn != null ? accountIdFn() : accountId,
      type: typeFn != null ? typeFn() : type,
      categoryId: categoryIdFn != null ? categoryIdFn() : categoryId,
      dateRange: dateRangeFn != null ? dateRangeFn() : dateRange,
      minAmountCents:
          minAmountCentsFn != null ? minAmountCentsFn() : minAmountCents,
      maxAmountCents:
          maxAmountCentsFn != null ? maxAmountCentsFn() : maxAmountCents,
      tagId: tagIdFn != null ? tagIdFn() : tagId,
      currency: currencyFn != null ? currencyFn() : currency,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionFilter &&
        other.accountId == accountId &&
        other.type == type &&
        other.categoryId == categoryId &&
        other.dateRange?.start == dateRange?.start &&
        other.dateRange?.end == dateRange?.end &&
        other.minAmountCents == minAmountCents &&
        other.maxAmountCents == maxAmountCents &&
        other.tagId == tagId &&
        other.currency == currency;
  }

  @override
  int get hashCode => Object.hash(
        accountId,
        type,
        categoryId,
        dateRange?.start,
        dateRange?.end,
        minAmountCents,
        maxAmountCents,
        tagId,
        currency,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

/// Manages the active [TransactionFilter] state. Exposes typed mutation methods
/// so the UI never has to construct raw [TransactionFilter] instances directly.
class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  // ── Account ──────────────────────────────────────────────────────────────────

  /// Sets (or clears when `null`) the account-ID filter.
  void setAccount(String? accountId) {
    state = state.copyWith(accountIdFn: () => accountId);
  }

  // ── Type ────────────────────────────────────────────────────────────────────

  /// Sets (or clears when `null`) the transaction-type filter.
  void setType(TransactionType? type) {
    state = state.copyWith(typeFn: () => type);
  }

  // ── Category ────────────────────────────────────────────────────────────────

  /// Sets (or clears when `null`) the category-ID filter.
  void setCategory(String? categoryId) {
    state = state.copyWith(categoryIdFn: () => categoryId);
  }

  // ── Date range ───────────────────────────────────────────────────────────────

  /// Applies a custom date range. Pass `null` to remove the date filter.
  void setDateRange(DateTimeRange? dateRange) {
    state = state.copyWith(dateRangeFn: () => dateRange);
  }

  // ── Amount range ─────────────────────────────────────────────────────────────

  /// Sets the minimum amount in **cents**. Pass `null` to remove lower bound.
  void setMinAmount(int? cents) {
    state = state.copyWith(minAmountCentsFn: () => cents);
  }

  /// Sets the maximum amount in **cents**. Pass `null` to remove upper bound.
  void setMaxAmount(int? cents) {
    state = state.copyWith(maxAmountCentsFn: () => cents);
  }

  /// Convenience: set both bounds at once (either can be `null`).
  void setAmountRange(int? minCents, int? maxCents) {
    state = state.copyWith(
      minAmountCentsFn: () => minCents,
      maxAmountCentsFn: () => maxCents,
    );
  }

  // ── Tag ──────────────────────────────────────────────────────────────────────

  /// Sets (or clears when `null`) the tag filter by tag ID.
  void setTag(String? tagId) {
    state = state.copyWith(tagIdFn: () => tagId);
  }

  // ── Currency ─────────────────────────────────────────────────────────────────

  /// Sets (or clears when `null`) the currency filter (ISO-4217 code).
  void setCurrency(String? currency) {
    state = state.copyWith(currencyFn: () => currency);
  }

  // ── Reset ────────────────────────────────────────────────────────────────────

  /// Removes all active filters, resetting to the default state.
  void clearAll() {
    state = const TransactionFilter();
  }

  /// Replaces the entire filter with the provided [filter] value. Useful
  /// when the filter sheet collects all changes in a draft and applies them
  /// all at once.
  void setFilter(TransactionFilter filter) {
    state = filter;
  }
}

/// Holds the active [TransactionFilter]; mutate it via [TransactionFilterNotifier].
final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilter>(
  TransactionFilterNotifier.new,
);

// ─── Derived data provider ────────────────────────────────────────────────────

/// Watches the active [TransactionFilter] and streams the matching
/// [Transaction] list from the repository. Re-evaluates automatically
/// whenever either the filter state or the underlying DB rows change.
final filteredTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final filter = ref.watch(transactionFilterProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchFilteredTransactions(filter.toQueryFilter());
});
