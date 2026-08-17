import 'package:stalvi/domain/entities/budget.dart';
import 'package:stalvi/domain/repositories/i_budget_repository.dart';
import '../database/app_database.dart';
import '../mappers/budget_mapper.dart';

class BudgetRepository implements IBudgetRepository {
  final AppDatabase _db;

  BudgetRepository(this._db);

  @override
  Future<List<Budget>> getBudgets() async {
    final data = await _db.budgetDao.getBudgets();
    return data.map(BudgetMapper.fromDataClass).toList();
  }

  @override
  Stream<List<Budget>> watchBudgets() {
    return _db.budgetDao.watchBudgets().map(
          (rows) => rows.map(BudgetMapper.fromDataClass).toList(),
        );
  }

  @override
  Future<Budget?> getBudgetById(String id) async {
    final data = await _db.budgetDao.getBudgetById(id);
    return data != null ? BudgetMapper.fromDataClass(data) : null;
  }

  @override
  Future<List<Budget>> getBudgetsByCategoryId(String categoryId) async {
    final data = await _db.budgetDao.getBudgetsByCategoryId(categoryId);
    return data.map(BudgetMapper.fromDataClass).toList();
  }

  @override
  Future<void> createBudget(Budget budget) async {
    final companion = BudgetMapper.toCompanion(budget);
    await _db.budgetDao.createBudget(companion);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final companion = BudgetMapper.toCompanion(budget);
    await _db.budgetDao.updateBudget(companion);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _db.budgetDao.softDelete(id);
  }
}
