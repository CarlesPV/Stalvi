import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/data/models/exchange_rate_model.dart';

// ---------------------------------------------------------------------------
// Abstract interface
// ---------------------------------------------------------------------------

/// Data-layer contract for the remote exchange rate data source.
///
/// Declared as an abstract class so it can be mocked in unit tests without
/// any framework-specific tooling.
abstract class IExchangeRateRemoteDataSource {
  /// Fetches the latest exchange rates relative to [baseCurrency] from the
  /// remote Frankfurter API.
  ///
  /// Returns an [ExchangeRateModel] on success.
  /// Throws a [NetworkException] on any failure.
  Future<ExchangeRateModel> fetchLatestRates({required String baseCurrency});
}

// ---------------------------------------------------------------------------
// Concrete implementation
// ---------------------------------------------------------------------------

/// Concrete implementation of [IExchangeRateRemoteDataSource] backed by the
/// [Frankfurter](https://www.frankfurter.app/) public exchange rate API.
///
/// **Privacy guarantee:** The only data transmitted to the remote server is
/// the [baseCurrency] ISO 4217 code (a public configuration value, not user
/// data). No personal information ever leaves the device.
///
/// **Security constraint:** All requests are made over HTTPS. An assertion
/// guards against accidental HTTP usage at construction time.
class ExchangeRateRemoteDataSourceImpl implements IExchangeRateRemoteDataSource {
  /// The injected HTTP client. Injecting it enables deterministic unit tests
  /// without any real network calls.
  final http.Client _httpClient;

  /// Base URI of the Frankfurter API. MUST use the `https` scheme.
  static const String _baseUrl = 'https://api.frankfurter.app';

  ExchangeRateRemoteDataSourceImpl({required http.Client httpClient})
      : _httpClient = httpClient {
    // Guard: ensure the configured base URL is strictly HTTPS.
    assert(
      _baseUrl.startsWith('https://'),
      'ExchangeRateRemoteDataSourceImpl requires a strict HTTPS base URL.',
    );
  }

  @override
  Future<ExchangeRateModel> fetchLatestRates({
    required String baseCurrency,
  }) async {
    final uri = Uri.parse('$_baseUrl/latest').replace(
      queryParameters: {'from': baseCurrency},
    );

    // Redundant runtime guard — catches any accidental URI manipulation.
    if (uri.scheme != 'https') {
      throw const NetworkException(
        message: 'Only HTTPS requests are permitted.',
        code: 'INSECURE_SCHEME',
      );
    }

    try {
      final response = await _httpClient.get(uri);

      final statusCode = response.statusCode;

      if (statusCode == 200) {
        // Happy path: parse the JSON body.
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          return ExchangeRateModel.fromJson(json);
        } on FormatException catch (e) {
          throw NetworkException(
            message: 'Failed to parse exchange rate response.',
            code: 'PARSE_ERROR',
            details: e.message,
          );
        } on TypeError catch (e) {
          throw NetworkException(
            message: 'Unexpected JSON structure in exchange rate response.',
            code: 'PARSE_ERROR',
            details: e.toString(),
          );
        }
      } else if (statusCode >= 400 && statusCode < 500) {
        throw NetworkException(
          message: 'Exchange rate API returned a client error.',
          code: 'HTTP_4XX',
          details: 'HTTP $statusCode: ${response.body}',
        );
      } else {
        // Covers 5xx and any other non-200 status.
        throw NetworkException(
          message: 'Exchange rate API returned a server error.',
          code: 'HTTP_5XX',
          details: 'HTTP $statusCode: ${response.body}',
        );
      }
    } on NetworkException {
      // Re-throw our own typed exceptions without wrapping them again.
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException(
        message: 'No internet connection or host unreachable.',
        code: 'NO_INTERNET',
        details: e.message,
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        message: 'HTTP client error while fetching exchange rates.',
        code: 'NO_INTERNET',
        details: e.message,
      );
    }
  }
}
