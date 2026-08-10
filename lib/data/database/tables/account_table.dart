import 'package:drift/drift.dart';
import 'profile_table.dart';

enum AccountType { cash, bank, savings, card, other }

@DataClassName('Account')
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id').references(Profiles, #id)();
  TextColumn get name => text()();
  IntColumn get type => intEnum<AccountType>()();
  RealColumn get initialBalance => real().named('initial_balance')();
  TextColumn get currency => text()();
  TextColumn get color => text()();
  TextColumn get icon => text()();
  BoolColumn get isDefault =>
      boolean().named('is_default').withDefault(const Constant(false))();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get modifiedAt => dateTime().named('modified_at')();

  @override
  Set<Column> get primaryKey => {id};
}
