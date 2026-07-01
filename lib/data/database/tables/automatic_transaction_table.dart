import 'package:drift/drift.dart';
import 'account_table.dart';
import 'category_table.dart';
import 'tag_table.dart';
import 'transaction_table.dart'; // For TransactionType

@DataClassName('AutomaticTransactionEntity')
class AutomaticTransactions extends Table {
  TextColumn get id => text()();
  IntColumn get amount => integer()();
  IntColumn get type => intEnum<TransactionType>()();
  TextColumn get accountId =>
      text().named('account_id').references(Accounts, #id)();
  TextColumn get categoryId =>
      text().named('category_id').nullable().references(Categories, #id)();
  TextColumn get tagId =>
      text().named('tag_id').nullable().references(Tags, #id)();
  TextColumn get notes => text().nullable()();
  IntColumn get recurrenceDays => integer().named('recurrence_days')();
  DateTimeColumn get nextExecutionDate =>
      dateTime().named('next_execution_date')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
