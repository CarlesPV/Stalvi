import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/savings_goal_table.dart';

part 'savings_goal_dao.g.dart';

@DriftAccessor(tables: [SavingsGoals])
class SavingsGoalDao extends DatabaseAccessor<AppDatabase>
    with _$SavingsGoalDaoMixin {
  SavingsGoalDao(super.db);

  Future<List<SavingsGoalTableData>> getSavingsGoals() {
    return (select(
      savingsGoals,
    )..where((t) => t.isDeleted.equals(false)))
        .get();
  }

  Stream<List<SavingsGoalTableData>> watchSavingsGoals() {
    return (select(
      savingsGoals,
    )..where((t) => t.isDeleted.equals(false)))
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

  Future<void> cascadeSoftDelete(String id) async {
    await transaction(() async {
      // 1. Soft-delete the goal
      await softDelete(id);

      final db = attachedDatabase;

      // 2. Find transfers
      final transfers = await db.transactionDao.getTransfersForGoal(id);

      // 3. Soft-delete transfers
      await db.transactionDao.setDeletedStatusForGoalTransfers(id, true);

      // 4. Return money to origin accounts
      for (final tx in transfers) {
        final double delta = tx.amount / 100.0;
        await db.accountDao.adjustBalance(tx.accountId, delta);
      }
    });
  }

  Future<void> cascadeRestore(String id) async {
    await transaction(() async {
      final now = DateTime.now();
      // 1. Restore the goal
      await (update(savingsGoals)..where((t) => t.id.equals(id))).write(
        SavingsGoalsCompanion(
          isDeleted: const Value(false),
          deletedAt: const Value(null),
          modifiedAt: Value(now),
        ),
      );

      final db = attachedDatabase;

      // 2. Find transfers
      final transfers = await db.transactionDao.getTransfersForGoal(id);

      // 3. Restore transfers
      await db.transactionDao.setDeletedStatusForGoalTransfers(id, false);

      // 4. Deduct money from origin accounts
      for (final tx in transfers) {
        final double delta = tx.amount / 100.0;
        await db.accountDao.adjustBalance(tx.accountId, -delta);
      }
    });
  }
}
