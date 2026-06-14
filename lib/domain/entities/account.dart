import 'account_type.dart';

class Account {
  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final double initialBalance;
  final String currency;
  final String color;
  final String icon;
  final bool isDefault;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.currency,
    required this.color,
    required this.icon,
    required this.isDefault,
    required this.isDeleted,
    required this.createdAt,
    required this.modifiedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Account &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.type == type &&
        other.initialBalance == initialBalance &&
        other.currency == currency &&
        other.color == color &&
        other.icon == icon &&
        other.isDefault == isDefault &&
        other.isDeleted == isDeleted &&
        other.createdAt == createdAt &&
        other.modifiedAt == modifiedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        type.hashCode ^
        initialBalance.hashCode ^
        currency.hashCode ^
        color.hashCode ^
        icon.hashCode ^
        isDefault.hashCode ^
        isDeleted.hashCode ^
        createdAt.hashCode ^
        modifiedAt.hashCode;
  }

  Account copyWith({
    String? id,
    String? userId,
    String? name,
    AccountType? type,
    double? initialBalance,
    String? currency,
    String? color,
    String? icon,
    bool? isDefault,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      currency: currency ?? this.currency,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
