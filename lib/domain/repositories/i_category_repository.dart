import 'package:konta/domain/entities/category.dart';

abstract class ICategoryRepository {
  Future<Category> createCategory(Category category);
  Future<Category?> getCategoryById(String id);
  Future<List<Category>> getAllCategories();
  Stream<List<Category>> watchAllCategories();
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}
