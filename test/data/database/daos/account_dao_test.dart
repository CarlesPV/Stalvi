import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_onreferenced_packages

import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/database/daos/account_dao.dart';
import 'package:stalvi/data/database/tables/account_table.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Inserts a profile row required by the FK on [Accounts.userId].
Future<void> _seedProfile(AppDatabase db, String id) async {
  final now = DateTime.now();
  await db.into(db.profiles).insert(
        ProfilesCompanion.insert(
          id: id,
          name: 'Test User',
          username: id,
          password: '',
          createdAt: now,
          modifiedAt: now,
        ),
      );
}

/// Inserts an account and returns its id.
Future<String> _insertAccount(
  AppDatabase db, {
  required String id,
  required String userId,
  bool isDefault = false,
  bool isDeleted = false,
}) async {
  final now = DateTime.now();
  await db.into(db.accounts).insert(
        AccountsCompanion.insert(
          id: id,
          userId: userId,
          name: 'Account $id',
          type: AccountType.cash,
          initialBalance: 0,
          currency: 'EUR',
          color: '#000000',
          icon: 'wallet',
          isDefault: drift.Value(isDefault),
          isDeleted: drift.Value(isDeleted),
          createdAt: now,
          modifiedAt: now,
        ),
      );
  return id;
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late AppDatabase database;
  late AccountDao dao;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dao = AccountDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  // ── setDefaultAccount – exclusive default logic ─────────────────────────────

  group('AccountDao.setDefaultAccount()', () {
    test('marks a single account as default when none was set', () async {
      await _seedProfile(database, 'user1');
      await _insertAccount(database, id: 'acc1', userId: 'user1');

      await dao.setDefaultAccount('acc1');

      final account = await (database.select(database.accounts)
            ..where((a) => a.id.equals('acc1')))
          .getSingleOrNull();
      expect(account, isNotNull);
      expect(account!.isDefault, isTrue);
    });

    test(
        'clears previous default before setting a new one (exclusive invariant)',
        () async {
      await _seedProfile(database, 'user1');
      // acc1 starts as the default.
      await _insertAccount(
        database,
        id: 'acc1',
        userId: 'user1',
        isDefault: true,
      );
      await _insertAccount(database, id: 'acc2', userId: 'user1');

      // Switch default to acc2.
      await dao.setDefaultAccount('acc2');

      final acc1 = await (database.select(database.accounts)
            ..where((a) => a.id.equals('acc1')))
          .getSingleOrNull();
      final acc2 = await (database.select(database.accounts)
            ..where((a) => a.id.equals('acc2')))
          .getSingleOrNull();

      expect(acc1!.isDefault, isFalse, reason: 'old default must be cleared');
      expect(acc2!.isDefault, isTrue, reason: 'new target must be set');
    });

    test('only one account is default when multiple accounts exist', () async {
      await _seedProfile(database, 'user1');
      await _insertAccount(database, id: 'acc1', userId: 'user1');
      await _insertAccount(database, id: 'acc2', userId: 'user1');
      await _insertAccount(database, id: 'acc3', userId: 'user1');

      await dao.setDefaultAccount('acc2');

      final all = await (database.select(database.accounts)
            ..where((a) => a.userId.equals('user1')))
          .get();
      final defaults = all.where((a) => a.isDefault).toList();
      expect(defaults.length, 1);
      expect(defaults.first.id, 'acc2');
    });

    test('does not affect accounts of a different user', () async {
      await _seedProfile(database, 'user1');
      await _seedProfile(database, 'user2');
      await _insertAccount(
        database,
        id: 'acc_u1',
        userId: 'user1',
        isDefault: true,
      );
      await _insertAccount(database, id: 'acc_u2', userId: 'user2');

      // Changing default for user1 must not touch user2's accounts.
      await _insertAccount(database, id: 'acc_u1b', userId: 'user1');
      await dao.setDefaultAccount('acc_u1b');

      final u2Account = await (database.select(database.accounts)
            ..where((a) => a.id.equals('acc_u2')))
          .getSingleOrNull();
      // user2's account was never set as default – it should still be false.
      expect(u2Account!.isDefault, isFalse);
    });

    test('throws ArgumentError when account id does not exist', () async {
      await expectLater(
        () => dao.setDefaultAccount('nonexistent'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('re-setting the already-default account leaves it as default',
        () async {
      await _seedProfile(database, 'user1');
      await _insertAccount(
        database,
        id: 'acc1',
        userId: 'user1',
        isDefault: true,
      );

      // Setting acc1 as default again should be a no-op for the flag value.
      await dao.setDefaultAccount('acc1');

      final acc1 = await (database.select(database.accounts)
            ..where((a) => a.id.equals('acc1')))
          .getSingleOrNull();
      expect(acc1!.isDefault, isTrue);
    });
  });

  // ── getDefaultAccount ───────────────────────────────────────────────────────

  group('AccountDao.getDefaultAccount()', () {
    test('returns null when no default is set', () async {
      await _seedProfile(database, 'user1');
      await _insertAccount(database, id: 'acc1', userId: 'user1');

      final result = await dao.getDefaultAccount('user1');
      expect(result, isNull);
    });

    test('returns the default account when one is set', () async {
      await _seedProfile(database, 'user1');
      await _insertAccount(
        database,
        id: 'acc1',
        userId: 'user1',
        isDefault: true,
      );
      await _insertAccount(database, id: 'acc2', userId: 'user1');

      final result = await dao.getDefaultAccount('user1');
      expect(result, isNotNull);
      expect(result!.id, 'acc1');
    });

    test('returns null for a different user even if one account is default',
        () async {
      await _seedProfile(database, 'user1');
      await _seedProfile(database, 'user2');
      await _insertAccount(
        database,
        id: 'acc1',
        userId: 'user1',
        isDefault: true,
      );

      // user2 has no accounts – should get null.
      final result = await dao.getDefaultAccount('user2');
      expect(result, isNull);
    });

    test('ignores soft-deleted default accounts', () async {
      await _seedProfile(database, 'user1');
      // Default account is soft-deleted.
      await _insertAccount(
        database,
        id: 'acc1',
        userId: 'user1',
        isDefault: true,
        isDeleted: true,
      );

      final result = await dao.getDefaultAccount('user1');
      expect(result, isNull);
    });
  });

  // ── getAccountsByUserId ─────────────────────────────────────────────────────

  group('AccountDao.getAccountsByUserId()', () {
    test('returns only non-deleted accounts for the given user', () async {
      await _seedProfile(database, 'user1');
      await _insertAccount(database, id: 'acc1', userId: 'user1');
      await _insertAccount(
        database,
        id: 'acc2',
        userId: 'user1',
        isDeleted: true,
      );

      final result = await dao.getAccountsByUserId('user1');
      expect(result.length, 1);
      expect(result.first.id, 'acc1');
    });

    test('returns accounts sorted alphabetically by name', () async {
      await _seedProfile(database, 'user1');
      final now = DateTime.now();
      // Insert in reverse alphabetical order.
      for (final name in ['Zebra', 'Alpha', 'Mango']) {
        await database.into(database.accounts).insert(
              AccountsCompanion.insert(
                id: name.toLowerCase(),
                userId: 'user1',
                name: name,
                type: AccountType.cash,
                initialBalance: 0,
                currency: 'EUR',
                color: '#000',
                icon: 'icon',
                isDefault: const drift.Value(false),
                createdAt: now,
                modifiedAt: now,
              ),
            );
      }

      final result = await dao.getAccountsByUserId('user1');
      final names = result.map((a) => a.name).toList();
      expect(names, ['Alpha', 'Mango', 'Zebra']);
    });
  });
}
