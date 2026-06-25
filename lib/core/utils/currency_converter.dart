import 'dart:convert';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';

class CurrencyConverter {
  /// Converts the transaction amount to the target currency.
  ///
  /// It first attempts to use the [Transaction.exchangeRateSnapshot] saved at the time
  /// of the transaction. If it's not available, it falls back to the current [currentRates].
  static double convertAmount(
    Transaction tx,
    String targetCurrency,
    ExchangeRate? currentRates,
  ) {
    if (tx.originalCurrency == targetCurrency) {
      return tx.amount.toDouble();
    }

    if (tx.exchangeRateSnapshot != null) {
      try {
        final Map<String, dynamic> ratesMap =
            jsonDecode(tx.exchangeRateSnapshot!);
        final num? rateOrig = ratesMap[tx.originalCurrency];
        final num? rateTarget = ratesMap[targetCurrency];

        if (rateOrig != null && rateTarget != null && rateOrig != 0) {
          final crossRate = rateOrig / rateTarget;
          return tx.amount / crossRate;
        }
      } catch (_) {
        // Fallback to current rates if snapshot is invalid
      }
    }

    if (currentRates != null) {
      final rate = currentRates.rateFor(tx.originalCurrency);
      if (rate != null && rate != 0) {
        return tx.amount / rate;
      }
    }

    return tx.amount.toDouble();
  }
}
