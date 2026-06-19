import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/theme/app_theme.dart';
import 'package:stalvi/domain/entities/budget.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/savings_goal.dart';
import 'package:stalvi/presentation/features/budgets_and_goals/budgets_and_goals_screen.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:stalvi/core/utils/currency_formatter.dart';
import 'package:stalvi/presentation/widgets/progress_bar_widget.dart';

/// A completely passive, synchronous Stream that never emits any values and never completes.
/// Useful for testing loading states without scheduling any event loop tasks.
class NeverStream<T> extends Stream<T> {
  const NeverStream();

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return NeverSubscription<T>();
  }
}

class NeverSubscription<T> implements StreamSubscription<T> {
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

void main() {
  final testCategory = Category(
    id: 'cat_food',
    name: 'Food & Dining',
    icon: 'restaurant',
    color: '#FF9800',
    createdAt: DateTime(2026, 6, 1),
    modifiedAt: DateTime(2026, 6, 1),
  );

  final testBudgetNormal = Budget(
    id: 'b_normal',
    categoryId: 'cat_food',
    targetAmount: 20000, // €200.00
    currentAmount: 8000, // €80.00
    startDate: DateTime(2026, 6, 1),
    endDate: DateTime(2026, 6, 30),
    createdAt: DateTime(2026, 6, 1),
    modifiedAt: DateTime(2026, 6, 1),
  );

  final testBudgetExceeded = Budget(
    id: 'b_exceeded',
    categoryId: 'cat_food',
    targetAmount: 10000, // €100.00
    currentAmount: 12000, // €120.00
    startDate: DateTime(2026, 6, 1),
    endDate: DateTime(2026, 6, 30),
    createdAt: DateTime(2026, 6, 1),
    modifiedAt: DateTime(2026, 6, 1),
  );

  final testSavingsGoal = SavingsGoal(
    id: 'sg_car',
    name: 'New Electric Car',
    targetAmount: 3000000, // €30,000.00
    currentAmount: 1500000, // €15,000.00
    targetDate: DateTime(2027, 12, 31),
    color: '#2196F3',
    icon: 'directions_car',
    createdAt: DateTime(2026, 6, 1),
    modifiedAt: DateTime(2026, 6, 1),
  );

  Widget createTestWidget({
    required Stream<List<Budget>> budgetsStream,
    required Stream<List<SavingsGoal>> savingsGoalsStream,
    required Stream<List<Category>> categoriesStream,
  }) {
    return ProviderScope(
      overrides: [
        budgetsStreamProvider.overrideWith((ref) => budgetsStream),
        savingsGoalsStreamProvider.overrideWith((ref) => savingsGoalsStream),
        categoriesListProvider.overrideWith((ref) => categoriesStream),
        currencyFormatterProvider
            .overrideWith((ref) => CurrencyFormatter(currencyCode: 'EUR')),
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
        home: const BudgetsAndGoalsScreen(),
      ),
    );
  }

  group('BudgetsAndGoalsScreen Tests', () {
    testWidgets('renders loading state when streams are loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          budgetsStream: const NeverStream<List<Budget>>(),
          savingsGoalsStream: const NeverStream<List<SavingsGoal>>(),
          categoriesStream: const NeverStream<List<Category>>(),
        ),
      );

      // Verify that a CircularProgressIndicator is rendered
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state when streams fail',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          budgetsStream: Stream<List<Budget>>.error(Exception('Db error')),
          savingsGoalsStream: Stream.value([testSavingsGoal]),
          categoriesStream: Stream.value([testCategory]),
        ),
      );

      await tester.pump();

      // Verify that the error message shows up on the budgets tab
      expect(find.text('Failed to load budgets.'), findsOneWidget);
    });

    testWidgets('renders empty state when lists are empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          budgetsStream: Stream.value(<Budget>[]),
          savingsGoalsStream: Stream.value(<SavingsGoal>[]),
          categoriesStream: Stream.value([testCategory]),
        ),
      );

      await tester.pumpAndSettle();

      // Budgets tab is default active. Check budgets empty state text.
      expect(find.text('No budgets set yet'), findsOneWidget);
      expect(
        find.text(
          'Set spending limits for categories to track your monthly expenses and stay within your limits.',
        ),
        findsOneWidget,
      );

      // Switch to Savings Goals tab
      await tester.tap(find.text('Savings Goals'));
      await tester.pumpAndSettle();

      // Check savings goals empty state text.
      expect(find.text('No savings goals yet'), findsOneWidget);
      expect(
        find.text(
          'Create a savings goal to plan for your future dreams, trips, or big purchases.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'renders budgets correctly with progress bars and remaining calculations',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          budgetsStream: Stream.value([testBudgetNormal, testBudgetExceeded]),
          savingsGoalsStream: Stream.value([testSavingsGoal]),
          categoriesStream: Stream.value([testCategory]),
        ),
      );

      await tester.pumpAndSettle();

      // Check Category names
      expect(
        find.text('Food & Dining'),
        findsWidgets,
      ); // Should find two occurrences because we have two budgets with the same category

      // Budget 1 (Normal): Spent €80.00 of €200.00 (progress: 40%) -> remaining: €120.00
      final b1Spent = CurrencyFormatter().format(80.0);
      final b1Target = CurrencyFormatter().format(200.0);
      final b1Remaining = CurrencyFormatter().format(120.0);
      expect(find.text('$b1Spent of $b1Target'), findsOneWidget);
      expect(find.text('$b1Remaining remaining'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);

      // Budget 2 (Exceeded): Spent €120.00 of €100.00 (progress: 120%) -> overspent: €20.00
      final b2Spent = CurrencyFormatter().format(120.0);
      final b2Target = CurrencyFormatter().format(100.0);
      final b2Overspent = CurrencyFormatter().format(20.0);
      expect(find.text('$b2Spent of $b2Target'), findsOneWidget);
      expect(find.text('$b2Overspent overspent'), findsOneWidget);
      expect(find.text('120%'), findsOneWidget);

      // Verify progress bars are rendered
      expect(find.byType(ProgressBarWidget), findsNWidgets(2));
    });

    testWidgets(
        'renders savings goals correctly with custom color/icon and achievements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          budgetsStream: Stream.value([testBudgetNormal]),
          savingsGoalsStream: Stream.value([testSavingsGoal]),
          categoriesStream: Stream.value([testCategory]),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to Savings Goals tab
      await tester.tap(find.text('Savings Goals'));
      await tester.pumpAndSettle();

      // Check Savings Goal Details
      expect(find.text('New Electric Car'), findsOneWidget);
      final sgSaved = CurrencyFormatter().format(15000.0);
      final sgTarget = CurrencyFormatter().format(30000.0);
      expect(find.text('$sgSaved saved of $sgTarget'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Target date: Dec 31, 2027'), findsOneWidget);

      // Check the icon is rendered
      expect(find.byIcon(Icons.directions_car_rounded), findsOneWidget);

      // Verify progress bar is rendered
      expect(find.byType(ProgressBarWidget), findsOneWidget);
    });
  });
}
