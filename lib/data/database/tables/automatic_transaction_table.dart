import 'package:drift/drift.dart';
import 'account_table.dart';
import 'category_table.dart';
import 'tag_table.dart';
import 'transaction_table.dart'; // For TransactionType

import 'package:stalvi/domain/entities/recurrence_type.dart';

@DataClassName('AutomaticTransactionEntity')
class AutomaticTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get amount => integer()();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  IntColumn get type => intEnum<TransactionType>()();
  TextColumn get accountId =>
      text().named('account_id').references(Accounts, #id)();
  TextColumn get categoryId =>
      text().named('category_id').nullable().references(Categories, #id)();
  TextColumn get tagId =>
      text().named('tag_id').nullable().references(Tags, #id)();
  TextColumn get notes => text().nullable()();
  IntColumn get recurrenceType => intEnum<RecurrenceType>()
      .named('recurrence_type')
      .withDefault(const Constant(0))();
  IntColumn get recurrenceDays => integer().named('recurrence_days')();
  DateTimeColumn get nextExecutionDate =>
      dateTime().named('next_execution_date')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
