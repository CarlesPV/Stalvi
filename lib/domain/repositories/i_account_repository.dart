import '../entities/account.dart';

abstract class IAccountRepository {
  Future<Account> createAccount(Account account);
  Future<Account?> getAccountById(String id);
  Future<List<Account>> getAccountsByUserId(String userId);
  Stream<List<Account>> watchAccountsByUserId(String userId);
  Future<Account> updateAccount(Account account);
  Future<void> deleteAccount(String id);
}
