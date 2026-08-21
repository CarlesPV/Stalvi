import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/database/tables/account_table.dart';
import 'package:stalvi/domain/entities/trash_item.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart';
// ignore: depend_onreferenced_packages
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'getTrashItems returns only soft-deleted items sorted by deletedAt descending (most recently deleted first)',
    () async {
      const uuid = Uuid();
      final now = DateTime.fromMillisecondsSinceEpoch(
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) * 1000,
      );
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
              isDefault: const Value(false),
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
              modifiedAt: now.subtract(
                const Duration(days: 10),
              ), // 20 days remaining
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
              isDefault: const Value(false),
              isDeleted: const Value(true),
              createdAt: now,
              modifiedAt: now.subtract(
                const Duration(days: 20),
              ), // 10 days remaining
            ),
          );

      final t3Id = uuid.v4();
      await db.into(db.tags).insert(
            TagsCompanion.insert(
              id: t3Id,
              name: 'Deleted Tag',
              isDeleted: const Value(true),
              createdAt: now,
              modifiedAt: now.subtract(
                const Duration(hours: 5),
              ),
            ),
          );

      final t4Id = uuid.v4();
      await db.into(db.tags).insert(
            TagsCompanion.insert(
              id: t4Id,
              name: 'Recently Deleted Tag',
              isDeleted: const Value(true),
              createdAt: now,
              modifiedAt: now.subtract(
                const Duration(hours: 1),
              ),
            ),
          );

      final items = await db.trashDao.getTrashItems();

      expect(items.length, 4);
      // T4 was deleted 1 hour ago (most recently deleted first)
      expect(items[0].id, t4Id);
      expect(items[0].deletedAt, now.subtract(const Duration(hours: 1)));
      // T3 was deleted 5 hours ago
      expect(items[1].id, t3Id);
      expect(items[1].deletedAt, now.subtract(const Duration(hours: 5)));
      // T1 was deleted 10 days ago
      expect(items[2].id, t1Id);
      expect(items[2].daysRemaining, 20);
      expect(items[2].deletedAt, now.subtract(const Duration(days: 10)));
      // T2 was deleted 20 days ago (oldest deleted last)
      expect(items[3].id, t2Id);
      expect(items[3].daysRemaining, 10);
      expect(items[3].deletedAt, now.subtract(const Duration(days: 20)));
    },
  );

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

    final category = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(id)))
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

    final category = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(id)))
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
            isDefault: const Value(true),
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

    final account = await (db.select(
      db.accounts,
    )..where((a) => a.id.equals(accountId)))
        .getSingle();
    expect(account.initialBalance, 70.0);

    final txn = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(transactionId)))
        .getSingle();
    expect(txn.isDeleted, false);
  });
}
