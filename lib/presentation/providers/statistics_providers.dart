import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/database/tables/transaction_table.dart';
import 'package:konta/domain/entities/category_statistic.dart';
import 'package:konta/domain/entities/period_summary.dart';
import 'package:konta/domain/use_cases/statistics/get_period_summary_use_case.dart';
import 'package:konta/domain/use_cases/statistics/get_top_categories_use_case.dart';
import 'package:konta/presentation/providers/repository_providers.dart';

// ─── Use-case providers ───────────────────────────────────────────────────────

/// Provides the [GetPeriodSummaryUseCase], wired to [statisticsRepositoryProvider].
final getPeriodSummaryUseCaseProvider =
    Provider<GetPeriodSummaryUseCase>((ref) {
  return GetPeriodSummaryUseCase(ref.watch(statisticsRepositoryProvider));
});

/// Provides the [GetTopCategoriesUseCase], wired to [statisticsRepositoryProvider].
final getTopCategoriesUseCaseProvider =
    Provider<GetTopCategoriesUseCase>((ref) {
  return GetTopCategoriesUseCase(ref.watch(statisticsRepositoryProvider));
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
  thisMonth,
  last3Months,
  last6Months,
  thisYear,
  custom;

  String get label {
    switch (this) {
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
    const initialPreset = StatisticsDatePreset.thisMonth;
    return StatisticsFilter(
      dateRange: initialPreset.toDateTimeRange(),
      preset: initialPreset,
    );
  }

  /// Switches to one of the named presets and recomputes the date range.
  void setPreset(StatisticsDatePreset preset) {
    state = StatisticsFilter(
      dateRange: preset.toDateTimeRange(),
      preset: preset,
    );
  }

  /// Applies a free-form date range (triggered by the calendar picker).
  void setCustomDateTimeRange(DateTimeRange dateRange) {
    state = StatisticsFilter(
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

/// Watches the current filter and fetches a [PeriodSummary] for the active date range.
/// Re-evaluates automatically whenever [statisticsFilterProvider] changes.
final periodSummaryProvider = FutureProvider<PeriodSummary>((ref) async {
  final filter = ref.watch(statisticsFilterProvider);
  final useCase = ref.watch(getPeriodSummaryUseCaseProvider);
  return useCase.execute(
    startDate: filter.dateRange.start,
    endDate: filter.dateRange.end,
  );
});

/// Watches the current filter and fetches top-expense categories.
/// Re-evaluates automatically whenever [statisticsFilterProvider] changes.
final topExpenseCategoriesProvider =
    FutureProvider<List<CategoryStatistic>>((ref) async {
  final filter = ref.watch(statisticsFilterProvider);
  final useCase = ref.watch(getTopCategoriesUseCaseProvider);
  return useCase.execute(
    startDate: filter.dateRange.start,
    endDate: filter.dateRange.end,
    type: TransactionType.expense,
  );
});

/// Watches the current filter and fetches top-income categories.
/// Re-evaluates automatically whenever [statisticsFilterProvider] changes.
final topIncomeCategoriesProvider =
    FutureProvider<List<CategoryStatistic>>((ref) async {
  final filter = ref.watch(statisticsFilterProvider);
  final useCase = ref.watch(getTopCategoriesUseCaseProvider);
  return useCase.execute(
    startDate: filter.dateRange.start,
    endDate: filter.dateRange.end,
    type: TransactionType.income,
  );
});
