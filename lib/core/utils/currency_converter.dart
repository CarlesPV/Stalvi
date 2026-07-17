import 'dart:convert';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';

class CurrencyConverter {
  /// The 8 supported currencies.
  static const List<String> supportedCurrencies = [
    'EUR',
    'USD',
    'GBP',
    'JPY',
    'CHF',
    'CAD',
    'AUD',
    'CNY',
  ];

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

  /// Converts a raw amount from one currency to another using the provided rates.
  static double convertRaw(
    double amount,
    String fromCurrency,
    String targetCurrency,
    ExchangeRate? currentRates,
  ) {
    if (fromCurrency == targetCurrency) {
      return amount;
    }

    if (currentRates != null) {
      if (currentRates.baseCurrency == targetCurrency) {
        final rate = currentRates.rateFor(fromCurrency);
        if (rate != null && rate != 0) {
          return amount / rate;
        }
      } else if (currentRates.baseCurrency == fromCurrency) {
        final rate = currentRates.rateFor(targetCurrency);
        if (rate != null && rate != 0) {
          return amount * rate;
        }
      } else {
        // Cross currency conversion using targetCurrency and fromCurrency rates relative to the baseCurrency
        final rateFrom = currentRates.rateFor(fromCurrency);
        final rateTarget = currentRates.rateFor(targetCurrency);
        if (rateFrom != null && rateTarget != null && rateFrom != 0) {
          final crossRate = rateFrom / rateTarget;
          return amount / crossRate;
        }
      }
    }

    return amount;
  }
}
