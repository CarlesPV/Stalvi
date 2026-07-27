import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import '../database/app_database.dart' as db;
import '../database/tables/transaction_table.dart' as db_table;

extension TransactionMapper on Transaction {
  db.Transaction toDb() {
    return db.Transaction(
      id: id,
      amount: amount,
      date: date,
      type: _mapTypeToDb(type),
      accountId: accountId,
      categoryId: categoryId,
      savingsGoalId: savingsGoalId,
      notes: notes,
      originalCurrency: originalCurrency,
      convertedAmount: convertedAmount,
      exchangeRate: exchangeRate,
      exchangeRateSnapshot: exchangeRateSnapshot,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      isDeleted: false,
      transferId: transferId,
      parentRecurringId: parentRecurringId,
      expectedExecutionDate: expectedExecutionDate,
    );
  }

  db_table.TransactionType _mapTypeToDb(TransactionType domainType) {
    switch (domainType) {
      case TransactionType.income:
        return db_table.TransactionType.income;
      case TransactionType.expense:
        return db_table.TransactionType.expense;
      case TransactionType.transfer:
        return db_table.TransactionType.transfer;
    }
  }
}

extension DbTransactionMapper on db.Transaction {
  Transaction toDomain() {
    return Transaction(
      id: id,
      amount: amount,
      date: date,
      type: _mapTypeToDomain(type),
      accountId: accountId,
      categoryId: categoryId,
      savingsGoalId: savingsGoalId,
      notes: notes,
      originalCurrency: originalCurrency,
      convertedAmount: convertedAmount,
      exchangeRate: exchangeRate,
      exchangeRateSnapshot: exchangeRateSnapshot,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      transferId: transferId,
      parentRecurringId: parentRecurringId,
      expectedExecutionDate: expectedExecutionDate,
    );
  }

  TransactionType _mapTypeToDomain(db_table.TransactionType dbType) {
    switch (dbType) {
      case db_table.TransactionType.income:
        return TransactionType.income;
      case db_table.TransactionType.expense:
        return TransactionType.expense;
      case db_table.TransactionType.transfer:
        return TransactionType.transfer;
    }
  }
}
