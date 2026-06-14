import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konta/core/theme/app_theme.dart';
import 'package:konta/presentation/widgets/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget Tests', () {
    testWidgets('renders title, subtitle and icon correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Empty Title',
              subtitle: 'Empty Subtitle description goes here.',
            ),
          ),
        ),
      );

      expect(find.text('Empty Title'), findsOneWidget);
      expect(
          find.text('Empty Subtitle description goes here.'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
      // Action button should not be rendered when onActionPressed is null
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('renders action button and fires callback on tap',
        (WidgetTester tester) async {
      var callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Empty Title',
              subtitle: 'Empty Subtitle description.',
              actionLabel: 'Click Me',
              onActionPressed: () {
                callbackCalled = true;
              },
            ),
          ),
        ),
      );

      // Verify button renders with correct label
      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);

      // Tap action button and verify callback fires
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(callbackCalled, true);
    });

    testWidgets(
        'renders SVG fallback graphic correctly when svgAssetPath is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              svgAssetPath: 'assets/dummy_icon.svg',
              title: 'SVG Title',
              subtitle: 'SVG Subtitle description.',
            ),
          ),
        ),
      );

      expect(find.text('SVG Title'), findsOneWidget);
      // Verify image wrapper is rendered
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('supports light theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: EmptyStateWidget(
              icon: Icons.category_rounded,
              title: 'Theme Title',
              subtitle: 'Theme Subtitle.',
            ),
          ),
        ),
      );

      final BuildContext lightContext =
          tester.element(find.byType(EmptyStateWidget));
      final Color lightPrimaryColor =
          Theme.of(lightContext).colorScheme.primary;
      expect(lightPrimaryColor, AppTheme.navyDark);
    });

    testWidgets('supports dark theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: EmptyStateWidget(
              icon: Icons.category_rounded,
              title: 'Theme Title',
              subtitle: 'Theme Subtitle.',
            ),
          ),
        ),
      );

      final BuildContext darkContext =
          tester.element(find.byType(EmptyStateWidget));
      final Color darkPrimaryColor = Theme.of(darkContext).colorScheme.primary;
      expect(darkPrimaryColor, const Color(0xFF60A5FA));
    });
  });
}
