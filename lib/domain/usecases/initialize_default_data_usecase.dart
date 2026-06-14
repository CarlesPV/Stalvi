import 'package:uuid/uuid.dart';

import 'package:konta/domain/entities/account.dart';
import 'package:konta/domain/entities/account_type.dart';
import 'package:konta/domain/repositories/i_account_repository.dart';

/// Use case that automatically initializes a user's default data.
///
/// Specifically, it creates a default account ("wallet") if the user
/// has no existing accounts.
class InitializeDefaultDataUseCase {
  final IAccountRepository _accountRepository;

  InitializeDefaultDataUseCase(this._accountRepository);

  /// Executes the default data initialization.
  ///
  /// If the user already has accounts, this operation completes silently
  /// without modifying data.
  Future<void> execute({
    required String userId,
    required String walletName,
    required String currency,
  }) async {
    final existingAccounts = await _accountRepository.getAccountsByUserId(userId);
    if (existingAccounts.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final defaultAccount = Account(
      id: const Uuid().v4(),
      userId: userId,
      name: walletName,
      type: AccountType.cash,
      initialBalance: 0.0,
      currency: currency,
      color: '#4CAF50',
      icon: 'wallet',
      isDefault: true,
      isDeleted: false,
      createdAt: now,
      modifiedAt: now,
    );

    await _accountRepository.createAccount(defaultAccount);
  }
}
