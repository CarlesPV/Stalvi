import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';

/// Provider for CurrencyFormatter that uses the user's preferred currency.
final currencyFormatterProvider = Provider<CurrencyFormatter>((ref) {
  final profileAsync = ref.watch(defaultProfileProvider);
  final currencyCode = profileAsync.valueOrNull?.defaultCurrency ?? 'EUR';
  return CurrencyFormatter(currencyCode: currencyCode);
});

/// Utility class to handle standard monetary and percentage formatting.
class CurrencyFormatter {
  final String currencyCode;

  CurrencyFormatter({this.currencyCode = 'EUR'});

  String? _formatMillions(
    double amount, {
    String? locale,
    String? currencyCode,
    bool showSign = false,
    bool useCurrencyCode = false,
  }) {
    if (amount.abs() < 1000000) return null;

    final millionsAbs = amount.abs() / 1000000;
    final numberFormat = NumberFormat.decimalPattern(locale);
    numberFormat.minimumFractionDigits = 0;
    numberFormat.maximumFractionDigits = 3;
    final numberString = numberFormat.format(millionsAbs);

    final currencyFmt = useCurrencyCode
        ? NumberFormat.currency(
            locale: locale,
            name: currencyCode ?? this.currencyCode,
          )
        : (currencyCode ?? this.currencyCode) == 'CNY'
            ? NumberFormat.currency(
                locale: locale,
                name: 'CNY',
                symbol: '¥',
              )
            : NumberFormat.simpleCurrency(
                locale: locale,
                name: currencyCode ?? this.currencyCode,
              );

    final currencyString = currencyFmt.format(amount < 0 ? -1 : 1);
    var result =
        currencyString.replaceFirst(RegExp(r'[0-9.,]+'), '${numberString}M');

    if (showSign && amount > 0) {
      result = '+$result';
    }

    return result;
  }

  /// Formats a double value to a currency string.
  ///
  /// [amount] is the monetary value to format.
  /// [locale] determines formatting rules (e.g., 'en_US' uses $1,000.00, 'es_ES' uses 1.000,00 €).
  /// [decimalDigits] sets the number of fraction digits. Defaults to 2.
  /// [showSign] if true, prepends '+' for positive values. (Negative values always have '-').
  String format(
    double amount, {
    String? locale,
    String? currencyCode,
    int decimalDigits = 2,
    bool showSign = false,
  }) {
    final millions = _formatMillions(
      amount,
      locale: locale,
      currencyCode: currencyCode,
      showSign: showSign,
    );
    if (millions != null) return millions;

    final format = (currencyCode ?? this.currencyCode) == 'CNY'
        ? NumberFormat.currency(
            locale: locale,
            name: 'CNY',
            symbol: '¥',
            decimalDigits: decimalDigits,
          )
        : NumberFormat.simpleCurrency(
            locale: locale,
            name: currencyCode ?? this.currencyCode,
            decimalDigits: decimalDigits,
          );

    final result = format.format(amount);

    if (showSign && amount > 0) {
      return '+$result';
    }

    return result;
  }

  /// Formats a double value to a currency string with the currency code.
  /// Used primarily in the Settings screen.
  String formatWithCode(
    double amount, {
    String? locale,
    String? currencyCode,
    int decimalDigits = 2,
    bool showSign = false,
  }) {
    final millions = _formatMillions(
      amount,
      locale: locale,
      currencyCode: currencyCode,
      showSign: showSign,
      useCurrencyCode: true,
    );
    if (millions != null) return millions;

    final format = NumberFormat.currency(
      locale: locale,
      name: currencyCode ?? this.currencyCode,
      decimalDigits: decimalDigits,
    );

    final result = format.format(amount);

    if (showSign && amount > 0) {
      return '+$result';
    }

    return result;
  }

  /// Formats a double value to a compact currency string (e.g., €1.2M, €450K).
  String formatCompact(
    double amount, {
    String? locale,
    String? currencyCode,
  }) {
    final millions =
        _formatMillions(amount, locale: locale, currencyCode: currencyCode);
    if (millions != null) return millions;

    final code = currencyCode ?? this.currencyCode;
    if (code == 'CNY') {
      final format = NumberFormat.compactCurrency(
        locale: locale,
        name: 'CNY',
        symbol: '¥',
      );
      return format.format(amount);
    }

    final format = NumberFormat.compactSimpleCurrency(
      locale: locale,
      name: code,
    );
    return format.format(amount);
  }

  /// Safely parses a formatted currency string back to a double.
  /// Returns `null` if parsing fails.
  static double? tryParse(String value, {String? locale}) {
    if (value.trim().isEmpty) return null;

    try {
      // Remove currency symbols, non-breaking spaces, and standard spaces
      String cleanValue = value
          .replaceAll(
            RegExp(r'[^\d.,\-+]'),
            '',
          ) // Keep only digits, dots, commas, and signs
          .trim();

      final hasComma = cleanValue.contains(',');
      final hasDot = cleanValue.contains('.');

      if (hasComma && hasDot) {
        // If both exist, the last one is always the decimal separator.
        final lastComma = cleanValue.lastIndexOf(',');
        final lastDot = cleanValue.lastIndexOf('.');
        if (lastComma > lastDot) {
          // Comma is decimal separator (e.g., 1.234,56 -> 1234.56)
          cleanValue = cleanValue.replaceAll('.', '').replaceAll(',', '.');
        } else {
          // Dot is decimal separator (e.g., 1,234.56 -> 1234.56)
          cleanValue = cleanValue.replaceAll(',', '');
        }
      } else {
        // Fallback to locale-based parsing
        final format = NumberFormat.decimalPattern(locale);
        final decimalSep = format.symbols.DECIMAL_SEP;
        final groupSep = format.symbols.GROUP_SEP;

        if (decimalSep == ',') {
          cleanValue = cleanValue.replaceAll(groupSep, '').replaceAll(',', '.');
        } else {
          cleanValue = cleanValue.replaceAll(groupSep, '');
        }
      }

      return double.tryParse(cleanValue);
    } catch (_) {
      return null;
    }
  }

  /// Formats a percentage value (e.g., 0.125 -> 12.50%).
  ///
  /// [value] represents the decimal ratio (e.g., 0.125 for 12.5%).
  static String formatPercentage(
    double value, {
    String? locale,
    int decimalDigits = 2,
    bool showSign = false,
  }) {
    final format = NumberFormat.percentPattern(locale);
    format.minimumFractionDigits = decimalDigits;
    format.maximumFractionDigits = decimalDigits;

    final result = format.format(value);
    if (showSign && value > 0) {
      return '+$result';
    }
    return result;
  }

  /// Returns the currency symbol for the given currency code.
  static String getCurrencySymbol(String currencyCode) {
    if (currencyCode.toUpperCase() == 'CNY') {
      return '¥';
    }
    return NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
  }
}
