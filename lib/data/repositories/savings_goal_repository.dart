import 'package:drift/drift.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/i_savings_goal_repository.dart';
import '../database/app_database.dart';
import '../mappers/savings_goal_mapper.dart';

class SavingsGoalRepository implements ISavingsGoalRepository {
  final AppDatabase _db;

  SavingsGoalRepository(this._db);

  @override
  Future<List<SavingsGoal>> getSavingsGoals() async {
    final query = _db.select(_db.savingsGoals)
      ..where((tbl) => tbl.isDeleted.equals(false));
    final data = await query.get();
    return data.map(SavingsGoalMapper.fromDataClass).toList();
  }

  @override
  Stream<List<SavingsGoal>> watchSavingsGoals() {
    final query = _db.select(_db.savingsGoals)
      ..where((tbl) => tbl.isDeleted.equals(false));
    return query
        .watch()
        .map((rows) => rows.map(SavingsGoalMapper.fromDataClass).toList());
  }

  @override
  Future<SavingsGoal?> getSavingsGoalById(String id) async {
    final query = _db.select(_db.savingsGoals)
      ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false));
    final data = await query.getSingleOrNull();
    return data != null ? SavingsGoalMapper.fromDataClass(data) : null;
  }

  @override
  Future<void> createSavingsGoal(SavingsGoal savingsGoal) async {
    final companion = SavingsGoalMapper.toCompanion(savingsGoal);
    await _db.into(_db.savingsGoals).insert(companion);
  }

  @override
  Future<void> updateSavingsGoal(SavingsGoal savingsGoal) async {
    final companion = SavingsGoalMapper.toCompanion(savingsGoal);
    await _db.update(_db.savingsGoals).replace(companion);
  }

  @override
  Future<void> deleteSavingsGoal(String id) async {
    await (_db.update(_db.savingsGoals)..where((tbl) => tbl.id.equals(id)))
        .write(
      const SavingsGoalsCompanion(isDeleted: Value(true)),
    );
  }
}
