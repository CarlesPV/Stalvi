import 'package:flutter_test/flutter_test.dart';
import 'package:konta/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('format formats correctly with symbols', () {
      final formatted = CurrencyFormatter().format(
        1234.56,
        locale: 'en_US',
        currencyCode: 'EUR',
      );
      expect(formatted, contains('1,234.56'));
      expect(formatted, contains('€'));
    });

    test('formatWithCode formats correctly with ISO codes', () {
      final formatted = CurrencyFormatter().formatWithCode(
        1234.56,
        locale: 'en_US',
        currencyCode: 'EUR',
      );
      expect(formatted, contains('1,234.56'));
      expect(formatted, contains('EUR'));
    });

    test('format with sign prepends plus sign for positive values', () {
      final formatted = CurrencyFormatter().format(
        1234.56,
        locale: 'en_US',
        currencyCode: 'USD',
        showSign: true,
      );
      expect(formatted, startsWith('+'));
    });

    test('format compact formats correctly with symbols', () {
      final formatted = CurrencyFormatter().formatCompact(
        1200000,
        locale: 'en_US',
        currencyCode: 'USD',
      );
      expect(formatted, contains('1.2M'));
      expect(formatted, contains('\$'));
    });

    test('tryParse parses currency strings correctly', () {
      expect(
        CurrencyFormatter.tryParse('\$1,234.56', locale: 'en_US'),
        1234.56,
      );
      expect(
        CurrencyFormatter.tryParse('1.234,56 €', locale: 'es_ES'),
        1234.56,
      );
      expect(CurrencyFormatter.tryParse('1,234.56'), 1234.56);
      expect(CurrencyFormatter.tryParse('1.234,56'), 1234.56);
    });

    test('formatPercentage formats percentage correctly', () {
      final formatted =
          CurrencyFormatter.formatPercentage(0.125, locale: 'en_US');
      expect(formatted, equals('12.50%'));

      final signed = CurrencyFormatter.formatPercentage(
        0.125,
        locale: 'en_US',
        showSign: true,
      );
      expect(signed, equals('+12.50%'));
    });
  });
}
