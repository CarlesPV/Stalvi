import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/presentation/features/budgets_and_goals/widgets/create_edit_savings_goal_sheet.dart';
import 'package:stalvi/presentation/features/settings/categories_tags_management_screen.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('CategoryDialog renders exactly 21 color options', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildTestableWidget(
        Consumer(
          builder: (context, ref, child) {
            return CategoryDialog(ref: ref);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // CircleAvatars inside the color palette Wrap
    final circleAvatars = find.descendant(
      of: find.byType(GridView),
      matching: find.byType(CircleAvatar),
    );

    expect(circleAvatars, findsNWidgets(21));
  });

  testWidgets('CreateEditSavingsGoalSheet renders 8 goal icon selectors', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(const CreateEditSavingsGoalSheet()),
    );
    await tester.pumpAndSettle();

    // The goal icons are rendered in a Row with 8 GestureDetector children containing Icons
    final iconFinders = [
      find.byIcon(Icons.savings_rounded),
      find.byIcon(Icons.directions_car_rounded),
      find.byIcon(Icons.home_rounded),
      find.byIcon(Icons.flight_rounded),
      find.byIcon(Icons.school_rounded),
      find.byIcon(Icons.medical_services_rounded),
      find.byIcon(Icons.laptop_rounded),
      find.byIcon(Icons.beach_access_rounded),
    ];

    for (final finder in iconFinders) {
      expect(finder, findsOneWidget);
    }
  });
}
