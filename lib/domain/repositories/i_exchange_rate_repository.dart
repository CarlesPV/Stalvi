import '../entities/exchange_rate.dart';

/// Domain-layer contract for fetching exchange rate data.
///
/// Implementations live in the data layer and may source rates from a
/// remote API, a local cache, or both. The domain layer depends only on
/// this abstraction — never on concrete HTTP or database clients.
abstract class IExchangeRateRepository {
  /// Fetches the latest exchange rates relative to [baseCurrency].
  ///
  /// [baseCurrency] must be a valid ISO 4217 currency code (e.g., "EUR").
  ///
  /// Throws an [AppException] subclass on failure:
  /// - [NetworkException] if the remote source is unreachable or returns
  ///   an unexpected response.
  /// - [ValidationException] if [baseCurrency] is empty or invalid.
  Future<ExchangeRate> getLatestRates({required String baseCurrency});

  /// Fetches the exchange rates from the local database if available.
  Future<ExchangeRate?> getLocalRates({required String baseCurrency});

  /// Fetches the latest rates from remote and saves them to the local database.
  Future<void> syncRates({required String baseCurrency});
}
