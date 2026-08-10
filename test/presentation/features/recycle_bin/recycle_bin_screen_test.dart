import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/trash_item.dart';
import 'package:stalvi/domain/usecases/trash_usecases.dart';
import 'package:stalvi/presentation/features/recycle_bin/recycle_bin_screen.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';

class MockTrashUsecases extends Mock implements TrashUsecases {}

void main() {
  late MockTrashUsecases mockTrashUsecases;

  setUp(() {
    mockTrashUsecases = MockTrashUsecases();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [trashUsecasesProvider.overrideWithValue(mockTrashUsecases)],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: RecycleBinScreen(),
      ),
    );
  }

  testWidgets(
    'renders RecycleBinScreen and displays items with expiration date followed by item type',
    (WidgetTester tester) async {
      final now = DateTime.now();
      final items = [
        TrashItem(
          id: 'cat_1',
          name: 'Test Category',
          type: TrashItemType.category,
          daysRemaining: 25,
          deletedAt: now.subtract(const Duration(days: 5)),
        ),
      ];

      when(
        () => mockTrashUsecases.getTrashItems(),
      ).thenAnswer((_) async => items);
      when(
        () => mockTrashUsecases.watchTrashItems(),
      ).thenAnswer((_) => Stream.value(items));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      // Verify item title is shown
      expect(find.text('Test Category'), findsOneWidget);

      // Verify subtitle has the new order: expiration date followed by item type
      // Expected text: "Expires in 25 days • Category"
      expect(find.text('Expires in 25 days • Category'), findsOneWidget);
    },
  );
}
