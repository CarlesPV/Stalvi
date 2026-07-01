import '../../entities/automatic_transaction.dart';
import '../../repositories/i_automatic_transaction_repository.dart';

class CreateAutomaticTransactionUseCase {
  final IAutomaticTransactionRepository repository;
  CreateAutomaticTransactionUseCase(this.repository);
  Future<AutomaticTransaction> execute(AutomaticTransaction txn) =>
      repository.createAutomaticTransaction(txn);
}

class ReadAutomaticTransactionUseCase {
  final IAutomaticTransactionRepository repository;
  ReadAutomaticTransactionUseCase(this.repository);
  Future<AutomaticTransaction?> execute(String id) =>
      repository.getAutomaticTransactionById(id);
  Future<List<AutomaticTransaction>> executeAll() =>
      repository.getAllAutomaticTransactions();
}

class UpdateAutomaticTransactionUseCase {
  final IAutomaticTransactionRepository repository;
  UpdateAutomaticTransactionUseCase(this.repository);
  Future<AutomaticTransaction> execute(AutomaticTransaction txn) =>
      repository.updateAutomaticTransaction(txn);
}

class DeleteAutomaticTransactionUseCase {
  final IAutomaticTransactionRepository repository;
  DeleteAutomaticTransactionUseCase(this.repository);
  Future<void> execute(String id) => repository.deleteAutomaticTransaction(id);
}
