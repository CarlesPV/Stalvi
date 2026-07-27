import 'package:stalvi/domain/entities/exchange_rate.dart';

/// Infrastructure class holding fallback exchange rates for offline-first usage.
///
/// Contains approximate base conversion rates for major supported currencies
/// (EUR, USD, GBP, JPY, CHF, CAD, AUD, CNY).
abstract class FallbackExchangeRates {
  /// Approximate conversion rates relative to 1 EUR.
  static const Map<String, double> defaultEurRates = {
    'EUR': 1.0,
    'USD': 1.15,
    'GBP': 0.86,
    'JPY': 184.0,
    'CHF': 0.93,
    'CAD': 1.6,
    'AUD': 1.63,
    'CNY': 7.8,
  };

  /// Calculates approximate rates for the given [baseCurrency].
  static Map<String, double> getFallbackRates(String baseCurrency) {
    final baseEurRate = defaultEurRates[baseCurrency] ?? 1.0;
    final rates = <String, double>{};
    for (final entry in defaultEurRates.entries) {
      rates[entry.key] =
          double.parse((entry.value / baseEurRate).toStringAsFixed(6));
    }
    return rates;
  }

  /// Returns a complete [ExchangeRate] domain entity with fallback rates.
  static ExchangeRate getExchangeRate(String baseCurrency) {
    return ExchangeRate(
      baseCurrency: baseCurrency,
      date: DateTime.now(),
      rates: getFallbackRates(baseCurrency),
    );
  }
}
