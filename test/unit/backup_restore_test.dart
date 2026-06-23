import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/repositories/export_service_impl.dart';
import 'package:stalvi/data/repositories/import_service_impl.dart';
import 'package:stalvi/domain/entities/account.dart' as ent_acc;
import 'package:stalvi/domain/entities/account_type.dart' as ent_acc_type;
import 'package:stalvi/domain/entities/category.dart' as ent_cat;
import 'package:stalvi/domain/entities/tag.dart' as ent_tag;
import 'package:stalvi/domain/entities/transaction.dart' as t;
import 'package:stalvi/domain/entities/transaction_type.dart' as t_type;

void main() {
  test('export and import relational data', () async {
    final executor = NativeDatabase.memory();
    final db = AppDatabase.forTesting(executor);

    // Create the schema
    await db.customStatement('PRAGMA foreign_keys = ON');

    final exportService = ExportServiceImpl();
    final importService =
        ImportServiceImpl(database: db, exportService: exportService);

    // Seed a profile
    await db.into(db.profiles).insert(ProfilesCompanion.insert(
        id: 'u1',
        name: 'User 1',
        username: 'user1',
        password: 'pwd',
        defaultCurrency: const Value('USD'),
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now()));

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
        modifiedAt: now);

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
        modifiedAt: now);

    // Generate the backup file
    final exported = await exportService.generateEncryptedJson(
        accounts: [acc],
        categories: [cat],
        tags: [tag],
        transactions: [tx],
        password: 'mypassword');

    // Wipe and Import
    await importService.restoreFromEncryptedJson(exported.bytes,
        password: 'mypassword');

    // Verify
    final accounts = await db.select(db.accounts).get();
    final categories = await db.select(db.categories).get();
    final tags = await db.select(db.tags).get();
    final transactions = await db.select(db.transactions).get();

    expect(accounts.length, 1);
    expect(accounts.first.name, 'My Bank');
    expect(accounts.first.userId, 'u1',
        reason: 'Should map to the current profile id');

    expect(categories.length, 1);
    expect(categories.first.name, 'Groceries');

    expect(tags.length, 1);
    expect(tags.first.name, 'Urgent');

    expect(transactions.length, 1);
    expect(transactions.first.amount, 5000);
    expect(transactions.first.categoryId, 'c1');
    expect(transactions.first.accountId, 'a1');

    await db.close();
  });
}
