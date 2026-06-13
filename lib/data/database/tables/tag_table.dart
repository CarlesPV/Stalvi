import 'package:drift/drift.dart';

@DataClassName('Tag')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isDeleted => boolean().named('is_deleted').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get modifiedAt => dateTime().named('modified_at')();

  @override
  Set<Column> get primaryKey => {id};
}
