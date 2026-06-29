import 'package:stalvi/domain/entities/savings_goal.dart';
import 'package:stalvi/domain/repositories/i_savings_goal_repository.dart';
import '../database/app_database.dart';
import '../mappers/savings_goal_mapper.dart';

class SavingsGoalRepository implements ISavingsGoalRepository {
  final AppDatabase _db;

  SavingsGoalRepository(this._db);

  @override
  Future<List<SavingsGoal>> getSavingsGoals() async {
    final data = await _db.savingsGoalDao.getSavingsGoals();
    return data.map(SavingsGoalMapper.fromDataClass).toList();
  }

  @override
  Stream<List<SavingsGoal>> watchSavingsGoals() {
    return _db.savingsGoalDao
        .watchSavingsGoals()
        .map((rows) => rows.map(SavingsGoalMapper.fromDataClass).toList());
  }

  @override
  Future<SavingsGoal?> getSavingsGoalById(String id) async {
    final data = await _db.savingsGoalDao.getSavingsGoalById(id);
    return data != null ? SavingsGoalMapper.fromDataClass(data) : null;
  }

  @override
  Future<void> createSavingsGoal(SavingsGoal savingsGoal) async {
    final companion = SavingsGoalMapper.toCompanion(savingsGoal);
    await _db.savingsGoalDao.createSavingsGoal(companion);
  }

  @override
  Future<void> updateSavingsGoal(SavingsGoal savingsGoal) async {
    final companion = SavingsGoalMapper.toCompanion(savingsGoal);
    await _db.savingsGoalDao.updateSavingsGoal(companion);
  }

  @override
  Future<void> deleteSavingsGoal(String id) async {
    await _db.savingsGoalDao.softDelete(id);
  }
}
