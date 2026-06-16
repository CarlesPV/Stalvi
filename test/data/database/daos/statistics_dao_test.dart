import 'dart:ffi';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konta/data/database/app_database.dart';
import 'package:konta/data/database/daos/statistics_dao.dart';
import 'package:konta/data/database/tables/account_table.dart';
import 'package:konta/data/database/tables/transaction_table.dart';
import 'package:konta/data/database/tables/category_table.dart';
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

  test('getPeriodSummary should return total income and expense', () async {
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
            isDefault: true,
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

    // Act
    final result =
        await dao.getPeriodSummary(DateTime(2023, 1, 1), DateTime(2023, 1, 31));

    // Assert
    expect(result.$1, 1000); // Income
    expect(result.$2, 500); // Expense
  });

  test(
      'getTopCategories should return categories grouped by id and sorted by sum',
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
            isDefault: true,
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
            amount: 300,
            date: DateTime(2023, 1, 11),
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
            id: 't3',
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
    final result = await dao.getTopCategories(
      DateTime(2023, 1, 1),
      DateTime(2023, 1, 31),
      type: TransactionType.expense,
    );

    // Assert
    expect(result.length, 2);
    expect(result[0].categoryId, 'cat2');
    expect(result[0].totalAmount, 1000);
    expect(result[1].categoryId, 'cat1');
    expect(result[1].totalAmount, 800);
  });

  test('getPeriodSummary should return 0 when DB is empty', () async {
    final result =
        await dao.getPeriodSummary(DateTime(2023, 1, 1), DateTime(2023, 1, 31));
    expect(result.$1, 0);
    expect(result.$2, 0);
  });
}
