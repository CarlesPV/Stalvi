import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_automatic_transaction_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/usecases/automatic_transactions/evaluate_automatic_transactions_usecase.dart';

class MockAutomaticTransactionRepository extends Mock
    implements IAutomaticTransactionRepository {}

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

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
      useCase =
          EvaluateAutomaticTransactionsUseCase(automaticRepo, transactionRepo);
    });

    test('creates transaction and updates nextExecutionDate when due',
        () async {
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

      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);
      when(() => transactionRepo.createTransaction(any()))
          .thenAnswer((_) async => dummyTxn);
      when(() => automaticRepo.updateAutomaticTransaction(any()))
          .thenAnswer((_) async => autoTxn);

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

      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);

      await useCase.execute();

      verify(() => automaticRepo.getAllAutomaticTransactions()).called(1);
      verifyNever(() => transactionRepo.createTransaction(any()));
      verifyNever(() => automaticRepo.updateAutomaticTransaction(any()));
    });
  });
}
