import 'package:flutter/material.dart' show DateTimeRange;
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';

class GetPeriodSummaryUseCase {
  final ITransactionRepository _transactionRepository;
  final IExchangeRateRepository _exchangeRateRepository;

  GetPeriodSummaryUseCase(
      this._transactionRepository, this._exchangeRateRepository);

  Future<PeriodSummary> execute({
    required DateTime startDate,
    required DateTime endDate,
    required String targetCurrency,
    String? accountId,
  }) async {
    final filter = TransactionQueryFilter(
      dateRange: DateTimeRange(start: startDate, end: endDate),
      accountId: accountId,
    );
    final transactions =
        await _transactionRepository.watchFilteredTransactions(filter).first;

    final rates = await _exchangeRateRepository.getLocalRates(
        baseCurrency: targetCurrency);

    double totalIncome = 0;
    double totalExpense = 0;

    for (final tx in transactions) {
      double amount = tx.amount.toDouble();
      if (tx.originalCurrency != targetCurrency) {
        final rate = rates?.rateFor(tx.originalCurrency);
        if (rate != null && rate != 0) {
          amount = amount / rate;
        }
      }

      if (tx.type == TransactionType.income) {
        totalIncome += amount;
      } else if (tx.type == TransactionType.expense) {
        totalExpense += amount;
      }
    }

    return PeriodSummary(
      totalIncome: totalIncome.round(),
      totalExpense: totalExpense.round(),
    );
  }
}
