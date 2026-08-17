import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/category_type.dart';
import 'package:stalvi/data/database/tables/category_table.dart' as db_table;
import 'package:stalvi/data/mappers/category_mapper.dart';

void main() {
  group('CategoryMapper', () {
    final now = DateTime.now();

    test('maps custom category (null associatedType) correctly', () {
      final domainCategory = Category(
        id: 'test-id',
        name: 'Custom Category',
        associatedType: null,
        icon: 'test_icon',
        color: '#FFFFFF',
        createdAt: now,
        modifiedAt: now,
      );

      final dbCategory = domainCategory.toDb();

      expect(dbCategory.id, 'test-id');
      expect(dbCategory.name, 'Custom Category');
      expect(dbCategory.associatedType, null);

      final restoredDomainCategory = dbCategory.toDomain();

      expect(restoredDomainCategory.associatedType, null);
      expect(restoredDomainCategory.id, 'test-id');
      expect(restoredDomainCategory.name, 'Custom Category');
    });

    test('maps income category correctly', () {
      final domainCategory = Category(
        id: 'test-id-2',
        name: 'Income Category',
        associatedType: CategoryType.income,
        icon: 'test_icon',
        color: '#FFFFFF',
        createdAt: now,
        modifiedAt: now,
      );

      final dbCategory = domainCategory.toDb();

      expect(dbCategory.associatedType, db_table.CategoryAssociatedType.income);

      final restoredDomainCategory = dbCategory.toDomain();

      expect(restoredDomainCategory.associatedType, CategoryType.income);
    });

    test('maps expense category correctly', () {
      final domainCategory = Category(
        id: 'test-id-3',
        name: 'Expense Category',
        associatedType: CategoryType.expense,
        icon: 'test_icon',
        color: '#FFFFFF',
        createdAt: now,
        modifiedAt: now,
      );

      final dbCategory = domainCategory.toDb();

      expect(
        dbCategory.associatedType,
        db_table.CategoryAssociatedType.expense,
      );

      final restoredDomainCategory = dbCategory.toDomain();

      expect(restoredDomainCategory.associatedType, CategoryType.expense);
    });
  });
}
