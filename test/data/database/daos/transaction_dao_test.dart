import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_onreferenced_packages

import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/database/daos/transaction_dao.dart';
import 'package:stalvi/data/database/tables/account_table.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

Future<void> _seedProfile(AppDatabase db, String id) async {
  final now = DateTime.now();
  await db.into(db.profiles).insert(
        ProfilesCompanion.insert(
          id: id,
          name: 'Test',
          username: id,
          password: '',
          createdAt: now,
          modifiedAt: now,
        ),
      );
}

Future<void> _seedAccount(
  AppDatabase db, {
  required String id,
  required String userId,
  String currency = 'EUR',
}) async {
  final now = DateTime.now();
  await db.into(db.accounts).insert(
        AccountsCompanion.insert(
          id: id,
          userId: userId,
          name: 'Account $id',
          type: AccountType.cash,
          initialBalance: 0,
          currency: currency,
          color: '#000',
          icon: 'wallet',
          isDefault: const drift.Value(false),
          createdAt: now,
          modifiedAt: now,
        ),
      );
}

Future<void> _seedCategory(AppDatabase db, {required String id}) async {
  final now = DateTime.now();
  await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          id: id,
          name: 'Cat $id',
          icon: 'icon',
          color: '#fff',
          createdAt: now,
          modifiedAt: now,
        ),
      );
}

Future<void> _seedTag(
  AppDatabase db, {
  required String id,
  required String name,
}) async {
  final now = DateTime.now();
  await db.into(db.tags).insert(
        TagsCompanion.insert(
          id: id,
          name: name,
          createdAt: now,
          modifiedAt: now,
        ),
      );
}

Future<String> _seedTransaction(
  AppDatabase db, {
  required String id,
  required String accountId,
  TransactionType type = TransactionType.expense,
  int amount = 1000,
  DateTime? date,
  String? categoryId,
  String? notes,
  String currency = 'EUR',
  bool isDeleted = false,
  String? exchangeRateSnapshot,
}) async {
  final now = DateTime.now();
  await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: id,
          amount: amount,
          date: date ?? DateTime(2024, 1, 15),
          type: type,
          accountId: accountId,
          categoryId: drift.Value(categoryId),
          notes: drift.Value(notes),
          originalCurrency: currency,
          isDeleted: drift.Value(isDeleted),
          exchangeRateSnapshot: drift.Value(exchangeRateSnapshot),
          createdAt: now,
          modifiedAt: now,
        ),
      );
  return id;
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late AppDatabase database;
  late TransactionDao dao;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dao = TransactionDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  // ── No filters – baseline ───────────────────────────────────────────────────

  group('TransactionDao.watchFiltered() — no filters', () {
    test('returns all non-deleted transactions when no filter is applied',
        () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');
      await _seedTransaction(database, id: 't1', accountId: 'acc1');
      await _seedTransaction(database, id: 't2', accountId: 'acc1');
      await _seedTransaction(
        database,
        id: 't3',
        accountId: 'acc1',
        isDeleted: true,
      );

      final stream = dao.watchFiltered();
      final result = await stream.first;

      expect(result.length, 2);
      expect(result.map((t) => t.id), containsAll(['t1', 't2']));
    });

    test('retrieves exchangeRateSnapshot correctly', () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');
      await _seedTransaction(
        database,
        id: 't_snapshot',
        accountId: 'acc1',
        exchangeRateSnapshot: '{"EUR": 1.0, "USD": 1.1}',
      );

      final stream = dao.watchFiltered();
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.exchangeRateSnapshot, '{"EUR": 1.0, "USD": 1.1}');
    });
  });

  // ── accountId filter ────────────────────────────────────────────────────────

  group('TransactionDao.watchFiltered(accountId:)', () {
    test('returns only transactions for the specified account', () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');
      await _seedAccount(database, id: 'acc2', userId: 'u1');
      await _seedTransaction(database, id: 't1', accountId: 'acc1');
      await _seedTransaction(database, id: 't2', accountId: 'acc2');

      final stream = dao.watchFiltered(accountId: 'acc1');
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 't1');
    });

    test('returns empty list when account has no transactions', () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');

      final stream = dao.watchFiltered(accountId: 'acc1');
      final result = await stream.first;

      expect(result, isEmpty);
    });
  });

  // ── type filter ─────────────────────────────────────────────────────────────

  group('TransactionDao.watchFiltered(type:)', () {
    test('returns only income transactions', () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');
      await _seedTransaction(
        database,
        id: 't_income',
        accountId: 'acc1',
        type: TransactionType.income,
      );
      await _seedTransaction(
        database,
        id: 't_expense',
        accountId: 'acc1',
        type: TransactionType.expense,
      );
      await _seedTransaction(
        database,
        id: 't_transfer',
        accountId: 'acc1',
        type: TransactionType.transfer,
      );

      final stream = dao.watchFiltered(type: TransactionType.income);
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 't_income');
    });

    test('filters transfer transactions correctly', () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');
      await _seedTransaction(
        database,
        id: 't1',
        accountId: 'acc1',
        type: TransactionType.transfer,
      );
      await _seedTransaction(
        database,
        id: 't2',
        accountId: 'acc1',
        type: TransactionType.expense,
      );

      final stream = dao.watchFiltered(type: TransactionType.transfer);
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 't1');
    });
  });

  // ── categoryId filter ───────────────────────────────────────────────────────

  group('TransactionDao.watchFiltered(categoryId:)', () {
    test('returns only transactions with the given category', () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');
      await _seedCategory(database, id: 'cat1');
      await _seedCategory(database, id: 'cat2');

      await _seedTransaction(
        database,
        id: 't1',
        accountId: 'acc1',
        categoryId: 'cat1',
      );
      await _seedTransaction(
        database,
        id: 't2',
        accountId: 'acc1',
        categoryId: 'cat2',
      );
      await _seedTransaction(database, id: 't3', accountId: 'acc1');

      final stream = dao.watchFiltered(categoryId: 'cat1');
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 't1');
    });
  });

  // ── date range filter ───────────────────────────────────────────────────────

  group('TransactionDao.watchFiltered(startDate/endDate:)', () {
    test('returns transactions within date range', () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');

      await _seedTransaction(
        database,
        id: 't_before',
        accountId: 'acc1',
        date: DateTime(2024, 1, 1),
      );
      await _seedTransaction(
        database,
        id: 't_in',
        accountId: 'acc1',
        date: DateTime(2024, 6, 15),
      );
      await _seedTransaction(
        database,
        id: 't_after',
        accountId: 'acc1',
        date: DateTime(2024, 12, 31),
      );

      final stream = dao.watchFiltered(
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 9, 30),
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 't_in');
    });

    test('startDate-only filter excludes earlier transactions', () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');
      await _seedTransaction(
        database,
        id: 't_old',
        accountId: 'acc1',
        date: DateTime(2023, 12, 31),
      );
      await _seedTransaction(
        database,
        id: 't_new',
        accountId: 'acc1',
        date: DateTime(2024, 1, 1),
      );

      final stream = dao.watchFiltered(startDate: DateTime(2024, 1, 1));
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 't_new');
    });
  });

  // ── amount range filter ─────────────────────────────────────────────────────

  group('TransactionDao.watchFiltered(minAmountCents/maxAmountCents:)', () {
    test('returns transactions within the amount range', () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');

      await _seedTransaction(
        database,
        id: 't_low',
        accountId: 'acc1',
        amount: 100,
      );
      await _seedTransaction(
        database,
        id: 't_mid',
        accountId: 'acc1',
        amount: 500,
      );
      await _seedTransaction(
        database,
        id: 't_high',
        accountId: 'acc1',
        amount: 10000,
      );

      final stream = dao.watchFiltered(
        minAmountCents: 200,
        maxAmountCents: 1000,
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 't_mid');
    });

    test('minAmountCents boundary is inclusive', () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');
      await _seedTransaction(
        database,
        id: 't1',
        accountId: 'acc1',
        amount: 500,
      );

      final stream = dao.watchFiltered(minAmountCents: 500);
      final result = await stream.first;

      expect(result.first.id, 't1');
    });

    test('maxAmountCents boundary is inclusive', () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');
      await _seedTransaction(
        database,
        id: 't1',
        accountId: 'acc1',
        amount: 500,
      );

      final stream = dao.watchFiltered(maxAmountCents: 500);
      final result = await stream.first;

      expect(result.first.id, 't1');
    });
  });

  // ── currency filter ─────────────────────────────────────────────────────────

  group('TransactionDao.watchFiltered(currency:)', () {
    test('returns only transactions matching the given currency', () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');

      await _seedTransaction(
        database,
        id: 't_eur',
        accountId: 'acc1',
        currency: 'EUR',
      );
      await _seedTransaction(
        database,
        id: 't_usd',
        accountId: 'acc1',
        currency: 'USD',
      );

      final stream = dao.watchFiltered(currency: 'USD');
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 't_usd');
    });
  });

  // ── tagId filter ────────────────────────────────────────────────────────────

  group('TransactionDao.watchFiltered(tagId:)', () {
    test('returns transactions whose notes contain the tag name', () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');
      await _seedTag(database, id: 'tag1', name: 'groceries');

      await _seedTransaction(
        database,
        id: 't_tagged',
        accountId: 'acc1',
        notes: 'Weekly #groceries run',
      );
      await _seedTransaction(
        database,
        id: 't_untagged',
        accountId: 'acc1',
        notes: 'Coffee',
      );

      final stream = dao.watchFiltered(tagId: 'tag1');
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 't_tagged');
    });

    test('returns empty list when tag does not exist in the database',
        () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');
      await _seedTransaction(database, id: 't1', accountId: 'acc1');

      final stream = dao.watchFiltered(tagId: 'nonexistent_tag');
      final result = await stream.first;

      expect(result, isEmpty);
    });

    test('is case-insensitive (SQLite LIKE default behaviour)', () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');
      await _seedTag(database, id: 'tag1', name: 'RENT');

      await _seedTransaction(
        database,
        id: 't1',
        accountId: 'acc1',
        notes: 'Monthly rent payment',
      );

      // Tag name is "RENT" but note has lowercase "rent" — LIKE is case-insensitive.
      final stream = dao.watchFiltered(tagId: 'tag1');
      final result = await stream.first;

      expect(result.length, 1);
    });
  });

  // ── combined filters ────────────────────────────────────────────────────────

  group('TransactionDao.watchFiltered() — multiple filters combined', () {
    test('AND semantics: all active filters must match simultaneously',
        () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');
      await _seedCategory(database, id: 'cat1');

      // Matches type + category + amount.
      await _seedTransaction(
        database,
        id: 't_match',
        accountId: 'acc1',
        type: TransactionType.expense,
        categoryId: 'cat1',
        amount: 500,
      );

      // Wrong type.
      await _seedTransaction(
        database,
        id: 't_wrong_type',
        accountId: 'acc1',
        type: TransactionType.income,
        categoryId: 'cat1',
        amount: 500,
      );

      // Wrong category.
      await _seedTransaction(
        database,
        id: 't_wrong_cat',
        accountId: 'acc1',
        type: TransactionType.expense,
        amount: 500,
      );

      // Amount too low.
      await _seedTransaction(
        database,
        id: 't_low_amt',
        accountId: 'acc1',
        type: TransactionType.expense,
        categoryId: 'cat1',
        amount: 10,
      );

      final stream = dao.watchFiltered(
        type: TransactionType.expense,
        categoryId: 'cat1',
        minAmountCents: 100,
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 't_match');
    });

    test('accountId + type + currency combination', () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');
      await _seedAccount(database, id: 'acc2', userId: 'u1');

      await _seedTransaction(
        database,
        id: 't_target',
        accountId: 'acc1',
        type: TransactionType.income,
        currency: 'USD',
      );
      await _seedTransaction(
        database,
        id: 't_wrong_acc',
        accountId: 'acc2',
        type: TransactionType.income,
        currency: 'USD',
      );
      await _seedTransaction(
        database,
        id: 't_wrong_currency',
        accountId: 'acc1',
        type: TransactionType.income,
        currency: 'EUR',
      );

      final stream = dao.watchFiltered(
        accountId: 'acc1',
        type: TransactionType.income,
        currency: 'USD',
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 't_target');
    });
  });

  // ── soft-delete is always enforced ─────────────────────────────────────────

  group('TransactionDao.watchFiltered() — isDeleted always enforced', () {
    test('never returns soft-deleted rows regardless of other filters',
        () async {
      await _seedProfile(database, 'u1');
      await _seedAccount(database, id: 'acc1', userId: 'u1');

      await _seedTransaction(
        database,
        id: 't_deleted',
        accountId: 'acc1',
        isDeleted: true,
      );

      final stream = dao.watchFiltered();
      final result = await stream.first;

      expect(result, isEmpty);
    });
  });
}
