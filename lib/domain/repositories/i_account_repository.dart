import '../entities/account.dart';

abstract class IAccountRepository {
  Future<Account> createAccount(Account account);
  Future<Account?> getAccountById(String id);
  Future<List<Account>> getAccountsByUserId(String userId);
  Stream<List<Account>> watchAccountsByUserId(String userId);
  Future<Account> updateAccount(Account account);

  /// Soft-deletes the account **and** all its associated transactions.
  ///
  /// Both operations are performed inside a single atomic Drift `.transaction()`
  /// so they succeed or fail together.
  Future<void> deleteAccount(String id);

  /// Permanently hard-deletes the account row **and** all its transactions.
  ///
  /// This is called when the account is purged from the trash. Both operations
  /// are atomic.
  Future<void> hardDeleteAccount(String id);

  /// Returns the account currently flagged as default for [userId], or `null`.
  Future<Account?> getDefaultAccount(String userId);

  /// Marks [accountId] as the exclusive default for its owner.
  ///
  /// All other accounts belonging to the same user are automatically
  /// unset from default inside a single atomic transaction.
  Future<void> setDefaultAccount(String accountId);
}
