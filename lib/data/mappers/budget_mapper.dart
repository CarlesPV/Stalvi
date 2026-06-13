import '../../domain/entities/budget.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart' as drift;

class BudgetMapper {
  static Budget fromDataClass(BudgetTableData data) {
    return Budget(
      id: data.id,
      categoryId: data.categoryId,
      targetAmount: data.targetAmount,
      currentAmount: data.currentAmount,
      startDate: data.startDate,
      endDate: data.endDate,
      createdAt: data.createdAt,
      modifiedAt: data.modifiedAt,
      isDeleted: data.isDeleted,
    );
  }

  static BudgetsCompanion toCompanion(Budget budget) {
    return BudgetsCompanion.insert(
      id: budget.id,
      categoryId: budget.categoryId,
      targetAmount: budget.targetAmount,
      currentAmount: drift.Value(budget.currentAmount),
      startDate: budget.startDate,
      endDate: budget.endDate,
      createdAt: budget.createdAt,
      modifiedAt: budget.modifiedAt,
      isDeleted: drift.Value(budget.isDeleted),
    );
  }
}
