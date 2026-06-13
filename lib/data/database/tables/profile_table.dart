import 'package:drift/drift.dart';

@DataClassName('Profile')
class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get username => text()();
  TextColumn get password => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get modifiedAt => dateTime().named('modified_at')();

  @override
  Set<Column> get primaryKey => {id};
}
