// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/recurrence_type.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

AutomaticTransaction _buildAutoTxn({
  required RecurrenceType recurrenceType,
  int recurrenceDays = 1,
}) {
  final base = DateTime(2026, 1, 15, 9, 0, 0);
  return AutomaticTransaction(
    id: 'test',
    name: 'Test',
    amount: 1000,
    currency: 'EUR',
    type: TransactionType.expense,
    accountId: 'acc1',
    recurrenceType: recurrenceType,
    recurrenceDays: recurrenceDays,
    nextExecutionDate: base,
    createdAt: base,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AutomaticTransaction.calculateNextExecutionDate', () {
    // ── intervalDays ──────────────────────────────────────────────────────────
    group('intervalDays', () {
      test('adds exactly recurrenceDays days', () {
        final txn = _buildAutoTxn(
          recurrenceType: RecurrenceType.intervalDays,
          recurrenceDays: 10,
        );
        final from = DateTime(2026, 3, 1);
        expect(
          txn.calculateNextExecutionDate(from),
          equals(DateTime(2026, 3, 11)),
        );
      });

      test('crossing month boundary', () {
        final txn = _buildAutoTxn(
          recurrenceType: RecurrenceType.intervalDays,
          recurrenceDays: 45,
        );
        final from = DateTime(2026, 1, 1);
        // Jan 1 + 45 days = Feb 15
        expect(
          txn.calculateNextExecutionDate(from),
          equals(DateTime(2026, 2, 15)),
        );
      });

      test('crossing year boundary', () {
        final txn = _buildAutoTxn(
          recurrenceType: RecurrenceType.intervalDays,
          recurrenceDays: 10,
        );
        final from = DateTime(2026, 12, 28);
        expect(
          txn.calculateNextExecutionDate(from),
          equals(DateTime(2027, 1, 7)),
        );
      });
    });

    // ── weekly ────────────────────────────────────────────────────────────────
    group('weekly', () {
      test('always adds exactly 7 days', () {
        final txn = _buildAutoTxn(recurrenceType: RecurrenceType.weekly);
        final from = DateTime(2026, 4, 1);
        expect(
          txn.calculateNextExecutionDate(from),
          equals(DateTime(2026, 4, 8)),
        );
      });

      test('preserves time-of-day component', () {
        final txn = _buildAutoTxn(recurrenceType: RecurrenceType.weekly);
        final from = DateTime(2026, 4, 1, 14, 30, 0);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.hour, 14);
        expect(next.minute, 30);
        expect(next.second, 0);
      });

      test('crossing month boundary', () {
        final txn = _buildAutoTxn(recurrenceType: RecurrenceType.weekly);
        final from = DateTime(2026, 1, 29);
        expect(
          txn.calculateNextExecutionDate(from),
          equals(DateTime(2026, 2, 5)),
        );
      });
    });

    // ── monthly ───────────────────────────────────────────────────────────────
    group('monthly', () {
      test('advances by exactly one calendar month on the same day', () {
        final txn = _buildAutoTxn(recurrenceType: RecurrenceType.monthly);
        final from = DateTime(2026, 3, 15);
        expect(
          txn.calculateNextExecutionDate(from),
          equals(DateTime(2026, 4, 15)),
        );
      });

      test('crossing year boundary (December → January)', () {
        final txn = _buildAutoTxn(recurrenceType: RecurrenceType.monthly);
        final from = DateTime(2026, 12, 10);
        expect(
          txn.calculateNextExecutionDate(from),
          equals(DateTime(2027, 1, 10)),
        );
      });

      test('Jan 31 → Feb 28 in non-leap year (day clamping)', () {
        final txn = _buildAutoTxn(recurrenceType: RecurrenceType.monthly);
        final from = DateTime(2026, 1, 31);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.year, 2026);
        expect(next.month, 2);
        expect(next.day, 28);
      });

      test('Jan 31 → Feb 29 in leap year (day clamping)', () {
        final txn = _buildAutoTxn(recurrenceType: RecurrenceType.monthly);
        final from = DateTime(2024, 1, 31);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.year, 2024);
        expect(next.month, 2);
        expect(next.day, 29);
      });

      test('Mar 31 → Apr 30 (April has 30 days)', () {
        final txn = _buildAutoTxn(recurrenceType: RecurrenceType.monthly);
        final from = DateTime(2026, 3, 31);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.year, 2026);
        expect(next.month, 4);
        expect(next.day, 30);
      });

      test('preserves time-of-day component', () {
        final txn = _buildAutoTxn(recurrenceType: RecurrenceType.monthly);
        final from = DateTime(2026, 5, 10, 22, 0, 0);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.hour, 22);
        expect(next.minute, 0);
        expect(next.second, 0);
      });
    });

    // ── yearly ────────────────────────────────────────────────────────────────
    group('yearly', () {
      test('advances by exactly one calendar year on the same date', () {
        final txn = _buildAutoTxn(recurrenceType: RecurrenceType.yearly);
        final from = DateTime(2026, 6, 15);
        expect(
          txn.calculateNextExecutionDate(from),
          equals(DateTime(2027, 6, 15)),
        );
      });

      test('Feb 29 in leap year → Feb 28 in following non-leap year', () {
        final txn = _buildAutoTxn(recurrenceType: RecurrenceType.yearly);
        final from = DateTime(2024, 2, 29);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.year, 2025);
        expect(next.month, 2);
        expect(next.day, 28);
      });

      test('Feb 28 in non-leap year stays Feb 28 next year', () {
        final txn = _buildAutoTxn(recurrenceType: RecurrenceType.yearly);
        final from = DateTime(2026, 2, 28);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.year, 2027);
        expect(next.month, 2);
        expect(next.day, 28);
      });

      test('Dec 31 → Dec 31 next year', () {
        final txn = _buildAutoTxn(recurrenceType: RecurrenceType.yearly);
        final from = DateTime(2026, 12, 31);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.year, 2027);
        expect(next.month, 12);
        expect(next.day, 31);
      });

      test('preserves time-of-day component', () {
        final txn = _buildAutoTxn(recurrenceType: RecurrenceType.yearly);
        final from = DateTime(2026, 7, 4, 8, 45, 30);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.hour, 8);
        expect(next.minute, 45);
        expect(next.second, 30);
      });
    });

    // ── specificDayOfMonth ────────────────────────────────────────────────────
    group('specificDayOfMonth', () {
      test('targets the specific day in the current month if not yet passed',
          () {
        final txn = _buildAutoTxn(
          recurrenceType: RecurrenceType.specificDayOfMonth,
          recurrenceDays: 15,
        );
        final from = DateTime(2026, 1, 5);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.year, 2026);
        expect(next.month, 1);
        expect(next.day, 15);
      });

      test('advances to the target day in the next calendar month', () {
        final txn = _buildAutoTxn(
          recurrenceType: RecurrenceType.specificDayOfMonth,
          recurrenceDays: 15,
        );
        final from = DateTime(2026, 1, 15);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.year, 2026);
        expect(next.month, 2);
        expect(next.day, 15);
      });

      test('day 31 in January → day 28 in February (non-leap year clamping)',
          () {
        final txn = _buildAutoTxn(
          recurrenceType: RecurrenceType.specificDayOfMonth,
          recurrenceDays: 31,
        );
        final from = DateTime(2026, 1, 31);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.year, 2026);
        expect(next.month, 2);
        expect(next.day, 28);
      });

      test('day 31 in January → day 29 in February (leap year clamping)', () {
        final txn = _buildAutoTxn(
          recurrenceType: RecurrenceType.specificDayOfMonth,
          recurrenceDays: 31,
        );
        final from = DateTime(2024, 1, 31);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.year, 2024);
        expect(next.month, 2);
        expect(next.day, 29);
      });

      test('day 31 in March → day 30 in April (April has 30 days)', () {
        final txn = _buildAutoTxn(
          recurrenceType: RecurrenceType.specificDayOfMonth,
          recurrenceDays: 31,
        );
        final from = DateTime(2026, 3, 31);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.year, 2026);
        expect(next.month, 4);
        expect(next.day, 30);
      });

      test('crossing year boundary (December → January)', () {
        final txn = _buildAutoTxn(
          recurrenceType: RecurrenceType.specificDayOfMonth,
          recurrenceDays: 10,
        );
        final from = DateTime(2026, 12, 10);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.year, 2027);
        expect(next.month, 1);
        expect(next.day, 10);
      });

      test(
          'from Feb 28 (non-leap) → Mar 31 when recurrenceDays is 31 '
          '(March has 31 days so no clamping needed)', () {
        final txn = _buildAutoTxn(
          recurrenceType: RecurrenceType.specificDayOfMonth,
          recurrenceDays: 31,
        );
        final from = DateTime(2026, 2, 28);
        final next = txn.calculateNextExecutionDate(from);
        expect(next.year, 2026);
        expect(next.month, 3);
        expect(next.day, 31);
      });
    });
  });
}
