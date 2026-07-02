import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/presentation/features/settings/about_me_screen.dart';

void main() {
  testWidgets('AboutMeScreen renders correctly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AboutMeScreen(),
        ),
      ),
    );

    // Give time for future builder / asset loading to complete
    await tester.pumpAndSettle();

    expect(find.byType(Markdown), findsOneWidget);
    final BuildContext context = tester.element(find.byType(AboutMeScreen));
    final l10n = AppLocalizations.of(context)!;
    expect(find.text(l10n.aboutMeGithubButton), findsOneWidget);
  });
}
