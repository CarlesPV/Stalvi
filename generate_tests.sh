#!/bin/bash

mkdir -p test/data/daos test/data/mappers test/domain/usecases/automatic_transactions

cat << 'EOF' > test/data/mappers/automatic_transaction_mapper_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:stalvi/data/mappers/automatic_transaction_mapper.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart' as db_table;

void main() {
  group('AutomaticTransactionMapper', () {
    final now = DateTime.now();
    final entity = AutomaticTransactionEntity(
      id: '1',
      amount: 1000,
      type: db_table.TransactionType.expense,
      accountId: 'acc1',
      categoryId: 'cat1',
      tagId: 'tag1',
      notes: 'Test note',
      recurrenceDays: 30,
      nextExecutionDate: now,
      createdAt: now,
    );

    final model = AutomaticTransaction(
      id: '1',
      amount: 1000,
      type: TransactionType.expense,
      accountId: 'acc1',
      categoryId: 'cat1',
      tagId: 'tag1',
      notes: 'Test note',
      recurrenceDays: 30,
      nextExecutionDate: now,
      createdAt: now,
    );

    test('fromEntity maps correctly', () {
      final result = AutomaticTransactionMapper.fromEntity(entity);
      expect(result.id, model.id);
      expect(result.amount, model.amount);
      expect(result.type, model.type);
      expect(result.accountId, model.accountId);
      expect(result.categoryId, model.categoryId);
      expect(result.tagId, model.tagId);
      expect(result.notes, model.notes);
      expect(result.recurrenceDays, model.recurrenceDays);
      expect(result.nextExecutionDate, model.nextExecutionDate);
      expect(result.createdAt, model.createdAt);
    });

    test('toCompanion maps correctly', () {
      final companion = AutomaticTransactionMapper.toCompanion(model);
      expect(companion.id.value, model.id);
      expect(companion.amount.value, model.amount);
      expect(companion.type.value, db_table.TransactionType.expense);
      expect(companion.accountId.value, model.accountId);
      expect(companion.categoryId.value, model.categoryId);
      expect(companion.tagId.value, model.tagId);
      expect(companion.notes.value, model.notes);
      expect(companion.recurrenceDays.value, model.recurrenceDays);
      expect(companion.nextExecutionDate.value, model.nextExecutionDate);
      expect(companion.createdAt.value, model.createdAt);
    });
  });
}
EOF

cat << 'EOF' > test/domain/usecases/automatic_transactions/crud_automatic_transactions_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_automatic_transaction_repository.dart';
import 'package:stalvi/domain/usecases/automatic_transactions/crud_automatic_transactions_usecase.dart';

class MockAutomaticTransactionRepository extends Mock implements IAutomaticTransactionRepository {}

class FakeAutomaticTransaction extends Fake implements AutomaticTransaction {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAutomaticTransaction());
  });

  group('CRUD Automatic Transactions UseCases', () {
    late MockAutomaticTransactionRepository repository;
    late CreateAutomaticTransactionUseCase createUseCase;
    late ReadAutomaticTransactionUseCase readUseCase;
    late UpdateAutomaticTransactionUseCase updateUseCase;
    late DeleteAutomaticTransactionUseCase deleteUseCase;

    final now = DateTime.now();
    final txn = AutomaticTransaction(
      id: '1',
      amount: 1000,
      type: TransactionType.expense,
      accountId: 'acc1',
      categoryId: null,
      tagId: null,
      notes: null,
      recurrenceDays: 30,
      nextExecutionDate: now,
      createdAt: now,
    );

    setUp(() {
      repository = MockAutomaticTransactionRepository();
      createUseCase = CreateAutomaticTransactionUseCase(repository);
      readUseCase = ReadAutomaticTransactionUseCase(repository);
      updateUseCase = UpdateAutomaticTransactionUseCase(repository);
      deleteUseCase = DeleteAutomaticTransactionUseCase(repository);
    });

    test('create execute calls repository', () async {
      when(() => repository.createAutomaticTransaction(any())).thenAnswer((_) async => txn);
      final result = await createUseCase.execute(txn);
      expect(result, txn);
      verify(() => repository.createAutomaticTransaction(txn)).called(1);
    });

    test('read execute calls repository', () async {
      when(() => repository.getAutomaticTransactionById('1')).thenAnswer((_) async => txn);
      final result = await readUseCase.execute('1');
      expect(result, txn);
      verify(() => repository.getAutomaticTransactionById('1')).called(1);
    });

    test('read executeAll calls repository', () async {
      when(() => repository.getAllAutomaticTransactions()).thenAnswer((_) async => [txn]);
      final result = await readUseCase.executeAll();
      expect(result, [txn]);
      verify(() => repository.getAllAutomaticTransactions()).called(1);
    });

    test('update execute calls repository', () async {
      when(() => repository.updateAutomaticTransaction(any())).thenAnswer((_) async => txn);
      final result = await updateUseCase.execute(txn);
      expect(result, txn);
      verify(() => repository.updateAutomaticTransaction(txn)).called(1);
    });

    test('delete execute calls repository', () async {
      when(() => repository.deleteAutomaticTransaction('1')).thenAnswer((_) async => null);
      await deleteUseCase.execute('1');
      verify(() => repository.deleteAutomaticTransaction('1')).called(1);
    });
  });
}
EOF

cat << 'EOF' > test/domain/usecases/automatic_transactions/evaluate_automatic_transactions_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_automatic_transaction_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/usecases/automatic_transactions/evaluate_automatic_transactions_usecase.dart';

class MockAutomaticTransactionRepository extends Mock implements IAutomaticTransactionRepository {}
class MockTransactionRepository extends Mock implements ITransactionRepository {}

class FakeTransaction extends Fake implements Transaction {}
class FakeAutomaticTransaction extends Fake implements AutomaticTransaction {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTransaction());
    registerFallbackValue(FakeAutomaticTransaction());
  });

  group('EvaluateAutomaticTransactionsUseCase', () {
    late MockAutomaticTransactionRepository automaticRepo;
    late MockTransactionRepository transactionRepo;
    late EvaluateAutomaticTransactionsUseCase useCase;

    setUp(() {
      automaticRepo = MockAutomaticTransactionRepository();
      transactionRepo = MockTransactionRepository();
      useCase = EvaluateAutomaticTransactionsUseCase(automaticRepo, transactionRepo);
    });

    test('creates transaction and updates nextExecutionDate when due', () async {
      final now = DateTime.now();
      final pastDate = now.subtract(const Duration(days: 1));
      
      final autoTxn = AutomaticTransaction(
        id: '1',
        amount: 1000,
        type: TransactionType.expense,
        accountId: 'acc1',
        categoryId: null,
        tagId: null,
        notes: null,
        recurrenceDays: 30,
        nextExecutionDate: pastDate,
        createdAt: pastDate,
      );

      final dummyTxn = Transaction(
        id: 'dummy',
        amount: 1000,
        date: now,
        type: TransactionType.expense,
        accountId: 'acc1',
        originalCurrency: 'EUR',
        createdAt: now,
        modifiedAt: now,
      );

      when(() => automaticRepo.getAllAutomaticTransactions()).thenAnswer((_) async => [autoTxn]);
      when(() => transactionRepo.createTransaction(any())).thenAnswer((_) async => dummyTxn);
      when(() => automaticRepo.updateAutomaticTransaction(any())).thenAnswer((_) async => autoTxn);

      await useCase.execute();

      verify(() => automaticRepo.getAllAutomaticTransactions()).called(1);
      verify(() => transactionRepo.createTransaction(any())).called(1);
      verify(() => automaticRepo.updateAutomaticTransaction(any())).called(1);
    });
    
    test('does not create transaction when not due', () async {
      final now = DateTime.now();
      final futureDate = now.add(const Duration(days: 1));
      
      final autoTxn = AutomaticTransaction(
        id: '1',
        amount: 1000,
        type: TransactionType.expense,
        accountId: 'acc1',
        categoryId: null,
        tagId: null,
        notes: null,
        recurrenceDays: 30,
        nextExecutionDate: futureDate,
        createdAt: now,
      );

      when(() => automaticRepo.getAllAutomaticTransactions()).thenAnswer((_) async => [autoTxn]);

      await useCase.execute();

      verify(() => automaticRepo.getAllAutomaticTransactions()).called(1);
      verifyNever(() => transactionRepo.createTransaction(any()));
      verifyNever(() => automaticRepo.updateAutomaticTransaction(any()));
    });
  });
}
EOF

