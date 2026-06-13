import '../../domain/entities/savings_goal.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart' as drift;

class SavingsGoalMapper {
  static SavingsGoal fromDataClass(SavingsGoalTableData data) {
    return SavingsGoal(
      id: data.id,
      name: data.name,
      targetAmount: data.targetAmount,
      currentAmount: data.currentAmount,
      targetDate: data.targetDate,
      color: data.color,
      icon: data.icon,
      createdAt: data.createdAt,
      modifiedAt: data.modifiedAt,
      isDeleted: data.isDeleted,
    );
  }

  static SavingsGoalsCompanion toCompanion(SavingsGoal goal) {
    return SavingsGoalsCompanion.insert(
      id: goal.id,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: drift.Value(goal.currentAmount),
      targetDate: drift.Value(goal.targetDate),
      color: goal.color,
      icon: goal.icon,
      createdAt: goal.createdAt,
      modifiedAt: goal.modifiedAt,
      isDeleted: drift.Value(goal.isDeleted),
    );
  }
}
