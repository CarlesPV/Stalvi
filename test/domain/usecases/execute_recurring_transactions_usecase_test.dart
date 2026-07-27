import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/recurrence_type.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_automatic_transaction_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/usecases/execute_recurring_transactions_usecase.dart';

import 'package:stalvi/domain/repositories/i_settings_repository.dart';
import 'package:stalvi/infrastructure/services/notification_service.dart';
import 'package:stalvi/domain/services/financial_threshold_service.dart';
import 'package:stalvi/domain/entities/transaction.dart';

import 'execute_recurring_transactions_usecase_test.mocks.dart';

@GenerateMocks([
  IAutomaticTransactionRepository,
  ITransactionRepository,
  IAccountRepository,
  IProfileRepository,
  IExchangeRateRepository,
  NotificationService,
  ISettingsRepository,
])
class FakeFinancialThresholdService implements IFinancialThresholdService {
  @override
  Future<List<ThresholdResult>> evaluateThresholds(
    List<Transaction> transactions,
  ) async {
    return [];
  }
}

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

    test(
        'SpecificDayOfMonth targets the current month if the day has not passed',
        () {
      final from = utcPlus2(2026, 7, 3);
      final nextDate =
          ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.specificDayOfMonth,
        5, // The 5th day of the month
      );
      // Targets July, day 5
      expect(nextDate, utcPlus2(2026, 7, 5));
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
      final from = utcPlus2(2026, 1, 31);
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

  group('ExecuteRecurringTransactionsUseCase Batch and Cycle Logic', () {
    late ExecuteRecurringTransactionsUseCase usecase;
    late MockIAutomaticTransactionRepository mockAutomaticRepo;
    late MockITransactionRepository mockTransactionRepo;
    late MockIAccountRepository mockAccountRepo;
    late MockIProfileRepository mockProfileRepo;
    late MockIExchangeRateRepository mockExchangeRateRepo;
    late FakeFinancialThresholdService fakeFinancialThresholdService;

    setUp(() {
      mockAutomaticRepo = MockIAutomaticTransactionRepository();
      mockTransactionRepo = MockITransactionRepository();
      mockAccountRepo = MockIAccountRepository();
      mockProfileRepo = MockIProfileRepository();
      mockExchangeRateRepo = MockIExchangeRateRepository();
      fakeFinancialThresholdService = FakeFinancialThresholdService();

      usecase = ExecuteRecurringTransactionsUseCase(
        mockAutomaticRepo,
        mockTransactionRepo,
        mockAccountRepo,
        mockProfileRepo,
        mockExchangeRateRepo,
        fakeFinancialThresholdService,
      );
    });

    test('Creates transactions in a single batch (Idempotency + Batch logic)',
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
        // Set next execution date to yesterday to force one cycle
        nextExecutionDate:
            DateTime.now().toUtc().subtract(const Duration(days: 1)),
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      );

      when(mockAutomaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);

      when(mockAccountRepo.getAccountById(any)).thenAnswer((_) async => null);

      when(mockTransactionRepo.createTransactions(any))
          .thenAnswer((_) async {});
      when(mockAutomaticRepo.updateAutomaticTransaction(any))
          .thenAnswer((_) async => autoTxn);

      await usecase.execute();

      // Verify createTransactions is called exactly once with 1 pending transaction
      verify(mockTransactionRepo.createTransactions(argThat(hasLength(1))))
          .called(1);
      verify(mockAutomaticRepo.updateAutomaticTransaction(any)).called(1);
    });

    test('Calculates exactly the missed cycles if device was off for 28 hours',
        () async {
      final nowUtc = DateTime.now().toUtc();

      final autoTxn = AutomaticTransaction(
        id: 'auto-daily',
        name: 'Daily Coffee',
        amount: 250,
        currency: 'EUR',
        type: TransactionType.expense,
        accountId: 'acc-1',
        categoryId: 'cat-1',
        recurrenceType: RecurrenceType.intervalDays,
        recurrenceDays: 1, // Daily
        // Assume device was off for 2 days, nextExecutionDate is 2 days ago
        nextExecutionDate: nowUtc.subtract(const Duration(days: 2)),
        isActive: true,
        createdAt: nowUtc.subtract(const Duration(days: 30)),
      );

      when(mockAutomaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);

      when(mockAccountRepo.getAccountById(any)).thenAnswer((_) async => null);

      when(mockTransactionRepo.createTransactions(any))
          .thenAnswer((_) async {});
      when(mockAutomaticRepo.updateAutomaticTransaction(any))
          .thenAnswer((_) async => autoTxn);

      await usecase.execute();

      // Verify createTransactions is called with exactly 3 transactions:
      // (1 for 2 days ago, 1 for 1 day ago, 1 for today)
      verify(mockTransactionRepo.createTransactions(argThat(hasLength(3))))
          .called(1);
    });

    test(
        'Dispatches local push notification when transaction is created and settings allow it',
        () async {
      final mockNotificationService = MockNotificationService();
      final mockSettingsRepo = MockISettingsRepository();

      final usecaseWithNotification = ExecuteRecurringTransactionsUseCase(
        mockAutomaticRepo,
        mockTransactionRepo,
        mockAccountRepo,
        mockProfileRepo,
        mockExchangeRateRepo,
        fakeFinancialThresholdService,
        mockNotificationService,
        mockSettingsRepo,
      );

      final autoTxn = AutomaticTransaction(
        id: 'auto-notify-1',
        name: 'Gym Subscription',
        amount: 3000,
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
      when(mockAccountRepo.getAccountById(any)).thenAnswer((_) async => null);
      when(mockTransactionRepo.createTransactions(any))
          .thenAnswer((_) async {});
      when(mockAutomaticRepo.updateAutomaticTransaction(any))
          .thenAnswer((_) async => autoTxn);
      when(mockSettingsRepo.getNotificationsEnabled())
          .thenAnswer((_) async => true);
      when(
        mockNotificationService.showAutomaticTransactionNotification(
          transactionName: anyNamed('transactionName'),
          languageCode: anyNamed('languageCode'),
          notificationId: anyNamed('notificationId'),
        ),
      ).thenAnswer((_) async {});

      await usecaseWithNotification.execute();

      verify(mockSettingsRepo.getNotificationsEnabled()).called(1);
      verify(
        mockNotificationService.showAutomaticTransactionNotification(
          transactionName: 'Gym Subscription',
          languageCode: anyNamed('languageCode'),
        ),
      ).called(1);
    });

    test('Does not dispatch notification if settings disable it', () async {
      final mockNotificationService = MockNotificationService();
      final mockSettingsRepo = MockISettingsRepository();

      final usecaseWithNotification = ExecuteRecurringTransactionsUseCase(
        mockAutomaticRepo,
        mockTransactionRepo,
        mockAccountRepo,
        mockProfileRepo,
        mockExchangeRateRepo,
        fakeFinancialThresholdService,
        mockNotificationService,
        mockSettingsRepo,
      );

      final autoTxn = AutomaticTransaction(
        id: 'auto-notify-2',
        name: 'Disabled Notification',
        amount: 3000,
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
      when(mockAccountRepo.getAccountById(any)).thenAnswer((_) async => null);
      when(mockTransactionRepo.createTransactions(any))
          .thenAnswer((_) async {});
      when(mockAutomaticRepo.updateAutomaticTransaction(any))
          .thenAnswer((_) async => autoTxn);
      when(mockSettingsRepo.getNotificationsEnabled())
          .thenAnswer((_) async => false);

      await usecaseWithNotification.execute();

      verify(mockSettingsRepo.getNotificationsEnabled()).called(1);
      verifyNever(
        mockNotificationService.showAutomaticTransactionNotification(
          transactionName: anyNamed('transactionName'),
          languageCode: anyNamed('languageCode'),
          notificationId: anyNamed('notificationId'),
        ),
      );
    });

    test(
        'Dispatches threshold push notifications when recurring execution triggers threshold results',
        () async {
      final mockNotificationService = MockNotificationService();
      final mockSettingsRepo = MockISettingsRepository();
      final thresholdService = ThresholdTestFinancialThresholdService([
        ThresholdResult(isBudgetExceeded: true),
        ThresholdResult(isSavingsGoalReached: true),
      ]);

      final usecaseWithThresholdNotifications =
          ExecuteRecurringTransactionsUseCase(
        mockAutomaticRepo,
        mockTransactionRepo,
        mockAccountRepo,
        mockProfileRepo,
        mockExchangeRateRepo,
        thresholdService,
        mockNotificationService,
        mockSettingsRepo,
      );

      final autoTxn = AutomaticTransaction(
        id: 'auto-notify-threshold',
        name: 'Electric Bill',
        amount: 5000,
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
      when(mockAccountRepo.getAccountById(any)).thenAnswer((_) async => null);
      when(mockTransactionRepo.createTransactions(any))
          .thenAnswer((_) async {});
      when(mockAutomaticRepo.updateAutomaticTransaction(any))
          .thenAnswer((_) async => autoTxn);
      when(mockSettingsRepo.getNotificationsEnabled())
          .thenAnswer((_) async => true);
      when(
        mockNotificationService.showAutomaticTransactionNotification(
          transactionName: anyNamed('transactionName'),
          languageCode: anyNamed('languageCode'),
          notificationId: anyNamed('notificationId'),
        ),
      ).thenAnswer((_) async {});
      when(
        mockNotificationService.showBudgetExceededNotification(
          languageCode: anyNamed('languageCode'),
          notificationId: anyNamed('notificationId'),
        ),
      ).thenAnswer((_) async {});
      when(
        mockNotificationService.showGoalReachedNotification(
          languageCode: anyNamed('languageCode'),
          notificationId: anyNamed('notificationId'),
        ),
      ).thenAnswer((_) async {});

      await usecaseWithThresholdNotifications.execute();

      verify(
        mockNotificationService.showBudgetExceededNotification(
          languageCode: anyNamed('languageCode'),
        ),
      ).called(1);
      verify(
        mockNotificationService.showGoalReachedNotification(
          languageCode: anyNamed('languageCode'),
        ),
      ).called(1);
    });
  });
}

class ThresholdTestFinancialThresholdService
    implements IFinancialThresholdService {
  final List<ThresholdResult> results;
  ThresholdTestFinancialThresholdService(this.results);
  @override
  Future<List<ThresholdResult>> evaluateThresholds(
    List<Transaction> transactions,
  ) async {
    return results;
  }
}
