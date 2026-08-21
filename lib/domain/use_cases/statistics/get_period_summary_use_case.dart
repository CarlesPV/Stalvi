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

    final transactions =
        await _transactionRepository.watchRawTransactions().first;

    final rates = await _exchangeRateRepository.getLocalRates(
      baseCurrency: targetCurrency,
    );

    double totalIncome = 0;
    double totalExpense = 0;
    double totalTransfersIn = 0;
    double totalTransfersOut = 0;

    for (final tx in transactions) {
      if (accountId != null && tx.accountId != accountId) continue;
      if (tx.date.isBefore(effectiveStart) || tx.date.isAfter(effectiveEnd)) {
        continue;
      }

      double amount = CurrencyConverter.convertAmount(
        tx,
        targetCurrency,
        rates,
      );

      if (tx.type == TransactionType.income) {
        totalIncome += amount;
      } else if (tx.type == TransactionType.expense) {
        totalExpense += amount;
      } else if (tx.type == TransactionType.transfer) {
        bool isOrigin = !tx.id.endsWith('_dst');
        if (isOrigin) {
          totalTransfersOut += amount;
        } else {
          totalTransfersIn += amount;
        }
      }
    }

    return PeriodSummary(
      totalIncome: totalIncome.round(),
      totalExpense: totalExpense.round(),
      totalTransfersIn: totalTransfersIn.round(),
      totalTransfersOut: totalTransfersOut.round(),
    );
  }
}
