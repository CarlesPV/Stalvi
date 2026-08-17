import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/presentation/widgets/terms_and_conditions_viewer.dart';

Widget createTestWidget({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  group('TermsAndConditionsViewer Widget Tests', () {
    testWidgets(
        'renders Terms and Conditions by default with scrollable markdown',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const TermsAndConditionsViewer()),
      );
      await tester.pumpAndSettle();

      // Verify AppBar title is Terms and Conditions in English
      expect(find.text('Terms and Conditions'), findsWidgets);

      // Verify Markdown widgets are rendered
      expect(find.byType(Markdown), findsWidgets);

      // Verify the content is scrollable
      final scrollableFinder = find.byType(Scrollable).first;
      expect(scrollableFinder, findsOneWidget);

      // Perform a vertical scroll drag
      await tester.drag(scrollableFinder, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Ensure no errors or overflows after scroll
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Privacy Policy when showPrivacyPolicy is true',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const TermsAndConditionsViewer(showPrivacyPolicy: true),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Privacy Policy is displayed
      expect(find.text('Privacy Policy'), findsWidgets);
      expect(find.byType(Markdown), findsWidgets);
    });

    testWidgets('renders correctly in Spanish (es)', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('es'),
          child: const TermsAndConditionsViewer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Términos y Condiciones'), findsWidgets);
      expect(find.byType(Markdown), findsWidgets);
    });

    testWidgets('renders correctly in Catalan (ca)', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('ca'),
          child: const TermsAndConditionsViewer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Termes i Condicions'), findsWidgets);
      expect(find.byType(Markdown), findsWidgets);
    });

    testWidgets('adapts responsively without overflow on small screens',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(child: const TermsAndConditionsViewer()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TermsAndConditionsViewer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'adapts responsively without overflow on tablet / large screens',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(child: const TermsAndConditionsViewer()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TermsAndConditionsViewer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
