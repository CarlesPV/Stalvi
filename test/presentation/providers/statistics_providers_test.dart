import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:stalvi/presentation/providers/statistics_providers.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  test(
    'statisticsCurrencyProvider returns profile default currency when accountId is null',
    () async {
      final container = ProviderContainer(
        overrides: [
          defaultProfileProvider.overrideWith(
            (ref) => Future.value(
              Profile(
                id: 'p1',
                name: 'Test',
                username: 'test',
                password: '',
                defaultCurrency: 'GBP',
                createdAt: DateTime.now(),
                modifiedAt: DateTime.now(),
              ),
            ),
          ),
        ],
      );

      // Wait for the async provider to resolve
      await container.read(defaultProfileProvider.future);

      final currency = container.read(statisticsCurrencyProvider);
      expect(currency, 'GBP');
    },
  );

  test(
    'statisticsCurrencyProvider returns account currency when accountId is not null',
    () async {
      final account = Account(
        id: 'acc1',
        userId: 'p1',
        name: 'Account',
        type: AccountType.cash,
        initialBalance: 0,
        currency: 'USD',
        color: 'blue',
        icon: 'icon',
        isDefault: true,
        isDeleted: false,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          accountsListProvider.overrideWith((ref) => Stream.value([account])),
        ],
      );

      // Set the accountId in the filter
      container.read(statisticsFilterProvider.notifier).setAccountId('acc1');

      final sub = container.listen(accountsListProvider, (_, __) {});
      // Wait for the accounts provider to resolve
      await container.read(accountsListProvider.future);

      final currency = container.read(statisticsCurrencyProvider);
      expect(currency, 'USD');
      sub.close();
    },
  );

  test(
    'globalBalanceProvider calculates sum of account initial balances with currency conversion',
    () async {
      final profile = Profile(
        id: 'p1',
        name: 'Test',
        username: 'test',
        password: '',
        defaultCurrency: 'EUR',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      final accounts = [
        Account(
          id: 'acc1',
          userId: 'p1',
          name: 'Account 1',
          type: AccountType.cash,
          initialBalance: 100, // 100 EUR = 100 EUR
          currency: 'EUR',
          color: 'blue',
          icon: 'icon',
          isDefault: true,
          isDeleted: false,
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        ),
        Account(
          id: 'acc2',
          userId: 'p1',
          name: 'Account 2',
          type: AccountType.cash,
          initialBalance: 200, // 200 USD -> 200 / 1.1 = 181.81 EUR
          currency: 'USD',
          color: 'red',
          icon: 'icon',
          isDefault: false,
          isDeleted: false,
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        ),
      ];

      final mockExchangeRateRepo = MockExchangeRateRepository();
      when(
        () => mockExchangeRateRepo.getLocalRates(baseCurrency: 'EUR'),
      ).thenAnswer(
        (_) async => ExchangeRate(
          baseCurrency: 'EUR',
          date: DateTime.now(),
          rates: {'USD': 1.1},
        ),
      );

      final container = ProviderContainer(
        overrides: [
          defaultProfileProvider.overrideWith((ref) => Future.value(profile)),
          accountsListProvider.overrideWith((ref) => Stream.value(accounts)),
          exchangeRateRepositoryProvider.overrideWithValue(
            mockExchangeRateRepo,
          ),
          accountBalanceProvider.overrideWith((ref, accountId) {
            if (accountId == 'acc1') return const AsyncData(100.0);
            if (accountId == 'acc2') return const AsyncData(200.0);
            return const AsyncData(0.0);
          }),
        ],
      );

      final sub = container.listen(globalBalanceProvider, (_, __) {});

      // Wait for the streams to emit
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(globalBalanceProvider);
      expect(state, isA<AsyncData<double>>());
      expect(state.value, closeTo(100 + (200 / 1.1), 0.01));

      sub.close();
    },
  );

  test(
    'dashboardPeriodSummaryProvider calculates correct period summary in default currency across multiple accounts and currencies',
    () async {
      final profile = Profile(
        id: 'p1',
        name: 'Test',
        username: 'test',
        password: '',
        defaultCurrency: 'EUR',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      final transactions = [
        Transaction(
          id: 'tx1',
          amount: 10000, // 100 USD Income
          date: DateTime.now(),
          type: TransactionType.income,
          accountId: 'acc1',
          originalCurrency: 'USD',
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        ),
        Transaction(
          id: 'tx2',
          amount: 5000, // 50 EUR Expense
          date: DateTime.now(),
          type: TransactionType.expense,
          accountId: 'acc2',
          originalCurrency: 'EUR',
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        ),
      ];

      final mockExchangeRateRepo = MockExchangeRateRepository();
      when(
        () => mockExchangeRateRepo.getLocalRates(baseCurrency: 'EUR'),
      ).thenAnswer(
        (_) async => ExchangeRate(
          baseCurrency: 'EUR',
          date: DateTime.now(),
          rates: {'USD': 1.1},
        ),
      );

      final container = ProviderContainer(
        overrides: [
          defaultProfileProvider.overrideWith((ref) => Future.value(profile)),
          rawTransactionsStreamProvider.overrideWith(
            (ref) => Stream.value(transactions),
          ),
          exchangeRateRepositoryProvider.overrideWithValue(
            mockExchangeRateRepo,
          ),
        ],
      );

      final sub = container.listen(dashboardPeriodSummaryProvider, (_, __) {});

      // Wait for the streams to emit
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(dashboardPeriodSummaryProvider);
      expect(state, isA<AsyncData<PeriodSummary>>());

      // 100 USD = 100 / 1.1 = 90.909 EUR => (90.909 * 100).round() = 9091 cents
      expect(state.value?.totalIncome, 9091);
      // 50 EUR = 50 EUR => 5000 cents
      expect(state.value?.totalExpense, 5000);

      sub.close();
    },
  );

  group('periodSummaryProvider transfer tests', () {
    final now = DateTime.now();
    final transactions = [
      Transaction(
        id: 'tx_salary',
        amount: 60000, // 600 EUR Income in Account A
        date: now,
        type: TransactionType.income,
        accountId: 'acc_A',
        originalCurrency: 'EUR',
        createdAt: now,
        modifiedAt: now,
      ),
      Transaction(
        id: 'tx_transfer_1',
        amount: 20000, // 200 EUR Transfer Out from Account A
        date: now,
        type: TransactionType.transfer,
        accountId: 'acc_A',
        originalCurrency: 'EUR',
        createdAt: now,
        modifiedAt: now,
        transferId: 'tr_1',
      ),
      Transaction(
        id: 'tx_transfer_1_dst',
        amount: 20000, // 200 EUR Transfer In to Account B
        date: now,
        type: TransactionType.transfer,
        accountId: 'acc_B',
        originalCurrency: 'EUR',
        createdAt: now,
        modifiedAt: now,
        transferId: 'tr_1',
      ),
      Transaction(
        id: 'tx_expense_a',
        amount: 10000, // 100 EUR Expense in Account A
        date: now,
        type: TransactionType.expense,
        accountId: 'acc_A',
        originalCurrency: 'EUR',
        createdAt: now,
        modifiedAt: now,
      ),
      Transaction(
        id: 'tx_expense_b',
        amount: 15000, // 150 EUR Expense in Account B
        date: now,
        type: TransactionType.expense,
        accountId: 'acc_B',
        originalCurrency: 'EUR',
        createdAt: now,
        modifiedAt: now,
      ),
    ];

    test('calculates correct summary for Destination Account B', () async {
      final container = ProviderContainer(
        overrides: [
          rawTransactionsStreamProvider.overrideWith(
            (ref) => Stream.value(transactions),
          ),
          latestExchangeRatesProvider('EUR').overrideWith(
            (ref) => Future.value(null),
          ),
        ],
      );

      container.read(statisticsFilterProvider.notifier).setAccountId('acc_B');

      final sub = container.listen(periodSummaryProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(periodSummaryProvider);
      expect(state, isA<AsyncData<PeriodSummary>>());

      final summary = state.value!;
      expect(summary.totalIncome, 0); // No income in B
      expect(summary.totalExpense, 15000); // 150 EUR in B
      expect(summary.totalTransfersIn, 20000); // 200 EUR received in B
      expect(summary.totalTransfersOut, 0);

      sub.close();
    });

    test('calculates correct summary for Origin Account A', () async {
      final container = ProviderContainer(
        overrides: [
          rawTransactionsStreamProvider.overrideWith(
            (ref) => Stream.value(transactions),
          ),
          latestExchangeRatesProvider('EUR').overrideWith(
            (ref) => Future.value(null),
          ),
        ],
      );

      container.read(statisticsFilterProvider.notifier).setAccountId('acc_A');

      final sub = container.listen(periodSummaryProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(periodSummaryProvider);
      expect(state, isA<AsyncData<PeriodSummary>>());

      final summary = state.value!;
      expect(summary.totalIncome, 60000); // 600 EUR salary in A
      expect(summary.totalExpense, 10000); // 100 EUR in A
      expect(summary.totalTransfersIn, 0);
      expect(
        summary.totalTransfersOut,
        20000,
      ); // 200 EUR transferred out from A

      sub.close();
    });

    test('calculates correct summary for All Accounts (Global view)', () async {
      final container = ProviderContainer(
        overrides: [
          rawTransactionsStreamProvider.overrideWith(
            (ref) => Stream.value(transactions),
          ),
          latestExchangeRatesProvider('EUR').overrideWith(
            (ref) => Future.value(null),
          ),
        ],
      );

      final sub = container.listen(periodSummaryProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(periodSummaryProvider);
      expect(state, isA<AsyncData<PeriodSummary>>());

      final summary = state.value!;
      expect(summary.totalIncome, 60000);
      expect(summary.totalExpense, 25000);
      expect(summary.totalTransfersIn, 20000);
      expect(summary.totalTransfersOut, 20000);

      sub.close();
    });
  });
}

class MockExchangeRateRepository extends Mock
    implements IExchangeRateRepository {}
