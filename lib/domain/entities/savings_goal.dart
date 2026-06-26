class SavingsGoal {
  final String id;
  final String name;
  final int targetAmount; // Stored in cents
  final int currentAmount; // Stored in cents
  final DateTime? targetDate;
  final String color;
  final String icon;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deletedAt;
  final bool isDeleted;
  final bool isCompleted;
  final String currency;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.targetDate,
    required this.color,
    required this.icon,
    required this.createdAt,
    required this.modifiedAt,
    this.deletedAt,
    this.isDeleted = false,
    this.isCompleted = false,
    required this.currency,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SavingsGoal &&
        other.id == id &&
        other.name == name &&
        other.targetAmount == targetAmount &&
        other.currentAmount == currentAmount &&
        other.targetDate == targetDate &&
        other.color == color &&
        other.icon == icon &&
        other.createdAt == createdAt &&
        other.modifiedAt == modifiedAt &&
        other.deletedAt == deletedAt &&
        other.isDeleted == isDeleted &&
        other.isCompleted == isCompleted &&
        other.currency == currency;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        targetAmount.hashCode ^
        currentAmount.hashCode ^
        targetDate.hashCode ^
        color.hashCode ^
        icon.hashCode ^
        createdAt.hashCode ^
        modifiedAt.hashCode ^
        deletedAt.hashCode ^
        isDeleted.hashCode ^
        isCompleted.hashCode ^
        currency.hashCode;
  }

  SavingsGoal copyWith({
    String? id,
    String? name,
    int? targetAmount,
    int? currentAmount,
    DateTime? targetDate,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? modifiedAt,
    DateTime? deletedAt,
    bool? isDeleted,
    bool? isCompleted,
    String? currency,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isCompleted: isCompleted ?? this.isCompleted,
      currency: currency ?? this.currency,
    );
  }
}
