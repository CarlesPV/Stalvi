import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/core/utils/currency_converter.dart';
import 'package:stalvi/infrastructure/services/fallback_exchange_rates.dart';

void main() {
  group('FallbackExchangeRates Infrastructure Unit Tests', () {
    test('contains rates for all 8 supported currencies', () {
      final eurRates = FallbackExchangeRates.getFallbackRates('EUR');

      for (final currency in CurrencyConverter.supportedCurrencies) {
        expect(eurRates.containsKey(currency), isTrue);
        expect(eurRates[currency], greaterThan(0));
      }
    });

    test('calculates correct base rates for USD', () {
      final usdRates = FallbackExchangeRates.getFallbackRates('USD');

      expect(usdRates['USD'], equals(1.0));
      expect(usdRates['EUR'], closeTo(0.8695, 0.001));
      expect(usdRates['GBP'], closeTo(0.7478, 0.01));
    });

    test('returns complete ExchangeRate entity', () {
      final entity = FallbackExchangeRates.getExchangeRate('GBP');

      expect(entity.baseCurrency, equals('GBP'));
      expect(entity.rates['GBP'], equals(1.0));
      expect(entity.rates.length, equals(8));
    });
  });
}
