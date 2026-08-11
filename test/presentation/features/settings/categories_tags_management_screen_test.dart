import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/category_type.dart';
import 'package:stalvi/domain/usecases/delete_and_reassign_category_usecase.dart';
import 'package:stalvi/presentation/features/settings/categories_tags_management_screen.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';

class MockDeleteAndReassignCategoryUseCase extends Mock
    implements DeleteAndReassignCategoryUseCase {}

void main() {
  late MockDeleteAndReassignCategoryUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockDeleteAndReassignCategoryUseCase();
    when(() => mockUseCase.isCategoryInUse(any()))
        .thenAnswer((_) async => true);
  });

  Widget createTestableWidget({required List<Category> categories}) {
    return ProviderScope(
      overrides: [
        categoriesListProvider.overrideWith((ref) => Stream.value(categories)),
        deleteAndReassignCategoryUseCaseProvider.overrideWithValue(mockUseCase),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CategoriesTagsManagementScreen(),
      ),
    );
  }

  group('CategoriesTagsManagementScreen', () {
    testWidgets(
        'shows correctly filtered dropdown when deleting an INCOME category',
        (tester) async {
      final now = DateTime.now();
      final catIncome = Category(
        id: 'inc1',
        name: 'Salary',
        associatedType: CategoryType.income,
        icon: '',
        color: '',
        createdAt: now,
        modifiedAt: now,
      );
      final catIncome2 = Category(
        id: 'inc2',
        name: 'Sale',
        associatedType: CategoryType.income,
        icon: '',
        color: '',
        createdAt: now,
        modifiedAt: now,
      );
      final catExpense = Category(
        id: 'exp1',
        name: 'Food',
        associatedType: CategoryType.expense,
        icon: '',
        color: '',
        createdAt: now,
        modifiedAt: now,
      );
      final catCustom = Category(
        id: 'cus1',
        name: 'Investment',
        associatedType: null,
        icon: '',
        color: '',
        createdAt: now,
        modifiedAt: now,
      );

      await tester.pumpWidget(
        createTestableWidget(
          categories: [catIncome, catIncome2, catExpense, catCustom],
        ),
      );
      await tester.pumpAndSettle();

      // Tap delete on 'Salary'
      final deleteButtons = find.byIcon(Icons.delete);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Tap the dropdown to expand
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Should see 'Sale' and 'Investment' in the dropdown list
      expect(
        find.widgetWithText(DropdownMenuItem<String>, 'Sale').last,
        findsOneWidget,
      );
      expect(
        find.widgetWithText(DropdownMenuItem<String>, 'Investment').last,
        findsOneWidget,
      );

      // Should NOT see 'Food' or 'Salary' in the dropdown options
      expect(
        find.widgetWithText(DropdownMenuItem<String>, 'Food'),
        findsNothing,
      );
      // 'Salary' is in the dialog title/message, but not in dropdown items
      final dropdownItems = tester.widgetList<DropdownMenuItem<String>>(
        find.byType(DropdownMenuItem<String>),
      );
      expect(
        dropdownItems.length,
        3,
      ); // 2 in the menu + 1 selected in the button
    });
  });
}
