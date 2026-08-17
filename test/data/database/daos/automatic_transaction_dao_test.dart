import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/database/daos/automatic_transaction_dao.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart'
    show TransactionType;
import 'package:stalvi/domain/entities/recurrence_type.dart';

void main() {
  late AppDatabase database;
  late AutomaticTransactionDao dao;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dao = database.automaticTransactionDao;
  });

  tearDown(() async {
    await database.close();
  });

  group('AutomaticTransactionDao', () {
    test(
      'insertAutomaticTransaction inserts data correctly with nullables absent',
      () async {
        // Disable foreign keys so we don't have to create Profile and Account records
        await database.customStatement('PRAGMA foreign_keys = OFF');

        // Insert AutomaticTransaction using the DAO
        final companion = AutomaticTransactionsCompanion.insert(
          id: 'txn1',
          name: 'Test Txn',
          amount: 100,
          currency: const Value('EUR'),
          type: TransactionType.expense,
          accountId: 'acc1',
          // categoryId and tagId are omitted (absent by default)
          recurrenceType: const Value(RecurrenceType.intervalDays),
          recurrenceDays: 30,
          nextExecutionDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final rowId = await dao.insertAutomaticTransaction(companion);
        expect(rowId, isPositive);

        final result = await dao.watchAllAutomaticTransactions().first;
        expect(result.length, 1);
        expect(result.first.id, 'txn1');
        expect(result.first.categoryId, isNull);
        expect(result.first.tagId, isNull);
      },
    );
  });
}
