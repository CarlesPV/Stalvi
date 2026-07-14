import 'transaction_type.dart';
import 'recurrence_type.dart';

class AutomaticTransaction {
  final String id;
  final String name;
  final int amount;
  final String currency;
  final TransactionType type;
  final String accountId;
  final String? categoryId;
  final String? tagId;
  final String? notes;
  final RecurrenceType recurrenceType;

  /// Meaning depends on [recurrenceType]:
  /// - [RecurrenceType.intervalDays]       → number of days between firings.
  /// - [RecurrenceType.specificDayOfMonth] → target calendar day (1–31).
  /// - [RecurrenceType.weekly]             → unused (always 7 days).
  /// - [RecurrenceType.monthly]            → unused (always 1 calendar month).
  /// - [RecurrenceType.yearly]             → unused (always 1 calendar year).
  final int recurrenceDays;

  final DateTime nextExecutionDate;
  final DateTime createdAt;
  final bool isActive;
  final bool isDeleted;
  final DateTime? deletedAt;

  const AutomaticTransaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.type,
    required this.accountId,
    this.categoryId,
    this.tagId,
    this.notes,
    this.recurrenceType = RecurrenceType.intervalDays,
    required this.recurrenceDays,
    required this.nextExecutionDate,
    required this.createdAt,
    this.isActive = true,
    this.isDeleted = false,
    this.deletedAt,
  });

  AutomaticTransaction copyWith({
    String? id,
    String? name,
    int? amount,
    String? currency,
    TransactionType? type,
    String? accountId,
    String? categoryId,
    String? tagId,
    String? notes,
    RecurrenceType? recurrenceType,
    int? recurrenceDays,
    DateTime? nextExecutionDate,
    DateTime? createdAt,
    bool? isActive,
    bool? isDeleted,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return AutomaticTransaction(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      tagId: tagId ?? this.tagId,
      notes: notes ?? this.notes,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
      nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  /// Computes the next execution date after [fromDate] based on [recurrenceType].
  ///
  /// - [RecurrenceType.intervalDays]       — adds [recurrenceDays] days.
  /// - [RecurrenceType.weekly]             — adds exactly 7 days.
  /// - [RecurrenceType.monthly]            — advances one calendar month on the
  ///                                         same day, clamped to the last day
  ///                                         of that month when needed.
  /// - [RecurrenceType.yearly]             — advances one calendar year on the
  ///                                         same date, clamped to the last day
  ///                                         of that month (handles Feb 29 in
  ///                                         non-leap years).
  /// - [RecurrenceType.specificDayOfMonth] — advances one calendar month, then
  ///                                         sets the day to [recurrenceDays],
  ///                                         clamped to the last day of the
  ///                                         resulting month.
  DateTime calculateNextExecutionDate(DateTime fromDate) {
    switch (recurrenceType) {
      case RecurrenceType.intervalDays:
        return fromDate.add(Duration(days: recurrenceDays));

      case RecurrenceType.weekly:
        return fromDate.add(const Duration(days: 7));

      case RecurrenceType.monthly:
        return _advanceByMonths(fromDate, 1, fromDate.day);

      case RecurrenceType.yearly:
        return _advanceByYears(fromDate, 1, fromDate.month, fromDate.day);

      case RecurrenceType.specificDayOfMonth:
        return _advanceByMonths(fromDate, 1, recurrenceDays);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns a [DateTime] that is [months] calendar months after [from],
  /// targeting [targetDay], clamped to the last day of the resulting month.
  ///
  /// The time-of-day component from [from] is preserved.
  static DateTime _advanceByMonths(
    DateTime from,
    int months,
    int targetDay,
  ) {
    int newMonth = from.month + months;
    int newYear = from.year;
    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }
    final lastDay = DateTime(newYear, newMonth + 1, 0).day;
    final day = targetDay.clamp(1, lastDay);
    return DateTime(
        newYear, newMonth, day, from.hour, from.minute, from.second);
  }

  /// Returns a [DateTime] that is [years] calendar years after [from],
  /// targeting [targetMonth]/[targetDay], clamped when the day does not exist
  /// in the target year (e.g. Feb 29 → Feb 28 in non-leap years).
  ///
  /// The time-of-day component from [from] is preserved.
  static DateTime _advanceByYears(
    DateTime from,
    int years,
    int targetMonth,
    int targetDay,
  ) {
    final newYear = from.year + years;
    final lastDay = DateTime(newYear, targetMonth + 1, 0).day;
    final day = targetDay.clamp(1, lastDay);
    return DateTime(
      newYear,
      targetMonth,
      day,
      from.hour,
      from.minute,
      from.second,
    );
  }
}
