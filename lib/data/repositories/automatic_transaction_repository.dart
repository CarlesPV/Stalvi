import '../database/app_database.dart' as db;
import '../mappers/automatic_transaction_mapper.dart';
import '../../domain/entities/automatic_transaction.dart';
import '../../domain/repositories/i_automatic_transaction_repository.dart';

class AutomaticTransactionRepository
    implements IAutomaticTransactionRepository {
  final db.AppDatabase _db;

  AutomaticTransactionRepository(this._db);

  @override
  Future<AutomaticTransaction> createAutomaticTransaction(
    AutomaticTransaction transaction,
  ) async {
    final companion = AutomaticTransactionMapper.toCompanion(transaction);
    await _db.automaticTransactionDao.insertAutomaticTransaction(companion);
    return transaction;
  }

  @override
  Future<AutomaticTransaction?> getAutomaticTransactionById(String id) async {
    final entity =
        await _db.automaticTransactionDao.getAutomaticTransactionById(id);
    return AutomaticTransactionMapper.fromEntity(entity);
  }

  @override
  Future<List<AutomaticTransaction>> getAllAutomaticTransactions() async {
    final entities =
        await _db.automaticTransactionDao.getAllAutomaticTransactions();
    return entities.map(AutomaticTransactionMapper.fromEntity).toList();
  }

  @override
  Future<AutomaticTransaction> updateAutomaticTransaction(
    AutomaticTransaction transaction,
  ) async {
    final companion = AutomaticTransactionMapper.toCompanion(transaction);
    await _db.automaticTransactionDao.updateAutomaticTransaction(companion);
    return transaction;
  }

  @override
  Future<void> deleteAutomaticTransaction(String id) async {
    await _db.automaticTransactionDao.deleteAutomaticTransaction(id);
  }
}
