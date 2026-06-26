import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/entities/budget.dart';
import 'package:stalvi/domain/repositories/i_budget_repository.dart';

class UpdateBudgetParams {
  final String id;
  final String categoryId;
  final DateTime startDate;
  final DateTime endDate;

  const UpdateBudgetParams({
    required this.id,
    required this.categoryId,
    required this.startDate,
    required this.endDate,
  });
}

class UpdateBudgetUseCase {
  final IBudgetRepository _budgetRepository;

  UpdateBudgetUseCase(this._budgetRepository);

  Future<Budget> execute(UpdateBudgetParams params) async {
    if (!params.endDate.isAfter(params.startDate)) {
      throw const ValidationException(
        message: 'End date must be after start date',
        code: 'INVALID_DATES',
      );
    }

    final existing = await _budgetRepository.getBudgetById(params.id);
    if (existing == null) {
      throw NotFoundException(
        message: 'Budget with id "${params.id}" not found',
        code: 'BUDGET_NOT_FOUND',
      );
    }

    final updated = existing.copyWith(
      categoryId: params.categoryId,
      startDate: params.startDate,
      endDate: params.endDate,
      modifiedAt: DateTime.now(),
    );

    await _budgetRepository.updateBudget(updated);
    return updated;
  }
}
