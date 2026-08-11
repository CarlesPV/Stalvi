import 'package:drift/drift.dart';

enum CategoryAssociatedType { income, expense }

@DataClassName('Category')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get associatedType =>
      intEnum<CategoryAssociatedType>().nullable()();
  TextColumn get icon => text()();
  TextColumn get color => text()();
  TextColumn get parentCategoryId => text().nullable()();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get modifiedAt => dateTime().named('modified_at')();

  @override
  Set<Column> get primaryKey => {id};
}
