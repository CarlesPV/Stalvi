import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/presentation/widgets/obfuscated_text.dart';
import 'package:stalvi/presentation/providers/discreet_mode_provider.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ObfuscatedText('123.45'),
        ),
      ),
    );
  }

  testWidgets(
      'exposes a11yDiscreetModeHidden semantics when discreetModeProvider is true',
      (tester) async {
    final semanticsHandle = tester.ensureSemantics();

    final container = ProviderContainer();
    container.read(discreetModeProvider.notifier).setDiscreet(true);
    addTearDown(container.dispose);

    await tester.pumpWidget(createWidgetUnderTest(container));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Balance hidden.'), findsOneWidget);

    semanticsHandle.dispose();
  });

  testWidgets('exposes raw text semantics when discreetModeProvider is false',
      (tester) async {
    final semanticsHandle = tester.ensureSemantics();

    final container = ProviderContainer();
    container.read(discreetModeProvider.notifier).setDiscreet(false);
    addTearDown(container.dispose);

    await tester.pumpWidget(createWidgetUnderTest(container));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('123.45'), findsOneWidget);

    semanticsHandle.dispose();
  });
}
