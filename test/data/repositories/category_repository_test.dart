import 'dart:ffi';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';
import 'package:uuid/uuid.dart';
import 'package:stalvi/data/database/app_database.dart' as db_data;
import 'package:stalvi/data/repositories/category_repository.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/category_type.dart';

void main() {
  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () {
      return DynamicLibrary.open('libsqlite3.so.0');
    });
  });

  late db_data.AppDatabase db;
  late CategoryRepository repository;
  const uuid = Uuid();

  setUp(() {
    db = db_data.AppDatabase.forTesting(NativeDatabase.memory());
    repository = CategoryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Category buildTestCategory({
    required String id,
    String name = 'Test Category',
    bool isDeleted = false,
  }) {
    return Category(
      id: id,
      name: name,
      associatedType: CategoryType.expense,
      icon: 'category',
      color: '#FF00FF',
      isDeleted: isDeleted,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );
  }

  group('CategoryRepository Tests', () {
    test('createCategory saves category and getCategoryById retrieves it',
        () async {
      final id = uuid.v4();
      final category = buildTestCategory(id: id);

      await repository.createCategory(category);
      final retrieved = await repository.getCategoryById(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, id);
      expect(retrieved.name, 'Test Category');
      expect(retrieved.associatedType, CategoryType.expense);
    });

    test('getAllCategories returns seeded plus new non-deleted categories',
        () async {
      final catActive = buildTestCategory(id: uuid.v4(), name: 'Active Cat');
      final catDeleted = buildTestCategory(
        id: uuid.v4(),
        name: 'Deleted Cat',
        isDeleted: true,
      );

      await repository.createCategory(catActive);
      await repository.createCategory(catDeleted);

      final list = await repository.getAllCategories();

      // Seeded categories: Food, Transport, Salary. Total: 3. plus Active Cat: 4.
      expect(list.length, 4);
      final names = list.map((c) => c.name).toList();
      expect(names, containsAll(['Food', 'Transport', 'Salary', 'Active Cat']));
      expect(names, isNot(contains('Deleted Cat')));
    });

    test('updateCategory correctly modifies database fields', () async {
      final id = uuid.v4();
      final category = buildTestCategory(id: id, name: 'Original Category');
      await repository.createCategory(category);

      final updated =
          category.copyWith(name: 'Updated Category', color: '#00FFFF');
      await repository.updateCategory(updated);

      final retrieved = await repository.getCategoryById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Updated Category');
      expect(retrieved.color, '#00FFFF');
    });

    test('deleteCategory soft-deletes the category record', () async {
      final id = uuid.v4();
      final category = buildTestCategory(id: id, name: 'Category to Delete');
      await repository.createCategory(category);

      await repository.deleteCategory(id);

      final retrieved = await repository.getCategoryById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.isDeleted, isTrue);
    });
  });
}
