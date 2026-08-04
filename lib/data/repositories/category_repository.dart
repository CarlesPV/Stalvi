import 'package:drift/drift.dart';
import '../database/app_database.dart' as db;
import '../mappers/category_mapper.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';

/// Concrete implementation of [ICategoryRepository] backed by Drift.
class CategoryRepository implements ICategoryRepository {
  final db.AppDatabase _db;

  CategoryRepository(this._db);

  @override
  Future<Category> createCategory(Category category) async {
    final dbCategory = category.toDb();
    await _db.into(_db.categories).insert(dbCategory);
    return category;
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final query = _db.select(_db.categories)..where((c) => c.id.equals(id));
    final row = await query.getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final query = _db.select(_db.categories)
      ..where((c) => c.isDeleted.equals(false))
      ..orderBy([(c) => OrderingTerm(expression: c.name)]);
    final rows = await query.get();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Stream<List<Category>> watchAllCategories() {
    final query = _db.select(_db.categories)
      ..where((c) => c.isDeleted.equals(false))
      ..orderBy([(c) => OrderingTerm(expression: c.name)]);
    return query.watch().map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final dbCategory = category.toDb();
    await (_db.update(_db.categories)..where((c) => c.id.equals(category.id)))
        .write(dbCategory.toCompanion(false));
    return category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
      const db.CategoriesCompanion(
        isDeleted: Value(true),
      ),
    );
  }

  @override
  Future<void> deleteCategoryPermanently(String id) async {
    await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  }
}
