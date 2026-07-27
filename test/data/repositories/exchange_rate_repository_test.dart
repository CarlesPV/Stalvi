import 'dart:io';

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

  group('ExchangeRateRepository — getLatestRates & Offline Fallback', () {
    // -----------------------------------------------------------------------
    // Happy path & Local Cache
    // -----------------------------------------------------------------------
    test(
      'GIVEN local rates exist in DAO '
      'WHEN getLatestRates is called '
      'THEN returns the cached local rates without calling remote data source',
      () async {
        final cached = ExchangeRate(
          baseCurrency: 'EUR',
          date: DateTime.now(),
          rates: {'USD': 1.08, 'GBP': 0.85},
        );
        when(() => mockDao.getRates('EUR')).thenAnswer((_) async => cached);

        final result = await repository.getLatestRates(baseCurrency: 'EUR');

        expect(result, equals(cached));
        verifyNever(
          () => mockDataSource.fetchLatestRates(
            baseCurrency: any(named: 'baseCurrency'),
          ),
        );
      },
    );

    test(
      'GIVEN no local rates exist and remote data source returns valid model '
      'WHEN getLatestRates is called '
      'THEN fetches remote, saves to DAO, and returns mapped entity',
      () async {
        final model = _buildModel(
          base: 'EUR',
          date: DateTime(2026, 6, 13),
          rates: {'USD': 1.085, 'GBP': 0.856},
        );
        when(() => mockDao.getRates('EUR')).thenAnswer((_) async => null);
        when(
          () => mockDataSource.fetchLatestRates(baseCurrency: 'EUR'),
        ).thenAnswer((_) async => model);
        when(() => mockDao.saveRates(any())).thenAnswer((_) async {});

        final result = await repository.getLatestRates(baseCurrency: 'EUR');

        expect(result.baseCurrency, 'EUR');
        expect(result.rates['USD'], closeTo(1.085, 0.001));
        verify(() => mockDao.saveRates(any())).called(1);
      },
    );

    // -----------------------------------------------------------------------
    // Offline Fallback logic
    // -----------------------------------------------------------------------
    test(
      'GIVEN no local rates exist and remote data source throws NetworkException (NO_INTERNET) '
      'WHEN getLatestRates is called '
      'THEN gracefully returns infrastructure fallback rates and saves them to DAO',
      () async {
        when(() => mockDao.getRates('EUR')).thenAnswer((_) async => null);
        when(
          () => mockDataSource.fetchLatestRates(baseCurrency: 'EUR'),
        ).thenThrow(
          const NetworkException(
            message: 'No internet connection',
            code: 'NO_INTERNET',
          ),
        );
        when(() => mockDao.saveRates(any())).thenAnswer((_) async {});

        final result = await repository.getLatestRates(baseCurrency: 'EUR');

        expect(result.baseCurrency, 'EUR');
        expect(result.rates['USD'], equals(1.15));
        expect(result.rates['GBP'], equals(0.86));
        verify(() => mockDao.saveRates(any())).called(1);
      },
    );

    test(
      'GIVEN no local rates exist and remote data source throws SocketException '
      'WHEN getLatestRates is called '
      'THEN gracefully returns infrastructure fallback rates and saves them to DAO',
      () async {
        when(() => mockDao.getRates('USD')).thenAnswer((_) async => null);
        when(
          () => mockDataSource.fetchLatestRates(baseCurrency: 'USD'),
        ).thenThrow(const SocketException('Host lookup failed'));
        when(() => mockDao.saveRates(any())).thenAnswer((_) async {});

        final result = await repository.getLatestRates(baseCurrency: 'USD');

        expect(result.baseCurrency, 'USD');
        expect(result.rates['USD'], equals(1.0));
        expect(result.rates['EUR'], closeTo(0.8695, 0.001));
        verify(() => mockDao.saveRates(any())).called(1);
      },
    );

    test(
      'GIVEN getLocalRates is called when DAO returns null '
      'WHEN getLocalRates is invoked '
      'THEN returns fallback exchange rates for requested base currency',
      () async {
        when(() => mockDao.getRates('GBP')).thenAnswer((_) async => null);

        final result = await repository.getLocalRates(baseCurrency: 'GBP');

        expect(result, isNotNull);
        expect(result!.baseCurrency, 'GBP');
        expect(result.rates['EUR'], closeTo(1.1627, 0.01));
      },
    );

    test(
      'GIVEN syncRates encounters network exception and DAO is empty '
      'WHEN syncRates is called '
      'THEN populates DAO with infrastructure fallback rates before rethrowing exception',
      () async {
        when(
          () => mockDataSource.fetchLatestRates(baseCurrency: 'EUR'),
        ).thenThrow(
          const NetworkException(message: 'Offline', code: 'NO_INTERNET'),
        );
        when(() => mockDao.getRates('EUR')).thenAnswer((_) async => null);
        when(() => mockDao.saveRates(any())).thenAnswer((_) async {});

        await expectLater(
          repository.syncRates(baseCurrency: 'EUR'),
          throwsA(isA<NetworkException>()),
        );

        verify(() => mockDao.saveRates(any())).called(1);
      },
    );
  });
}
