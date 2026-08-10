import 'package:stalvi/domain/entities/exchange_rate.dart';

/// Data Transfer Object (DTO) that mirrors the JSON response shape of the
/// Frankfurter exchange rate API:
///
/// ```json
/// {
///   "amount": 1.0,
///   "base": "EUR",
///   "date": "2026-06-13",
///   "rates": { "USD": 1.085, "GBP": 0.856 }
/// }
/// ```
///
/// This class is the JSON deserialization boundary. The domain [ExchangeRate]
/// entity is intentionally kept free of any serialization logic.
class ExchangeRateModel {
  /// The amount the rates are based on (always 1.0 for standard queries).
  final double amount;

  /// The base ISO 4217 currency code (e.g., "EUR").
  final String base;

  /// The publication date of these rates (ISO-8601 date string in source).
  final DateTime date;

  /// Map of target currency codes to their rates relative to [base].
  final Map<String, double> rates;

  const ExchangeRateModel({
    required this.amount,
    required this.base,
    required this.date,
    required this.rates,
  });

  /// Deserializes a Frankfurter API JSON map into an [ExchangeRateModel].
  ///
  /// Throws a [FormatException] if the JSON structure is unexpected, which
  /// the data source layer catches and converts to a typed [NetworkException].
  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>;
    final rates = rawRates.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return ExchangeRateModel(
      amount: (json['amount'] as num).toDouble(),
      base: json['base'] as String,
      date: DateTime.parse(json['date'] as String),
      rates: Map.unmodifiable(rates),
    );
  }

  /// Maps this DTO to the domain [ExchangeRate] entity.
  ExchangeRate toDomain() {
    return ExchangeRate(baseCurrency: base, date: date, rates: rates);
  }

  @override
  String toString() {
    return 'ExchangeRateModel(base: $base, date: $date, '
        'rates: ${rates.length} entries)';
  }
}
