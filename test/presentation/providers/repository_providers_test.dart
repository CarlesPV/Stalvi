import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/category_type.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';

void main() {
  group('replacementCategoriesProvider', () {
    test('filters categories correctly based on deleted category type',
        () async {
      final now = DateTime.now();
      final catIncome = Category(
        id: 'inc1',
        name: 'Income',
        associatedType: CategoryType.income,
        icon: 'icon',
        color: 'color',
        createdAt: now,
        modifiedAt: now,
      );
      final catExpense = Category(
        id: 'exp1',
        name: 'Expense',
        associatedType: CategoryType.expense,
        icon: 'icon',
        color: 'color',
        createdAt: now,
        modifiedAt: now,
      );
      final catCustom = Category(
        id: 'cus1',
        name: 'Custom',
        associatedType: null,
        icon: 'icon',
        color: 'color',
        createdAt: now,
        modifiedAt: now,
      );
      final catCustom2 = Category(
        id: 'cus2',
        name: 'Custom2',
        associatedType: null,
        icon: 'icon',
        color: 'color',
        createdAt: now,
        modifiedAt: now,
      );

      final container = ProviderContainer(
        overrides: [
          categoriesListProvider.overrideWith((ref) {
            return Stream.value([catIncome, catExpense, catCustom, catCustom2]);
          }),
        ],
      );

      addTearDown(container.dispose);

      // Trigger stream execution and wait for the value to arrive
      final sub = container.listen(categoriesListProvider, (_, __) {});
      await Future.delayed(Duration.zero);
      sub.close();

      // 1. Deleting Income category
      final incomeReplacements =
          container.read(replacementCategoriesProvider(catIncome));
      expect(incomeReplacements.map((c) => c.id).toList(), ['cus1', 'cus2']);

      // 2. Deleting Expense category
      final expenseReplacements =
          container.read(replacementCategoriesProvider(catExpense));
      expect(expenseReplacements.map((c) => c.id).toList(), ['cus1', 'cus2']);

      // 3. Deleting Custom category
      final customReplacements =
          container.read(replacementCategoriesProvider(catCustom));
      expect(
        customReplacements.map((c) => c.id).toList(),
        ['inc1', 'exp1', 'cus2'],
      );
    });
  });
}
