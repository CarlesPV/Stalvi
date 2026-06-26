import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/budget_table.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [Budgets])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(super.db);

  Future<List<BudgetTableData>> getBudgets() {
    return (select(budgets)..where((t) => t.isDeleted.equals(false))).get();
  }

  Stream<List<BudgetTableData>> watchBudgets() {
    return (select(budgets)..where((t) => t.isDeleted.equals(false))).watch();
  }

  Future<BudgetTableData?> getBudgetById(String id) {
    return (select(budgets)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<BudgetTableData>> getBudgetsByCategoryId(String categoryId) {
    return (select(budgets)
          ..where((t) =>
              t.categoryId.equals(categoryId) & t.isDeleted.equals(false)))
        .get();
  }

  Future<void> createBudget(BudgetsCompanion companion) {
    return into(budgets).insert(companion).then((_) => {});
  }

  Future<void> updateBudget(BudgetsCompanion companion) {
    return update(budgets).replace(companion).then((_) => {});
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now();
    await (update(budgets)..where((t) => t.id.equals(id))).write(
      BudgetsCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(now),
        modifiedAt: Value(now),
      ),
    );
  }
}
