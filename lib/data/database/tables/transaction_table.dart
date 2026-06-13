import 'package:drift/drift.dart';
import 'account_table.dart';
import 'category_table.dart';

enum TransactionType {
  income,
  expense,
  transfer,
}

@DataClassName('Transaction')
class Transactions extends Table {
  TextColumn get id => text()();
  IntColumn get amount => integer()(); // stored in cents (minor units) to prevent floating-point calculation errors
  DateTimeColumn get date => dateTime()();
  IntColumn get type => intEnum<TransactionType>()();
  TextColumn get accountId => text().named('account_id').references(Accounts, #id)();
  TextColumn get categoryId => text().named('category_id').nullable().references(Categories, #id)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get modifiedAt => dateTime().named('modified_at')();

  @override
  Set<Column> get primaryKey => {id};
}
