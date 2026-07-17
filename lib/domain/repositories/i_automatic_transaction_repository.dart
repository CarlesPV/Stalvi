import '../entities/automatic_transaction.dart';

abstract class IAutomaticTransactionRepository {
  Future<AutomaticTransaction> createAutomaticTransaction(
    AutomaticTransaction transaction,
  );
  Future<AutomaticTransaction?> getAutomaticTransactionById(String id);
  Future<List<AutomaticTransaction>> getAllAutomaticTransactions();

  /// Reactive stream: emits the full list whenever the table changes.
  /// Consumers should filter [AutomaticTransaction.isDeleted] as needed.
  Stream<List<AutomaticTransaction>> watchAllAutomaticTransactions();

  Future<AutomaticTransaction> updateAutomaticTransaction(
    AutomaticTransaction transaction,
  );
  Future<void> deleteAutomaticTransaction(String id);
}
