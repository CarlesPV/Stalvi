import 'package:stalvi/data/database/daos/trash_dao.dart';
import '../entities/trash_item.dart';
import '../entities/transaction_type.dart';
import '../repositories/i_account_repository.dart';
import '../repositories/i_transaction_repository.dart';
import 'update_budget_progress_usecase.dart';
import 'package:stalvi/data/database/daos/savings_goal_dao.dart';

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
  final TrashDao _trashDao;
  final ITransactionRepository _transactionRepository;
  final IAccountRepository _accountRepository;
  final UpdateBudgetProgressUseCase _updateBudgetProgressUseCase;
  final SavingsGoalDao _savingsGoalDao;

  TrashUsecases(
    this._trashDao,
    this._transactionRepository,
    this._accountRepository,
    this._updateBudgetProgressUseCase,
    this._savingsGoalDao,
  );

  Future<List<TrashItem>> getTrashItems() => _trashDao.getTrashItems();

  /// Restores a soft-deleted item.
  ///
  /// For [TrashItemType.transaction]: restores the row (and its transfer
  /// mirror, if any) through the repository so that balance reversals and
  /// mirror operations are applied atomically.
  ///
  /// For [TrashItemType.account]: restores only the account row; associated
  /// transactions remain soft-deleted (user can restore them individually).
  ///
  /// For all other types: delegates directly to [TrashDao.restoreItem].
  Future<void> restoreItem(String id, TrashItemType type) async {
    if (type == TrashItemType.transaction) {
      await _transactionRepository.restoreTransaction(id);
      final txn = await _transactionRepository.getTransactionById(id);
      if (txn != null && txn.type == TransactionType.expense) {
        await _updateBudgetProgressUseCase.execute(transaction: txn);
      }
    } else if (type == TrashItemType.savingsGoal) {
      await _savingsGoalDao.cascadeRestore(id);
    } else {
      await _trashDao.restoreItem(id, type);
    }
  }

  /// Soft deletes a savings goal along with its related transfer transactions
  /// and automatically reverts the balances to the origin accounts.
  Future<void> softDeleteSavingsGoal(String id) async {
    await _savingsGoalDao.cascadeSoftDelete(id);
  }

  /// Permanently deletes an item from the database.
  ///
  /// For [TrashItemType.transaction]: hard-deletes the row (and its transfer
  /// mirror, if any) through the repository.
  ///
  /// For [TrashItemType.account]: hard-deletes the account **and** all its
  /// transaction rows through [IAccountRepository.hardDeleteAccount].
  ///
  /// For all other types: delegates directly to [TrashDao.deleteItemPermanently].
  Future<void> deleteItemPermanently(String id, TrashItemType type) async {
    if (type == TrashItemType.transaction) {
      await _transactionRepository.hardDeleteTransaction(id);
    } else if (type == TrashItemType.account) {
      await _accountRepository.hardDeleteAccount(id);
    } else {
      await _trashDao.deleteItemPermanently(id, type);
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
