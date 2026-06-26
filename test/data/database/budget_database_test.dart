import 'dart:ffi';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/repositories/budget_repository.dart';
import 'package:stalvi/domain/entities/budget.dart';
import 'package:stalvi/data/database/tables/account_table.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

void main() {
  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () {
      return DynamicLibrary.open('libsqlite3.so.0');
    });
  });

  late AppDatabase db;
  late BudgetRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = BudgetRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('BudgetRepository / AppDatabase', () {
    final testBudget = Budget(
      id: 'budget-1',
      accountId: 'account-1',
      categoryId: 'category-1',
      targetAmount: 50000,
      currentAmount: 10000,
      startDate: DateTime(2023, 1, 1),
      endDate: DateTime(2023, 1, 31),
      createdAt: DateTime(2023, 1, 1),
      modifiedAt: DateTime(2023, 1, 1),
      isDeleted: false,
    );

    Future<void> insertDummyDependencies() async {
      final now = DateTime.now();
      await db.into(db.profiles).insert(
            ProfilesCompanion.insert(
              id: 'user-1',
              name: 'User 1',
              username: 'user1',
              password: '',
              createdAt: now,
              modifiedAt: now,
            ),
          );
      await db.into(db.accounts).insert(
            AccountsCompanion.insert(
              id: 'account-1',
              name: 'Account 1',
              userId: 'user-1',
              type: AccountType.cash,
              initialBalance: 0,
              currency: 'EUR',
              color: 'blue',
              icon: 'wallet',
              createdAt: now,
              modifiedAt: now,
            ),
          );
      await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              id: 'category-1',
              name: 'Food',
              icon: 'food',
              color: 'red',
              createdAt: now,
              modifiedAt: now,
            ),
          );
    }

    test('can create and retrieve a budget', () async {
      await insertDummyDependencies();

      await repository.createBudget(testBudget);

      final fetched = await repository.getBudgetById('budget-1');
      expect(fetched, isNotNull);
      expect(fetched?.id, testBudget.id);
      expect(fetched?.categoryId, testBudget.categoryId);
      expect(fetched?.targetAmount, testBudget.targetAmount);
    });

    test('soft delete hides budget from getBudgets', () async {
      await insertDummyDependencies();

      await repository.createBudget(testBudget);
      await repository.deleteBudget(testBudget.id);

      final budgets = await repository.getBudgets();
      expect(budgets.isEmpty, isTrue);

      final fetched = await repository.getBudgetById(testBudget.id);
      expect(fetched, isNull);
    });

    test('update budget modifies values', () async {
      await insertDummyDependencies();

      await repository.createBudget(testBudget);

      final updatedBudget = testBudget.copyWith(targetAmount: 60000);
      await repository.updateBudget(updatedBudget);

      final fetched = await repository.getBudgetById(testBudget.id);
      expect(fetched?.targetAmount, 60000);
    });
  });
}
