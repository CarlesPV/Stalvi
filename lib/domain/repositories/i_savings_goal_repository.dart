import '../entities/savings_goal.dart';

abstract class ISavingsGoalRepository {
  Future<List<SavingsGoal>> getSavingsGoals();
  Future<SavingsGoal?> getSavingsGoalById(String id);
  Stream<List<SavingsGoal>> watchSavingsGoals();
  Future<void> createSavingsGoal(SavingsGoal savingsGoal);
  Future<void> updateSavingsGoal(SavingsGoal savingsGoal);
  Future<void> deleteSavingsGoal(String id);
}
