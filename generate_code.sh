#!/bin/bash

cat << 'EOF' > lib/data/database/daos/automatic_transaction_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/automatic_transaction_table.dart';
import '../tables/account_table.dart';
import '../tables/category_table.dart';
import '../tables/tag_table.dart';

part 'automatic_transaction_dao.g.dart';

@DriftAccessor(tables: [AutomaticTransactions, Accounts, Categories, Tags])
class AutomaticTransactionDao extends DatabaseAccessor<AppDatabase>
    with _$AutomaticTransactionDaoMixin {
  AutomaticTransactionDao(AppDatabase db) : super(db);

  Future<int> insertAutomaticTransaction(AutomaticTransactionsCompanion companion) {
    return into(automaticTransactions).insert(companion);
  }

  Future<AutomaticTransactionEntity> getAutomaticTransactionById(String id) {
    return (select(automaticTransactions)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<List<AutomaticTransactionEntity>> getAllAutomaticTransactions() {
    return select(automaticTransactions).get();
  }

  Future<bool> updateAutomaticTransaction(AutomaticTransactionsCompanion companion) {
    return update(automaticTransactions).replace(companion);
  }

  Future<int> deleteAutomaticTransaction(String id) {
    return (delete(automaticTransactions)..where((t) => t.id.equals(id))).go();
  }
}
EOF

cat << 'EOF' > lib/domain/entities/automatic_transaction.dart
import 'transaction_type.dart';

class AutomaticTransaction {
  final String id;
  final int amount;
  final TransactionType type;
  final String accountId;
  final String? categoryId;
  final String? tagId;
  final String? notes;
  final int recurrenceDays;
  final DateTime nextExecutionDate;
  final DateTime createdAt;

  const AutomaticTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.accountId,
    this.categoryId,
    this.tagId,
    this.notes,
    required this.recurrenceDays,
    required this.nextExecutionDate,
    required this.createdAt,
  });
}
EOF

cat << 'EOF' > lib/domain/repositories/i_automatic_transaction_repository.dart
import '../entities/automatic_transaction.dart';

abstract class IAutomaticTransactionRepository {
  Future<AutomaticTransaction> createAutomaticTransaction(AutomaticTransaction transaction);
  Future<AutomaticTransaction?> getAutomaticTransactionById(String id);
  Future<List<AutomaticTransaction>> getAllAutomaticTransactions();
  Future<AutomaticTransaction> updateAutomaticTransaction(AutomaticTransaction transaction);
  Future<void> deleteAutomaticTransaction(String id);
}
EOF

cat << 'EOF' > lib/data/mappers/automatic_transaction_mapper.dart
import 'package:drift/drift.dart';
import '../../domain/entities/automatic_transaction.dart';
import '../database/app_database.dart';
import '../../domain/entities/transaction_type.dart' as domain;
import '../database/tables/transaction_table.dart' as db_table;

class AutomaticTransactionMapper {
  static AutomaticTransaction fromEntity(AutomaticTransactionEntity entity) {
    return AutomaticTransaction(
      id: entity.id,
      amount: entity.amount,
      type: _mapDbTypeToDomain(entity.type),
      accountId: entity.accountId,
      categoryId: entity.categoryId,
      tagId: entity.tagId,
      notes: entity.notes,
      recurrenceDays: entity.recurrenceDays,
      nextExecutionDate: entity.nextExecutionDate,
      createdAt: entity.createdAt,
    );
  }

  static AutomaticTransactionsCompanion toCompanion(AutomaticTransaction model) {
    return AutomaticTransactionsCompanion(
      id: Value(model.id),
      amount: Value(model.amount),
      type: Value(_mapDomainTypeToDB(model.type)),
      accountId: Value(model.accountId),
      categoryId: Value(model.categoryId),
      tagId: Value(model.tagId),
      notes: Value(model.notes),
      recurrenceDays: Value(model.recurrenceDays),
      nextExecutionDate: Value(model.nextExecutionDate),
      createdAt: Value(model.createdAt),
    );
  }

  static db_table.TransactionType _mapDomainTypeToDB(domain.TransactionType domainType) {
    switch (domainType) {
      case domain.TransactionType.income: return db_table.TransactionType.income;
      case domain.TransactionType.expense: return db_table.TransactionType.expense;
      case domain.TransactionType.transfer: return db_table.TransactionType.transfer;
    }
  }

  static domain.TransactionType _mapDbTypeToDomain(db_table.TransactionType dbType) {
    switch (dbType) {
      case db_table.TransactionType.income: return domain.TransactionType.income;
      case db_table.TransactionType.expense: return domain.TransactionType.expense;
      case db_table.TransactionType.transfer: return domain.TransactionType.transfer;
    }
  }
}
EOF

cat << 'EOF' > lib/data/repositories/automatic_transaction_repository.dart
import 'package:drift/drift.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import '../database/app_database.dart' as db;
import '../mappers/automatic_transaction_mapper.dart';
import '../../domain/entities/automatic_transaction.dart';
import '../../domain/repositories/i_automatic_transaction_repository.dart';

class AutomaticTransactionRepository implements IAutomaticTransactionRepository {
  final db.AppDatabase _db;

  AutomaticTransactionRepository(this._db);

  @override
  Future<AutomaticTransaction> createAutomaticTransaction(AutomaticTransaction transaction) async {
    final companion = AutomaticTransactionMapper.toCompanion(transaction);
    await _db.automaticTransactionDao.insertAutomaticTransaction(companion);
    return transaction;
  }

  @override
  Future<AutomaticTransaction?> getAutomaticTransactionById(String id) async {
    final entity = await _db.automaticTransactionDao.getAutomaticTransactionById(id);
    return AutomaticTransactionMapper.fromEntity(entity);
  }

  @override
  Future<List<AutomaticTransaction>> getAllAutomaticTransactions() async {
    final entities = await _db.automaticTransactionDao.getAllAutomaticTransactions();
    return entities.map(AutomaticTransactionMapper.fromEntity).toList();
  }

  @override
  Future<AutomaticTransaction> updateAutomaticTransaction(AutomaticTransaction transaction) async {
    final companion = AutomaticTransactionMapper.toCompanion(transaction);
    await _db.automaticTransactionDao.updateAutomaticTransaction(companion);
    return transaction;
  }

  @override
  Future<void> deleteAutomaticTransaction(String id) async {
    await _db.automaticTransactionDao.deleteAutomaticTransaction(id);
  }
}
EOF

cat << 'EOF' > lib/domain/usecases/automatic_transactions/crud_automatic_transactions_usecase.dart
import '../../entities/automatic_transaction.dart';
import '../../repositories/i_automatic_transaction_repository.dart';

class CreateAutomaticTransactionUseCase {
  final IAutomaticTransactionRepository repository;
  CreateAutomaticTransactionUseCase(this.repository);
  Future<AutomaticTransaction> execute(AutomaticTransaction txn) => repository.createAutomaticTransaction(txn);
}

class ReadAutomaticTransactionUseCase {
  final IAutomaticTransactionRepository repository;
  ReadAutomaticTransactionUseCase(this.repository);
  Future<AutomaticTransaction?> execute(String id) => repository.getAutomaticTransactionById(id);
  Future<List<AutomaticTransaction>> executeAll() => repository.getAllAutomaticTransactions();
}

class UpdateAutomaticTransactionUseCase {
  final IAutomaticTransactionRepository repository;
  UpdateAutomaticTransactionUseCase(this.repository);
  Future<AutomaticTransaction> execute(AutomaticTransaction txn) => repository.updateAutomaticTransaction(txn);
}

class DeleteAutomaticTransactionUseCase {
  final IAutomaticTransactionRepository repository;
  DeleteAutomaticTransactionUseCase(this.repository);
  Future<void> execute(String id) => repository.deleteAutomaticTransaction(id);
}
EOF

cat << 'EOF' > lib/domain/usecases/automatic_transactions/evaluate_automatic_transactions_usecase.dart
import '../../entities/automatic_transaction.dart';
import '../../entities/transaction.dart' as dtxn;
import '../../repositories/i_automatic_transaction_repository.dart';
import '../../repositories/i_transaction_repository.dart';
import 'package:uuid/uuid.dart';

class EvaluateAutomaticTransactionsUseCase {
  final IAutomaticTransactionRepository automaticRepo;
  final ITransactionRepository transactionRepo;

  EvaluateAutomaticTransactionsUseCase(this.automaticRepo, this.transactionRepo);

  Future<void> execute() async {
    final now = DateTime.now();
    final automaticTxns = await automaticRepo.getAllAutomaticTransactions();

    for (final autoTxn in automaticTxns) {
      if (autoTxn.nextExecutionDate.isBefore(now) || autoTxn.nextExecutionDate.isAtSameMomentAs(now)) {
        // Generate actual transaction
        final newTxn = dtxn.Transaction(
          id: const Uuid().v4(),
          amount: autoTxn.amount,
          date: now,
          type: autoTxn.type,
          accountId: autoTxn.accountId,
          categoryId: autoTxn.categoryId,
          notes: autoTxn.notes,
          originalCurrency: 'EUR', // Need to fetch from account ideally
          createdAt: now,
          modifiedAt: now,
        );

        await transactionRepo.createTransaction(newTxn);

        // Update next_execution_date
        final nextDate = autoTxn.nextExecutionDate.add(Duration(days: autoTxn.recurrenceDays));
        final updatedAutoTxn = AutomaticTransaction(
          id: autoTxn.id,
          amount: autoTxn.amount,
          type: autoTxn.type,
          accountId: autoTxn.accountId,
          categoryId: autoTxn.categoryId,
          tagId: autoTxn.tagId,
          notes: autoTxn.notes,
          recurrenceDays: autoTxn.recurrenceDays,
          nextExecutionDate: nextDate,
          createdAt: autoTxn.createdAt,
        );
        await automaticRepo.updateAutomaticTransaction(updatedAutoTxn);
      }
    }
  }
}
EOF

