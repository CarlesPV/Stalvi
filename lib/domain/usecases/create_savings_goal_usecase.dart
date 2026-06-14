import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/domain/entities/savings_goal.dart';
import 'package:konta/domain/repositories/i_savings_goal_repository.dart';

class CreateSavingsGoalParams {
  final String id;
  final String name;
  final int targetAmount;
  final DateTime? targetDate;
  final String color;
  final String icon;

  const CreateSavingsGoalParams({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.targetDate,
    required this.color,
    required this.icon,
  });
}

class CreateSavingsGoalUseCase {
  final ISavingsGoalRepository _savingsGoalRepository;

  CreateSavingsGoalUseCase(this._savingsGoalRepository);

  Future<SavingsGoal> execute(CreateSavingsGoalParams params) async {
    if (params.targetAmount <= 0) {
      throw const ValidationException(
        message: 'Savings goal target amount must be greater than 0',
        code: 'INVALID_AMOUNT',
      );
    }

    final now = DateTime.now();

    if (params.targetDate != null && !params.targetDate!.isAfter(now)) {
      throw const ValidationException(
        message: 'Target date must be in the future',
        code: 'INVALID_TARGET_DATE',
      );
    }

    final goal = SavingsGoal(
      id: params.id,
      name: params.name,
      targetAmount: params.targetAmount,
      currentAmount: 0,
      targetDate: params.targetDate,
      color: params.color,
      icon: params.icon,
      createdAt: now,
      modifiedAt: now,
      isDeleted: false,
    );

    await _savingsGoalRepository.createSavingsGoal(goal);
    return goal;
  }
}
