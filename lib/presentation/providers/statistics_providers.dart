import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/use_cases/statistics/get_period_summary_use_case.dart';
import 'package:stalvi/domain/use_cases/statistics/get_top_categories_use_case.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';

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
  bool _hasInitializedDefaultAccount = false;

  @override
  StatisticsFilter build() {
    const initialPreset = StatisticsDatePreset.thisMonth;

    ref.listen<AsyncValue<List<Account>>>(accountsListProvider,
        (previous, next) {
      if (!_hasInitializedDefaultAccount) {
        next.whenData((accounts) {
          try {
            final defaultAccount = accounts.firstWhere((a) => a.isDefault);
            state = state.copyWith(accountIdFn: () => defaultAccount.id);
            _hasInitializedDefaultAccount = true;
          } catch (_) {
            if (accounts.isNotEmpty) {
              state = state.copyWith(accountIdFn: () => accounts.first.id);
              _hasInitializedDefaultAccount = true;
            }
          }
        });
      }
    });

    final accountsAsync = ref.read(accountsListProvider);
    String? initialAccountId;
    accountsAsync.whenData((accounts) {
      try {
        final defaultAccount = accounts.firstWhere((a) => a.isDefault);
        initialAccountId = defaultAccount.id;
        _hasInitializedDefaultAccount = true;
      } catch (_) {
        if (accounts.isNotEmpty) {
          initialAccountId = accounts.first.id;
          _hasInitializedDefaultAccount = true;
        }
      }
    });

    return StatisticsFilter(
      dateRange: initialPreset.toDateTimeRange(),
      preset: initialPreset,
      accountId: initialAccountId,
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

/// Watches the current filter and fetches a [PeriodSummary] for the active date range.
///
/// Uses [FutureProvider.autoDispose] so the provider cleans up when no widget
/// is listening, but the first subscription (triggered eagerly from
/// [_StatisticsScreenState.initState] via `ref.read`) guarantees data is
/// fetched within milliseconds of screen mount.
final periodSummaryProvider =
    FutureProvider.autoDispose<PeriodSummary>((ref) async {
  // keepAlive prevents disposal while the user is on the screen and has
  // just switched filter tabs, avoiding unnecessary flickering.
  ref.keepAlive();
  final filter = ref.watch(statisticsFilterProvider);
  final targetCurrency = ref.watch(statisticsCurrencyProvider);
  final useCase = ref.watch(getPeriodSummaryUseCaseProvider);
  return useCase.execute(
    startDate: filter.dateRange.start,
    endDate: filter.dateRange.end,
    targetCurrency: targetCurrency,
    accountId: filter.accountId,
  );
});

/// Watches the current filter and fetches top-expense categories.
final topExpenseCategoriesProvider =
    FutureProvider.autoDispose<List<CategoryStatistic>>((ref) async {
  ref.keepAlive();
  final filter = ref.watch(statisticsFilterProvider);
  final targetCurrency = ref.watch(statisticsCurrencyProvider);
  final useCase = ref.watch(getTopCategoriesUseCaseProvider);
  return useCase.execute(
    startDate: filter.dateRange.start,
    endDate: filter.dateRange.end,
    targetCurrency: targetCurrency,
    type: TransactionType.expense,
    accountId: filter.accountId,
  );
});

/// Watches the current filter and fetches top-income categories.
final topIncomeCategoriesProvider =
    FutureProvider.autoDispose<List<CategoryStatistic>>((ref) async {
  ref.keepAlive();
  final filter = ref.watch(statisticsFilterProvider);
  final targetCurrency = ref.watch(statisticsCurrencyProvider);
  final useCase = ref.watch(getTopCategoriesUseCaseProvider);
  return useCase.execute(
    startDate: filter.dateRange.start,
    endDate: filter.dateRange.end,
    targetCurrency: targetCurrency,
    type: TransactionType.income,
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

/// Calculates the global balance using dynamic currency conversion in Dart.
final globalBalanceProvider = StreamProvider.autoDispose<double>((ref) async* {
  final profile = await ref.watch(defaultProfileProvider.future);
  final targetCurrency = profile.defaultCurrency;

  final transactionsStream =
      ref.watch(transactionRepositoryProvider).watchAllTransactions();
  final exchangeRateRepo = ref.watch(exchangeRateRepositoryProvider);

  await for (final transactions in transactionsStream) {
    final rates =
        await exchangeRateRepo.getLocalRates(baseCurrency: targetCurrency);

    double balance = 0;
    for (final tx in transactions) {
      double amount = tx.amount.toDouble();
      if (tx.originalCurrency != targetCurrency) {
        final rate = rates?.rateFor(tx.originalCurrency);
        if (rate != null && rate != 0) {
          amount = amount / rate;
        }
      }

      if (tx.type == TransactionType.income) {
        balance += amount;
      } else if (tx.type == TransactionType.expense) {
        balance -= amount;
      }
    }

    yield balance / 100.0;
  }
});
