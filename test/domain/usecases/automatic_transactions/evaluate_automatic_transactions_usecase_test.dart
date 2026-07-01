import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/recurrence_type.dart';
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

    test(
        'creates transaction and updates nextExecutionDate when due (intervalDays)',
        () async {
      final now = DateTime.now();
      final pastDate = now.subtract(const Duration(days: 1));

      final autoTxn = AutomaticTransaction(
        id: '1',
        name: 'Test',
        amount: 1000,
        currency: 'USD',
        type: TransactionType.expense,
        accountId: 'acc1',
        categoryId: null,
        tagId: null,
        notes: null,
        recurrenceType: RecurrenceType.intervalDays,
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

      final captured =
          verify(() => automaticRepo.updateAutomaticTransaction(captureAny()))
              .captured;
      final updatedAutoTxn = captured.first as AutomaticTransaction;

      expect(updatedAutoTxn.nextExecutionDate,
          equals(pastDate.add(const Duration(days: 30))));
    });

    test(
        'creates transaction and updates nextExecutionDate when due (specificDayOfMonth)',
        () async {
      final now = DateTime(2026, 1, 31);
      final pastDate = DateTime(2026, 1, 31); // Jan 31

      final autoTxn = AutomaticTransaction(
        id: '1',
        name: 'Test',
        amount: 1000,
        currency: 'USD',
        type: TransactionType.expense,
        accountId: 'acc1',
        categoryId: null,
        tagId: null,
        notes: null,
        recurrenceType: RecurrenceType.specificDayOfMonth,
        recurrenceDays: 31, // Try to set it to 31 next month
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

      final captured =
          verify(() => automaticRepo.updateAutomaticTransaction(captureAny()))
              .captured;
      final updatedAutoTxn = captured.first as AutomaticTransaction;

      // Should clamp to Feb 28
      expect(updatedAutoTxn.nextExecutionDate.month, equals(2));
      expect(updatedAutoTxn.nextExecutionDate.day, equals(28));
      expect(updatedAutoTxn.nextExecutionDate.year, equals(2026));
    });

    test('does not create transaction when not due', () async {
      final now = DateTime.now();
      final futureDate = now.add(const Duration(days: 1));

      final autoTxn = AutomaticTransaction(
        id: '1',
        name: 'Test',
        amount: 1000,
        currency: 'USD',
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
