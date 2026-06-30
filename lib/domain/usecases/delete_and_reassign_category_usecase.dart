import '../entities/category.dart';
import '../repositories/i_category_repository.dart';
import '../repositories/i_transaction_repository.dart';

class DeleteAndReassignCategoryUseCase {
  final ICategoryRepository _categoryRepo;
  final ITransactionRepository _transactionRepo;

  DeleteAndReassignCategoryUseCase(this._categoryRepo, this._transactionRepo);

  /// Checks if a category is in use by any transaction.
  Future<bool> isCategoryInUse(String categoryId) async {
    final transactions = await _transactionRepo
        .watchFilteredTransactions(
          TransactionQueryFilter(categoryId: categoryId),
        )
        .first;
    return transactions.isNotEmpty;
  }

  /// Returns a list of categories that can be used as replacements when deleting [categoryToDelete].
  /// - Deleting EXPENSE -> options are EXPENSE or CUSTOM
  /// - Deleting INCOME -> options are INCOME or CUSTOM
  /// - Deleting CUSTOM -> ALL categories are options
  Future<List<Category>> getReplacementCategories(
    Category categoryToDelete,
  ) async {
    final allCategories = await _categoryRepo.watchAllCategories().first;

    return allCategories.where((c) {
      if (c.id == categoryToDelete.id) return false;

      // c) If deleting CUSTOM -> ALL categories are options
      if (categoryToDelete.associatedType == null) {
        return true;
      }

      // a/b) If deleting EXPENSE/INCOME -> options are same type OR CUSTOM
      return c.associatedType == null ||
          c.associatedType == categoryToDelete.associatedType;
    }).toList();
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

    await _categoryRepo.deleteCategory(oldCategoryId);
  }
}
