/// Immutable domain entity representing a snapshot of exchange rates
/// for a given [baseCurrency] on a specific [date].
///
/// This is a pure Dart value object with no framework dependencies.
/// No user data is contained here — [baseCurrency] is a public ISO 4217
/// currency code (e.g., "EUR") that is safe to transmit to a public API.
class ExchangeRate {
  /// The ISO 4217 currency code used as the base for the [rates] map.
  final String baseCurrency;

  /// The date on which these rates were published.
  final DateTime date;

  /// A map of target ISO 4217 currency codes to their exchange rate
  /// relative to [baseCurrency]. E.g., `{"USD": 1.085, "GBP": 0.856}`.
  final Map<String, double> rates;

  const ExchangeRate({
    required this.baseCurrency,
    required this.date,
    required this.rates,
  });

  /// Returns the exchange rate for the given [targetCurrency], or `null`
  /// if the currency is not present in the [rates] snapshot.
  double? rateFor(String targetCurrency) => rates[targetCurrency];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExchangeRate &&
        other.baseCurrency == baseCurrency &&
        other.date == date &&
        _mapsEqual(other.rates, rates);
  }

  @override
  int get hashCode {
    return baseCurrency.hashCode ^ date.hashCode ^ rates.hashCode;
  }

  ExchangeRate copyWith({
    String? baseCurrency,
    DateTime? date,
    Map<String, double>? rates,
  }) {
    return ExchangeRate(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      date: date ?? this.date,
      rates: rates ?? Map.unmodifiable(this.rates),
    );
  }

  @override
  String toString() {
    return 'ExchangeRate(baseCurrency: $baseCurrency, date: $date, '
        'rates: ${rates.length} entries)';
  }

  /// Deep equality helper for the [rates] map.
  static bool _mapsEqual(Map<String, double> a, Map<String, double> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
