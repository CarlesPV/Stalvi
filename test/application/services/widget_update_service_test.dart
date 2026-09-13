import 'dart:ui' show Locale;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/application/services/widget_update_service.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockProfileRepository extends Mock implements IProfileRepository {}

class MockExchangeRateRepository extends Mock
    implements IExchangeRateRepository {}

class MockHomeWidgetClient extends Mock implements HomeWidgetClient {}

class FakeTransactionQueryFilter extends Fake
    implements TransactionQueryFilter {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTransactionRepository mockTxRepo;
  late MockProfileRepository mockProfileRepo;
  late MockExchangeRateRepository mockExchangeRateRepo;
  late MockHomeWidgetClient mockHomeWidgetClient;
  late WidgetUpdateService service;
  late DateTime fixedNow;

  setUpAll(() {
    registerFallbackValue(FakeTransactionQueryFilter());
  });

  setUp(() {
    mockTxRepo = MockTransactionRepository();
    mockProfileRepo = MockProfileRepository();
    mockExchangeRateRepo = MockExchangeRateRepository();
    mockHomeWidgetClient = MockHomeWidgetClient();
    fixedNow = DateTime(2026, 9, 13, 12, 0, 0);

    when(
      () => mockHomeWidgetClient.saveWidgetData<String>(
        any(),
        any(),
        appGroupId: any(named: 'appGroupId'),
      ),
    ).thenAnswer((_) async => true);

    when(
      () => mockHomeWidgetClient.updateWidget(
        name: any(named: 'name'),
        androidName: any(named: 'androidName'),
        iOSName: any(named: 'iOSName'),
        qualifiedAndroidName: any(named: 'qualifiedAndroidName'),
      ),
    ).thenAnswer((_) async => true);

    service = WidgetUpdateService(
      transactionRepository: mockTxRepo,
      profileRepository: mockProfileRepo,
      exchangeRateRepository: mockExchangeRateRepo,
      homeWidgetClient: mockHomeWidgetClient,
      clock: () => fixedNow,
    );
  });

  Profile createProfile({String currency = 'EUR'}) {
    return Profile(
      id: 'p1',
      name: 'Test Profile',
      username: 'test',
      password: '',
      defaultCurrency: currency,
      createdAt: fixedNow,
      modifiedAt: fixedNow,
    );
  }

  Transaction createTx({
    required String id,
    required int amount,
    required TransactionType type,
    required DateTime date,
    String currency = 'EUR',
    String? snapshot,
  }) {
    return Transaction(
      id: id,
      amount: amount,
      date: date,
      type: type,
      accountId: 'acc1',
      originalCurrency: currency,
      exchangeRateSnapshot: snapshot,
      createdAt: date,
      modifiedAt: date,
    );
  }

  group('WidgetUpdateService.formatAmount', () {
    test('formats positive amounts with two decimals and appends symbol', () {
      expect(WidgetUpdateService.formatAmount(100.5, '€'), equals('100.50 €'));
      expect(WidgetUpdateService.formatAmount(0.0, r'$'), equals(r'0.00 $'));
      expect(
        WidgetUpdateService.formatAmount(1234.567, '£'),
        equals('1234.57 £'),
      );
    });
  });

  group('WidgetUpdateService.updateWidgetData', () {
    test(
        'calculates income and expenses for the last 30 days and updates widget',
        () async {
      when(() => mockProfileRepo.getFirstProfile())
          .thenAnswer((_) async => createProfile(currency: 'EUR'));

      final transactions = [
        createTx(
          id: '1',
          amount: 15050, // 150.50 EUR
          type: TransactionType.income,
          date: fixedNow.subtract(const Duration(days: 5)),
        ),
        createTx(
          id: '2',
          amount: 4500, // 45.00 EUR
          type: TransactionType.expense,
          date: fixedNow.subtract(const Duration(days: 10)),
        ),
        createTx(
          id: '3',
          amount: 2000, // 20.00 EUR
          type: TransactionType.expense,
          date: fixedNow.subtract(const Duration(days: 1)),
        ),
        createTx(
          id: '4',
          amount: 10000, // Transfer should be ignored
          type: TransactionType.transfer,
          date: fixedNow.subtract(const Duration(days: 2)),
        ),
      ];

      when(() => mockTxRepo.watchFilteredTransactions(any()))
          .thenAnswer((_) => Stream.value(transactions));
      when(() => mockExchangeRateRepo.getLocalRates(baseCurrency: 'EUR'))
          .thenAnswer((_) async => null);

      await service.updateWidgetData();

      // Total income: 150.50 EUR -> "150.50 €"
      // Total expenses: 65.00 EUR -> "65.00 €"
      verify(
        () => mockHomeWidgetClient.saveWidgetData<String>(
          WidgetUpdateService.incomeKey,
          '150.50 €',
          appGroupId: WidgetUpdateService.appGroupId,
        ),
      ).called(1);

      verify(
        () => mockHomeWidgetClient.saveWidgetData<String>(
          WidgetUpdateService.expenseKey,
          '65.00 €',
          appGroupId: WidgetUpdateService.appGroupId,
        ),
      ).called(1);

      verify(
        () => mockHomeWidgetClient.saveWidgetData<String>(
          WidgetUpdateService.incomeTitleKey,
          'Income',
          appGroupId: WidgetUpdateService.appGroupId,
        ),
      ).called(1);

      verify(
        () => mockHomeWidgetClient.saveWidgetData<String>(
          WidgetUpdateService.expenseTitleKey,
          'Expenses',
          appGroupId: WidgetUpdateService.appGroupId,
        ),
      ).called(1);

      verify(
        () => mockHomeWidgetClient.updateWidget(
          name: WidgetUpdateService.androidWidgetName,
          androidName: WidgetUpdateService.androidWidgetName,
          iOSName: WidgetUpdateService.iOSWidgetName,
        ),
      ).called(1);
    });

    test('pushes localized titles for Spanish (ES)', () async {
      when(() => mockProfileRepo.getFirstProfile())
          .thenAnswer((_) async => createProfile(currency: 'EUR'));
      when(() => mockTxRepo.watchFilteredTransactions(any()))
          .thenAnswer((_) => Stream.value([]));
      when(() => mockExchangeRateRepo.getLocalRates(baseCurrency: 'EUR'))
          .thenAnswer((_) async => null);

      await service.updateWidgetData(locale: const Locale('es'));

      verify(
        () => mockHomeWidgetClient.saveWidgetData<String>(
          WidgetUpdateService.incomeTitleKey,
          'Ingresos',
          appGroupId: WidgetUpdateService.appGroupId,
        ),
      ).called(1);

      verify(
        () => mockHomeWidgetClient.saveWidgetData<String>(
          WidgetUpdateService.expenseTitleKey,
          'Gastos',
          appGroupId: WidgetUpdateService.appGroupId,
        ),
      ).called(1);
    });

    test('pushes localized titles for Catalan (CA)', () async {
      when(() => mockProfileRepo.getFirstProfile())
          .thenAnswer((_) async => createProfile(currency: 'EUR'));
      when(() => mockTxRepo.watchFilteredTransactions(any()))
          .thenAnswer((_) => Stream.value([]));
      when(() => mockExchangeRateRepo.getLocalRates(baseCurrency: 'EUR'))
          .thenAnswer((_) async => null);

      await service.updateWidgetData(locale: const Locale('ca'));

      verify(
        () => mockHomeWidgetClient.saveWidgetData<String>(
          WidgetUpdateService.incomeTitleKey,
          'Ingressos',
          appGroupId: WidgetUpdateService.appGroupId,
        ),
      ).called(1);

      verify(
        () => mockHomeWidgetClient.saveWidgetData<String>(
          WidgetUpdateService.expenseTitleKey,
          'Despeses',
          appGroupId: WidgetUpdateService.appGroupId,
        ),
      ).called(1);
    });

    test('ignores transactions outside the 30-day window', () async {
      when(() => mockProfileRepo.getFirstProfile())
          .thenAnswer((_) async => createProfile(currency: 'EUR'));

      final transactions = [
        // Within 30 days
        createTx(
          id: '1',
          amount: 5000,
          type: TransactionType.income,
          date: fixedNow.subtract(const Duration(days: 15)),
        ),
        // Older than 30 days
        createTx(
          id: '2',
          amount: 99900,
          type: TransactionType.income,
          date: fixedNow.subtract(const Duration(days: 35)),
        ),
        // Future date beyond now
        createTx(
          id: '3',
          amount: 88800,
          type: TransactionType.expense,
          date: fixedNow.add(const Duration(days: 2)),
        ),
      ];

      when(() => mockTxRepo.watchFilteredTransactions(any()))
          .thenAnswer((_) => Stream.value(transactions));
      when(() => mockExchangeRateRepo.getLocalRates(baseCurrency: 'EUR'))
          .thenAnswer((_) async => null);

      await service.updateWidgetData();

      verify(
        () => mockHomeWidgetClient.saveWidgetData<String>(
          WidgetUpdateService.incomeKey,
          '50.00 €',
          appGroupId: WidgetUpdateService.appGroupId,
        ),
      ).called(1);

      verify(
        () => mockHomeWidgetClient.saveWidgetData<String>(
          WidgetUpdateService.expenseKey,
          '0.00 €',
          appGroupId: WidgetUpdateService.appGroupId,
        ),
      ).called(1);
    });

    test('formats with correct currency symbol for USD, GBP, JPY, and CNY',
        () async {
      final currencies = [
        ('USD', '\$'),
        ('GBP', '£'),
        ('JPY', '¥'),
        ('CNY', '¥'),
      ];

      for (final (currency, symbol) in currencies) {
        when(() => mockProfileRepo.getFirstProfile())
            .thenAnswer((_) async => createProfile(currency: currency));

        final transactions = [
          createTx(
            id: '1',
            amount: 2500, // 25.00
            type: TransactionType.income,
            date: fixedNow.subtract(const Duration(days: 2)),
            currency: currency,
          ),
          createTx(
            id: '2',
            amount: 1000, // 10.00
            type: TransactionType.expense,
            date: fixedNow.subtract(const Duration(days: 3)),
            currency: currency,
          ),
        ];

        when(() => mockTxRepo.watchFilteredTransactions(any()))
            .thenAnswer((_) => Stream.value(transactions));
        when(() => mockExchangeRateRepo.getLocalRates(baseCurrency: currency))
            .thenAnswer((_) async => null);

        await service.updateWidgetData();

        verify(
          () => mockHomeWidgetClient.saveWidgetData<String>(
            WidgetUpdateService.incomeKey,
            '25.00 $symbol',
            appGroupId: WidgetUpdateService.appGroupId,
          ),
        ).called(1);

        verify(
          () => mockHomeWidgetClient.saveWidgetData<String>(
            WidgetUpdateService.expenseKey,
            '10.00 $symbol',
            appGroupId: WidgetUpdateService.appGroupId,
          ),
        ).called(1);
      }
    });

    test('defaults to EUR when getFirstProfile returns null', () async {
      when(() => mockProfileRepo.getFirstProfile())
          .thenAnswer((_) async => null);
      when(() => mockTxRepo.watchFilteredTransactions(any()))
          .thenAnswer((_) => Stream.value([]));
      when(() => mockExchangeRateRepo.getLocalRates(baseCurrency: 'EUR'))
          .thenAnswer((_) async => null);

      await service.updateWidgetData();

      verify(
        () => mockHomeWidgetClient.saveWidgetData<String>(
          WidgetUpdateService.incomeKey,
          '0.00 €',
          appGroupId: WidgetUpdateService.appGroupId,
        ),
      ).called(1);

      verify(
        () => mockHomeWidgetClient.saveWidgetData<String>(
          WidgetUpdateService.expenseKey,
          '0.00 €',
          appGroupId: WidgetUpdateService.appGroupId,
        ),
      ).called(1);
    });

    test('converts multi-currency transactions using exchange rates', () async {
      when(() => mockProfileRepo.getFirstProfile())
          .thenAnswer((_) async => createProfile(currency: 'EUR'));

      final rates = ExchangeRate(
        baseCurrency: 'EUR',
        rates: {'USD': 1.10},
        date: fixedNow,
      );

      when(() => mockExchangeRateRepo.getLocalRates(baseCurrency: 'EUR'))
          .thenAnswer((_) async => rates);

      // 110.00 USD Income = 100.00 EUR (11000 cents / 1.10 = 10000 cents)
      final transactions = [
        createTx(
          id: '1',
          amount: 11000,
          type: TransactionType.income,
          date: fixedNow.subtract(const Duration(days: 3)),
          currency: 'USD',
        ),
      ];

      when(() => mockTxRepo.watchFilteredTransactions(any()))
          .thenAnswer((_) => Stream.value(transactions));

      await service.updateWidgetData();

      verify(
        () => mockHomeWidgetClient.saveWidgetData<String>(
          WidgetUpdateService.incomeKey,
          '100.00 €',
          appGroupId: WidgetUpdateService.appGroupId,
        ),
      ).called(1);
    });

    test('handles exchange rate repository failure gracefully', () async {
      when(() => mockProfileRepo.getFirstProfile())
          .thenAnswer((_) async => createProfile(currency: 'EUR'));

      when(() => mockExchangeRateRepo.getLocalRates(baseCurrency: 'EUR'))
          .thenThrow(Exception('Network error'));

      final transactions = [
        createTx(
          id: '1',
          amount: 3000,
          type: TransactionType.income,
          date: fixedNow.subtract(const Duration(days: 3)),
          currency: 'EUR',
        ),
      ];

      when(() => mockTxRepo.watchFilteredTransactions(any()))
          .thenAnswer((_) => Stream.value(transactions));

      await service.updateWidgetData();

      verify(
        () => mockHomeWidgetClient.saveWidgetData<String>(
          WidgetUpdateService.incomeKey,
          '30.00 €',
          appGroupId: WidgetUpdateService.appGroupId,
        ),
      ).called(1);
    });
  });

  group('widgetUpdateServiceProvider', () {
    test(
        'resolves WidgetUpdateService from ProviderContainer with overridden repos',
        () {
      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(mockTxRepo),
          profileRepositoryProvider.overrideWithValue(mockProfileRepo),
          exchangeRateRepositoryProvider
              .overrideWithValue(mockExchangeRateRepo),
        ],
      );
      addTearDown(container.dispose);

      final resolvedService = container.read(widgetUpdateServiceProvider);
      expect(resolvedService, isA<WidgetUpdateService>());
    });
  });

  group('DefaultHomeWidgetClient', () {
    test('invokes method channel methods saveWidgetData and updateWidget',
        () async {
      final methodCalls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('home_widget'),
              (call) async {
        methodCalls.add(call);
        return true;
      });

      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel('home_widget'), null);
      });

      const client = DefaultHomeWidgetClient();

      await client.saveWidgetData<String>(
        'test_key',
        '123.45',
        appGroupId: 'test.group',
      );
      await client.updateWidget(
        name: 'TestName',
        androidName: 'AndroidTest',
        iOSName: 'IOSTest',
      );

      expect(methodCalls.length, equals(2));
      expect(methodCalls[0].method, equals('saveWidgetData'));
      expect(
        methodCalls[0].arguments,
        equals(
          {
            'id': 'test_key',
            'data': '123.45',
            'appGroupId': 'test.group',
          },
        ),
      );

      expect(methodCalls[1].method, equals('updateWidget'));
      expect(
        methodCalls[1].arguments,
        equals(
          {
            'name': 'TestName',
            'android': 'AndroidTest',
            'ios': 'IOSTest',
            'qualifiedAndroidName': null,
          },
        ),
      );
    });
  });
}
