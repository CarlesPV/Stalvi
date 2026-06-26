import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/data/database/daos/exchange_rate_dao.dart';
import 'package:stalvi/data/models/exchange_rate_model.dart';
import 'package:stalvi/data/network/exchange_rate_remote_data_source.dart';
import 'package:stalvi/data/repositories/exchange_rate_repository.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockExchangeRateRemoteDataSource extends Mock
    implements IExchangeRateRemoteDataSource {}

class MockExchangeRateDao extends Mock implements ExchangeRateDao {}

class FakeExchangeRate extends Fake implements ExchangeRate {}

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
  late MockExchangeRateDao mockDao;
  late ExchangeRateRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeExchangeRate());
  });

  setUp(() {
    mockDataSource = MockExchangeRateRemoteDataSource();
    mockDao = MockExchangeRateDao();
    repository = ExchangeRateRepository(
      remoteDataSource: mockDataSource,
      exchangeRateDao: mockDao,
    );
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
        when(() => mockDao.saveRates(any())).thenAnswer((_) async {});
        when(() => mockDao.getRates(any())).thenAnswer((_) async => null);

        // Act
        final result = await repository.getLatestRates(baseCurrency: 'EUR');

        // Assert
        expect(result, isA<ExchangeRate>());
        expect(result.baseCurrency, 'EUR');
        expect(
          result.date.difference(DateTime.now()).inSeconds.abs() < 5,
          true,
        );
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
        when(() => mockDao.saveRates(any())).thenAnswer((_) async {});
        when(() => mockDao.getRates(any())).thenAnswer((_) async => null);

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
        when(() => mockDao.getRates(any())).thenAnswer((_) async => null);

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
        when(() => mockDao.getRates(any())).thenAnswer((_) async => null);

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
        when(() => mockDao.getRates(any())).thenAnswer((_) async => null);

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
