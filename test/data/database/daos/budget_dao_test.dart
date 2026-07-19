import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/database/daos/budget_dao.dart';
import 'package:stalvi/data/database/tables/account_table.dart';
import 'package:stalvi/data/database/tables/category_table.dart';

Future<void> _seedForeignKeys(AppDatabase db) async {
  final now = DateTime.now();
  await db.into(db.profiles).insert(
        ProfilesCompanion.insert(
          id: 'user1',
          name: 'Test',
          username: 'test',
          password: '',
          createdAt: now,
          modifiedAt: now,
        ),
      );
  await db.into(db.accounts).insert(
        AccountsCompanion.insert(
          id: 'acc1',
          userId: 'user1',
          name: 'Account',
          type: AccountType.cash,
          initialBalance: 0,
          currency: 'EUR',
          color: '#000',
          icon: 'icon',
          createdAt: now,
          modifiedAt: now,
        ),
      );
  await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          id: 'cat1',
          name: 'Cat',
          associatedType: const drift.Value(CategoryAssociatedType.expense),
          icon: 'icon',
          color: '#000',
          createdAt: now,
          modifiedAt: now,
        ),
      );
}

void main() {
  late AppDatabase database;
  late BudgetDao dao;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dao = BudgetDao(database);
    await _seedForeignKeys(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('createBudget and getBudgets ignores soft-deleted items', () async {
    final now = DateTime.now();
    await dao.createBudget(
      BudgetsCompanion.insert(
        id: 'b1',
        accountId: 'acc1',
        categoryId: 'cat1',
        targetAmount: 1000,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        createdAt: now,
        modifiedAt: now,
      ),
    );

    final budgets = await dao.getBudgets();
    expect(budgets.length, 1);
    expect(budgets.first.id, 'b1');

    await dao.softDelete('b1');

    final afterDelete = await dao.getBudgets();
    expect(afterDelete.isEmpty, isTrue);
  });

  test('getBudgetById ignores soft-deleted items', () async {
    final now = DateTime.now();
    await dao.createBudget(
      BudgetsCompanion.insert(
        id: 'b2',
        accountId: 'acc1',
        categoryId: 'cat1',
        targetAmount: 1000,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        createdAt: now,
        modifiedAt: now,
      ),
    );

    final b = await dao.getBudgetById('b2');
    expect(b, isNotNull);

    await dao.softDelete('b2');

    final after = await dao.getBudgetById('b2');
    expect(after, isNull);
  });
}
