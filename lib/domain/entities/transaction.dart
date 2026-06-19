import 'transaction_type.dart';

class Transaction {
  final String id;
  final int
      amount; // Stored in cents (e.g. 1000 for 10.00) to avoid floating-point errors
  final DateTime date;
  final TransactionType type;
  final String accountId;
  final String? categoryId;
  final String? notes;
  final String originalCurrency;
  final int? convertedAmount;
  final double? exchangeRate;
  final String? exchangeRateSnapshot;
  final DateTime createdAt;
  final DateTime modifiedAt;

  /// Shared identifier linking both legs of a transfer pair.
  ///
  /// When a transfer is recorded, two [Transaction] rows are created:
  ///   - Origin account  → negative amount, type = transfer, transferId = X
  ///   - Destination account → positive amount, type = transfer, transferId = X
  ///
  /// `null` for income / expense transactions.
  final String? transferId;

  const Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.accountId,
    this.categoryId,
    this.notes,
    required this.originalCurrency,
    this.convertedAmount,
    this.exchangeRate,
    this.exchangeRateSnapshot,
    required this.createdAt,
    required this.modifiedAt,
    this.transferId,
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
        other.originalCurrency == originalCurrency &&
        other.convertedAmount == convertedAmount &&
        other.exchangeRate == exchangeRate &&
        other.exchangeRateSnapshot == exchangeRateSnapshot &&
        other.createdAt == createdAt &&
        other.modifiedAt == modifiedAt &&
        other.transferId == transferId;
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
        originalCurrency.hashCode ^
        convertedAmount.hashCode ^
        exchangeRate.hashCode ^
        exchangeRateSnapshot.hashCode ^
        createdAt.hashCode ^
        modifiedAt.hashCode ^
        transferId.hashCode;
  }

  Transaction copyWith({
    String? id,
    int? amount,
    DateTime? date,
    TransactionType? type,
    String? accountId,
    String? categoryId,
    String? notes,
    String? originalCurrency,
    int? convertedAmount,
    double? exchangeRate,
    String? exchangeRateSnapshot,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? transferId,
    bool clearTransferId = false,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      notes: notes ?? this.notes,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      exchangeRateSnapshot: exchangeRateSnapshot ?? this.exchangeRateSnapshot,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      transferId: clearTransferId ? null : (transferId ?? this.transferId),
    );
  }
}
