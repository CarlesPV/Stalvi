import 'package:drift/drift.dart';

@DataClassName('SavingsGoalTableData')
class SavingsGoals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get targetAmount =>
      integer().named('target_amount')(); // stored in cents
  IntColumn get currentAmount => integer()
      .named('current_amount')
      .withDefault(const Constant(0))(); // stored in cents
  DateTimeColumn get targetDate => dateTime().named('target_date').nullable()();
  TextColumn get color => text()();
  TextColumn get icon => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get modifiedAt => dateTime().named('modified_at')();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();
  BoolColumn get isCompleted =>
      boolean().named('is_completed').withDefault(const Constant(false))();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();

  @override
  Set<Column> get primaryKey => {id};
}
