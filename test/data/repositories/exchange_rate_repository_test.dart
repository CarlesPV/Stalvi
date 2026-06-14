import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/data/models/exchange_rate_model.dart';
import 'package:konta/data/network/exchange_rate_remote_data_source.dart';
import 'package:konta/data/repositories/exchange_rate_repository.dart';
import 'package:konta/domain/entities/exchange_rate.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockExchangeRateRemoteDataSource extends Mock
    implements IExchangeRateRemoteDataSource {}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

ExchangeRateModel _buildModel({
  String base = 'EUR',
  DateTime? date,
  Map<String, double> rates = const {'USD': 1.085, 'GBP': 0.856},
}) {
  return ExchangeRateModel(
    amount: 1.0,
    base: base,
    date: date ?? DateTime(2026, 6, 13),
    rates: rates,
  );
}

void main() {
  late MockExchangeRateRemoteDataSource mockDataSource;
  late ExchangeRateRepository repository;

  setUp(() {
    mockDataSource = MockExchangeRateRemoteDataSource();
    repository = ExchangeRateRepository(remoteDataSource: mockDataSource);
  });

  group('ExchangeRateRepository — getLatestRates', () {
    // -----------------------------------------------------------------------
    // Happy path
    // -----------------------------------------------------------------------
    test(
      'GIVEN the data source returns a valid ExchangeRateModel '
      'WHEN getLatestRates is called with baseCurrency "EUR" '
      'THEN returns the correctly mapped ExchangeRate domain entity',
      () async {
        // Arrange
        final model = _buildModel(
          base: 'EUR',
          date: DateTime(2026, 6, 13),
          rates: {'USD': 1.085, 'GBP': 0.856},
        );
        when(
          () => mockDataSource.fetchLatestRates(baseCurrency: 'EUR'),
        ).thenAnswer((_) async => model);

        // Act
        final result = await repository.getLatestRates(baseCurrency: 'EUR');

        // Assert
        expect(result, isA<ExchangeRate>());
        expect(result.baseCurrency, 'EUR');
        expect(result.date, DateTime(2026, 6, 13));
        expect(result.rates['USD'], closeTo(1.085, 0.001));
        expect(result.rates['GBP'], closeTo(0.856, 0.001));

        verify(
          () => mockDataSource.fetchLatestRates(baseCurrency: 'EUR'),
        ).called(1);
      },
    );

    test(
      'GIVEN the data source returns a model with multiple currencies '
      'WHEN getLatestRates is called '
      'THEN the resulting ExchangeRate.rateFor helper resolves correctly',
      () async {
        // Arrange
        final model = _buildModel(
          base: 'USD',
          rates: {'EUR': 0.921, 'JPY': 150.32, 'GBP': 0.788},
        );
        when(
          () => mockDataSource.fetchLatestRates(baseCurrency: 'USD'),
        ).thenAnswer((_) async => model);

        // Act
        final result = await repository.getLatestRates(baseCurrency: 'USD');

        // Assert
        expect(result.baseCurrency, 'USD');
        expect(result.rateFor('EUR'), closeTo(0.921, 0.001));
        expect(result.rateFor('JPY'), closeTo(150.32, 0.01));
        expect(result.rateFor('XXX'), isNull); // Unknown currency → null
      },
    );

    // -----------------------------------------------------------------------
    // Error propagation
    // -----------------------------------------------------------------------
    test(
      'GIVEN the data source throws a NetworkException '
      'WHEN getLatestRates is called '
      'THEN the repository propagates the same NetworkException unchanged',
      () async {
        // Arrange
        const expectedException = NetworkException(
          message: 'No internet connection or host unreachable.',
          code: 'NO_INTERNET',
        );
        when(
          () => mockDataSource.fetchLatestRates(baseCurrency: 'EUR'),
        ).thenThrow(expectedException);

        // Act & Assert
        await expectLater(
          repository.getLatestRates(baseCurrency: 'EUR'),
          throwsA(
            isA<NetworkException>()
                .having((e) => e.code, 'code', 'NO_INTERNET')
                .having(
                  (e) => e.message,
                  'message',
                  'No internet connection or host unreachable.',
                ),
          ),
        );
      },
    );

    test(
      'GIVEN the data source throws a NetworkException with code HTTP_4XX '
      'WHEN getLatestRates is called '
      'THEN the repository propagates it without wrapping or swallowing',
      () async {
        // Arrange
        const exception = NetworkException(
          message: 'Exchange rate API returned a client error.',
          code: 'HTTP_4XX',
          details: 'HTTP 404: Not Found',
        );
        when(
          () => mockDataSource.fetchLatestRates(baseCurrency: 'XYZ'),
        ).thenThrow(exception);

        // Act & Assert
        await expectLater(
          repository.getLatestRates(baseCurrency: 'XYZ'),
          throwsA(
            isA<NetworkException>()
                .having((e) => e.code, 'code', 'HTTP_4XX')
                .having((e) => e.details, 'details', 'HTTP 404: Not Found'),
          ),
        );
      },
    );

    test(
      'GIVEN the data source throws a NetworkException with code PARSE_ERROR '
      'WHEN getLatestRates is called '
      'THEN the repository propagates it with all fields intact',
      () async {
        // Arrange
        const exception = NetworkException(
          message: 'Failed to parse exchange rate response.',
          code: 'PARSE_ERROR',
        );
        when(
          () => mockDataSource.fetchLatestRates(baseCurrency: 'EUR'),
        ).thenThrow(exception);

        // Act & Assert
        await expectLater(
          repository.getLatestRates(baseCurrency: 'EUR'),
          throwsA(
            isA<NetworkException>()
                .having((e) => e.code, 'code', 'PARSE_ERROR'),
          ),
        );
      },
    );
  });
}
