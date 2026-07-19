import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/database/tables/account_table.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart';
import 'package:stalvi/data/repositories/transaction_repository.dart';
import 'package:stalvi/domain/entities/transaction_type.dart' as domain;
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
// ignore: depend_onreferenced_packages

/// Inserts a Tag row and returns its id.
Future<String> _seedTag(
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
  return id;
}

// ──────────────────────────────────────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────────────────────────────────────

/// Inserts minimal seed data required by FK constraints and returns the
/// account ID.
Future<String> _seedAccount(AppDatabase db) async {
  final now = DateTime.now();
  const profileId = 'profile-test';
  const accountId = 'acc-test';

  await db.into(db.profiles).insert(
        ProfilesCompanion.insert(
          id: profileId,
          name: 'Test',
          username: 'test',
          password: '',
          createdAt: now,
          modifiedAt: now,
        ),
      );

  await db.into(db.accounts).insert(
        AccountsCompanion.insert(
          id: accountId,
          userId: profileId,
          name: 'Wallet',
          type: AccountType.cash,
          initialBalance: 0,
          currency: 'EUR',
          color: '#FFFFFF',
          icon: 'wallet',
          isDefault: const drift.Value(true),
          createdAt: now,
          modifiedAt: now,
        ),
      );

  return accountId;
}

/// Inserts a single transaction row and returns the row ID.
Future<void> _insertTransaction(
  AppDatabase db, {
  required String id,
  required String accountId,
  required TransactionType type,
  required int amountCents,
  required DateTime date,
  String? categoryId,
  String? notes,
  String currency = 'EUR',
  bool isDeleted = false,
}) async {
  final now = DateTime.now();
  await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: id,
          amount: amountCents,
          date: date,
          type: type,
          accountId: accountId,
          categoryId: drift.Value(categoryId),
          notes: drift.Value(notes),
          originalCurrency: currency,
          isDeleted: drift.Value(isDeleted),
          createdAt: now,
          modifiedAt: now,
        ),
      );
}

// ──────────────────────────────────────────────────────────────────────────────
// Tests
// ──────────────────────────────────────────────────────────────────────────────

void main() {
  late AppDatabase database;
  late TransactionRepository repo;
  late String accountId;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TransactionRepository(database);
    accountId = await _seedAccount(database);
  });

  tearDown(() async {
    await database.close();
  });

  // ──────────────────────────────────────────────────────────────────────────
  // No-filter / baseline
  // ──────────────────────────────────────────────────────────────────────────

  group('watchFilteredTransactions – no filters (baseline)', () {
    test('returns all non-deleted transactions when filter is empty', () async {
      await _insertTransaction(
        database,
        id: 't1',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 1000,
        date: DateTime(2024, 1, 10),
      );
      await _insertTransaction(
        database,
        id: 't2',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 500,
        date: DateTime(2024, 1, 15),
      );
      // Soft-deleted – must NOT appear.
      await _insertTransaction(
        database,
        id: 't3',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 200,
        date: DateTime(2024, 1, 20),
        isDeleted: true,
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(),
      );
      final result = await stream.first;

      expect(result.length, 2);
      expect(result.map((t) => t.id), containsAll(['t1', 't2']));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Type filter
  // ──────────────────────────────────────────────────────────────────────────

  group('watchFilteredTransactions – type filter', () {
    test('filters only income transactions', () async {
      await _insertTransaction(
        database,
        id: 'inc1',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 2000,
        date: DateTime(2024, 3, 1),
      );
      await _insertTransaction(
        database,
        id: 'exp1',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 800,
        date: DateTime(2024, 3, 2),
      );
      await _insertTransaction(
        database,
        id: 'trf1',
        accountId: accountId,
        type: TransactionType.transfer,
        amountCents: 500,
        date: DateTime(2024, 3, 3),
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(type: domain.TransactionType.income),
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 'inc1');
    });

    test('filters only expense transactions', () async {
      await _insertTransaction(
        database,
        id: 'inc1',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 2000,
        date: DateTime(2024, 3, 1),
      );
      await _insertTransaction(
        database,
        id: 'exp1',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 800,
        date: DateTime(2024, 3, 2),
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(type: domain.TransactionType.expense),
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 'exp1');
    });

    test('returns empty list when no transactions match the type', () async {
      await _insertTransaction(
        database,
        id: 'inc1',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 1000,
        date: DateTime(2024, 3, 1),
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(type: domain.TransactionType.transfer),
      );
      final result = await stream.first;

      expect(result, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Category filter
  // ──────────────────────────────────────────────────────────────────────────

  group('watchFilteredTransactions – category filter', () {
    test('returns only transactions for the specified category', () async {
      await _insertTransaction(
        database,
        id: 't1',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 300,
        date: DateTime(2024, 4, 1),
        categoryId: 'cat-food',
      );
      await _insertTransaction(
        database,
        id: 't2',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 150,
        date: DateTime(2024, 4, 2),
        categoryId: 'cat-transport',
      );
      await _insertTransaction(
        database,
        id: 't3',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 200,
        date: DateTime(2024, 4, 3),
        categoryId: null, // no category
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(categoryId: 'cat-food'),
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 't1');
    });

    test('returns empty when no transaction has the category', () async {
      await _insertTransaction(
        database,
        id: 't1',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 300,
        date: DateTime(2024, 4, 1),
        categoryId: 'cat-other',
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(categoryId: 'cat-nonexistent'),
      );
      final result = await stream.first;

      expect(result, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Date range filter
  // ──────────────────────────────────────────────────────────────────────────

  group('watchFilteredTransactions – date range filter', () {
    test('returns only transactions within the date range (inclusive)',
        () async {
      await _insertTransaction(
        database,
        id: 'before',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 100,
        date: DateTime(2024, 5, 31), // just before range
      );
      await _insertTransaction(
        database,
        id: 'start',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 200,
        date: DateTime(2024, 6, 1), // inclusive start
      );
      await _insertTransaction(
        database,
        id: 'mid',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 300,
        date: DateTime(2024, 6, 15),
      );
      await _insertTransaction(
        database,
        id: 'end',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 400,
        date: DateTime(2024, 6, 30), // inclusive end
      );
      await _insertTransaction(
        database,
        id: 'after',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 500,
        date: DateTime(2024, 7, 1), // just after range
      );

      final stream = repo.watchFilteredTransactions(
        TransactionQueryFilter(
          dateRange: DateTimeRange(
            start: DateTime(2024, 6, 1),
            end: DateTime(2024, 6, 30),
          ),
        ),
      );
      final result = await stream.first;

      expect(result.length, 3);
      expect(result.map((t) => t.id), containsAll(['start', 'mid', 'end']));
      expect(result.map((t) => t.id), isNot(contains('before')));
      expect(result.map((t) => t.id), isNot(contains('after')));
    });

    test('returns empty when no transactions fall within the date range',
        () async {
      await _insertTransaction(
        database,
        id: 't1',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 100,
        date: DateTime(2024, 1, 1),
      );

      final stream = repo.watchFilteredTransactions(
        TransactionQueryFilter(
          dateRange: DateTimeRange(
            start: DateTime(2025, 1, 1),
            end: DateTime(2025, 12, 31),
          ),
        ),
      );
      final result = await stream.first;

      expect(result, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Amount range filter
  // ──────────────────────────────────────────────────────────────────────────

  group('watchFilteredTransactions – amount range filter', () {
    test('filters by minimum amount (inclusive)', () async {
      await _insertTransaction(
        database,
        id: 'low',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 499,
        date: DateTime(2024, 7, 1),
      );
      await _insertTransaction(
        database,
        id: 'exact',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 500,
        date: DateTime(2024, 7, 2),
      );
      await _insertTransaction(
        database,
        id: 'high',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 1000,
        date: DateTime(2024, 7, 3),
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(minAmountCents: 500),
      );
      final result = await stream.first;

      expect(result.length, 2);
      expect(result.map((t) => t.id), containsAll(['exact', 'high']));
      expect(result.map((t) => t.id), isNot(contains('low')));
    });

    test('filters by maximum amount (inclusive)', () async {
      await _insertTransaction(
        database,
        id: 'low',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 300,
        date: DateTime(2024, 8, 1),
      );
      await _insertTransaction(
        database,
        id: 'exact',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 500,
        date: DateTime(2024, 8, 2),
      );
      await _insertTransaction(
        database,
        id: 'over',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 501,
        date: DateTime(2024, 8, 3),
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(maxAmountCents: 500),
      );
      final result = await stream.first;

      expect(result.length, 2);
      expect(result.map((t) => t.id), containsAll(['low', 'exact']));
      expect(result.map((t) => t.id), isNot(contains('over')));
    });

    test('filters by both min and max amount simultaneously', () async {
      await _insertTransaction(
        database,
        id: 'below',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 99,
        date: DateTime(2024, 9, 1),
      );
      await _insertTransaction(
        database,
        id: 'inRange',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 500,
        date: DateTime(2024, 9, 2),
      );
      await _insertTransaction(
        database,
        id: 'above',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 1001,
        date: DateTime(2024, 9, 3),
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(
          minAmountCents: 100,
          maxAmountCents: 1000,
        ),
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 'inRange');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Tag filter (notes substring)
  // ──────────────────────────────────────────────────────────────────────────

  group('watchFilteredTransactions – tag filter', () {
    test(
        'returns transactions whose notes contain the tag name (resolved from tagId)',
        () async {
      await _seedTag(database, id: 'tag-food', name: '#food');

      await _insertTransaction(
        database,
        id: 't1',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 200,
        date: DateTime(2024, 10, 1),
        notes: 'Groceries #food shopping',
      );
      await _insertTransaction(
        database,
        id: 't2',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 300,
        date: DateTime(2024, 10, 2),
        notes: 'Bus ticket #transport',
      );
      await _insertTransaction(
        database,
        id: 't3',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 5000,
        date: DateTime(2024, 10, 3),
        notes: null, // no notes
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(tagId: 'tag-food'),
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 't1');
    });

    test('tag match is case-insensitive (SQLite LIKE default)', () async {
      await _seedTag(database, id: 'tag-health', name: '#health');

      await _insertTransaction(
        database,
        id: 't1',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 100,
        date: DateTime(2024, 10, 5),
        notes: 'Some note #HEALTH stuff',
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(tagId: 'tag-health'),
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 't1');
    });

    test('returns empty when no notes contain the tag name', () async {
      await _seedTag(database, id: 'tag-gym', name: '#gym');

      await _insertTransaction(
        database,
        id: 't1',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 200,
        date: DateTime(2024, 10, 6),
        notes: 'Unrelated note',
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(tagId: 'tag-gym'),
      );
      final result = await stream.first;

      expect(result, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Currency filter
  // ──────────────────────────────────────────────────────────────────────────

  group('watchFilteredTransactions – currency filter', () {
    test('returns only transactions in the specified currency', () async {
      await _insertTransaction(
        database,
        id: 'eur1',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 500,
        date: DateTime(2024, 11, 1),
        currency: 'EUR',
      );
      await _insertTransaction(
        database,
        id: 'usd1',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 600,
        date: DateTime(2024, 11, 2),
        currency: 'USD',
      );
      await _insertTransaction(
        database,
        id: 'gbp1',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 700,
        date: DateTime(2024, 11, 3),
        currency: 'GBP',
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(currency: 'USD'),
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 'usd1');
    });

    test('returns empty when no transaction uses the specified currency',
        () async {
      await _insertTransaction(
        database,
        id: 'eur1',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 200,
        date: DateTime(2024, 11, 4),
        currency: 'EUR',
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(currency: 'JPY'),
      );
      final result = await stream.first;

      expect(result, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Concurrent (multiple) filters applied simultaneously
  // ──────────────────────────────────────────────────────────────────────────

  group('watchFilteredTransactions – concurrent filters', () {
    test('type + currency applied simultaneously', () async {
      await _insertTransaction(
        database,
        id: 'inc-eur',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 1000,
        date: DateTime(2024, 12, 1),
        currency: 'EUR',
      );
      await _insertTransaction(
        database,
        id: 'exp-eur',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 500,
        date: DateTime(2024, 12, 2),
        currency: 'EUR',
      );
      await _insertTransaction(
        database,
        id: 'inc-usd',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 800,
        date: DateTime(2024, 12, 3),
        currency: 'USD',
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(
          type: domain.TransactionType.income,
          currency: 'EUR',
        ),
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 'inc-eur');
    });

    test('type + date range applied simultaneously', () async {
      await _insertTransaction(
        database,
        id: 'inside-income',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 1000,
        date: DateTime(2024, 6, 15),
      );
      await _insertTransaction(
        database,
        id: 'inside-expense',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 400,
        date: DateTime(2024, 6, 20),
      );
      await _insertTransaction(
        database,
        id: 'outside-income',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 2000,
        date: DateTime(2024, 8, 1), // outside range
      );

      final stream = repo.watchFilteredTransactions(
        TransactionQueryFilter(
          type: domain.TransactionType.income,
          dateRange: DateTimeRange(
            start: DateTime(2024, 6, 1),
            end: DateTime(2024, 6, 30),
          ),
        ),
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 'inside-income');
    });

    test('type + amount range + currency applied simultaneously', () async {
      // Should match: income, EUR, amount in [500, 2000]
      await _insertTransaction(
        database,
        id: 'match',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 1000,
        date: DateTime(2024, 6, 1),
        currency: 'EUR',
      );
      // Excluded by type
      await _insertTransaction(
        database,
        id: 'wrong-type',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 1000,
        date: DateTime(2024, 6, 2),
        currency: 'EUR',
      );
      // Excluded by currency
      await _insertTransaction(
        database,
        id: 'wrong-currency',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 1000,
        date: DateTime(2024, 6, 3),
        currency: 'USD',
      );
      // Excluded by amount (too low)
      await _insertTransaction(
        database,
        id: 'too-low',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 499,
        date: DateTime(2024, 6, 4),
        currency: 'EUR',
      );
      // Excluded by amount (too high)
      await _insertTransaction(
        database,
        id: 'too-high',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 2001,
        date: DateTime(2024, 6, 5),
        currency: 'EUR',
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(
          type: domain.TransactionType.income,
          minAmountCents: 500,
          maxAmountCents: 2000,
          currency: 'EUR',
        ),
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 'match');
    });

    test(
        'type + category + date range + amount range + currency: all six filters',
        () async {
      // The single transaction that satisfies all six filters.
      await _insertTransaction(
        database,
        id: 'all-match',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 750,
        date: DateTime(2024, 9, 15),
        categoryId: 'cat-food',
        currency: 'EUR',
        notes: 'Supermarket #food',
      );

      // Fails type filter
      await _insertTransaction(
        database,
        id: 'fail-type',
        accountId: accountId,
        type: TransactionType.income,
        amountCents: 750,
        date: DateTime(2024, 9, 15),
        categoryId: 'cat-food',
        currency: 'EUR',
        notes: 'Supermarket #food',
      );

      // Fails category filter
      await _insertTransaction(
        database,
        id: 'fail-category',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 750,
        date: DateTime(2024, 9, 15),
        categoryId: 'cat-transport',
        currency: 'EUR',
        notes: 'Supermarket #food',
      );

      // Fails date range
      await _insertTransaction(
        database,
        id: 'fail-date',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 750,
        date: DateTime(2024, 10, 1), // outside September
        categoryId: 'cat-food',
        currency: 'EUR',
        notes: 'Supermarket #food',
      );

      // Fails amount range (too low)
      await _insertTransaction(
        database,
        id: 'fail-amount',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 50,
        date: DateTime(2024, 9, 10),
        categoryId: 'cat-food',
        currency: 'EUR',
        notes: 'Supermarket #food',
      );

      // Fails currency filter
      await _insertTransaction(
        database,
        id: 'fail-currency',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 750,
        date: DateTime(2024, 9, 15),
        categoryId: 'cat-food',
        currency: 'USD',
        notes: 'Supermarket #food',
      );

      // Fails tag filter (notes don't contain #food)
      await _insertTransaction(
        database,
        id: 'fail-tag',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 750,
        date: DateTime(2024, 9, 15),
        categoryId: 'cat-food',
        currency: 'EUR',
        notes: 'Supermarket – no tag',
      );

      await _seedTag(database, id: 'tag-food', name: '#food');

      final stream = repo.watchFilteredTransactions(
        TransactionQueryFilter(
          type: domain.TransactionType.expense,
          categoryId: 'cat-food',
          dateRange: DateTimeRange(
            start: DateTime(2024, 9, 1),
            end: DateTime(2024, 9, 30),
          ),
          minAmountCents: 500,
          maxAmountCents: 1000,
          tagId: 'tag-food',
          currency: 'EUR',
        ),
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 'all-match');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Soft-delete exclusion
  // ──────────────────────────────────────────────────────────────────────────

  group('watchFilteredTransactions – soft-delete exclusion', () {
    test('never returns soft-deleted rows even when all other filters match',
        () async {
      await _insertTransaction(
        database,
        id: 'deleted',
        accountId: accountId,
        type: TransactionType.expense,
        amountCents: 500,
        date: DateTime(2024, 1, 1),
        currency: 'EUR',
        isDeleted: true,
      );

      final stream = repo.watchFilteredTransactions(
        const TransactionQueryFilter(currency: 'EUR'),
      );
      final result = await stream.first;

      expect(result, isEmpty);
    });
  });
}
