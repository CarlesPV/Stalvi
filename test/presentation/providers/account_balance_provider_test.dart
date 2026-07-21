import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';

void main() {
  group('accountBalanceProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    final now = DateTime.now();

    final testAccount = Account(
      id: 'acc1',
      userId: 'user1',
      name: 'Test Account',
      type: AccountType.bank,
      initialBalance: 100.0,
      currency: 'EUR',
      color: '#000000',
      icon: 'icon',
      isDefault: true,
      isDeleted: false,
      createdAt: now,
      modifiedAt: now,
    );

    test('calculates correct balance without currency conversion', () async {
      final transactions = [
        Transaction(
          id: 'tx1',
          amount: 5000, // 50 EUR
          date: now,
          type: TransactionType.income,
          accountId: 'acc1',
          categoryId: 'cat1',
          originalCurrency: 'EUR',
          createdAt: now,
          modifiedAt: now,
        ),
        Transaction(
          id: 'tx2',
          amount: 2000, // 20 EUR
          date: now,
          type: TransactionType.expense,
          accountId: 'acc1',
          categoryId: 'cat2',
          originalCurrency: 'EUR',
          createdAt: now,
          modifiedAt: now,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          accountsListProvider
              .overrideWith((ref) => Stream.value([testAccount])),
          rawTransactionsStreamProvider
              .overrideWith((ref) => Stream.value(transactions)),
        ],
      );

      final subscription =
          container.listen(accountBalanceProvider('acc1'), (_, __) {});

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result = container.read(accountBalanceProvider('acc1'));

      expect(result.value, equals(100.0 + 50.0 - 20.0)); // 130.0

      subscription.close();
    });

    test('calculates correct balance with currency conversion', () async {
      // Rates: EUR = 1.0 (base), USD = 1.10
      final exchangeRates = {
        'EUR': 1.0,
        'USD': 1.10,
      };
      final ratesJson = jsonEncode(exchangeRates);

      final transactions = [
        Transaction(
          id: 'tx1',
          amount: 11000, // 110 USD -> 100 EUR
          date: now,
          type: TransactionType.income,
          accountId: 'acc1',
          categoryId: 'cat1',
          originalCurrency: 'USD',
          exchangeRateSnapshot: ratesJson,
          createdAt: now,
          modifiedAt: now,
        ),
        Transaction(
          id: 'tx2',
          amount: 2200, // 22 USD -> 20 EUR
          date: now,
          type: TransactionType.expense,
          accountId: 'acc1',
          categoryId: 'cat2',
          originalCurrency: 'USD',
          exchangeRateSnapshot: ratesJson,
          createdAt: now,
          modifiedAt: now,
        ),
        Transaction(
          id: 'tx3',
          amount: 5000, // 50 EUR -> no conversion
          date: now,
          type: TransactionType.expense,
          accountId: 'acc1',
          categoryId: 'cat3',
          originalCurrency: 'EUR', // same as account
          exchangeRateSnapshot: ratesJson,
          createdAt: now,
          modifiedAt: now,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          accountsListProvider
              .overrideWith((ref) => Stream.value([testAccount])),
          rawTransactionsStreamProvider
              .overrideWith((ref) => Stream.value(transactions)),
        ],
      );

      final subscription =
          container.listen(accountBalanceProvider('acc1'), (_, __) {});

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result = container.read(accountBalanceProvider('acc1'));

      expect(result.value, closeTo(130.0, 0.001));

      subscription.close();
    });

    test('calculates correct balance for transfers with conversion', () async {
      // Origin account in EUR, transaction in GBP
      // Rates: EUR = 1.0 (base), GBP = 0.85
      final exchangeRates = {
        'EUR': 1.0,
        'GBP': 0.85,
      };
      final ratesJson = jsonEncode(exchangeRates);

      final transactions = [
        // Transfer Origin (outflow from acc1)
        Transaction(
          id: 'tx_transfer',
          amount: 8500, // 85 GBP -> 100 EUR
          date: now,
          type: TransactionType.transfer,
          accountId: 'acc1',
          categoryId: 'cat1',
          originalCurrency: 'GBP',
          exchangeRateSnapshot: ratesJson,
          createdAt: now,
          modifiedAt: now,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          accountsListProvider
              .overrideWith((ref) => Stream.value([testAccount])),
          rawTransactionsStreamProvider
              .overrideWith((ref) => Stream.value(transactions)),
        ],
      );

      final subscription =
          container.listen(accountBalanceProvider('acc1'), (_, __) {});

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result = container.read(accountBalanceProvider('acc1'));

      expect(result.value, closeTo(0.0, 0.001));

      subscription.close();
    });

    test('calculates correct balance for transfer destination with conversion',
        () async {
      final exchangeRates = {
        'EUR': 1.0,
        'JPY': 150.0,
      };
      final ratesJson = jsonEncode(exchangeRates);

      final transactions = [
        // Transfer Destination (inflow to acc1)
        Transaction(
          id: 'tx_transfer_dst', // destination leg
          amount:
              15000, // 150 EUR -> 150 EUR. Wait, if originalCurrency is EUR,
          // because destination amount is in destination currency.
          date: now,
          type: TransactionType.transfer,
          accountId: 'acc1',
          categoryId: 'cat1',
          originalCurrency:
              'EUR', // Destination leg has originalCurrency = destination account currency
          exchangeRateSnapshot: ratesJson,
          createdAt: now,
          modifiedAt: now,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          accountsListProvider
              .overrideWith((ref) => Stream.value([testAccount])),
          rawTransactionsStreamProvider
              .overrideWith((ref) => Stream.value(transactions)),
        ],
      );

      final subscription =
          container.listen(accountBalanceProvider('acc1'), (_, __) {});

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result = container.read(accountBalanceProvider('acc1'));

      expect(result.value, closeTo(250.0, 0.001));

      subscription.close();
    });
  });
}
