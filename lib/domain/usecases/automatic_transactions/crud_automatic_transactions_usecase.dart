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
  Future<void> execute(String id) async {
    final txn = await repository.getAutomaticTransactionById(id);
    if (txn != null) {
      final deletedTxn = txn.copyWith(
        isDeleted: true,
        isActive: false,
        deletedAt: DateTime.now(),
      );
      await repository.updateAutomaticTransaction(deletedTxn);
    }
  }
}

class RestoreAutomaticTransactionUseCase {
  final IAutomaticTransactionRepository repository;
  RestoreAutomaticTransactionUseCase(this.repository);
  Future<void> execute(String id) async {
    final txn = await repository.getAutomaticTransactionById(id);
    if (txn != null) {
      final restoredTxn = txn.copyWith(
        isDeleted: false,
        isActive: true,
        clearDeletedAt: true,
      );
      await repository.updateAutomaticTransaction(restoredTxn);
    }
  }
}
