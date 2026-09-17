import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/presentation/widgets/month_year_picker_dialog.dart';

void main() {
  Widget createTestWidget({
    DateTime? initialDate,
    DateTime? now,
    void Function(DateTime?)? onResult,
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                final res = await showDialog<DateTime>(
                  context: context,
                  builder: (ctx) => MonthYearPickerDialog(
                    initialDate: initialDate,
                    now: now,
                  ),
                );
                onResult?.call(res);
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
      'renders Material 3 AlertDialog with two DropdownButtons and buttons', (
    WidgetTester tester,
  ) async {
    final fixedNow = DateTime(2025, 6, 15);
    await tester.pumpWidget(createTestWidget(now: fixedNow));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(DropdownButton<int>), findsNWidgets(2));
    expect(find.byKey(const ValueKey('yearDropdown')), findsOneWidget);
    expect(find.byKey(const ValueKey('monthDropdown')), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Select'), findsOneWidget);
  });

  testWidgets(
      'bounds year dropdown from 2021 to current year and restricts future months',
      (
    WidgetTester tester,
  ) async {
    final fixedNow = DateTime(2025, 4, 10);
    await tester.pumpWidget(createTestWidget(now: fixedNow));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Year dropdown items
    final yearDropdown = tester.widget<DropdownButton<int>>(
      find.byKey(const ValueKey('yearDropdown')),
    );
    final yearValues = yearDropdown.items!.map((item) => item.value!).toList();
    expect(yearValues, [2021, 2022, 2023, 2024, 2025]);

    // When current year (2025) is selected, months are restricted to 1..4 (April)
    final monthDropdown = tester.widget<DropdownButton<int>>(
      find.byKey(const ValueKey('monthDropdown')),
    );
    final monthValues =
        monthDropdown.items!.map((item) => item.value!).toList();
    expect(monthValues, [1, 2, 3, 4]);
  });

  testWidgets('displays all 12 months when selecting a past year', (
    WidgetTester tester,
  ) async {
    final fixedNow = DateTime(2025, 4, 10);
    await tester.pumpWidget(
      createTestWidget(
        now: fixedNow,
        initialDate: DateTime(2023, 10),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    final monthDropdown = tester.widget<DropdownButton<int>>(
      find.byKey(const ValueKey('monthDropdown')),
    );
    final monthValues =
        monthDropdown.items!.map((item) => item.value!).toList();
    expect(monthValues, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
  });

  testWidgets(
      'clamps month to max month when switching from past year to current year',
      (
    WidgetTester tester,
  ) async {
    final fixedNow = DateTime(2025, 5, 10);
    await tester.pumpWidget(
      createTestWidget(
        now: fixedNow,
        initialDate: DateTime(2023, 11),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Tap the year dropdown to select 2025
    await tester.tap(find.byKey(const ValueKey('yearDropdown')));
    await tester.pumpAndSettle();

    // In the menu overlay, tap 2025 (find.text('2025').last)
    await tester.tap(find.text('2025').last);
    await tester.pumpAndSettle();

    // The selected month should now be clamped to May (5)
    final monthDropdown = tester.widget<DropdownButton<int>>(
      find.byKey(const ValueKey('monthDropdown')),
    );
    expect(monthDropdown.value, 5);
  });

  testWidgets('displays month words using intl DateFormat.MMMM with locale', (
    WidgetTester tester,
  ) async {
    final fixedNow = DateTime(2024, 2, 1);
    await tester.pumpWidget(
      createTestWidget(
        now: fixedNow,
        initialDate: DateTime(2024, 1),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('January'), findsOneWidget);
  });

  testWidgets('cancel button pops dialog returning null', (
    WidgetTester tester,
  ) async {
    DateTime? result;
    final fixedNow = DateTime(2025, 6, 1);
    await tester.pumpWidget(
      createTestWidget(
        now: fixedNow,
        onResult: (val) => result = val,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('cancelButton')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(result, isNull);
  });

  testWidgets(
      'select button pops dialog returning DateTime(selectedYear, selectedMonth)',
      (
    WidgetTester tester,
  ) async {
    DateTime? result;
    final fixedNow = DateTime(2025, 6, 1);
    await tester.pumpWidget(
      createTestWidget(
        now: fixedNow,
        initialDate: DateTime(2024, 3),
        onResult: (val) => result = val,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('selectButton')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(result, isNotNull);
    expect(result!.year, 2024);
    expect(result!.month, 3);
  });

  testWidgets('Dropdowns are wrapped in Semantics with correct labels', (
    WidgetTester tester,
  ) async {
    final fixedNow = DateTime(2025, 6, 1);
    await tester.pumpWidget(
      createTestWidget(
        now: fixedNow,
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    final yearDropdownFinder = find.byKey(const ValueKey('yearDropdown'));
    final monthDropdownFinder = find.byKey(const ValueKey('monthDropdown'));

    expect(
      find.ancestor(
        of: yearDropdownFinder,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'Select Year',
        ),
      ),
      findsWidgets,
    );

    expect(
      find.ancestor(
        of: monthDropdownFinder,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'Select Month',
        ),
      ),
      findsWidgets,
    );
  });
}
