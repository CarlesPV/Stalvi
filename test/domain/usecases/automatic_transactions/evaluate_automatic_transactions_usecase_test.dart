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

      expect(
        updatedAutoTxn.nextExecutionDate,
        equals(pastDate.add(const Duration(days: 30))),
      );
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

    test('intervalDays advances the exact number of days', () async {
      final now = DateTime(2026, 1, 15);
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
        recurrenceDays: 45, // exactly 45 days
        nextExecutionDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
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

      // Jan 1 + 45 days = Feb 15
      expect(updatedAutoTxn.nextExecutionDate,
          equals(DateTime(2026, 1, 1).add(const Duration(days: 45))));
      expect(updatedAutoTxn.nextExecutionDate.month, equals(2));
      expect(updatedAutoTxn.nextExecutionDate.day, equals(15));
    });

    test(
        'specificDayOfMonth falls on February 28th in non-leap year when day is 31',
        () async {
      final now = DateTime(2026, 1, 31);
      final autoTxn = AutomaticTransaction(
        id: '2',
        name: 'Test',
        amount: 100,
        currency: 'USD',
        type: TransactionType.expense,
        accountId: 'acc1',
        categoryId: null,
        tagId: null,
        notes: null,
        recurrenceType: RecurrenceType.specificDayOfMonth,
        recurrenceDays: 31,
        nextExecutionDate: DateTime(2026, 1, 31),
        createdAt: DateTime(2026, 1, 31),
      );
      final dummyTxn = Transaction(
        id: 'dummy',
        amount: 100,
        date: now,
        type: TransactionType.expense,
        accountId: 'acc1',
        originalCurrency: 'USD',
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

      expect(updatedAutoTxn.nextExecutionDate.month, equals(2));
      expect(updatedAutoTxn.nextExecutionDate.day, equals(28));
      expect(updatedAutoTxn.nextExecutionDate.year, equals(2026));
    });

    test(
        'specificDayOfMonth falls on February 29th in leap year when day is 31',
        () async {
      final now = DateTime(2024, 1, 31);
      final autoTxn = AutomaticTransaction(
        id: '2',
        name: 'Test',
        amount: 100,
        currency: 'USD',
        type: TransactionType.expense,
        accountId: 'acc1',
        categoryId: null,
        tagId: null,
        notes: null,
        recurrenceType: RecurrenceType.specificDayOfMonth,
        recurrenceDays: 31,
        nextExecutionDate: DateTime(2024, 1, 31),
        createdAt: DateTime(2024, 1, 31),
      );
      final dummyTxn = Transaction(
        id: 'dummy',
        amount: 100,
        date: now,
        type: TransactionType.expense,
        accountId: 'acc1',
        originalCurrency: 'USD',
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

      expect(updatedAutoTxn.nextExecutionDate.month, equals(2));
      expect(updatedAutoTxn.nextExecutionDate.day, equals(29));
      expect(updatedAutoTxn.nextExecutionDate.year, equals(2024));
    });

    test('specificDayOfMonth falls on April 30th when day is 31', () async {
      final now = DateTime(2026, 3, 31);
      final autoTxn = AutomaticTransaction(
        id: '2',
        name: 'Test',
        amount: 100,
        currency: 'USD',
        type: TransactionType.expense,
        accountId: 'acc1',
        categoryId: null,
        tagId: null,
        notes: null,
        recurrenceType: RecurrenceType.specificDayOfMonth,
        recurrenceDays: 31,
        nextExecutionDate: DateTime(2026, 3, 31),
        createdAt: DateTime(2026, 3, 31),
      );
      final dummyTxn = Transaction(
        id: 'dummy',
        amount: 100,
        date: now,
        type: TransactionType.expense,
        accountId: 'acc1',
        originalCurrency: 'USD',
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

      expect(updatedAutoTxn.nextExecutionDate.month, equals(4));
      expect(updatedAutoTxn.nextExecutionDate.day, equals(30));
      expect(updatedAutoTxn.nextExecutionDate.year, equals(2026));
    });
    test(
        'specificDayOfMonth from Feb 28 goes to Mar 31 when recurrenceDays is 31',
        () async {
      final now = DateTime(2026, 2, 28);
      final autoTxn = AutomaticTransaction(
        id: '3',
        name: 'Test',
        amount: 100,
        currency: 'USD',
        type: TransactionType.expense,
        accountId: 'acc1',
        categoryId: null,
        tagId: null,
        notes: null,
        recurrenceType: RecurrenceType.specificDayOfMonth,
        recurrenceDays: 31,
        nextExecutionDate: DateTime(2026, 2, 28),
        createdAt: DateTime(2026, 1, 31),
      );
      final dummyTxn = Transaction(
        id: 'dummy',
        amount: 100,
        date: now,
        type: TransactionType.expense,
        accountId: 'acc1',
        originalCurrency: 'USD',
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

      expect(updatedAutoTxn.nextExecutionDate.month, equals(3));
      expect(updatedAutoTxn.nextExecutionDate.day, equals(31));
      expect(updatedAutoTxn.nextExecutionDate.year, equals(2026));
    });
  });
}
