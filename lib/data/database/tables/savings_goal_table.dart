import 'package:drift/drift.dart';

@DataClassName('SavingsGoalTableData')
class SavingsGoals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get targetAmount => integer().named('target_amount')(); // stored in cents
  IntColumn get currentAmount => integer().named('current_amount').withDefault(const Constant(0))(); // stored in cents
  DateTimeColumn get targetDate => dateTime().named('target_date').nullable()();
  TextColumn get color => text()();
  TextColumn get icon => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get modifiedAt => dateTime().named('modified_at')();
  BoolColumn get isDeleted => boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
