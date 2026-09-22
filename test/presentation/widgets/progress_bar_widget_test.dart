import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/theme/app_theme.dart';
import 'package:stalvi/presentation/widgets/progress_bar_widget.dart';

void main() {
  Widget buildWidget({
    required int currentAmount,
    required int targetAmount,
    String? semanticLabel,
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: ProgressBarWidget(
            currentAmount: currentAmount,
            targetAmount: targetAmount,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }

  group('ProgressBarWidget Semantics Tests', () {
    testWidgets(
        'verifies the Semantics widget receives correct percentage value for 75%',
        (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(currentAmount: 75, targetAmount: 100),
      );
      await tester.pumpAndSettle();

      final semanticsFinder = find.descendant(
        of: find.byType(ProgressBarWidget),
        matching: find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.value == '75%',
        ),
      );

      expect(semanticsFinder, findsOneWidget);

      final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
      expect(semanticsWidget.properties.value, '75%');
      expect(semanticsWidget.properties.label, 'Progress: 75 percent');
    });

    testWidgets('verifies the Semantics widget receives 50% value and label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(currentAmount: 50, targetAmount: 100),
      );
      await tester.pumpAndSettle();

      final semanticsFinder = find.descendant(
        of: find.byType(ProgressBarWidget),
        matching: find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.value == '50%',
        ),
      );

      expect(semanticsFinder, findsOneWidget);
      final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
      expect(semanticsWidget.properties.value, '50%');
      expect(semanticsWidget.properties.label, 'Progress: 50 percent');
    });

    testWidgets(
        'verifies the Semantics widget receives 0% when currentAmount is 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(currentAmount: 0, targetAmount: 100),
      );
      await tester.pumpAndSettle();

      final semanticsFinder = find.descendant(
        of: find.byType(ProgressBarWidget),
        matching: find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.value == '0%',
        ),
      );

      expect(semanticsFinder, findsOneWidget);
      final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
      expect(semanticsWidget.properties.value, '0%');
      expect(semanticsWidget.properties.label, 'Progress: 0 percent');
    });

    testWidgets(
        'verifies the Semantics widget receives 0% when targetAmount is 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(currentAmount: 50, targetAmount: 0),
      );
      await tester.pumpAndSettle();

      final semanticsFinder = find.descendant(
        of: find.byType(ProgressBarWidget),
        matching: find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.value == '0%',
        ),
      );

      expect(semanticsFinder, findsOneWidget);
      final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
      expect(semanticsWidget.properties.value, '0%');
    });

    testWidgets('verifies Spanish localization of Semantics label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          currentAmount: 80,
          targetAmount: 100,
          locale: const Locale('es'),
        ),
      );
      await tester.pumpAndSettle();

      final semanticsFinder = find.descendant(
        of: find.byType(ProgressBarWidget),
        matching: find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.value == '80%',
        ),
      );

      expect(semanticsFinder, findsOneWidget);
      final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
      expect(semanticsWidget.properties.value, '80%');
      expect(semanticsWidget.properties.label, 'Progreso: 80 por ciento');
    });

    testWidgets('verifies Catalan localization of Semantics label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          currentAmount: 40,
          targetAmount: 100,
          locale: const Locale('ca'),
        ),
      );
      await tester.pumpAndSettle();

      final semanticsFinder = find.descendant(
        of: find.byType(ProgressBarWidget),
        matching: find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.value == '40%',
        ),
      );

      expect(semanticsFinder, findsOneWidget);
      final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
      expect(semanticsWidget.properties.value, '40%');
      expect(semanticsWidget.properties.label, 'Progrés: 40 per cent');
    });

    testWidgets('verifies custom semanticLabel is prepended to the label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          currentAmount: 60,
          targetAmount: 100,
          semanticLabel: 'Groceries budget',
        ),
      );
      await tester.pumpAndSettle();

      final semanticsFinder = find.descendant(
        of: find.byType(ProgressBarWidget),
        matching: find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.value == '60%',
        ),
      );

      expect(semanticsFinder, findsOneWidget);
      final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
      expect(semanticsWidget.properties.value, '60%');
      expect(
        semanticsWidget.properties.label,
        'Groceries budget, Progress: 60 percent',
      );
    });
  });
}
