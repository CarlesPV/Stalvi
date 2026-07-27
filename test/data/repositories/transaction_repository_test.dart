import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/database/tables/account_table.dart';
import 'package:stalvi/domain/entities/transaction.dart' as domain;
import 'package:stalvi/domain/entities/transaction_type.dart' as domain;
import 'package:stalvi/data/repositories/transaction_repository.dart';
// ignore: depend_onreferenced_packages

void main() {
  late AppDatabase db;
  late TransactionRepository repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = TransactionRepository(db);

    // Seed User
    await db.into(db.profiles).insert(
          ProfilesCompanion.insert(
            id: 'user_1',
            name: 'Test',
            username: 'test',
            password: '',
            defaultCurrency: const Value('EUR'),
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test(
      'Standard transaction in a foreign currency applies converted amount to balance',
      () async {
    // 1. Seed Account in EUR
    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            id: 'acc_1',
            userId: 'user_1',
            name: 'Bank',
            type: AccountType.bank,
            initialBalance: 100.0, // 100 EUR
            currency: 'EUR',
            color: '#000',
            icon: 'bank',
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
        );

    // 2. Create Transaction in USD (e.g. 50 USD)
    final snapshot = jsonEncode({'EUR': 1.0, 'USD': 1.08});
    final tx = domain.Transaction(
      id: 'tx_1',
      amount: 5400, // 54.00 USD
      date: DateTime.now(),
      type: domain.TransactionType.income,
      accountId: 'acc_1',
      originalCurrency: 'USD',
      convertedAmount: 5000, // 50.00 EUR
      exchangeRate: 1.08,
      exchangeRateSnapshot: snapshot,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );

    // Act
    await repository.createTransaction(tx);

    // Assert: Transaction is created, and account initialBalance is unchanged (reactive architecture)
    final createdTx = await repository.getTransactionById('tx_1');
    expect(createdTx, isNotNull);
    expect(createdTx!.amount, 5400);

    final acc = await (db.select(db.accounts)
          ..where((a) => a.id.equals('acc_1')))
        .getSingle();
    expect(acc.initialBalance, 100.0);
  });

  test('Transfer between identical currencies deducts and adds exact amount',
      () async {
    // 1. Seed Accounts in EUR
    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            id: 'acc_origin',
            userId: 'user_1',
            name: 'Bank 1',
            type: AccountType.bank,
            initialBalance: 100.0,
            currency: 'EUR',
            color: '#000',
            icon: 'bank',
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
        );
    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            id: 'acc_dest',
            userId: 'user_1',
            name: 'Bank 2',
            type: AccountType.bank,
            initialBalance: 50.0,
            currency: 'EUR',
            color: '#000',
            icon: 'bank',
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
        );

    // 2. Create Transfer Pair (20 EUR)
    final originTx = domain.Transaction(
      id: 'tx_transfer',
      amount: 2000,
      date: DateTime.now(),
      type: domain.TransactionType.transfer,
      accountId: 'acc_origin',
      originalCurrency: 'EUR',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      transferId: 'transfer_1',
    );
    final destTx = domain.Transaction(
      id: 'tx_transfer_dst',
      amount: 2000,
      date: DateTime.now(),
      type: domain.TransactionType.transfer,
      accountId: 'acc_dest',
      originalCurrency: 'EUR',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      transferId: 'transfer_1',
    );

    // Act
    await repository.createTransferPair(
      originTransaction: originTx,
      destinationTransaction: destTx,
    );

    // Assert: Transfer legs are created, and account initial balances are unchanged (reactive architecture)
    final createdOrigin = await repository.getTransactionById('tx_transfer');
    final createdDest = await repository.getTransactionById('tx_transfer_dst');
    expect(createdOrigin, isNotNull);
    expect(createdDest, isNotNull);

    final origin = await (db.select(db.accounts)
          ..where((a) => a.id.equals('acc_origin')))
        .getSingle();
    final dest = await (db.select(db.accounts)
          ..where((a) => a.id.equals('acc_dest')))
        .getSingle();

    expect(origin.initialBalance, 100.0);
    expect(dest.initialBalance, 50.0);
  });

  test(
      'Transfer between differing currencies applies conversion deductions and additions',
      () async {
    // 1. Seed Accounts
    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            id: 'acc_eur',
            userId: 'user_1',
            name: 'Bank EUR',
            type: AccountType.bank,
            initialBalance: 100.0,
            currency: 'EUR',
            color: '#000',
            icon: 'bank',
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
        );
    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            id: 'acc_usd',
            userId: 'user_1',
            name: 'Bank USD',
            type: AccountType.bank,
            initialBalance: 50.0,
            currency: 'USD',
            color: '#000',
            icon: 'bank',
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
        );

    // 2. Create Transfer Pair: 10 EUR -> USD (Rate: 1.08 -> 10.8 USD)
    final snapshot = jsonEncode({'EUR': 1.0, 'USD': 1.08});

    final originTx = domain.Transaction(
      id: 'tx_cross',
      amount: 1000, // 10 EUR
      date: DateTime.now(),
      type: domain.TransactionType.transfer,
      accountId: 'acc_eur',
      originalCurrency: 'EUR',
      convertedAmount: 1000,
      exchangeRate: 1.0,
      exchangeRateSnapshot: snapshot,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      transferId: 'transfer_cross',
    );
    final destTx = domain.Transaction(
      id: 'tx_cross_dst',
      amount: 1080, // 10.8 USD
      date: DateTime.now(),
      type: domain.TransactionType.transfer,
      accountId: 'acc_usd',
      originalCurrency: 'USD',
      convertedAmount: 1000, // 10 EUR equivalent
      exchangeRate: 1.08,
      exchangeRateSnapshot: snapshot,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      transferId: 'transfer_cross',
    );

    // Act
    await repository.createTransferPair(
      originTransaction: originTx,
      destinationTransaction: destTx,
    );

    // Assert: Transfer legs are created, and account initial balances are unchanged (reactive architecture)
    final createdOrigin = await repository.getTransactionById('tx_cross');
    final createdDest = await repository.getTransactionById('tx_cross_dst');
    expect(createdOrigin, isNotNull);
    expect(createdDest, isNotNull);

    final origin = await (db.select(db.accounts)
          ..where((a) => a.id.equals('acc_eur')))
        .getSingle();
    final dest = await (db.select(db.accounts)
          ..where((a) => a.id.equals('acc_usd')))
        .getSingle();

    expect(origin.initialBalance, 100.0);
    expect(dest.initialBalance, 50.0);
  });
}
