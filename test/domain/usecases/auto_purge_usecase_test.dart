import 'dart:ffi';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/domain/usecases/auto_purge_usecase.dart';
// ignore: depend_on_referenced_packages
import 'package:stalvi/data/database/tables/transaction_table.dart';
import 'package:stalvi/data/database/tables/account_table.dart';
import 'package:sqlite3/open.dart';
import 'package:uuid/uuid.dart';

void main() {
  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () {
      return DynamicLibrary.open('libsqlite3.so.0');
    });
  });

  late AppDatabase db;
  late AutoPurgeUseCase useCase;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    useCase = AutoPurgeUseCase(db.trashDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('AutoPurgeUseCase deletes 31-day old items and keeps 29-day old items',
      () async {
    const uuid = Uuid();
    final now = DateTime.now();

    final id31 = uuid.v4();
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: id31,
            name: '31 Days Old',
            icon: 'icon',
            color: 'color',
            isDeleted: const Value(true),
            createdAt: now,
            modifiedAt: now.subtract(const Duration(days: 31)),
          ),
        );

    final id29 = uuid.v4();
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: id29,
            name: '29 Days Old',
            icon: 'icon',
            color: 'color',
            isDeleted: const Value(true),
            createdAt: now,
            modifiedAt: now.subtract(const Duration(days: 29)),
          ),
        );

    await useCase.execute();

    final cat31 = await (db.select(db.categories)
          ..where((c) => c.id.equals(id31)))
        .getSingleOrNull();
    final cat29 = await (db.select(db.categories)
          ..where((c) => c.id.equals(id29)))
        .getSingleOrNull();

    expect(cat31, isNull);
    expect(cat29, isNotNull);
  });

  test(
      'AutoPurgeUseCase deletes 31-day old automatic transactions and keeps 29-day old ones',
      () async {
    const uuid = Uuid();
    final now = DateTime.now();
    final accountId = uuid.v4();

    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            id: accountId,
            userId: 'user-id',
            name: 'Test Account',
            type: AccountType.bank,
            initialBalance: 0.0,
            currency: 'EUR',
            icon: 'icon',
            color: 'color',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    final id31 = uuid.v4();
    await db.into(db.automaticTransactions).insert(
          AutomaticTransactionsCompanion.insert(
            id: id31,
            name: '31 Days Old',
            amount: 100,
            type: TransactionType.expense,
            accountId: accountId,
            recurrenceDays: 30,
            nextExecutionDate: now,
            createdAt: now,
            isDeleted: const Value(true),
            deletedAt: Value(now.subtract(const Duration(days: 31))),
          ),
        );

    final id29 = uuid.v4();
    await db.into(db.automaticTransactions).insert(
          AutomaticTransactionsCompanion.insert(
            id: id29,
            name: '29 Days Old',
            amount: 100,
            type: TransactionType.expense,
            accountId: accountId,
            recurrenceDays: 30,
            nextExecutionDate: now,
            createdAt: now,
            isDeleted: const Value(true),
            deletedAt: Value(now.subtract(const Duration(days: 29))),
          ),
        );

    await useCase.execute();

    final auto31 = await (db.select(db.automaticTransactions)
          ..where((a) => a.id.equals(id31)))
        .getSingleOrNull();
    final auto29 = await (db.select(db.automaticTransactions)
          ..where((a) => a.id.equals(id29)))
        .getSingleOrNull();

    expect(auto31, isNull);
    expect(auto29, isNotNull);
  });
}
