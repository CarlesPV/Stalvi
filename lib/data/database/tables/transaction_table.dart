import 'package:drift/drift.dart';
import 'account_table.dart';
import 'category_table.dart';
import 'savings_goal_table.dart';
import 'tag_table.dart';

enum TransactionType { income, expense, transfer }

@DataClassName('Transaction')
class Transactions extends Table {
  TextColumn get id => text()();
  IntColumn get amount =>
      integer()(); // stored in cents (minor units) to prevent floating-point calculation errors
  DateTimeColumn get date => dateTime()();
  IntColumn get type => intEnum<TransactionType>()();
  TextColumn get accountId =>
      text().named('account_id').references(Accounts, #id)();
  TextColumn get categoryId =>
      text().named('category_id').nullable().references(Categories, #id)();
  TextColumn get tagId =>
      text().named('tag_id').nullable().references(Tags, #id)();
  TextColumn get savingsGoalId => text()
      .named('savings_goal_id')
      .nullable()
      .references(SavingsGoals, #id)();
  TextColumn get notes => text().nullable()();
  TextColumn get originalCurrency => text().named('original_currency')();
  IntColumn get convertedAmount =>
      integer().named('converted_amount').nullable()();
  RealColumn get exchangeRate => real().named('exchange_rate').nullable()();
  TextColumn get exchangeRateSnapshot =>
      text().named('exchange_rate_snapshot').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get modifiedAt => dateTime().named('modified_at')();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  /// Links both legs of a transfer pair. Null for income/expense rows.
  TextColumn get transferId => text().named('transfer_id').nullable()();

  TextColumn get parentRecurringId =>
      text().named('parent_recurring_id').nullable()();
  DateTimeColumn get expectedExecutionDate =>
      dateTime().named('expected_execution_date').nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {parentRecurringId, expectedExecutionDate},
      ];
}
