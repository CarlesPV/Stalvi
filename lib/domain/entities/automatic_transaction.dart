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

  DateTime calculateNextExecutionDate(DateTime fromDate) {
    if (recurrenceType == RecurrenceType.intervalDays) {
      return fromDate.add(Duration(days: recurrenceDays));
    } else {
      int nextMonth = fromDate.month + 1;
      int nextYear = fromDate.year;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }

      int targetDay = recurrenceDays;
      int lastDayOfNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;

      if (targetDay > lastDayOfNextMonth) {
        targetDay = lastDayOfNextMonth;
      }

      return DateTime(
        nextYear,
        nextMonth,
        targetDay,
        fromDate.hour,
        fromDate.minute,
        fromDate.second,
      );
    }
  }
}
