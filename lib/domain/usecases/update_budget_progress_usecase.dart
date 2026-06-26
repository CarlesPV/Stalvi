import 'package:flutter/material.dart' show DateTimeRange;
import 'package:stalvi/core/utils/currency_converter.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_budget_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';

class UpdateBudgetProgressUseCase {
  final IBudgetRepository _budgetRepository;
  final ITransactionRepository _transactionRepository;
  final IAccountRepository _accountRepository;
  final IExchangeRateRepository _exchangeRateRepository;

  UpdateBudgetProgressUseCase(
    this._budgetRepository,
    this._transactionRepository,
    this._accountRepository,
    this._exchangeRateRepository,
  );

  /// Recalculates the progress for budgets associated with the given [categoryId]
  /// or derived from the [transaction].
  Future<void> execute({String? categoryId, Transaction? transaction}) async {
    final catId = categoryId ?? transaction?.categoryId;
    if (catId == null) return;

    final budgets = await _budgetRepository.getBudgetsByCategoryId(catId);
    if (budgets.isEmpty) return;

    for (final budget in budgets) {
      final filter = TransactionQueryFilter(
        categoryId: catId,
        type: TransactionType.expense,
        dateRange: DateTimeRange(start: budget.startDate, end: budget.endDate),
      );

      final transactionsStream =
          _transactionRepository.watchFilteredTransactions(filter);
      final transactions = await transactionsStream.first;

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

      for (final tx in transactions) {
        final amount = CurrencyConverter.convertAmount(
          tx,
          budgetAccount.currency,
          currentRates,
        );
        totalSpentCents += amount.round();
      }

      if (budget.currentAmount != totalSpentCents) {
        final updatedBudget = budget.copyWith(currentAmount: totalSpentCents);
        await _budgetRepository.updateBudget(updatedBudget);
      }
    }
  }
}
