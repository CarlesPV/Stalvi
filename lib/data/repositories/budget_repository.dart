import 'package:drift/drift.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/i_budget_repository.dart';
import '../database/app_database.dart';
import '../mappers/budget_mapper.dart';

class BudgetRepository implements IBudgetRepository {
  final AppDatabase _db;

  BudgetRepository(this._db);

  @override
  Future<List<Budget>> getBudgets() async {
    final query = _db.select(_db.budgets)
      ..where((tbl) => tbl.isDeleted.equals(false));
    final data = await query.get();
    return data.map(BudgetMapper.fromDataClass).toList();
  }

  @override
  Stream<List<Budget>> watchBudgets() {
    final query = _db.select(_db.budgets)
      ..where((tbl) => tbl.isDeleted.equals(false));
    return query
        .watch()
        .map((rows) => rows.map(BudgetMapper.fromDataClass).toList());
  }

  @override
  Future<Budget?> getBudgetById(String id) async {
    final query = _db.select(_db.budgets)
      ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false));
    final data = await query.getSingleOrNull();
    return data != null ? BudgetMapper.fromDataClass(data) : null;
  }

  @override
  Future<List<Budget>> getBudgetsByCategoryId(String categoryId) async {
    final query = _db.select(_db.budgets)
      ..where(
        (tbl) =>
            tbl.categoryId.equals(categoryId) & tbl.isDeleted.equals(false),
      );
    final data = await query.get();
    return data.map(BudgetMapper.fromDataClass).toList();
  }

  @override
  Future<void> createBudget(Budget budget) async {
    final companion = BudgetMapper.toCompanion(budget);
    await _db.into(_db.budgets).insert(companion);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final companion = BudgetMapper.toCompanion(budget);
    await _db.update(_db.budgets).replace(companion);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await (_db.update(_db.budgets)..where((tbl) => tbl.id.equals(id))).write(
      const BudgetsCompanion(isDeleted: Value(true)),
    );
  }
}
