import 'package:intl/intl.dart';

/// Utility class to handle standard monetary and percentage formatting.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats a double value to a currency string.
  ///
  /// [amount] is the monetary value to format.
  /// [locale] determines formatting rules (e.g., 'en_US' uses $1,000.00, 'es_ES' uses 1.000,00 €).
  /// [currencyCode] is the ISO 4217 code (e.g., 'USD', 'EUR').
  /// [decimalDigits] sets the number of fraction digits. Defaults to 2.
  /// [showSign] if true, prepends '+' for positive values. (Negative values always have '-').
  static String format(
    double amount, {
    String? locale,
    String currencyCode = 'EUR',
    int decimalDigits = 2,
    bool showSign = false,
  }) {
    final format = NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      decimalDigits: decimalDigits,
    );

    final result = format.format(amount);

    if (showSign && amount > 0) {
      return '+$result';
    }

    return result;
  }

  /// Formats a double value to a compact currency string (e.g., €1.2M, €450K).
  static String formatCompact(
    double amount, {
    String? locale,
    String currencyCode = 'EUR',
  }) {
    final format = NumberFormat.compactCurrency(
      locale: locale,
      name: currencyCode,
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
}
