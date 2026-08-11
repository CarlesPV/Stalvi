import '../../core/errors/app_exceptions.dart';
import '../repositories/i_automatic_transaction_repository.dart';
import '../repositories/i_budget_repository.dart';
import '../repositories/i_category_repository.dart';
import '../repositories/i_transaction_repository.dart';

class DeleteAndReassignCategoryUseCase {
  final ICategoryRepository _categoryRepo;
  final ITransactionRepository _transactionRepo;
  final IAutomaticTransactionRepository _automaticTransactionRepo;
  final IBudgetRepository _budgetRepo;

  DeleteAndReassignCategoryUseCase(
    this._categoryRepo,
    this._transactionRepo,
    this._automaticTransactionRepo,
    this._budgetRepo,
  );

  /// Checks if a category is in use by any transaction, budget, or automatic transaction.
  /// Throws [CategoryInUseByAutomaticTransactionException] if it's assigned to an automatic transaction.
  Future<bool> isCategoryInUse(String categoryId) async {
    final budgets = await _budgetRepo.getBudgetsByCategoryId(categoryId);
    if (budgets.any((b) => !b.isDeleted)) {
      return true;
    }

    final autoTransactions =
        await _automaticTransactionRepo.watchAllAutomaticTransactions().first;
    final inUseByAuto = autoTransactions.any(
      (tx) => tx.categoryId == categoryId && !tx.isDeleted,
    );
    if (inUseByAuto) {
      throw const CategoryInUseByAutomaticTransactionException(
        message: 'Category is in use by automatic transactions',
      );
    }

    final transactions = await _transactionRepo
        .watchFilteredTransactions(
          TransactionQueryFilter(categoryId: categoryId),
        )
        .first;
    return transactions.isNotEmpty;
  }

  /// Reassigns transactions from [oldCategoryId] to [newCategoryId],
  /// then soft-deletes [oldCategoryId].
  Future<void> execute({
    required String oldCategoryId,
    required String newCategoryId,
  }) async {
    if (oldCategoryId == newCategoryId) {
      throw ArgumentError(
        'New category cannot be the same as the old category',
      );
    }

    final transactions = await _transactionRepo
        .watchFilteredTransactions(
          TransactionQueryFilter(categoryId: oldCategoryId),
        )
        .first;

    for (var tx in transactions) {
      final updatedTx = tx.copyWith(
        categoryId: newCategoryId,
        modifiedAt: DateTime.now(),
      );
      await _transactionRepo.updateTransaction(updatedTx);
    }

    final autoTransactions =
        await _automaticTransactionRepo.watchAllAutomaticTransactions().first;
    final linkedAuto = autoTransactions.where(
      (tx) => tx.categoryId == oldCategoryId,
    );
    for (var tx in linkedAuto) {
      final updatedTx = tx.copyWith(categoryId: newCategoryId);
      await _automaticTransactionRepo.updateAutomaticTransaction(updatedTx);
    }

    final linkedBudgets =
        await _budgetRepo.getBudgetsByCategoryId(oldCategoryId);
    for (var b in linkedBudgets) {
      if (!b.isDeleted) {
        final updatedB = b.copyWith(
          categoryId: newCategoryId,
          modifiedAt: DateTime.now(),
        );
        await _budgetRepo.updateBudget(updatedB);
      }
    }

    await _categoryRepo.deleteCategory(oldCategoryId);
  }
}
