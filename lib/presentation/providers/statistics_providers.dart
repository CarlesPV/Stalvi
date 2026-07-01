import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart' as db
    show TransactionType;

import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
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
final periodSummaryProvider = StreamProvider.autoDispose<PeriodSummary>((ref) {
  final filter = ref.watch(statisticsFilterProvider);
  final targetCurrency = ref.watch(statisticsCurrencyProvider);
  final repo = ref.watch(statisticsRepositoryProvider);
  return repo.watchPeriodSummary(
    startDate: filter.dateRange.start,
    endDate: filter.dateRange.end,
    targetCurrency: targetCurrency,
    accountId: filter.accountId,
  );
});

/// Watches the current filter and emits a real-time top-expense category list.
final topExpenseCategoriesProvider =
    StreamProvider.autoDispose<List<CategoryStatistic>>((ref) {
  final filter = ref.watch(statisticsFilterProvider);
  final targetCurrency = ref.watch(statisticsCurrencyProvider);
  final repo = ref.watch(statisticsRepositoryProvider);
  return repo.watchTopCategories(
    startDate: filter.dateRange.start,
    endDate: filter.dateRange.end,
    targetCurrency: targetCurrency,
    type: db.TransactionType.expense,
    accountId: filter.accountId,
  );
});

/// Watches the current filter and emits a real-time top-income category list.
final topIncomeCategoriesProvider =
    StreamProvider.autoDispose<List<CategoryStatistic>>((ref) {
  final filter = ref.watch(statisticsFilterProvider);
  final targetCurrency = ref.watch(statisticsCurrencyProvider);
  final repo = ref.watch(statisticsRepositoryProvider);
  return repo.watchTopCategories(
    startDate: filter.dateRange.start,
    endDate: filter.dateRange.end,
    targetCurrency: targetCurrency,
    type: db.TransactionType.income,
    accountId: filter.accountId,
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
final globalBalanceProvider = FutureProvider.autoDispose<double>((ref) async {
  final profile = await ref.watch(defaultProfileProvider.future);
  final targetCurrency = profile.defaultCurrency;

  final accounts = await ref.watch(accountsListProvider.future);
  final exchangeRateRepo = ref.watch(exchangeRateRepositoryProvider);

  final rates =
      await exchangeRateRepo.getLocalRates(baseCurrency: targetCurrency);

  double balance = 0;
  for (final account in accounts) {
    if (account.currency == targetCurrency) {
      balance += account.initialBalance;
    } else {
      final rate = rates?.rateFor(account.currency);
      if (rate != null && rate != 0) {
        balance += account.initialBalance / rate;
      } else {
        balance += account.initialBalance;
      }
    }
  }

  return balance;
});
