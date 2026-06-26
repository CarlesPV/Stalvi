import 'package:drift/drift.dart';
import 'account_table.dart';
import 'category_table.dart';

@DataClassName('BudgetTableData')
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get accountId =>
      text().named('account_id').references(Accounts, #id)();
  TextColumn get categoryId =>
      text().named('category_id').references(Categories, #id)();
  IntColumn get targetAmount =>
      integer().named('target_amount')(); // stored in cents
  IntColumn get currentAmount => integer()
      .named('current_amount')
      .withDefault(const Constant(0))(); // stored in cents
  DateTimeColumn get startDate => dateTime().named('start_date')();
  DateTimeColumn get endDate => dateTime().named('end_date')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get modifiedAt => dateTime().named('modified_at')();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
