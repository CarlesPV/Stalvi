import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';

class DeleteAndReassignCategoryUseCase {
  final ICategoryRepository _categoryRepo;
  final ITransactionRepository _transactionRepo;

  DeleteAndReassignCategoryUseCase(this._categoryRepo, this._transactionRepo);

  /// Checks if a category is in use by any transaction.
  Future<bool> isCategoryInUse(String categoryId) async {
    final transactions = await _transactionRepo
        .watchFilteredTransactions(
            TransactionQueryFilter(categoryId: categoryId))
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
          'New category cannot be the same as the old category');
    }

    final transactions = await _transactionRepo
        .watchFilteredTransactions(
            TransactionQueryFilter(categoryId: oldCategoryId))
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
