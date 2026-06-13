class Budget {
  final String id;
  final String categoryId;
  final int targetAmount; // Stored in cents
  final int currentAmount; // Stored in cents
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool isDeleted;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.modifiedAt,
    this.isDeleted = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Budget &&
        other.id == id &&
        other.categoryId == categoryId &&
        other.targetAmount == targetAmount &&
        other.currentAmount == currentAmount &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.createdAt == createdAt &&
        other.modifiedAt == modifiedAt &&
        other.isDeleted == isDeleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        categoryId.hashCode ^
        targetAmount.hashCode ^
        currentAmount.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        createdAt.hashCode ^
        modifiedAt.hashCode ^
        isDeleted.hashCode;
  }

  Budget copyWith({
    String? id,
    String? categoryId,
    int? targetAmount,
    int? currentAmount,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool? isDeleted,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
