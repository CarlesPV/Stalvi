import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/theme/app_theme.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/tag.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/presentation/features/transactions/transaction_filter_sheet.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:stalvi/presentation/providers/transaction_filter_provider.dart';

// ─── Mock data helpers ────────────────────────────────────────────────────────

final _now = DateTime(2025, 1, 1);

Account _makeAccount({
  String id = 'acc-1',
  String name = 'Test Account',
  bool isDefault = false,
}) =>
    Account(
      id: id,
      userId: 'user-1',
      name: name,
      type: AccountType.bank,
      initialBalance: 1000,
      currency: 'EUR',
      color: '#3B82F6',
      icon: 'account_balance',
      isDefault: isDefault,
      isDeleted: false,
      createdAt: _now,
      modifiedAt: _now,
    );

Category _makeCategory({
  String id = 'cat-1',
  String name = 'Food & Drink',
  bool isDeleted = false,
}) =>
    Category(
      id: id,
      name: name,
      icon: 'restaurant',
      color: '#10B981',
      isDeleted: isDeleted,
      createdAt: _now,
      modifiedAt: _now,
    );

Tag _makeTag({
  String id = 'tag-1',
  String name = 'Work',
  bool isDeleted = false,
}) =>
    Tag(
      id: id,
      name: name,
      isDeleted: isDeleted,
      createdAt: _now,
      modifiedAt: _now,
    );

// ─── Widget test helpers ───────────────────────────────────────────────────────

/// Wraps [child] in a [ProviderScope] + [MaterialApp] configured with the
/// app's localizations and optional provider overrides.
Widget _wrap(
  Widget child, {
  List<Override> overrides = const [],
  TransactionFilter initialFilter = const TransactionFilter(),
}) {
  return ProviderScope(
    overrides: [
      // Override the filter with the given initial state.
      transactionFilterProvider.overrideWith(
        () => _TestFilterNotifier(initialFilter),
      ),
      // Override stream providers with fixed test data.
      accountsListProvider.overrideWith(
        (ref) => Stream.value([
          _makeAccount(id: 'acc-1', name: 'Savings'),
          _makeAccount(id: 'acc-2', name: 'Checking'),
        ]),
      ),
      categoriesListProvider.overrideWith(
        (ref) => Stream.value([
          _makeCategory(id: 'cat-1', name: 'Food'),
          _makeCategory(id: 'cat-2', name: 'Transport'),
          _makeCategory(id: 'cat-deleted', name: 'Deleted', isDeleted: true),
        ]),
      ),
      tagsListProvider.overrideWith(
        (_) async => [
          _makeTag(id: 'tag-1', name: 'Work'),
          _makeTag(id: 'tag-2', name: 'Personal'),
          _makeTag(id: 'tag-deleted', name: 'OldTag', isDeleted: true),
        ],
      ),
      ...overrides,
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    ),
  );
}

/// A simple [TransactionFilterNotifier] subclass that starts with a preset state.
class _TestFilterNotifier extends TransactionFilterNotifier {
  final TransactionFilter _initial;
  _TestFilterNotifier(this._initial);

  @override
  TransactionFilter build() => _initial;
}

// ─── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('TransactionFilterSheet', () {
    // ── Rendering ─────────────────────────────────────────────────────────────

    testWidgets('renders all section labels', (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      // Pump until stream data is delivered.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Section labels (uppercased by the widget).
      expect(find.textContaining('ACCOUNT'), findsOneWidget);
      expect(find.textContaining('TRANSACTION TYPE'), findsOneWidget);
      expect(find.textContaining('CATEGORY'), findsOneWidget);
      expect(find.textContaining('DATE RANGE'), findsOneWidget);
      expect(find.textContaining('AMOUNT RANGE'), findsOneWidget);
      expect(find.textContaining('TAG'), findsOneWidget);
      expect(find.textContaining('CURRENCY'), findsOneWidget);
    });

    testWidgets('renders Apply Filters and Cancel buttons', (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();

      expect(find.byKey(const ValueKey('filterApplyButton')), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('shows Clear All button disabled when filters are empty',
        (tester) async {
      // No active filters → Clear All button disabled (null onPressed).
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();

      final textButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Clear All'),
      );
      expect(textButton.onPressed, isNull);
    });

    testWidgets('shows Clear All button enabled when filters are active',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const TransactionFilterSheet(),
          initialFilter: const TransactionFilter(type: TransactionType.income),
        ),
      );
      await tester.pump();

      final textButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Clear All'),
      );
      expect(textButton.onPressed, isNotNull);
    });

    // ── Type chips ─────────────────────────────────────────────────────────────

    testWidgets('selecting Income chip marks it as selected', (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();

      final incomeChipContainer =
          find.byKey(const ValueKey('filterTypeIncome'));
      expect(incomeChipContainer, findsOneWidget);

      await tester.tap(incomeChipContainer);
      await tester.pump();

      // Find the FilterChip inside the _TypeChip widget.
      final chip = tester.widget<FilterChip>(
        find.descendant(
          of: incomeChipContainer,
          matching: find.byType(FilterChip),
        ),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('selecting All chip deselects Income chip', (tester) async {
      // Start with income selected.
      await tester.pumpWidget(
        _wrap(
          const TransactionFilterSheet(),
          initialFilter: const TransactionFilter(type: TransactionType.income),
        ),
      );
      await tester.pump();

      final incomeChipContainer =
          find.byKey(const ValueKey('filterTypeIncome'));
      final allChipContainer = find.byKey(const ValueKey('filterTypeAll'));

      FilterChip getChip(Finder container) => tester.widget<FilterChip>(
            find.descendant(of: container, matching: find.byType(FilterChip)),
          );

      // Income chip should be selected initially.
      expect(getChip(incomeChipContainer).selected, isTrue);

      // Tap "All" to clear type.
      await tester.tap(allChipContainer);
      await tester.pump();

      expect(getChip(incomeChipContainer).selected, isFalse);
      expect(getChip(allChipContainer).selected, isTrue);
    });

    testWidgets('Transfer chip is present and selectable', (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();

      final transferContainer =
          find.byKey(const ValueKey('filterTypeTransfer'));
      expect(transferContainer, findsOneWidget);

      await tester.tap(transferContainer);
      await tester.pump();

      expect(
        tester
            .widget<FilterChip>(
              find.descendant(
                of: transferContainer,
                matching: find.byType(FilterChip),
              ),
            )
            .selected,
        isTrue,
      );
    });

    testWidgets('Expense chip is present and selectable', (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();

      final expenseContainer = find.byKey(const ValueKey('filterTypeExpense'));
      expect(expenseContainer, findsOneWidget);

      await tester.tap(expenseContainer);
      await tester.pump();

      expect(
        tester
            .widget<FilterChip>(
              find.descendant(
                of: expenseContainer,
                matching: find.byType(FilterChip),
              ),
            )
            .selected,
        isTrue,
      );
    });

    testWidgets('only one type chip is selected at a time', (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();

      FilterChip getChip(Finder container) => tester.widget<FilterChip>(
            find.descendant(of: container, matching: find.byType(FilterChip)),
          );

      // Tap Expense.
      await tester.tap(find.byKey(const ValueKey('filterTypeExpense')));
      await tester.pump();
      // Tap Income.
      await tester.tap(find.byKey(const ValueKey('filterTypeIncome')));
      await tester.pump();

      expect(
        getChip(find.byKey(const ValueKey('filterTypeExpense'))).selected,
        isFalse,
      );
      expect(
        getChip(find.byKey(const ValueKey('filterTypeIncome'))).selected,
        isTrue,
      );
    });

    // ── Account selector ───────────────────────────────────────────────────────

    testWidgets('account dropdown is rendered', (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.byKey(const ValueKey('filterAccountDropdown')),
        findsOneWidget,
      );
    });

    // ── Category dropdown ──────────────────────────────────────────────────────

    testWidgets('category dropdown is rendered', (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.byKey(const ValueKey('filterCategoryDropdown')),
        findsOneWidget,
      );
    });

    // ── Tag dropdown ────────────────────────────────────────────────────────────

    testWidgets('tag dropdown is rendered', (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const ValueKey('filterTagDropdown')), findsOneWidget);
    });

    // ── Currency dropdown ──────────────────────────────────────────────────────

    testWidgets('currency dropdown is rendered', (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('filterCurrencyDropdown')),
        findsOneWidget,
      );
    });

    // ── Amount inputs ──────────────────────────────────────────────────────────

    testWidgets('min and max amount text fields are rendered', (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();

      expect(find.byKey(const ValueKey('filterMinAmount')), findsOneWidget);
      expect(find.byKey(const ValueKey('filterMaxAmount')), findsOneWidget);
    });

    testWidgets('entering min amount value updates the text field',
        (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();

      final minField = find.byKey(const ValueKey('filterMinAmount'));
      await tester.tap(minField);
      await tester.enterText(minField, '50.00');
      await tester.pump();

      expect(find.text('50.00'), findsOneWidget);
    });

    testWidgets('entering max amount value updates the text field',
        (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();

      final maxField = find.byKey(const ValueKey('filterMaxAmount'));
      await tester.tap(maxField);
      await tester.enterText(maxField, '500.00');
      await tester.pump();

      expect(find.text('500.00'), findsOneWidget);
    });

    testWidgets(
        'pre-populated min amount from initial filter shows in text field',
        (tester) async {
      // 5000 cents = 50.00.
      await tester.pumpWidget(
        _wrap(
          const TransactionFilterSheet(),
          initialFilter: const TransactionFilter(minAmountCents: 5000),
        ),
      );
      await tester.pump();

      expect(find.text('50.00'), findsOneWidget);
    });

    testWidgets(
        'pre-populated max amount from initial filter shows in text field',
        (tester) async {
      // 20000 cents = 200.00.
      await tester.pumpWidget(
        _wrap(
          const TransactionFilterSheet(),
          initialFilter: const TransactionFilter(maxAmountCents: 20000),
        ),
      );
      await tester.pump();

      expect(find.text('200.00'), findsOneWidget);
    });

    // ── Date range picker ──────────────────────────────────────────────────────

    testWidgets('date range tile shows placeholder when no date is selected',
        (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('filterDateRangePicker')),
        findsOneWidget,
      );
      expect(find.text('Select Date Range'), findsOneWidget);
    });

    // ── Active filter count badge ──────────────────────────────────────────────

    testWidgets('shows active filter count when filters are set',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const TransactionFilterSheet(),
          initialFilter: const TransactionFilter(
            type: TransactionType.expense,
            currency: 'USD',
          ),
        ),
      );
      await tester.pump();

      // 2 active filters: type + currency.
      expect(find.textContaining('2 active'), findsOneWidget);
    });

    testWidgets('does not show active filter badge when filter is empty',
        (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();

      expect(find.textContaining('active filter'), findsNothing);
    });

    testWidgets('1 active filter shows correct badge text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const TransactionFilterSheet(),
          initialFilter: const TransactionFilter(type: TransactionType.income),
        ),
      );
      await tester.pump();

      expect(find.textContaining('1 active'), findsOneWidget);
    });

    // ── Apply button ───────────────────────────────────────────────────────────

    testWidgets('apply button is always present', (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();

      final applyBtn = find.byKey(const ValueKey('filterApplyButton'));
      expect(applyBtn, findsOneWidget);
    });

    testWidgets('apply button can be tapped without throwing', (tester) async {
      await tester.pumpWidget(_wrap(const TransactionFilterSheet()));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('filterApplyButton')));
      await tester.pump();
      // No exception means success.
    });

    // ── Clear all ──────────────────────────────────────────────────────────────

    testWidgets('tapping Clear All resets type chip to All', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const TransactionFilterSheet(),
          initialFilter: const TransactionFilter(type: TransactionType.income),
        ),
      );
      await tester.pump();

      FilterChip getChip(Finder container) => tester.widget<FilterChip>(
            find.descendant(of: container, matching: find.byType(FilterChip)),
          );

      final incomeChipContainer =
          find.byKey(const ValueKey('filterTypeIncome'));
      // Income chip should be selected initially.
      expect(getChip(incomeChipContainer).selected, isTrue);

      // Tap Clear All.
      final clearBtn = find.widgetWithText(TextButton, 'Clear All');
      await tester.tap(clearBtn);
      await tester.pump();

      // After clear, "All" should be selected.
      final allChipContainer = find.byKey(const ValueKey('filterTypeAll'));
      expect(getChip(allChipContainer).selected, isTrue);
      expect(getChip(incomeChipContainer).selected, isFalse);
    });

    testWidgets('tapping Clear All empties the amount text fields',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const TransactionFilterSheet(),
          initialFilter: const TransactionFilter(
            minAmountCents: 1000,
            maxAmountCents: 5000,
          ),
        ),
      );
      await tester.pump();

      // Pre-populated values visible.
      expect(find.text('10.00'), findsOneWidget);
      expect(find.text('50.00'), findsOneWidget);

      // Tap Clear All.
      await tester.tap(find.widgetWithText(TextButton, 'Clear All'));
      await tester.pump();

      // Fields should be empty.
      expect(find.text('10.00'), findsNothing);
      expect(find.text('50.00'), findsNothing);
    });

    testWidgets('tapping Clear All hides the active filter badge',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const TransactionFilterSheet(),
          initialFilter: const TransactionFilter(currency: 'USD'),
        ),
      );
      await tester.pump();

      // Badge is visible.
      expect(find.textContaining('1 active'), findsOneWidget);

      // Clear.
      await tester.tap(find.widgetWithText(TextButton, 'Clear All'));
      await tester.pump();

      // Badge gone.
      expect(find.textContaining('active filter'), findsNothing);
    });
  });
}
