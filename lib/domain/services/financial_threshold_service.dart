import 'package:flutter/material.dart' show DateTimeRange;
import 'package:stalvi/core/utils/currency_converter.dart';
import '../entities/budget.dart';
import '../entities/exchange_rate.dart';
import '../entities/savings_goal.dart';
import '../entities/transaction.dart';
import '../entities/transaction_type.dart';
import '../repositories/i_account_repository.dart';
import '../repositories/i_budget_repository.dart';
import '../repositories/i_exchange_rate_repository.dart';
import '../repositories/i_savings_goal_repository.dart';
import '../repositories/i_transaction_repository.dart';

class ThresholdResult {
  final bool isBudgetExceeded;
  final bool isSavingsGoalReached;
  final Budget? budget;
  final SavingsGoal? savingsGoal;

  ThresholdResult({
    this.isBudgetExceeded = false,
    this.isSavingsGoalReached = false,
    this.budget,
    this.savingsGoal,
  });
}

abstract class IFinancialThresholdService {
  /// Evaluates thresholds for budgets and savings goals affected by the given transactions.
  Future<List<ThresholdResult>> evaluateThresholds(
    List<Transaction> transactions,
  );
}

class FinancialThresholdService implements IFinancialThresholdService {
  final IBudgetRepository _budgetRepository;
  final ISavingsGoalRepository _savingsGoalRepository;
  final ITransactionRepository _transactionRepository;
  final IAccountRepository _accountRepository;
  final IExchangeRateRepository _exchangeRateRepository;

  FinancialThresholdService(
    this._budgetRepository,
    this._savingsGoalRepository,
    this._transactionRepository,
    this._accountRepository,
    this._exchangeRateRepository,
  );

  @override
  Future<List<ThresholdResult>> evaluateThresholds(
    List<Transaction> transactions,
  ) async {
    final results = <ThresholdResult>[];
    if (transactions.isEmpty) return results;

    final categoryIds = <String>{};
    final savingsGoalIds = <String>{};

    for (final tx in transactions) {
      if (tx.categoryId != null) categoryIds.add(tx.categoryId!);
      if (tx.savingsGoalId != null) savingsGoalIds.add(tx.savingsGoalId!);
    }

    // Evaluate Budgets
    for (final catId in categoryIds) {
      final budgets = await _budgetRepository.getBudgetsByCategoryId(catId);
      final now = DateTime.now();

      for (final budget in budgets) {
        if (budget.isDeleted) continue;
        if (now.isBefore(budget.startDate) || now.isAfter(budget.endDate)) {
          continue;
        }

        final filter = TransactionQueryFilter(
          categoryId: catId,
          accountId: budget.accountId,
          type: TransactionType.expense,
          dateRange:
              DateTimeRange(start: budget.startDate, end: budget.endDate),
        );

        final txStream =
            _transactionRepository.watchFilteredTransactions(filter);
        final budgetTransactions = await txStream.first;

        final budgetAccount =
            await _accountRepository.getAccountById(budget.accountId);
        if (budgetAccount == null) continue;

        int totalSpentCents = 0;
        ExchangeRate? currentRates;
        try {
          currentRates = await _exchangeRateRepository.getLocalRates(
            baseCurrency: budgetAccount.currency,
          );
        } catch (_) {}

        for (final tx in budgetTransactions) {
          final amount = CurrencyConverter.convertAmount(
            tx,
            budgetAccount.currency,
            currentRates,
          );
          totalSpentCents += amount.round();
        }

        if (totalSpentCents >= budget.targetAmount) {
          results.add(
            ThresholdResult(
              isBudgetExceeded: true,
              budget: budget,
            ),
          );
        }
      }
    }

    // Evaluate Savings Goals
    for (final goalId in savingsGoalIds) {
      final goal = await _savingsGoalRepository.getSavingsGoalById(goalId);
      if (goal == null || goal.isDeleted) continue;

      final txStream = _transactionRepository.watchRawTransactions();
      final allTx = await txStream.first;

      final goalTransactions = allTx
          .where(
            (tx) =>
                tx.savingsGoalId == goalId &&
                tx.type == TransactionType.transfer,
          )
          .toList();

      int totalSavedCents = 0;
      ExchangeRate? currentRates;
      try {
        currentRates = await _exchangeRateRepository.getLocalRates(
          baseCurrency: goal.currency,
        );
      } catch (_) {}

      for (final tx in goalTransactions) {
        final amount = CurrencyConverter.convertAmount(
          tx,
          goal.currency,
          currentRates,
        );
        totalSavedCents += amount.round();
      }

      if (totalSavedCents >= goal.targetAmount) {
        results.add(
          ThresholdResult(
            isSavingsGoalReached: true,
            savingsGoal: goal,
          ),
        );
      }
    }

    return results;
  }
}
