import 'package:drift/drift.dart';
import '../../domain/entities/automatic_transaction.dart';
import '../database/app_database.dart';
import '../../domain/entities/transaction_type.dart' as domain;
import '../database/tables/transaction_table.dart' as db_table;

/// Maps between [AutomaticTransaction] domain entities and [AutomaticTransactionEntity] / [AutomaticTransactionsCompanion] database models.
class AutomaticTransactionMapper {
  /// Converts a database entity into a domain model.
  static AutomaticTransaction fromEntity(AutomaticTransactionEntity entity) {
    return AutomaticTransaction(
      id: entity.id,
      name: entity.name,
      amount: entity.amount,
      currency: entity.currency,
      type: _mapDbTypeToDomain(entity.type),
      accountId: entity.accountId,
      categoryId: entity.categoryId,
      tagId: entity.tagId,
      labelId: entity.labelId,
      notes: entity.notes,
      recurrenceType: entity.recurrenceType,
      recurrenceDays: entity.recurrenceDays,
      nextExecutionDate: entity.nextExecutionDate,
      createdAt: entity.createdAt,
      isActive: entity.isActive,
      isDeleted: entity.isDeleted,
      deletedAt: entity.deletedAt,
    );
  }

  /// Converts a domain model into a Drift companion object for inserts and updates.
  ///
  /// Note: Optional fields use `Value(model.field)` instead of `Value.absent()`
  /// so that updating a model to set an optional field to `null` properly writes `NULL`
  /// to the database.
  static AutomaticTransactionsCompanion toCompanion(
    AutomaticTransaction model,
  ) {
    return AutomaticTransactionsCompanion(
      id: Value(model.id),
      name: Value(model.name),
      amount: Value(model.amount),
      currency: Value(model.currency),
      type: Value(_mapDomainTypeToDB(model.type)),
      accountId: Value(model.accountId),
      categoryId: Value(model.categoryId),
      tagId: Value(model.tagId),
      labelId: Value(model.labelId),
      notes: Value(model.notes),
      recurrenceType: Value(model.recurrenceType),
      recurrenceDays: Value(model.recurrenceDays),
      nextExecutionDate: Value(model.nextExecutionDate),
      createdAt: Value(model.createdAt),
      isActive: Value(model.isActive),
      isDeleted: Value(model.isDeleted),
      deletedAt: Value(model.deletedAt),
    );
  }

  static db_table.TransactionType _mapDomainTypeToDB(
    domain.TransactionType domainType,
  ) {
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
    db_table.TransactionType dbType,
  ) {
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
