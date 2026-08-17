import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/data/models/exchange_rate_model.dart';
import 'package:stalvi/data/network/exchange_rate_remote_data_source.dart';

// ---------------------------------------------------------------------------
// Mocktail fakes & mocks
// ---------------------------------------------------------------------------

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

const _validJsonBody = '''
{
  "amount": 1.0,
  "base": "EUR",
  "date": "2026-06-13",
  "rates": {
    "USD": 1.085,
    "GBP": 0.856,
    "JPY": 163.42
  }
}
''';

http.Response _response(String body, int statusCode) =>
    http.Response(body, statusCode);

void main() {
  late MockHttpClient mockHttpClient;
  late ExchangeRateRemoteDataSourceImpl dataSource;

  setUpAll(() {
    // Required by mocktail for any call that uses a Uri argument.
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = ExchangeRateRemoteDataSourceImpl(httpClient: mockHttpClient);
  });

  // Helper: stubs the HTTP GET to return the given response.
  void whenGet(http.Response response) {
    when(() => mockHttpClient.get(any())).thenAnswer((_) async => response);
  }

  // Helper: stubs the HTTP GET to throw the given exception.
  void whenGetThrows(Object exception) {
    when(() => mockHttpClient.get(any())).thenThrow(exception);
  }

  group('ExchangeRateRemoteDataSourceImpl — fetchLatestRates', () {
    // -----------------------------------------------------------------------
    // Happy path
    // -----------------------------------------------------------------------
    test(
        'GIVEN a 200 response with valid JSON '
        'WHEN fetchLatestRates is called '
        'THEN returns a correctly parsed ExchangeRateModel', () async {
      // Arrange
      whenGet(_response(_validJsonBody, 200));

      // Act
      final result = await dataSource.fetchLatestRates(baseCurrency: 'EUR');

      // Assert
      expect(result, isA<ExchangeRateModel>());
      expect(result.base, 'EUR');
      expect(result.date, DateTime(2026, 6, 13));
      expect(result.rates['USD'], closeTo(1.085, 0.001));
      expect(result.rates['GBP'], closeTo(0.856, 0.001));
      expect(result.rates['JPY'], closeTo(163.42, 0.001));
      expect(result.amount, 1.0);

      // Verify exactly one GET was made.
      verify(() => mockHttpClient.get(any())).called(1);
    });

    // -----------------------------------------------------------------------
    // 4xx client error
    // -----------------------------------------------------------------------
    test(
        'GIVEN a 404 response '
        'WHEN fetchLatestRates is called '
        'THEN throws NetworkException with code HTTP_4XX', () async {
      // Arrange
      whenGet(_response('{"message":"Not Found"}', 404));

      // Act & Assert
      final call = dataSource.fetchLatestRates(baseCurrency: 'XYZ');

      await expectLater(
        call,
        throwsA(
          isA<NetworkException>().having((e) => e.code, 'code', 'HTTP_4XX'),
        ),
      );
    });

    test(
        'GIVEN a 400 response '
        'WHEN fetchLatestRates is called '
        'THEN throws NetworkException with code HTTP_4XX', () async {
      // Arrange
      whenGet(_response('{"message":"Bad Request"}', 400));

      // Act & Assert
      await expectLater(
        dataSource.fetchLatestRates(baseCurrency: ''),
        throwsA(
          isA<NetworkException>().having((e) => e.code, 'code', 'HTTP_4XX'),
        ),
      );
    });

    // -----------------------------------------------------------------------
    // 5xx server error
    // -----------------------------------------------------------------------
    test(
        'GIVEN a 500 response '
        'WHEN fetchLatestRates is called '
        'THEN throws NetworkException with code HTTP_5XX', () async {
      // Arrange
      whenGet(_response('Internal Server Error', 500));

      // Act & Assert
      await expectLater(
        dataSource.fetchLatestRates(baseCurrency: 'EUR'),
        throwsA(
          isA<NetworkException>().having((e) => e.code, 'code', 'HTTP_5XX'),
        ),
      );
    });

    test(
        'GIVEN a 503 response '
        'WHEN fetchLatestRates is called '
        'THEN throws NetworkException with code HTTP_5XX', () async {
      // Arrange
      whenGet(_response('Service Unavailable', 503));

      // Act & Assert
      await expectLater(
        dataSource.fetchLatestRates(baseCurrency: 'EUR'),
        throwsA(
          isA<NetworkException>().having((e) => e.code, 'code', 'HTTP_5XX'),
        ),
      );
    });

    // -----------------------------------------------------------------------
    // Network connectivity failure
    // -----------------------------------------------------------------------
    test(
        'GIVEN a SocketException is thrown '
        'WHEN fetchLatestRates is called '
        'THEN throws NetworkException with code NO_INTERNET', () async {
      // Arrange
      whenGetThrows(
        const SocketException('Failed host lookup: api.frankfurter.app'),
      );

      // Act & Assert
      await expectLater(
        dataSource.fetchLatestRates(baseCurrency: 'EUR'),
        throwsA(
          isA<NetworkException>()
              .having((e) => e.code, 'code', 'NO_INTERNET')
              .having(
                (e) => e.message,
                'message',
                contains('internet connection'),
              ),
        ),
      );
    });

    test(
        'GIVEN an http.ClientException is thrown '
        'WHEN fetchLatestRates is called '
        'THEN throws NetworkException with code NO_INTERNET', () async {
      // Arrange
      whenGetThrows(http.ClientException('Connection reset by peer'));

      // Act & Assert
      await expectLater(
        dataSource.fetchLatestRates(baseCurrency: 'EUR'),
        throwsA(
          isA<NetworkException>().having((e) => e.code, 'code', 'NO_INTERNET'),
        ),
      );
    });

    // -----------------------------------------------------------------------
    // Parse / deserialization failures
    // -----------------------------------------------------------------------
    test(
        'GIVEN a 200 response with malformed JSON '
        'WHEN fetchLatestRates is called '
        'THEN throws NetworkException with code PARSE_ERROR', () async {
      // Arrange
      whenGet(_response('this is not json {{{', 200));

      // Act & Assert
      await expectLater(
        dataSource.fetchLatestRates(baseCurrency: 'EUR'),
        throwsA(
          isA<NetworkException>().having((e) => e.code, 'code', 'PARSE_ERROR'),
        ),
      );
    });

    test(
        'GIVEN a 200 response with wrong JSON structure (missing "rates" key) '
        'WHEN fetchLatestRates is called '
        'THEN throws NetworkException with code PARSE_ERROR', () async {
      // Arrange
      final badJson = jsonEncode({'amount': 1.0, 'base': 'EUR'});
      whenGet(_response(badJson, 200));

      // Act & Assert
      await expectLater(
        dataSource.fetchLatestRates(baseCurrency: 'EUR'),
        throwsA(
          isA<NetworkException>().having((e) => e.code, 'code', 'PARSE_ERROR'),
        ),
      );
    });
  });
}
