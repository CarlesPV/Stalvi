import 'transaction_type.dart';

class AutomaticTransaction {
  final String id;
  final int amount;
  final TransactionType type;
  final String accountId;
  final String? categoryId;
  final String? tagId;
  final String? notes;
  final int recurrenceDays;
  final DateTime nextExecutionDate;
  final DateTime createdAt;

  const AutomaticTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.accountId,
    this.categoryId,
    this.tagId,
    this.notes,
    required this.recurrenceDays,
    required this.nextExecutionDate,
    required this.createdAt,
  });
}
