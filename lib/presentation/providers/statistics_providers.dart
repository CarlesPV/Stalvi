import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/core/utils/currency_converter.dart';
import 'package:stalvi/domain/use_cases/statistics/get_period_summary_use_case.dart';
import 'package:stalvi/domain/use_cases/statistics/get_top_categories_use_case.dart';
import 'repository_providers.dart';

// ─── Use-case providers ───────────────────────────────────────────────────────

/// Provides the [GetPeriodSummaryUseCase], wired to [transactionRepositoryProvider] and [exchangeRateRepositoryProvider].
final getPeriodSummaryUseCaseProvider =
    Provider<GetPeriodSummaryUseCase>((ref) {
  return GetPeriodSummaryUseCase(
    ref.watch(transactionRepositoryProvider),
    ref.watch(exchangeRateRepositoryProvider),
  );
});

/// Provides the [GetTopCategoriesUseCase], wired to [transactionRepositoryProvider], [categoryRepositoryProvider], and [exchangeRateRepositoryProvider].
final getTopCategoriesUseCaseProvider =
    Provider<GetTopCategoriesUseCase>((ref) {
  return GetTopCategoriesUseCase(
    ref.watch(transactionRepositoryProvider),
    ref.watch(categoryRepositoryProvider),
    ref.watch(exchangeRateRepositoryProvider),
  );
});

// ─── Filter State ─────────────────────────────────────────────────────────────

/// Represents the currently applied statistics filters.
class StatisticsFilter {
  final DateTimeRange dateRange;
  final StatisticsDatePreset preset;
  final String? accountId; // null means "all accounts"

  const StatisticsFilter({
    required this.dateRange,
    required this.preset,
    this.accountId,
  });

  StatisticsFilter copyWith({
    DateTimeRange? dateRange,
    StatisticsDatePreset? preset,
    String? Function()? accountIdFn,
  }) {
    return StatisticsFilter(
      dateRange: dateRange ?? this.dateRange,
      preset: preset ?? this.preset,
      accountId: accountIdFn != null ? accountIdFn() : accountId,
    );
  }
}

/// Preset date ranges for the statistics filter chips.
enum StatisticsDatePreset {
  last30Days,
  thisMonth,
  last3Months,
  last6Months,
  thisYear,
  custom;

  String get label {
    switch (this) {
      case last30Days:
        return 'Last 30 Days';
      case thisMonth:
        return 'This Month';
      case last3Months:
        return 'Last 3 Months';
      case last6Months:
        return 'Last 6 Months';
      case thisYear:
        return 'This Year';
      case custom:
        return 'Custom';
    }
  }

  DateTimeRange toDateTimeRange() {
    final now = DateTime.now();
    switch (this) {
      case last30Days:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );
      case thisMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
      case last3Months:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 2, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
      case last6Months:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 5, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
      case thisYear:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31),
        );
      case custom:
        // Fallback to this month if custom hasn't been set.
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
    }
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

/// Holds and mutates the active statistics filter state.
class StatisticsFilterNotifier extends Notifier<StatisticsFilter> {
  @override
  StatisticsFilter build() {
    const initialPreset = StatisticsDatePreset.last30Days;

    return StatisticsFilter(
      dateRange: initialPreset.toDateTimeRange(),
      preset: initialPreset,
      accountId: null,
    );
  }

  /// Switches to one of the named presets and recomputes the date range.
  void setPreset(StatisticsDatePreset preset) {
    state = state.copyWith(
      dateRange: preset.toDateTimeRange(),
      preset: preset,
    );
  }

  /// Applies a free-form date range (triggered by the calendar picker).
  void setCustomDateTimeRange(DateTimeRange dateRange) {
    state = state.copyWith(
      dateRange: dateRange,
      preset: StatisticsDatePreset.custom,
    );
  }

  /// Filters by a specific account ID; pass `null` to show all accounts.
  void setAccountId(String? accountId) {
    state = state.copyWith(accountIdFn: () => accountId);
  }
}

/// Holds the active [StatisticsFilter]; mutate it via [StatisticsFilterNotifier].
final statisticsFilterProvider =
    NotifierProvider<StatisticsFilterNotifier, StatisticsFilter>(
  StatisticsFilterNotifier.new,
);

// ─── Data providers ───────────────────────────────────────────────────────────

/// Watches the current filter and emits a real-time [PeriodSummary] for the
/// active date range. Backed by a Drift stream so any transaction insert /
/// update / delete inside the period triggers a fresh emission automatically.
final periodSummaryProvider =
    Provider.autoDispose<AsyncValue<PeriodSummary>>((ref) {
  final filter = ref.watch(statisticsFilterProvider);
  final targetCurrency = ref.watch(statisticsCurrencyProvider);

  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final ratesAsync = ref.watch(latestExchangeRatesProvider(targetCurrency));

  if (transactionsAsync.isLoading || ratesAsync.isLoading)
    return const AsyncLoading();
  if (transactionsAsync.hasError)
    return AsyncError(transactionsAsync.error!, transactionsAsync.stackTrace!);

  final transactions = transactionsAsync.value!;
  final rates = ratesAsync.valueOrNull;

  double totalIncome = 0;
  double totalExpense = 0;

  final start = filter.dateRange.start;
  final end = filter.dateRange.end;
  final effectiveEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);

  for (final tx in transactions) {
    if (filter.accountId != null && tx.accountId != filter.accountId) continue;
    if (tx.date.isBefore(start) || tx.date.isAfter(effectiveEnd)) continue;

    final convertedAmount =
        CurrencyConverter.convertAmount(tx, targetCurrency, rates) / 100.0;
    if (tx.type == TransactionType.income) {
      totalIncome += convertedAmount;
    } else if (tx.type == TransactionType.expense) {
      totalExpense += convertedAmount;
    }
  }

  return AsyncData(
    PeriodSummary(
      totalIncome: (totalIncome * 100).round(),
      totalExpense: (totalExpense * 100).round(),
    ),
  );
});

List<CategoryStatistic> _calculateTopCategories(
  List<Transaction> transactions,
  StatisticsFilter filter,
  String targetCurrency,
  dynamic rates,
  List<dynamic> categories,
  TransactionType targetType,
) {
  final Map<String, double> categorySums = {};
  final start = filter.dateRange.start;
  final end = filter.dateRange.end;
  final effectiveEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);

  for (final tx in transactions) {
    if (tx.type != targetType) continue;
    if (filter.accountId != null && tx.accountId != filter.accountId) continue;
    if (tx.date.isBefore(start) || tx.date.isAfter(effectiveEnd)) continue;
    if (tx.categoryId == null) continue;

    final convertedAmount =
        CurrencyConverter.convertAmount(tx, targetCurrency, rates) / 100.0;
    categorySums[tx.categoryId!] =
        (categorySums[tx.categoryId!] ?? 0) + convertedAmount;
  }

  final result = <CategoryStatistic>[];
  for (final entry in categorySums.entries) {
    final cat = categories
        .cast<dynamic>()
        .firstWhere((c) => c.id == entry.key, orElse: () => null);
    if (cat == null) continue;
    result.add(
      CategoryStatistic(
        categoryId: cat.id,
        categoryName: cat.name,
        categoryIcon: cat.icon,
        categoryColor: cat.color,
        totalAmount: (entry.value * 100).round(),
      ),
    );
  }
  result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
  return result;
}

/// Watches the current filter and emits a real-time top-expense category list.
final topExpenseCategoriesProvider =
    Provider.autoDispose<AsyncValue<List<CategoryStatistic>>>((ref) {
  final filter = ref.watch(statisticsFilterProvider);
  final targetCurrency = ref.watch(statisticsCurrencyProvider);

  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final categoriesAsync = ref.watch(categoriesListProvider);
  final ratesAsync = ref.watch(latestExchangeRatesProvider(targetCurrency));

  if (transactionsAsync.isLoading ||
      categoriesAsync.isLoading ||
      ratesAsync.isLoading) return const AsyncLoading();
  if (transactionsAsync.hasError)
    return AsyncError(transactionsAsync.error!, transactionsAsync.stackTrace!);
  if (categoriesAsync.hasError)
    return AsyncError(categoriesAsync.error!, categoriesAsync.stackTrace!);

  return AsyncData(
    _calculateTopCategories(
      transactionsAsync.value!,
      filter,
      targetCurrency,
      ratesAsync.valueOrNull,
      categoriesAsync.value!,
      TransactionType.expense,
    ),
  );
});

/// Watches the current filter and emits a real-time top-income category list.
final topIncomeCategoriesProvider =
    Provider.autoDispose<AsyncValue<List<CategoryStatistic>>>((ref) {
  final filter = ref.watch(statisticsFilterProvider);
  final targetCurrency = ref.watch(statisticsCurrencyProvider);

  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final categoriesAsync = ref.watch(categoriesListProvider);
  final ratesAsync = ref.watch(latestExchangeRatesProvider(targetCurrency));

  if (transactionsAsync.isLoading ||
      categoriesAsync.isLoading ||
      ratesAsync.isLoading) return const AsyncLoading();
  if (transactionsAsync.hasError)
    return AsyncError(transactionsAsync.error!, transactionsAsync.stackTrace!);
  if (categoriesAsync.hasError)
    return AsyncError(categoriesAsync.error!, categoriesAsync.stackTrace!);

  return AsyncData(
    _calculateTopCategories(
      transactionsAsync.value!,
      filter,
      targetCurrency,
      ratesAsync.valueOrNull,
      categoriesAsync.value!,
      TransactionType.income,
    ),
  );
});

/// Computes the currency code to use for displaying statistics.
/// Returns the selected account's currency, or the user's default currency if "All Accounts" is selected.
final statisticsCurrencyProvider = Provider.autoDispose<String>((ref) {
  final filter = ref.watch(statisticsFilterProvider);
  if (filter.accountId != null) {
    final accounts = ref.watch(accountsListProvider).valueOrNull ?? [];
    try {
      return accounts.firstWhere((a) => a.id == filter.accountId).currency;
    } catch (_) {}
  }
  final profile = ref.watch(defaultProfileProvider).valueOrNull;
  return profile?.defaultCurrency ?? 'EUR';
});

/// Calculates the global balance by summing the current balance of all accounts,
/// converting each to the target currency using the real-time exchange rates.
final globalBalanceProvider = Provider.autoDispose<AsyncValue<double>>((ref) {
  final profileAsync = ref.watch(defaultProfileProvider);
  if (profileAsync.isLoading) return const AsyncLoading();
  if (profileAsync.hasError)
    return AsyncError(profileAsync.error!, profileAsync.stackTrace!);

  final targetCurrency = profileAsync.value!.defaultCurrency;

  final accountsAsync = ref.watch(accountsListProvider);
  if (accountsAsync.isLoading) return const AsyncLoading();
  if (accountsAsync.hasError)
    return AsyncError(accountsAsync.error!, accountsAsync.stackTrace!);

  final accounts = accountsAsync.value!;

  final ratesAsync = ref.watch(latestExchangeRatesProvider(targetCurrency));
  if (ratesAsync.isLoading) return const AsyncLoading();

  double totalBalance = 0;

  for (final account in accounts) {
    final balanceAsync = ref.watch(accountBalanceProvider(account.id));
    if (balanceAsync.isLoading) return const AsyncLoading();
    if (balanceAsync.hasError)
      return AsyncError(balanceAsync.error!, balanceAsync.stackTrace!);

    double balance = balanceAsync.value!;

    if (account.currency == targetCurrency) {
      totalBalance += balance;
    } else {
      final rate = ratesAsync.valueOrNull?.rateFor(account.currency);
      if (rate != null && rate != 0) {
        totalBalance += balance / rate;
      } else {
        totalBalance += balance;
      }
    }
  }

  return AsyncData(totalBalance);
});
