import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_budget_repository.dart';

class DeleteAccountUseCase {
  final IAccountRepository _accountRepository;
  final IBudgetRepository _budgetRepository;

  DeleteAccountUseCase(
    this._accountRepository,
    this._budgetRepository,
  );

  Future<void> execute(String accountId) async {
    // 1. Fetch the account to delete.
    final account = await _accountRepository.getAccountById(accountId);
    if (account == null) {
      throw NotFoundException(
        message: 'Account with id "$accountId" not found',
        code: 'ACCOUNT_NOT_FOUND',
      );
    }

    // 2. Fetch the default account for the user.
    final defaultAccount =
        await _accountRepository.getDefaultAccount(account.userId);
    if (defaultAccount == null) {
      throw const ValidationException(
        message:
            'Cannot delete account because no default account exists for reassignment',
        code: 'NO_DEFAULT_ACCOUNT',
      );
    }

    if (defaultAccount.id == accountId) {
      // Trying to delete the default account - this is usually prevented by UI,
      // but we throw an exception just in case.
      throw const ValidationException(
        message:
            'Cannot delete the default account. Please set another account as default first.',
        code: 'DEFAULT_ACCOUNT_DELETION',
      );
    }

    // 3. Reassign budgets linked to this account to the default account.
    final budgets = await _budgetRepository.getBudgets();
    for (final budget in budgets) {
      if (budget.accountId == accountId) {
        final updatedBudget = budget.copyWith(accountId: defaultAccount.id);
        await _budgetRepository.updateBudget(updatedBudget);
      }
    }

    // 4. Delete the account.
    await _accountRepository.deleteAccount(accountId);
  }
}
