import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_automatic_transaction_repository.dart';
import 'package:stalvi/domain/usecases/automatic_transactions/crud_automatic_transactions_usecase.dart';

class MockAutomaticTransactionRepository extends Mock
    implements IAutomaticTransactionRepository {}

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
      when(() => repository.createAutomaticTransaction(any()))
          .thenAnswer((_) async => txn);
      final result = await createUseCase.execute(txn);
      expect(result, txn);
      verify(() => repository.createAutomaticTransaction(txn)).called(1);
    });

    test('read execute calls repository', () async {
      when(() => repository.getAutomaticTransactionById('1'))
          .thenAnswer((_) async => txn);
      final result = await readUseCase.execute('1');
      expect(result, txn);
      verify(() => repository.getAutomaticTransactionById('1')).called(1);
    });

    test('read executeAll calls repository', () async {
      when(() => repository.getAllAutomaticTransactions())
          .thenAnswer((_) async => [txn]);
      final result = await readUseCase.executeAll();
      expect(result, [txn]);
      verify(() => repository.getAllAutomaticTransactions()).called(1);
    });

    test('update execute calls repository', () async {
      when(() => repository.updateAutomaticTransaction(any()))
          .thenAnswer((_) async => txn);
      final result = await updateUseCase.execute(txn);
      expect(result, txn);
      verify(() => repository.updateAutomaticTransaction(txn)).called(1);
    });

    test('delete execute calls repository', () async {
      when(() => repository.deleteAutomaticTransaction('1'))
          .thenAnswer((_) async => null);
      await deleteUseCase.execute('1');
      verify(() => repository.deleteAutomaticTransaction('1')).called(1);
    });
  });
}
