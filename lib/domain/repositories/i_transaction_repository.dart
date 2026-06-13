import '../entities/transaction.dart';

abstract class ITransactionRepository {
  Future<Transaction> createTransaction(Transaction transaction);
  Future<Transaction?> getTransactionById(String id);
  Future<List<Transaction>> getTransactionsByAccountId(String accountId);
  Future<Transaction> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
}
