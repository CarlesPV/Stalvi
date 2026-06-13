import 'transaction_type.dart';

class Transaction {
  final String id;
  final int amount; // Stored in cents (e.g. 1000 for 10.00) to avoid floating-point errors
  final DateTime date;
  final TransactionType type;
  final String accountId;
  final String? categoryId;
  final String? notes;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.accountId,
    this.categoryId,
    this.notes,
    required this.createdAt,
    required this.modifiedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Transaction &&
        other.id == id &&
        other.amount == amount &&
        other.date == date &&
        other.type == type &&
        other.accountId == accountId &&
        other.categoryId == categoryId &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.modifiedAt == modifiedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        date.hashCode ^
        type.hashCode ^
        accountId.hashCode ^
        categoryId.hashCode ^
        notes.hashCode ^
        createdAt.hashCode ^
        modifiedAt.hashCode;
  }

  Transaction copyWith({
    String? id,
    int? amount,
    DateTime? date,
    TransactionType? type,
    String? accountId,
    String? categoryId,
    String? notes,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
