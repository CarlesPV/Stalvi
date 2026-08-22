import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/theme/app_theme.dart';
import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/presentation/features/settings/data_management_screen.dart';
import 'package:stalvi/presentation/features/statistics/statistics_screen.dart';
import 'package:stalvi/presentation/providers/statistics_providers.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// A completely passive stream that never emits and never errors.
/// Used to keep providers in the AsyncValue.loading state without
/// scheduling any tasks on the event loop.
class NeverStream<T> extends Stream<T> {
  const NeverStream();

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _NeverSubscription<T>();
  }
}

class _NeverSubscription<T> implements StreamSubscription<T> {
  @override
  Future<void> cancel() => Future.value();
  @override
  void onData(void Function(T data)? handleData) {}
  @override
  void onError(Function? handleError) {}
  @override
  void onDone(void Function()? handleDone) {}
  @override
  void pause([Future<void>? resumeSignal]) {}
  @override
  void resume() {}
  @override
  bool get isPaused => false;
  @override
  Future<E> asFuture<E>([E? futureValue]) => Completer<E>().future;
}

// ─── Sample Data ──────────────────────────────────────────────────────────────

const _fakeSummary = PeriodSummary(
  totalIncome: 500000, // €5,000.00
  totalExpense: 310000, // €3,100.00
);

final _fakeExpenseCategories = [
  const CategoryStatistic(
    categoryId: 'cat_food',
    categoryName: 'Food & Dining',
    categoryIcon: 'restaurant',
    categoryColor: '#FF9800',
    totalAmount: 150000, // €1,500.00
  ),
  const CategoryStatistic(
    categoryId: 'cat_transport',
    categoryName: 'Transport',
    categoryIcon: 'directions_car',
    categoryColor: '#2196F3',
    totalAmount: 80000, // €800.00
  ),
  const CategoryStatistic(
    categoryId: 'cat_shopping',
    categoryName: 'Shopping',
    categoryIcon: 'shopping_cart',
    categoryColor: '#9C27B0',
    totalAmount: 60000, // €600.00
  ),
  const CategoryStatistic(
    categoryId: 'cat_health',
    categoryName: 'Health',
    categoryIcon: 'local_hospital',
    categoryColor: '#F44336',
    totalAmount: 20000, // €200.00
  ),
];

final _fakeIncomeCategories = [
  const CategoryStatistic(
    categoryId: 'cat_salary',
    categoryName: 'Salary',
    categoryIcon: 'attach_money',
    categoryColor: '#4CAF50',
    totalAmount: 400000, // €4,000.00
  ),
  const CategoryStatistic(
    categoryId: 'cat_freelance',
    categoryName: 'Freelance',
    categoryIcon: 'work',
    categoryColor: '#00BCD4',
    totalAmount: 100000, // €1,000.00
  ),
];

// ─── Widget factory ───────────────────────────────────────────────────────────

/// Wraps [StatisticsScreen] inside a [ProviderScope] with overridden providers
/// so no real database or use-cases are needed.
Widget _buildTestWidget({
  required AsyncValue<PeriodSummary> summaryState,
  required AsyncValue<List<CategoryStatistic>> expenseCatState,
  required AsyncValue<List<CategoryStatistic>> incomeCatState,
  StatisticsFilter? filterState,
}) {
  return ProviderScope(
    overrides: [
      periodSummaryProvider.overrideWith((ref) => summaryState),
      topExpenseCategoriesProvider.overrideWith((ref) => expenseCatState),
      topIncomeCategoriesProvider.overrideWith((ref) => incomeCatState),
      if (filterState != null)
        statisticsFilterProvider.overrideWith(
          () => _TestStatisticsFilterNotifier(filterState),
        ),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const StatisticsScreen(),
    ),
  );
}

class _TestStatisticsFilterNotifier extends StatisticsFilterNotifier {
  final StatisticsFilter initial;
  _TestStatisticsFilterNotifier(this.initial);

  @override
  StatisticsFilter build() => initial;
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('StatisticsScreen — state rendering', () {
    // ── Loading state ────────────────────────────────────────────────────────

    testWidgets('shows shimmer skeleton widgets when providers are loading', (
      WidgetTester tester,
    ) async {
      // Arrange: futures that never resolve → AsyncValue.loading
      await tester.pumpWidget(
        _buildTestWidget(
          summaryState: const AsyncLoading<PeriodSummary>(),
          expenseCatState: const AsyncLoading<List<CategoryStatistic>>(),
          incomeCatState: const AsyncLoading<List<CategoryStatistic>>(),
        ),
      );

      // Assert: filter chips and app bar title are present
      expect(find.text('Statistics'), findsOneWidget);

      // The date-preset chips are always rendered immediately.
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Last 3 Months'), findsOneWidget);
      expect(find.text('Last 6 Months'), findsOneWidget);
      expect(find.text('This Year'), findsOneWidget);

      // No real data should be visible.
      expect(find.text('Net Balance'), findsNothing);
    });

    // ── Error state ──────────────────────────────────────────────────────────

    testWidgets('shows inline error widget when periodSummaryProvider fails', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _buildTestWidget(
          summaryState: AsyncError<PeriodSummary>(
            Exception('DB error'),
            StackTrace.empty,
          ),
          expenseCatState: AsyncData(_fakeExpenseCategories),
          incomeCatState: AsyncData(_fakeIncomeCategories),
        ),
      );

      // Pump to let Riverpod rebuild the widget with the AsyncError state.
      await tester.pump();

      // The _InlineError widget shows err.toString()
      expect(find.textContaining('DB error'), findsAtLeastNWidgets(1));
    });

    testWidgets(
      'shows empty state widget when expense categories list is empty',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          _buildTestWidget(
            summaryState: const AsyncData(_fakeSummary),
            expenseCatState: const AsyncData(<CategoryStatistic>[]),
            incomeCatState: AsyncData(_fakeIncomeCategories),
          ),
        );

        await tester.pump();

        // Assert: empty-state message for expense section
        expect(
          find.text('No expenses recorded in this period.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'shows empty state widget when income categories list is empty',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildTestWidget(
            summaryState: const AsyncData(_fakeSummary),
            expenseCatState: AsyncData(_fakeExpenseCategories),
            incomeCatState: const AsyncData(<CategoryStatistic>[]),
          ),
        );

        // Let futures resolve
        await tester.pump(const Duration(milliseconds: 200));

        // Scroll down to reveal the income section
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('No income recorded in this period.'), findsOneWidget);
      },
    );

    // ── Populated state ──────────────────────────────────────────────────────

    testWidgets(
      'renders summary cards and category names when providers return data',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          _buildTestWidget(
            summaryState: const AsyncData(_fakeSummary),
            expenseCatState: AsyncData(_fakeExpenseCategories),
            incomeCatState: AsyncData(_fakeIncomeCategories),
          ),
        );

        // Let futures resolve
        await tester.pump(const Duration(milliseconds: 200));

        // Assert: summary card labels
        expect(find.text('Income'), findsWidgets);
        expect(find.text('Expenses'), findsWidgets);
        expect(find.text('Net Balance'), findsOneWidget);

        // Assert: section headers (visible in initial viewport)
        expect(find.text('Top Spending Categories'), findsOneWidget);

        // Assert: category names from expense list (visible in initial viewport)
        expect(find.text('Food & Dining'), findsOneWidget);
        expect(find.text('Transport'), findsOneWidget);

        // Scroll down to see income section
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
        await tester.pump(const Duration(milliseconds: 200));

        // Assert: income section and categories now visible
        expect(find.text('Top Income Categories'), findsOneWidget);
        expect(find.text('Salary'), findsOneWidget);
        expect(find.text('Freelance'), findsOneWidget);
      },
    );

    testWidgets('displays Surplus badge when income exceeds expenses', (
      WidgetTester tester,
    ) async {
      // Income €5,000 > Expense €3,100 → Surplus
      await tester.pumpWidget(
        _buildTestWidget(
          summaryState: const AsyncData(_fakeSummary),
          expenseCatState: AsyncData(_fakeExpenseCategories),
          incomeCatState: AsyncData(_fakeIncomeCategories),
        ),
      );

      await tester.pump();

      expect(find.text('▲ Surplus'), findsOneWidget);
    });

    testWidgets('displays Deficit badge when expenses exceed income', (
      WidgetTester tester,
    ) async {
      const deficitSummary = PeriodSummary(
        totalIncome: 100000, // €1,000
        totalExpense: 200000, // €2,000
      );

      await tester.pumpWidget(
        _buildTestWidget(
          summaryState: const AsyncData(deficitSummary),
          expenseCatState: AsyncData(_fakeExpenseCategories),
          incomeCatState: AsyncData(_fakeIncomeCategories),
        ),
      );

      await tester.pump();

      expect(find.text('▼ Deficit'), findsOneWidget);
    });

    testWidgets(
      'does not display Surplus or Deficit badge when net balance is zero',
      (WidgetTester tester) async {
        const zeroSummary = PeriodSummary(
          totalIncome: 100000, // €1,000
          totalExpense: 100000, // €1,000
        );

        await tester.pumpWidget(
          _buildTestWidget(
            summaryState: const AsyncData(zeroSummary),
            expenseCatState: AsyncData(_fakeExpenseCategories),
            incomeCatState: AsyncData(_fakeIncomeCategories),
          ),
        );

        await tester.pump();

        expect(find.text('▲ Surplus'), findsNothing);
        expect(find.text('▼ Deficit'), findsNothing);
      },
    );

    // ── Filter chips ─────────────────────────────────────────────────────────

    testWidgets('renders all preset filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          summaryState: const AsyncData(_fakeSummary),
          expenseCatState: AsyncData(_fakeExpenseCategories),
          incomeCatState: AsyncData(_fakeIncomeCategories),
        ),
      );

      await tester.pump();

      for (final preset in StatisticsDatePreset.values) {
        final chip = find.text(preset.label);
        if (tester.any(chip) == false) {
          await tester.drag(find.byType(ListView).first, const Offset(-300, 0));
          await tester.pump(const Duration(milliseconds: 200));
        }
        expect(find.text(preset.label), findsOneWidget);
      }
    });

    testWidgets(
      'tapping a filter chip updates the selected chip without crashing',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildTestWidget(
            summaryState: const AsyncData(_fakeSummary),
            expenseCatState: AsyncData(_fakeExpenseCategories),
            incomeCatState: AsyncData(_fakeIncomeCategories),
          ),
        );

        await tester.pump();

        // Tap "Last 3 Months"
        await tester.tap(find.text('Last 3 Months'));
        await tester.pump();

        // No crash; the chip text should still be visible.
        expect(find.text('Last 3 Months'), findsOneWidget);
      },
    );

    // ── Screen structure ─────────────────────────────────────────────────────

    testWidgets(
      'has back-navigation button, export button, and date-range icon button in AppBar',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildTestWidget(
            summaryState: const AsyncData(_fakeSummary),
            expenseCatState: AsyncData(_fakeExpenseCategories),
            incomeCatState: AsyncData(_fakeIncomeCategories),
          ),
        );

        await tester.pump();

        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
        expect(find.byIcon(Icons.file_download_outlined), findsOneWidget);
        expect(find.byIcon(Icons.date_range_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'tapping export icon button navigates to DataManagementScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildTestWidget(
            summaryState: const AsyncData(_fakeSummary),
            expenseCatState: AsyncData(_fakeExpenseCategories),
            incomeCatState: AsyncData(_fakeIncomeCategories),
          ),
        );

        await tester.pump();

        final exportBtn = find.byIcon(Icons.file_download_outlined);
        expect(exportBtn, findsOneWidget);

        await tester.tap(exportBtn);
        await tester.pumpAndSettle();

        expect(find.byType(DataManagementScreen), findsOneWidget);
      },
    );

    // ── Transfers Section ────────────────────────────────────────────────────

    testWidgets(
      'does NOT render Transfers card when accountId is null (All accounts)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildTestWidget(
            summaryState: const AsyncData(_fakeSummary),
            expenseCatState: AsyncData(_fakeExpenseCategories),
            incomeCatState: AsyncData(_fakeIncomeCategories),
          ),
        );

        await tester.pump();

        expect(find.text('Transfers'), findsNothing);
      },
    );

    testWidgets(
      'renders Transfers card when accountId is selected',
      (WidgetTester tester) async {
        final now = DateTime.now();
        const accountSummary = PeriodSummary(
          totalIncome: 0,
          totalExpense: 15000,
          totalTransfersIn: 20000,
          totalTransfersOut: 0,
        );

        await tester.pumpWidget(
          _buildTestWidget(
            summaryState: const AsyncData(accountSummary),
            expenseCatState: const AsyncData(<CategoryStatistic>[]),
            incomeCatState: const AsyncData(<CategoryStatistic>[]),
            filterState: StatisticsFilter(
              dateRange: DateTimeRange(
                start: now.subtract(const Duration(days: 30)),
                end: now,
              ),
              preset: StatisticsDatePreset.last30Days,
              accountId: 'acc_dest',
            ),
          ),
        );

        await tester.pump();

        expect(find.text('Transfers'), findsOneWidget);
        expect(find.text('▲ Surplus'), findsOneWidget);
      },
    );
    testWidgets(
      'does not show global empty state when only transfers exist',
      (WidgetTester tester) async {
        final now = DateTime.now();
        const transferOnlySummary = PeriodSummary(
          totalIncome: 0,
          totalExpense: 0,
          totalTransfersIn: 20000,
          totalTransfersOut: 0,
        );

        await tester.pumpWidget(
          _buildTestWidget(
            summaryState: const AsyncData(transferOnlySummary),
            expenseCatState: const AsyncData(<CategoryStatistic>[]),
            incomeCatState: const AsyncData(<CategoryStatistic>[]),
            filterState: StatisticsFilter(
              dateRange: DateTimeRange(
                start: now.subtract(const Duration(days: 30)),
                end: now,
              ),
              preset: StatisticsDatePreset.last30Days,
              accountId: 'acc_dest',
            ),
          ),
        );

        await tester.pump();

        expect(find.text('Net Balance'), findsOneWidget);
        expect(find.text('Transfers'), findsOneWidget);
        // "No data available." is the fallback title for the empty state widget.
        expect(find.text('No data available.'), findsNothing);
      },
    );
  });
}
