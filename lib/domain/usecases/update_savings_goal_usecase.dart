import 'package:stalvi/core/errors/app_exceptions.dart';
import '../entities/savings_goal.dart';
import '../repositories/i_savings_goal_repository.dart';

class UpdateSavingsGoalParams {
  final String id;
  final String name;
  final DateTime? targetDate;
  final String color;
  final String icon;

  const UpdateSavingsGoalParams({
    required this.id,
    required this.name,
    this.targetDate,
    required this.color,
    required this.icon,
  });
}

class UpdateSavingsGoalUseCase {
  final ISavingsGoalRepository _savingsGoalRepository;

  UpdateSavingsGoalUseCase(this._savingsGoalRepository);

  Future<SavingsGoal> execute(UpdateSavingsGoalParams params) async {
    if (params.name.trim().isEmpty) {
      throw const ValidationException(
        message: 'Savings goal name must not be empty',
        code: 'INVALID_NAME',
      );
    }

    final existing = await _savingsGoalRepository.getSavingsGoalById(params.id);
    if (existing == null) {
      throw NotFoundException(
        message: 'Savings goal with id "${params.id}" not found',
        code: 'SAVINGS_GOAL_NOT_FOUND',
      );
    }

    final updated = existing.copyWith(
      name: params.name.trim(),
      targetDate: params.targetDate,
      color: params.color,
      icon: params.icon,
      modifiedAt: DateTime.now(),
    );

    await _savingsGoalRepository.updateSavingsGoal(updated);
    return updated;
  }
}
