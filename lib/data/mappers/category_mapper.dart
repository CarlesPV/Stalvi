import 'package:konta/domain/entities/category.dart';
import 'package:konta/domain/entities/category_type.dart';
import 'package:konta/data/database/app_database.dart' as db;
import 'package:konta/data/database/tables/category_table.dart' as db_table;

extension CategoryMapper on Category {
  db.Category toDb() {
    return db.Category(
      id: id,
      name: name,
      associatedType:
          associatedType != null ? _mapTypeToDb(associatedType!) : null,
      icon: icon,
      color: color,
      parentCategoryId: parentCategoryId,
      isDeleted: isDeleted,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
    );
  }

  db_table.CategoryAssociatedType _mapTypeToDb(CategoryType domainType) {
    switch (domainType) {
      case CategoryType.income:
        return db_table.CategoryAssociatedType.income;
      case CategoryType.expense:
        return db_table.CategoryAssociatedType.expense;
    }
  }
}

extension DbCategoryMapper on db.Category {
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      associatedType:
          associatedType != null ? _mapTypeToDomain(associatedType!) : null,
      icon: icon,
      color: color,
      parentCategoryId: parentCategoryId,
      isDeleted: isDeleted,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
    );
  }

  CategoryType _mapTypeToDomain(db_table.CategoryAssociatedType dbType) {
    switch (dbType) {
      case db_table.CategoryAssociatedType.income:
        return CategoryType.income;
      case db_table.CategoryAssociatedType.expense:
        return CategoryType.expense;
    }
  }
}
