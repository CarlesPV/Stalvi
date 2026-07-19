import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/recurrence_type.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/transaction.dart' as dtxn;
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_automatic_transaction_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/usecases/execute_recurring_transactions_usecase.dart';

import 'execute_recurring_transactions_usecase_test.mocks.dart';

@GenerateMocks([
  IAutomaticTransactionRepository,
  ITransactionRepository,
  IAccountRepository,
  IProfileRepository,
  IExchangeRateRepository,
])
void main() {
  group(
      'ExecuteRecurringTransactionsUseCase Date Calculations (UTC+2 Boundaries)',
      () {
    // Helper to represent 00:00 UTC+2 as a UTC DateTime instant (22:00 UTC the day prior)
    DateTime utcPlus2(int year, int month, int day) {
      return DateTime.utc(year, month, day).subtract(const Duration(hours: 2));
    }

    test('IntervalDays advances correctly', () {
      final from =
          utcPlus2(2026, 7, 17); // 00:00:00 UTC+2 -> 2026-07-16 22:00 UTC
      final nextDate =
          ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.intervalDays,
        5,
      );
      expect(nextDate, utcPlus2(2026, 7, 22));
    });

    test('Weekly advances exactly 7 days', () {
      final from = utcPlus2(2026, 7, 17);
      final nextDate =
          ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.weekly,
        0, // unused for weekly
      );
      expect(nextDate, utcPlus2(2026, 7, 24));
    });

    test('Monthly advances one calendar month (same day)', () {
      final from = utcPlus2(2026, 7, 15);
      final nextDate =
          ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.monthly,
        0, // unused
      );
      expect(nextDate, utcPlus2(2026, 8, 15));
    });

    test('Monthly clamps to end of month (e.g., Jan 31 -> Feb 28)', () {
      final from = utcPlus2(2026, 1, 31);
      final nextDate =
          ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.monthly,
        0,
      );
      expect(nextDate, utcPlus2(2026, 2, 28));
    });

    test('Yearly advances one calendar year', () {
      final from = utcPlus2(2026, 7, 17);
      final nextDate =
          ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.yearly,
        0, // unused
      );
      expect(nextDate, utcPlus2(2027, 7, 17));
    });

    test('Yearly handles leap year (Feb 29 -> Feb 28 next year)', () {
      final from = utcPlus2(2024, 2, 29); // 2024 is a leap year
      final nextDate =
          ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.yearly,
        0,
      );
      expect(nextDate, utcPlus2(2025, 2, 28));
    });

    test('SpecificDayOfMonth advances to the specific day of the next month',
        () {
      final from = utcPlus2(2026, 7, 17);
      final nextDate =
          ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.specificDayOfMonth,
        5, // The 5th day of the month
      );
      // Advances to August, day 5
      expect(nextDate, utcPlus2(2026, 8, 5));
    });

    test('SpecificDayOfMonth clamps if target day exceeds next month days', () {
      final from = utcPlus2(2026, 1, 15);
      final nextDate =
          ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.specificDayOfMonth,
        31, // Target day is 31
      );
      // Advances to February, max days is 28
      expect(nextDate, utcPlus2(2026, 2, 28));
    });

    test('Year rollover works correctly for Monthly', () {
      final from = utcPlus2(2026, 12, 15);
      final nextDate =
          ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.monthly,
        0,
      );
      expect(nextDate, utcPlus2(2027, 1, 15));
    });
  });

  group('ExecuteRecurringTransactionsUseCase Idempotency', () {
    late ExecuteRecurringTransactionsUseCase usecase;
    late MockIAutomaticTransactionRepository mockAutomaticRepo;
    late MockITransactionRepository mockTransactionRepo;
    late MockIAccountRepository mockAccountRepo;
    late MockIProfileRepository mockProfileRepo;
    late MockIExchangeRateRepository mockExchangeRateRepo;

    setUp(() {
      mockAutomaticRepo = MockIAutomaticTransactionRepository();
      mockTransactionRepo = MockITransactionRepository();
      mockAccountRepo = MockIAccountRepository();
      mockProfileRepo = MockIProfileRepository();
      mockExchangeRateRepo = MockIExchangeRateRepository();

      usecase = ExecuteRecurringTransactionsUseCase(
        mockAutomaticRepo,
        mockTransactionRepo,
        mockAccountRepo,
        mockProfileRepo,
        mockExchangeRateRepo,
      );
    });

    test('Creates a transaction if it does not exist (Idempotency check)',
        () async {
      final autoTxn = AutomaticTransaction(
        id: 'auto-1',
        name: 'Netflix',
        amount: 1500,
        currency: 'EUR',
        type: TransactionType.expense,
        accountId: 'acc-1',
        categoryId: 'cat-1',
        recurrenceType: RecurrenceType.monthly,
        recurrenceDays: 1,
        nextExecutionDate:
            DateTime.now().toUtc().subtract(const Duration(days: 1)),
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      );

      when(mockAutomaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);

      // Not found, so it should be created
      when(mockTransactionRepo.getTransactionById(any))
          .thenAnswer((_) async => null);

      when(mockAccountRepo.getAccountById(any)).thenAnswer((_) async => null);

      when(mockTransactionRepo.createTransaction(any)).thenAnswer(
        (_) async => dtxn.Transaction(
          id: 'mock-id',
          amount: 1500,
          date: DateTime.now().toUtc(),
          type: TransactionType.expense,
          accountId: 'acc-1',
          categoryId: 'cat-1',
          originalCurrency: 'EUR',
          createdAt: DateTime.now().toUtc(),
          modifiedAt: DateTime.now().toUtc(),
        ),
      );

      when(mockAutomaticRepo.updateAutomaticTransaction(any))
          .thenAnswer((_) async => autoTxn);

      await usecase.execute();

      verify(mockTransactionRepo.getTransactionById(any)).called(1);
      verify(mockTransactionRepo.createTransaction(any)).called(1);
      verify(mockAutomaticRepo.updateAutomaticTransaction(any)).called(1);
    });

    test('Skips creation if transaction already exists (Idempotency check)',
        () async {
      final autoTxn = AutomaticTransaction(
        id: 'auto-2',
        name: 'Spotify',
        amount: 1000,
        currency: 'EUR',
        type: TransactionType.expense,
        accountId: 'acc-1',
        categoryId: 'cat-1',
        recurrenceType: RecurrenceType.monthly,
        recurrenceDays: 1,
        nextExecutionDate:
            DateTime.now().toUtc().subtract(const Duration(days: 1)),
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      );

      when(mockAutomaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);

      // Found, so it should NOT be created
      when(mockTransactionRepo.getTransactionById(any)).thenAnswer(
        (_) async => dtxn.Transaction(
          id: 'existing-id',
          amount: 1000,
          date: DateTime.now().toUtc(),
          type: TransactionType.expense,
          accountId: 'acc-1',
          categoryId: 'cat-1',
          originalCurrency: 'EUR',
          createdAt: DateTime.now().toUtc(),
          modifiedAt: DateTime.now().toUtc(),
        ),
      );

      when(mockAutomaticRepo.updateAutomaticTransaction(any))
          .thenAnswer((_) async => autoTxn);

      await usecase.execute();

      verify(mockTransactionRepo.getTransactionById(any)).called(1);
      verifyNever(mockTransactionRepo.createTransaction(any));
      verify(mockAutomaticRepo.updateAutomaticTransaction(any)).called(1);
    });
  });
}
