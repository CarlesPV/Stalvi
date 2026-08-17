import '../entities/trash_item.dart';
import '../entities/transaction_type.dart';
import '../entities/category_type.dart';
import '../repositories/i_account_repository.dart';
import '../repositories/i_transaction_repository.dart';
import '../repositories/i_trash_repository.dart';
import '../repositories/i_category_repository.dart';
import '../repositories/i_profile_repository.dart';
import 'update_budget_progress_usecase.dart';

/// Use cases for the Trash (soft-delete recovery) screen.
///
/// **Transfer mirroring:**
/// When a transaction that belongs to a transfer pair is deleted or restored,
/// its counterpart row is automatically included in the same operation. This
/// is handled transparently by [ITransactionRepository.deleteTransaction],
/// [ITransactionRepository.hardDeleteTransaction], and
/// [ITransactionRepository.restoreTransaction].
///
/// **Account cascade:**
/// When an account is permanently deleted from the trash,
/// [IAccountRepository.hardDeleteAccount] removes the account row **and** all
/// its associated transaction rows atomically.
class TrashUsecases {
  final ITrashRepository _trashRepository;
  final ITransactionRepository _transactionRepository;
  final IAccountRepository _accountRepository;
  final ICategoryRepository _categoryRepository;
  final IProfileRepository _profileRepository;
  final UpdateBudgetProgressUseCase _updateBudgetProgressUseCase;

  TrashUsecases(
    this._trashRepository,
    this._transactionRepository,
    this._accountRepository,
    this._categoryRepository,
    this._profileRepository,
    this._updateBudgetProgressUseCase,
  );

  Future<List<TrashItem>> getTrashItems() => _trashRepository.getTrashItems();

  Stream<List<TrashItem>> watchTrashItems() =>
      _trashRepository.watchTrashItems();

  /// Restores a soft-deleted item.
  ///
  /// For [TrashItemType.transaction]: restores the row (and its transfer
  /// mirror, if any) through the repository so that balance reversals and
  /// mirror operations are applied atomically.
  ///
  /// For [TrashItemType.account]: restores only the account row; associated
  /// transactions remain soft-deleted (user can restore them individually).
  ///
  /// For all other types: delegates directly to [ITrashRepository.restoreItem].
  Future<void> restoreItem(String id, TrashItemType type) async {
    if (type == TrashItemType.transaction) {
      final txn = await _transactionRepository.getTransactionById(id);
      if (txn != null) {
        String finalAccountId = txn.accountId;
        String? finalCategoryId = txn.categoryId;
        bool needsUpdate = false;

        // Check if Account exists and is not deleted
        final account = await _accountRepository.getAccountById(txn.accountId);
        if (account == null || account.isDeleted) {
          final profile = await _profileRepository.getFirstProfile();
          if (profile != null) {
            final defaultAccount =
                await _accountRepository.getDefaultAccount(profile.id);
            if (defaultAccount != null) {
              finalAccountId = defaultAccount.id;
              needsUpdate = true;
            }
          }
        }

        // Check Category
        if (txn.categoryId != null) {
          final category =
              await _categoryRepository.getCategoryById(txn.categoryId!);
          if (category == null || category.isDeleted) {
            final categories = await _categoryRepository.getAllCategories();
            final activeCategories =
                categories.where((c) => !c.isDeleted).toList();

            // If the original category is deleted, fallback to an active category of the same type
            // to prevent the restored transaction from being orphaned or causing foreign key constraints issues.
            if (txn.type == TransactionType.expense) {
              final fallbackCategory = activeCategories.firstWhere(
                (c) =>
                    c.associatedType == CategoryType.expense ||
                    c.associatedType == null,
                orElse: () => activeCategories.first,
              );
              finalCategoryId = fallbackCategory.id;
              needsUpdate = true;
            } else if (txn.type == TransactionType.income) {
              final fallbackCategory = activeCategories.firstWhere(
                (c) =>
                    c.associatedType == CategoryType.income ||
                    c.associatedType == null,
                orElse: () => activeCategories.first,
              );
              finalCategoryId = fallbackCategory.id;
              needsUpdate = true;
            } else {
              // Transfer type, just clear the category
              finalCategoryId = null;
              needsUpdate = true;
            }
          }
        }

        if (needsUpdate) {
          final updatedTxn = txn.copyWith(
            accountId: finalAccountId,
            categoryId: finalCategoryId,
            clearTransferId: false,
          );
          await _transactionRepository.updateTransaction(updatedTxn);
        }

        await _transactionRepository.restoreTransaction(id);

        // Ensure budget progress uses the most updated transaction
        final restoredTxn = await _transactionRepository.getTransactionById(id);
        if (restoredTxn != null &&
            restoredTxn.type == TransactionType.expense) {
          await _updateBudgetProgressUseCase.execute(transaction: restoredTxn);
        }
      }
    } else if (type == TrashItemType.savingsGoal) {
      await _trashRepository.cascadeRestoreSavingsGoal(id);
    } else {
      await _trashRepository.restoreItem(id, type);
    }
  }

  /// Soft deletes a savings goal along with its related transfer transactions
  /// and automatically reverts the balances to the origin accounts.
  Future<void> softDeleteSavingsGoal(String id) async {
    await _trashRepository.cascadeSoftDeleteSavingsGoal(id);
  }

  /// Permanently deletes an item from the database.
  ///
  /// For [TrashItemType.transaction]: hard-deletes the row (and its transfer
  /// mirror, if any) through the repository.
  ///
  /// For [TrashItemType.account]: hard-deletes the account **and** all its
  /// transaction rows through [IAccountRepository.hardDeleteAccount].
  ///
  /// For all other types: delegates directly to [ITrashRepository.deleteItemPermanently].
  Future<void> deleteItemPermanently(String id, TrashItemType type) async {
    if (type == TrashItemType.transaction) {
      await _transactionRepository.hardDeleteTransaction(id);
    } else if (type == TrashItemType.account) {
      await _accountRepository.hardDeleteAccount(id);
    } else {
      await _trashRepository.deleteItemPermanently(id, type);
    }
  }

  /// Permanently deletes all items in the trash.
  Future<void> emptyTrash() async {
    final items = await getTrashItems();
    for (final item in items) {
      await deleteItemPermanently(item.id, item.type);
    }
  }
}
