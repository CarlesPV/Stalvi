import 'dart:ffi';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/database/daos/statistics_dao.dart';
import 'package:stalvi/data/database/tables/account_table.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart';
import 'package:stalvi/data/database/tables/category_table.dart';
import 'package:drift/drift.dart' as drift;
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

void main() {
  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () {
      return DynamicLibrary.open('libsqlite3.so.0');
    });
  });

  late AppDatabase database;
  late StatisticsDao dao;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dao = StatisticsDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('getTransactionsForPeriod should return transactions in the period',
      () async {
    // Arrange
    final now = DateTime.now();
    await database.into(database.profiles).insert(
          ProfilesCompanion.insert(
            id: 'profile1',
            name: 'Test',
            username: 'test',
            password: '',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.accounts).insert(
          AccountsCompanion.insert(
            id: 'acc1',
            userId: 'profile1',
            name: 'Cash',
            type: AccountType.cash,
            initialBalance: 0,
            currency: 'EUR',
            color: 'red',
            icon: 'icon',
            isDefault: const drift.Value(true),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.transactions).insert(
          TransactionsCompanion.insert(
            id: 't1',
            amount: 1000,
            date: DateTime(2023, 1, 10),
            type: TransactionType.income,
            accountId: 'acc1',
            originalCurrency: 'EUR',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.transactions).insert(
          TransactionsCompanion.insert(
            id: 't2',
            amount: 500,
            date: DateTime(2023, 1, 15),
            type: TransactionType.expense,
            accountId: 'acc1',
            originalCurrency: 'EUR',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.transactions).insert(
          TransactionsCompanion.insert(
            id: 't3',
            amount: 700,
            date: DateTime(2023, 2, 1),
            type: TransactionType.expense,
            accountId: 'acc1',
            originalCurrency: 'EUR',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // Act
    final result = await dao.getTransactionsForPeriod(
      DateTime(2023, 1, 1),
      DateTime(2023, 1, 31),
    );

    // Assert
    expect(result.length, 2);
    expect(result.any((t) => t.id == 't1'), isTrue);
    expect(result.any((t) => t.id == 't2'), isTrue);
    expect(result.any((t) => t.id == 't3'), isFalse);
  });

  test(
      'getTransactionsWithCategoryForPeriod should return transactions with categories in the period',
      () async {
    // Arrange
    final now = DateTime.now();
    await database.into(database.profiles).insert(
          ProfilesCompanion.insert(
            id: 'profile1',
            name: 'Test',
            username: 'test',
            password: '',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.accounts).insert(
          AccountsCompanion.insert(
            id: 'acc1',
            userId: 'profile1',
            name: 'Cash',
            type: AccountType.cash,
            initialBalance: 0,
            currency: 'EUR',
            color: 'red',
            icon: 'icon',
            isDefault: const drift.Value(true),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.categories).insert(
          CategoriesCompanion.insert(
            id: 'cat1',
            name: 'Food',
            associatedType: const drift.Value(CategoryAssociatedType.expense),
            icon: 'food',
            color: 'red',
            isDeleted: const drift.Value(false),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.categories).insert(
          CategoriesCompanion.insert(
            id: 'cat2',
            name: 'Transport',
            associatedType: const drift.Value(CategoryAssociatedType.expense),
            icon: 'car',
            color: 'blue',
            isDeleted: const drift.Value(false),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.transactions).insert(
          TransactionsCompanion.insert(
            id: 't1',
            amount: 500,
            date: DateTime(2023, 1, 10),
            type: TransactionType.expense,
            accountId: 'acc1',
            categoryId: const drift.Value('cat1'),
            originalCurrency: 'EUR',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.transactions).insert(
          TransactionsCompanion.insert(
            id: 't2',
            amount: 1000,
            date: DateTime(2023, 1, 12),
            type: TransactionType.expense,
            accountId: 'acc1',
            categoryId: const drift.Value('cat2'),
            originalCurrency: 'EUR',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // Act
    final result = await dao.getTransactionsWithCategoryForPeriod(
      DateTime(2023, 1, 1),
      DateTime(2023, 1, 31),
      type: TransactionType.expense,
    );

    // Assert
    expect(result.length, 2);
    expect(
      result.any((t) => t.categoryId == 'cat1' && t.categoryName == 'Food'),
      isTrue,
    );
    expect(
      result.any(
        (t) => t.categoryId == 'cat2' && t.categoryName == 'Transport',
      ),
      isTrue,
    );
  });

  test('getTransactionsForPeriod should return empty list when DB is empty',
      () async {
    final result = await dao.getTransactionsForPeriod(
      DateTime(2023, 1, 1),
      DateTime(2023, 1, 31),
    );
    expect(result, isEmpty);
  });

  test(
      'getTransactionsForPeriod should ignore soft-deleted transactions and transactions of soft-deleted accounts',
      () async {
    final now = DateTime.now();
    await database.into(database.profiles).insert(
          ProfilesCompanion.insert(
            id: 'profile2',
            name: 'Test2',
            username: 'test2',
            password: '',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.accounts).insert(
          AccountsCompanion.insert(
            id: 'acc_active',
            userId: 'profile2',
            name: 'Active Account',
            type: AccountType.cash,
            initialBalance: 0,
            currency: 'EUR',
            color: 'red',
            icon: 'icon',
            isDefault: const drift.Value(true),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.accounts).insert(
          AccountsCompanion.insert(
            id: 'acc_deleted',
            userId: 'profile2',
            name: 'Deleted Account',
            type: AccountType.cash,
            initialBalance: 0,
            currency: 'EUR',
            color: 'red',
            icon: 'icon',
            isDefault: const drift.Value(false),
            isDeleted: const drift.Value(true),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // 1. Transaction active in active account
    await database.into(database.transactions).insert(
          TransactionsCompanion.insert(
            id: 't_active',
            amount: 1000,
            date: DateTime(2023, 1, 10),
            type: TransactionType.income,
            accountId: 'acc_active',
            originalCurrency: 'EUR',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // 2. Transaction soft-deleted in active account
    await database.into(database.transactions).insert(
          TransactionsCompanion.insert(
            id: 't_soft_deleted',
            amount: 2000,
            date: DateTime(2023, 1, 10),
            type: TransactionType.income,
            accountId: 'acc_active',
            originalCurrency: 'EUR',
            isDeleted: const drift.Value(true),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // 3. Transaction active in soft-deleted account
    await database.into(database.transactions).insert(
          TransactionsCompanion.insert(
            id: 't_deleted_acc',
            amount: 4000,
            date: DateTime(2023, 1, 10),
            type: TransactionType.income,
            accountId: 'acc_deleted',
            originalCurrency: 'EUR',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    final result = await dao.getTransactionsForPeriod(
      DateTime(2023, 1, 1),
      DateTime(2023, 1, 31),
    );
    expect(result.length, 1);
    expect(result.first.id, 't_active');
  });

  test('getTransactionsForPeriod should filter by accountId when provided',
      () async {
    final now = DateTime.now();
    await database.into(database.profiles).insert(
          ProfilesCompanion.insert(
            id: 'profile3',
            name: 'Test3',
            username: 'test3',
            password: '',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.accounts).insert(
          AccountsCompanion.insert(
            id: 'acc3',
            userId: 'profile3',
            name: 'Account 3',
            type: AccountType.cash,
            initialBalance: 0,
            currency: 'USD',
            color: 'blue',
            icon: 'icon',
            isDefault: const drift.Value(true),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.accounts).insert(
          AccountsCompanion.insert(
            id: 'acc4',
            userId: 'profile3',
            name: 'Account 4',
            type: AccountType.cash,
            initialBalance: 0,
            currency: 'EUR',
            color: 'green',
            icon: 'icon',
            isDefault: const drift.Value(false),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.transactions).insert(
          TransactionsCompanion.insert(
            id: 't_acc3',
            amount: 1000,
            date: DateTime(2023, 1, 10),
            type: TransactionType.income,
            accountId: 'acc3',
            originalCurrency: 'USD',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.transactions).insert(
          TransactionsCompanion.insert(
            id: 't_acc4',
            amount: 2000,
            date: DateTime(2023, 1, 12),
            type: TransactionType.income,
            accountId: 'acc4',
            originalCurrency: 'EUR',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // Act - all accounts (accountId is null)
    final resultAll = await dao.getTransactionsForPeriod(
      DateTime(2023, 1, 1),
      DateTime(2023, 1, 31),
    );

    // Act - specific account acc3
    final resultAcc3 = await dao.getTransactionsForPeriod(
      DateTime(2023, 1, 1),
      DateTime(2023, 1, 31),
      accountId: 'acc3',
    );

    // Assert
    expect(resultAll.length, 2);
    expect(resultAcc3.length, 1);
    expect(resultAcc3.first.id, 't_acc3');
  });

  test(
      'getPeriodSummaryAggregates should correctly convert amounts based on exchangeRateSnapshot',
      () async {
    // Arrange
    final now = DateTime.now();
    await database.into(database.profiles).insert(
          ProfilesCompanion.insert(
            id: 'profile_curr',
            name: 'Test',
            username: 'test',
            password: '',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await database.into(database.accounts).insert(
          AccountsCompanion.insert(
            id: 'acc_curr',
            userId: 'profile_curr',
            name: 'Cash',
            type: AccountType.cash,
            initialBalance: 0,
            currency: 'EUR',
            color: 'red',
            icon: 'icon',
            isDefault: const drift.Value(true),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // Income in EUR (target currency) -> 1000 EUR
    await database.into(database.transactions).insert(
          TransactionsCompanion.insert(
            id: 't_eur',
            amount: 1000,
            date: DateTime(2023, 1, 10),
            type: TransactionType.income,
            accountId: 'acc_curr',
            originalCurrency: 'EUR',
            exchangeRateSnapshot:
                const drift.Value('{"rates": {"EUR": 1.0, "USD": 1.10}}'),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // Income in USD -> 1100 USD / 1.10 = 1000 EUR
    await database.into(database.transactions).insert(
          TransactionsCompanion.insert(
            id: 't_usd',
            amount: 1100,
            date: DateTime(2023, 1, 15),
            type: TransactionType.income,
            accountId: 'acc_curr',
            originalCurrency: 'USD',
            exchangeRateSnapshot:
                const drift.Value('{"rates": {"EUR": 1.0, "USD": 1.10}}'),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // Expense in JPY -> 14000 JPY / 140 = 100 EUR.
    await database.into(database.transactions).insert(
          TransactionsCompanion.insert(
            id: 't_jpy',
            amount: 14000,
            date: DateTime(2023, 1, 20),
            type: TransactionType.expense,
            accountId: 'acc_curr',
            originalCurrency: 'JPY',
            exchangeRateSnapshot: const drift.Value(
                '{"rates": {"EUR": 1.0, "JPY": 140.0, "USD": 1.10}}'),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // Act - fetch period summary in EUR
    final summaryEur = await dao.getPeriodSummaryAggregates(
      DateTime(2023, 1, 1),
      DateTime(2023, 1, 31),
      'EUR',
    );

    // Assert EUR
    expect(summaryEur.totalIncome, 2000); // 1000 EUR + 1000 EUR equivalent
    expect(summaryEur.totalExpense, 100); // 100 EUR equivalent

    // Act - fetch period summary in USD
    final summaryUsd = await dao.getPeriodSummaryAggregates(
      DateTime(2023, 1, 1),
      DateTime(2023, 1, 31),
      'USD',
    );

    // Assert USD
    expect(summaryUsd.totalIncome, 2200); // 1100 USD equivalent + 1100 USD
    expect(summaryUsd.totalExpense, 110); // 100 EUR * 1.10 = 110 USD
  });
}
