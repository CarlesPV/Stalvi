import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/domain/entities/recurrence_type.dart';
import 'package:stalvi/domain/usecases/execute_recurring_transactions_usecase.dart';

void main() {
  group('ExecuteRecurringTransactionsUseCase Date Calculations (UTC+2 Boundaries)', () {
    test('IntervalDays advances correctly', () {
      final from = DateTime.utc(2026, 7, 17); // 00:00:00 UTC
      final nextDate = ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.intervalDays,
        5,
      );
      expect(nextDate, DateTime.utc(2026, 7, 22));
    });

    test('Weekly advances exactly 7 days', () {
      final from = DateTime.utc(2026, 7, 17);
      final nextDate = ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.weekly,
        0, // unused for weekly
      );
      expect(nextDate, DateTime.utc(2026, 7, 24));
    });

    test('Monthly advances one calendar month (same day)', () {
      final from = DateTime.utc(2026, 7, 15);
      final nextDate = ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.monthly,
        0, // unused
      );
      expect(nextDate, DateTime.utc(2026, 8, 15));
    });

    test('Monthly clamps to end of month (e.g., Jan 31 -> Feb 28)', () {
      final from = DateTime.utc(2026, 1, 31);
      final nextDate = ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.monthly,
        0,
      );
      expect(nextDate, DateTime.utc(2026, 2, 28));
    });

    test('Yearly advances one calendar year', () {
      final from = DateTime.utc(2026, 7, 17);
      final nextDate = ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.yearly,
        0, // unused
      );
      expect(nextDate, DateTime.utc(2027, 7, 17));
    });

    test('Yearly handles leap year (Feb 29 -> Feb 28 next year)', () {
      final from = DateTime.utc(2024, 2, 29); // 2024 is a leap year
      final nextDate = ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.yearly,
        0,
      );
      expect(nextDate, DateTime.utc(2025, 2, 28));
    });

    test('SpecificDayOfMonth advances to the specific day of the next month', () {
      final from = DateTime.utc(2026, 7, 17);
      final nextDate = ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.specificDayOfMonth,
        5, // The 5th day of the month
      );
      // Advances to August, day 5
      expect(nextDate, DateTime.utc(2026, 8, 5));
    });

    test('SpecificDayOfMonth clamps if target day exceeds next month days', () {
      final from = DateTime.utc(2026, 1, 15);
      final nextDate = ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.specificDayOfMonth,
        31, // Target day is 31
      );
      // Advances to February, max days is 28
      expect(nextDate, DateTime.utc(2026, 2, 28));
    });
    
    test('Year rollover works correctly for Monthly', () {
      final from = DateTime.utc(2026, 12, 15);
      final nextDate = ExecuteRecurringTransactionsUseCase.calculateNextTriggerDateUtcPlus2(
        from,
        RecurrenceType.monthly,
        0,
      );
      expect(nextDate, DateTime.utc(2027, 1, 15));
    });
  });
}
