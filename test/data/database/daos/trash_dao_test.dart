import 'dart:ffi';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/database/tables/account_table.dart';
import 'package:stalvi/domain/entities/trash_item.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';
import 'package:uuid/uuid.dart';

void main() {
  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () {
      return DynamicLibrary.open('libsqlite3.so.0');
    });
  });

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('getTrashItems returns only soft-deleted items sorted by daysRemaining',
      () async {
    const uuid = Uuid();
    final now = DateTime.now();
    final userId = uuid.v4();

    await db.into(db.profiles).insert(
          ProfilesCompanion.insert(
            id: userId,
            name: 'Test',
            username: 'test',
            password: '',
            defaultCurrency: const Value('EUR'),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // Active item
    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            id: uuid.v4(),
            userId: userId,
            name: 'Active Account',
            type: AccountType.cash,
            initialBalance: 0,
            currency: 'EUR',
            color: 'red',
            icon: 'icon',
            isDefault: false,
            isDeleted: const Value(false),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // Trash items
    final t1Id = uuid.v4();
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: t1Id,
            name: 'Deleted Category',
            icon: 'icon',
            color: 'color',
            isDeleted: const Value(true),
            createdAt: now,
            modifiedAt:
                now.subtract(const Duration(days: 10)), // 20 days remaining
          ),
        );

    final t2Id = uuid.v4();
    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            id: t2Id,
            userId: userId,
            name: 'Deleted Account',
            type: AccountType.bank,
            initialBalance: 0,
            currency: 'EUR',
            color: 'blue',
            icon: 'icon',
            isDefault: false,
            isDeleted: const Value(true),
            createdAt: now,
            modifiedAt:
                now.subtract(const Duration(days: 20)), // 10 days remaining
          ),
        );

    final items = await db.trashDao.getTrashItems();

    expect(items.length, 2);
    // T2 should be first since it has fewer days remaining (10 < 20)
    expect(items[0].id, t2Id);
    expect(items[0].daysRemaining, 10);
    expect(items[1].id, t1Id);
    expect(items[1].daysRemaining, 20);
  });

  test('restoreItem sets isDeleted to false', () async {
    const uuid = Uuid();
    final id = uuid.v4();
    final now = DateTime.now();

    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: id,
            name: 'Deleted Category',
            icon: 'icon',
            color: 'color',
            isDeleted: const Value(true),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await db.trashDao.restoreItem(id, TrashItemType.category);

    final category = await (db.select(db.categories)
          ..where((c) => c.id.equals(id)))
        .getSingle();
    expect(category.isDeleted, false);
  });

  test('deleteItemPermanently hard deletes the item', () async {
    const uuid = Uuid();
    final id = uuid.v4();
    final now = DateTime.now();

    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: id,
            name: 'Deleted Category',
            icon: 'icon',
            color: 'color',
            isDeleted: const Value(true),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await db.trashDao.deleteItemPermanently(id, TrashItemType.category);

    final category = await (db.select(db.categories)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    expect(category, isNull);
  });

  test('restoring transaction updates account balance', () async {
    const uuid = Uuid();
    final userId = uuid.v4();
    final accountId = uuid.v4();
    final transactionId = uuid.v4();
    final now = DateTime.now();

    await db.into(db.profiles).insert(
          ProfilesCompanion.insert(
            id: userId,
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
            userId: userId,
            name: 'Main Account',
            type: AccountType.cash,
            initialBalance: 100.0,
            currency: 'EUR',
            color: 'red',
            icon: 'icon',
            isDefault: true,
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            id: transactionId,
            amount: 3000,
            date: now,
            type: TransactionType.expense,
            accountId: accountId,
            originalCurrency: 'EUR',
            isDeleted: const Value(true),
            createdAt: now,
            modifiedAt: now,
          ),
        );

    await db.trashDao.restoreItem(transactionId, TrashItemType.transaction);

    final account = await (db.select(db.accounts)
          ..where((a) => a.id.equals(accountId)))
        .getSingle();
    expect(account.initialBalance, 70.0);

    final txn = await (db.select(db.transactions)
          ..where((t) => t.id.equals(transactionId)))
        .getSingle();
    expect(txn.isDeleted, false);
  });
}
