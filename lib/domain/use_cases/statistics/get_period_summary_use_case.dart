import 'package:flutter/material.dart' show DateTimeRange;
import '../../entities/transaction_type.dart';
import '../../entities/period_summary.dart';
import '../../repositories/i_transaction_repository.dart';
import '../../repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/core/utils/currency_converter.dart';

class GetPeriodSummaryUseCase {
  final ITransactionRepository _transactionRepository;
  final IExchangeRateRepository _exchangeRateRepository;

  GetPeriodSummaryUseCase(
    this._transactionRepository,
    this._exchangeRateRepository,
  );

  Future<PeriodSummary> execute({
    DateTime? startDate,
    DateTime? endDate,
    required String targetCurrency,
    String? accountId,
  }) async {
    final now = DateTime.now();
    final effectiveEnd = endDate ?? now;
    final effectiveStart = startDate ?? now.subtract(const Duration(days: 30));

    final filter = TransactionQueryFilter(
      dateRange: DateTimeRange(start: effectiveStart, end: effectiveEnd),
      accountId: accountId,
    );
    final transactions =
        await _transactionRepository.watchFilteredTransactions(filter).first;

    final rates = await _exchangeRateRepository.getLocalRates(
      baseCurrency: targetCurrency,
    );

    double totalIncome = 0;
    double totalExpense = 0;

    for (final tx in transactions) {
      double amount =
          CurrencyConverter.convertAmount(tx, targetCurrency, rates);

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
