import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/domain/entities/budget.dart';
import 'package:konta/domain/repositories/i_budget_repository.dart';
import 'package:konta/domain/repositories/i_category_repository.dart';

class CreateBudgetParams {
  final String id;
  final String categoryId;
  final int targetAmount;
  final DateTime startDate;
  final DateTime endDate;

  const CreateBudgetParams({
    required this.id,
    required this.categoryId,
    required this.targetAmount,
    required this.startDate,
    required this.endDate,
  });
}

class CreateBudgetUseCase {
  final IBudgetRepository _budgetRepository;
  final ICategoryRepository _categoryRepository;

  CreateBudgetUseCase(this._budgetRepository, this._categoryRepository);

  Future<Budget> execute(CreateBudgetParams params) async {
    if (params.targetAmount <= 0) {
      throw const ValidationException(
        message: 'Budget target amount must be greater than 0',
        code: 'INVALID_AMOUNT',
      );
    }

    if (!params.endDate.isAfter(params.startDate)) {
      throw const ValidationException(
        message: 'End date must be after start date',
        code: 'INVALID_DATES',
      );
    }

    final category =
        await _categoryRepository.getCategoryById(params.categoryId);
    if (category == null) {
      throw NotFoundException(
        message: 'Category with id "${params.categoryId}" not found',
        code: 'CATEGORY_NOT_FOUND',
      );
    }

    final now = DateTime.now();

    final budget = Budget(
      id: params.id,
      categoryId: params.categoryId,
      targetAmount: params.targetAmount,
      currentAmount: 0,
      startDate: params.startDate,
      endDate: params.endDate,
      createdAt: now,
      modifiedAt: now,
      isDeleted: false,
    );

    await _budgetRepository.createBudget(budget);
    return budget;
  }
}
