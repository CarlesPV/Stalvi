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

  static AutomaticTransactionsCompanion toCompanion(
      AutomaticTransaction model) {
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

  static db_table.TransactionType _mapDomainTypeToDB(
      domain.TransactionType domainType) {
    switch (domainType) {
      case domain.TransactionType.income:
        return db_table.TransactionType.income;
      case domain.TransactionType.expense:
        return db_table.TransactionType.expense;
      case domain.TransactionType.transfer:
        return db_table.TransactionType.transfer;
    }
  }

  static domain.TransactionType _mapDbTypeToDomain(
      db_table.TransactionType dbType) {
    switch (dbType) {
      case db_table.TransactionType.income:
        return domain.TransactionType.income;
      case db_table.TransactionType.expense:
        return domain.TransactionType.expense;
      case db_table.TransactionType.transfer:
        return domain.TransactionType.transfer;
    }
  }
}
