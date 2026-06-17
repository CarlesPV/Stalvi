import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';

// ─── Presentation-layer Filter Model ─────────────────────────────────────────

/// Immutable value object capturing all concurrent filter dimensions for the
/// transaction list. Every field is optional – `null` means "no filter on
/// this dimension".
///
/// This is the **presentation-layer** state class. It maps to the
/// domain-layer [TransactionQueryFilter] (used by the repository) via
/// [toQueryFilter].
class TransactionFilter {
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

  /// Limit to a specific tag name (case-insensitive substring match against
  /// the transaction's notes field, prefixed with "#").
  final String? tag;

  /// Limit to a specific ISO-4217 currency code (e.g. "EUR", "USD").
  final String? currency;

  const TransactionFilter({
    this.type,
    this.categoryId,
    this.dateRange,
    this.minAmountCents,
    this.maxAmountCents,
    this.tag,
    this.currency,
  });

  /// Returns `true` when every dimension is `null` (no active filters).
  bool get isEmpty =>
      type == null &&
      categoryId == null &&
      dateRange == null &&
      minAmountCents == null &&
      maxAmountCents == null &&
      tag == null &&
      currency == null;

  /// Returns `true` when at least one filter dimension is active.
  bool get isNotEmpty => !isEmpty;

  /// Maps to the domain-layer [TransactionQueryFilter] consumed by the repository.
  TransactionQueryFilter toQueryFilter() => TransactionQueryFilter(
        type: type,
        categoryId: categoryId,
        dateRange: dateRange,
        minAmountCents: minAmountCents,
        maxAmountCents: maxAmountCents,
        tag: tag,
        currency: currency,
      );

  TransactionFilter copyWith({
    TransactionType? Function()? typeFn,
    String? Function()? categoryIdFn,
    DateTimeRange? Function()? dateRangeFn,
    int? Function()? minAmountCentsFn,
    int? Function()? maxAmountCentsFn,
    String? Function()? tagFn,
    String? Function()? currencyFn,
  }) {
    return TransactionFilter(
      type: typeFn != null ? typeFn() : type,
      categoryId: categoryIdFn != null ? categoryIdFn() : categoryId,
      dateRange: dateRangeFn != null ? dateRangeFn() : dateRange,
      minAmountCents:
          minAmountCentsFn != null ? minAmountCentsFn() : minAmountCents,
      maxAmountCents:
          maxAmountCentsFn != null ? maxAmountCentsFn() : maxAmountCents,
      tag: tagFn != null ? tagFn() : tag,
      currency: currencyFn != null ? currencyFn() : currency,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionFilter &&
        other.type == type &&
        other.categoryId == categoryId &&
        other.dateRange?.start == dateRange?.start &&
        other.dateRange?.end == dateRange?.end &&
        other.minAmountCents == minAmountCents &&
        other.maxAmountCents == maxAmountCents &&
        other.tag == tag &&
        other.currency == currency;
  }

  @override
  int get hashCode => Object.hash(
        type,
        categoryId,
        dateRange?.start,
        dateRange?.end,
        minAmountCents,
        maxAmountCents,
        tag,
        currency,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

/// Manages the active [TransactionFilter] state. Exposes typed mutation methods
/// so the UI never has to construct raw [TransactionFilter] instances directly.
class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

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

  /// Sets (or clears when `null`) the tag filter.
  void setTag(String? tag) {
    state = state.copyWith(tagFn: () => tag);
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
