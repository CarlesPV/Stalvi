import 'dart:io';
import 'dart:ffi';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/open.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/repositories/export_service_impl.dart';
import 'package:stalvi/data/repositories/import_service_impl.dart';
import 'package:stalvi/domain/entities/account.dart' as ent_acc;
import 'package:stalvi/domain/entities/account_type.dart' as ent_acc_type;
import 'package:stalvi/domain/entities/category.dart' as ent_cat;
import 'package:stalvi/domain/entities/tag.dart' as ent_tag;
import 'package:stalvi/domain/entities/transaction.dart' as t;
import 'package:stalvi/domain/entities/transaction_type.dart' as t_type;
import 'package:stalvi/domain/entities/budget.dart' as ent_budget;
import 'package:stalvi/domain/entities/savings_goal.dart' as ent_sg;
import 'package:stalvi/domain/entities/automatic_transaction.dart' as ent_at;

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String tempDir;
  FakePathProviderPlatform(this.tempDir);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return tempDir;
  }

  @override
  Future<String?> getDownloadsPath() async {
    return tempDir;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return tempDir;
  }
}

void main() {
  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () {
      return DynamicLibrary.open('libsqlite3.so.0');
    });
  });

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('backup_restore_test');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });
  test('export and import relational data', () async {
    final executor = NativeDatabase.memory();
    final db = AppDatabase.forTesting(executor);

    // Create the schema
    await db.customStatement('PRAGMA foreign_keys = ON');

    final exportService = ExportServiceImpl();
    final importService =
        ImportServiceImpl(database: db, exportService: exportService);

    // Seed a profile
    await db.delete(db.profiles).go();
    await db.into(db.profiles).insert(
          ProfilesCompanion.insert(
            id: 'u1',
            name: 'Original User Name',
            username: 'user1',
            password: 'pwd',
            defaultCurrency: const Value('USD'),
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
        );

    // Create domain entities for export
    final now = DateTime.now();

    final acc = ent_acc.Account(
      id: 'a1',
      userId: 'u1',
      name: 'My Bank',
      type: ent_acc_type.AccountType.bank,
      initialBalance: 10000,
      currency: 'USD',
      color: 'blue',
      icon: 'bank',
      isDefault: true,
      isDeleted: false,
      createdAt: now,
      modifiedAt: now,
    );

    final cat = ent_cat.Category(
      id: 'c1',
      name: 'Groceries',
      icon: 'cart',
      color: 'green',
      isDeleted: false,
      createdAt: now,
      modifiedAt: now,
    );

    final tag = ent_tag.Tag(
      id: 'tg1',
      name: 'Urgent',
      isDeleted: false,
      createdAt: now,
      modifiedAt: now,
    );

    final tx = t.Transaction(
      id: 't1',
      amount: 5000,
      date: now,
      type: t_type.TransactionType.expense,
      accountId: 'a1',
      categoryId: 'c1',
      originalCurrency: 'USD',
      createdAt: now,
      modifiedAt: now,
    );

    final budget = ent_budget.Budget(
      id: 'b1',
      accountId: 'a1',
      categoryId: 'c1',
      targetAmount: 10000,
      startDate: now,
      endDate: now.add(const Duration(days: 30)),
      createdAt: now,
      modifiedAt: now,
    );

    final savingsGoal = ent_sg.SavingsGoal(
      id: 'sg1',
      name: 'Car',
      targetAmount: 500000,
      color: 'red',
      icon: 'car',
      createdAt: now,
      modifiedAt: now,
      currency: 'USD',
    );

    final autoTx = ent_at.AutomaticTransaction(
      id: 'at1',
      name: 'Rent',
      amount: 100000,
      currency: 'USD',
      type: t_type.TransactionType.expense,
      accountId: 'a1',
      categoryId: 'c1',
      recurrenceDays: 30,
      nextExecutionDate: now.add(const Duration(days: 30)),
      createdAt: now,
    );

    // Generate the backup file
    final exported = await exportService.generateEncryptedJson(
      accounts: [acc],
      categories: [cat],
      tags: [tag],
      transactions: [tx],
      budgets: [budget],
      savingsGoals: [savingsGoal],
      automaticTransactions: [autoTx],
      password: 'mypassword',
      userName: 'Restored User Name',
    );

    // Wipe and Import
    await importService.restoreFromEncryptedJson(
      exported.bytes,
      password: 'mypassword',
    );

    // Verify
    final profiles = await db.select(db.profiles).get();
    expect(profiles.length, 1);
    expect(profiles.first.name, 'Restored User Name');

    final accounts = await db.select(db.accounts).get();
    final categories = await db.select(db.categories).get();
    final tags = await db.select(db.tags).get();
    final transactions = await db.select(db.transactions).get();

    expect(accounts.length, 1);
    expect(accounts.first.name, 'My Bank');
    expect(
      accounts.first.userId,
      'u1',
      reason: 'Should map to the current profile id',
    );

    expect(categories.length, 1);
    expect(categories.first.name, 'Groceries');

    expect(tags.length, 1);
    expect(tags.first.name, 'Urgent');

    expect(transactions.length, 1);
    expect(transactions.first.amount, 5000);
    expect(transactions.first.categoryId, 'c1');
    expect(transactions.first.accountId, 'a1');

    final budgets = await db.select(db.budgets).get();
    final savingsGoals = await db.select(db.savingsGoals).get();
    final automaticTransactions =
        await db.select(db.automaticTransactions).get();

    expect(budgets.length, 1);
    expect(budgets.first.id, 'b1');

    expect(savingsGoals.length, 1);
    expect(savingsGoals.first.name, 'Car');

    expect(automaticTransactions.length, 1);
    expect(automaticTransactions.first.name, 'Rent');

    await db.close();
  });
}
