import '../entities/budget.dart';

abstract class IBudgetRepository {
  Future<List<Budget>> getBudgets();
  Future<Budget?> getBudgetById(String id);
  Future<List<Budget>> getBudgetsByCategoryId(String categoryId);
  Stream<List<Budget>> watchBudgets();
  Future<void> createBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String id);
}
