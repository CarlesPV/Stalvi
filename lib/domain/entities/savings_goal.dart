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
  final bool isDeleted;

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
    this.isDeleted = false,
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
        other.isDeleted == isDeleted;
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
        isDeleted.hashCode;
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
    bool? isDeleted,
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
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
