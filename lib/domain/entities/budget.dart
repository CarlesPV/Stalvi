class Budget {
  final String id;
  final String accountId;
  final String categoryId;
  final int targetAmount; // Stored in cents
  final int currentAmount; // Stored in cents
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deletedAt;
  final bool isDeleted;

  const Budget({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.modifiedAt,
    this.deletedAt,
    this.isDeleted = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Budget &&
        other.id == id &&
        other.accountId == accountId &&
        other.categoryId == categoryId &&
        other.targetAmount == targetAmount &&
        other.currentAmount == currentAmount &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.createdAt == createdAt &&
        other.modifiedAt == modifiedAt &&
        other.deletedAt == deletedAt &&
        other.isDeleted == isDeleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        accountId.hashCode ^
        categoryId.hashCode ^
        targetAmount.hashCode ^
        currentAmount.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        createdAt.hashCode ^
        modifiedAt.hashCode ^
        deletedAt.hashCode ^
        isDeleted.hashCode;
  }

  Budget copyWith({
    String? id,
    String? accountId,
    String? categoryId,
    int? targetAmount,
    int? currentAmount,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? modifiedAt,
    DateTime? deletedAt,
    bool? isDeleted,
  }) {
    return Budget(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
