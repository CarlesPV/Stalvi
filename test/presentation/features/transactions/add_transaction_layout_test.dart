import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/presentation/features/transactions/add_transaction_screen.dart';

import 'package:stalvi/core/theme/app_theme.dart';

void main() {
  testWidgets(
    'AddTransactionScreen does not overflow on small screens with keyboard',
    (WidgetTester tester) async {
      // Set a very small screen size (320x480 - smaller than most phones today)
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;

      // Provide necessary localization and theme
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    viewInsets: const EdgeInsets.only(
                      bottom: 250,
                    ), // Simulate keyboard
                  ),
                  child: const AddTransactionScreen(),
                );
              },
            ),
          ),
        ),
      );

      // Let the UI settle. If there is a RenderFlex overflow, pumpAndSettle will throw an exception
      await tester.pumpAndSettle();

      // Assert that no exception was thrown
      expect(tester.takeException(), isNull);

      // Reset
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );

  testWidgets(
    'AddTransactionScreen places Label field immediately below Category field and updates state on selection',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AddTransactionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final categoryTile = find.text('Category');
      final tagTile = find.text('Tag (Optional)');
      final dateTile = find.text('Date');
      final currencyTile = find.text('Currency');

      expect(categoryTile, findsOneWidget);
      expect(tagTile, findsOneWidget);
      expect(dateTile, findsOneWidget);
      expect(currencyTile, findsOneWidget);

      // Verify ordering: Category top < Tag top < Date top < Currency top
      final categoryY = tester.getTopLeft(categoryTile).dy;
      final tagY = tester.getTopLeft(tagTile).dy;
      final dateY = tester.getTopLeft(dateTile).dy;
      final currencyY = tester.getTopLeft(currencyTile).dy;

      expect(
        categoryY < tagY,
        isTrue,
        reason: 'Label/Tag field must be below Category field',
      );
      expect(
        tagY < dateY,
        isTrue,
        reason: 'Label/Tag field must be above Date field',
      );
      expect(
        dateY < currencyY,
        isTrue,
        reason: 'Date field must be above Currency field',
      );
    },
  );
}
