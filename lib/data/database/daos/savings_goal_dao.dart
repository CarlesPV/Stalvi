import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/savings_goal_table.dart';

part 'savings_goal_dao.g.dart';

@DriftAccessor(tables: [SavingsGoals])
class SavingsGoalDao extends DatabaseAccessor<AppDatabase>
    with _$SavingsGoalDaoMixin {
  SavingsGoalDao(super.db);

  Future<List<SavingsGoalTableData>> getSavingsGoals() {
    return (select(savingsGoals)..where((t) => t.isDeleted.equals(false)))
        .get();
  }

  Stream<List<SavingsGoalTableData>> watchSavingsGoals() {
    return (select(savingsGoals)..where((t) => t.isDeleted.equals(false)))
        .watch();
  }

  Future<SavingsGoalTableData?> getSavingsGoalById(String id) {
    return (select(savingsGoals)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<void> createSavingsGoal(SavingsGoalsCompanion companion) {
    return into(savingsGoals).insert(companion).then((_) => {});
  }

  Future<void> updateSavingsGoal(SavingsGoalsCompanion companion) {
    return update(savingsGoals).replace(companion).then((_) => {});
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now();
    await (update(savingsGoals)..where((t) => t.id.equals(id))).write(
      SavingsGoalsCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(now),
        modifiedAt: Value(now),
      ),
    );
  }
}
