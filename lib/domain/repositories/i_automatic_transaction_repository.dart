import '../entities/automatic_transaction.dart';

abstract class IAutomaticTransactionRepository {
  Future<AutomaticTransaction> createAutomaticTransaction(
    AutomaticTransaction transaction,
  );
  Future<AutomaticTransaction?> getAutomaticTransactionById(String id);
  Future<List<AutomaticTransaction>> getAllAutomaticTransactions();
  Future<AutomaticTransaction> updateAutomaticTransaction(
    AutomaticTransaction transaction,
  );
  Future<void> deleteAutomaticTransaction(String id);
}
