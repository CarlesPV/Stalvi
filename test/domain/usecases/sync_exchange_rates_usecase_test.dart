import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:stalvi/domain/usecases/sync_exchange_rates_usecase.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';
import 'package:stalvi/core/utils/currency_converter.dart';

@GenerateNiceMocks([MockSpec<IExchangeRateRepository>()])
import 'sync_exchange_rates_usecase_test.mocks.dart';

void main() {
  late SyncExchangeRatesUseCase usecase;
  late MockIExchangeRateRepository mockRepository;

  setUp(() {
    mockRepository = MockIExchangeRateRepository();
    usecase = SyncExchangeRatesUseCase(mockRepository);
  });

  group('SyncExchangeRatesUseCase', () {
    test('should sync when local rates do not exist', () async {
      when(
        mockRepository.getLocalRates(baseCurrency: 'EUR'),
      ).thenAnswer((_) async => null);

      await usecase.execute(baseCurrency: 'EUR');

      verify(mockRepository.syncRates(baseCurrency: 'EUR')).called(1);
    });

    test('should sync when local rates are older than 24 hours', () async {
      final oldDate = DateTime.now().subtract(const Duration(hours: 25));
      final oldRates = ExchangeRate(
        baseCurrency: 'EUR',
        date: oldDate,
        rates: {},
      );
      when(
        mockRepository.getLocalRates(baseCurrency: 'EUR'),
      ).thenAnswer((_) async => oldRates);

      await usecase.execute(baseCurrency: 'EUR');

      verify(mockRepository.syncRates(baseCurrency: 'EUR')).called(1);
    });

    test(
      'should not sync when local rates are younger than 24 hours',
      () async {
        final recentDate = DateTime.now().subtract(const Duration(hours: 23));
        final recentRates = ExchangeRate(
          baseCurrency: 'EUR',
          date: recentDate,
          rates: {},
        );
        when(
          mockRepository.getLocalRates(baseCurrency: 'EUR'),
        ).thenAnswer((_) async => recentRates);

        await usecase.execute(baseCurrency: 'EUR');

        verifyNever(mockRepository.syncRates(baseCurrency: 'EUR'));
      },
    );

    test('strict 8-currency limit check', () {
      const supportedCurrencies = CurrencyConverter.supportedCurrencies;
      expect(supportedCurrencies.length, 8);
      expect(supportedCurrencies.contains('EUR'), isTrue);
      expect(supportedCurrencies.contains('USD'), isTrue);
      expect(supportedCurrencies.contains('GBP'), isTrue);
      expect(supportedCurrencies.contains('JPY'), isTrue);
      expect(supportedCurrencies.contains('CHF'), isTrue);
      expect(supportedCurrencies.contains('CAD'), isTrue);
      expect(supportedCurrencies.contains('AUD'), isTrue);
      expect(supportedCurrencies.contains('CNY'), isTrue);
    });
  });
}
