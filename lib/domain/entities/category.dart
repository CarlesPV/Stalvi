import 'category_type.dart';

class Category {
  final String id;
  final String name;
  final CategoryType? associatedType;
  final String icon;
  final String color;
  final String? parentCategoryId;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const Category({
    required this.id,
    required this.name,
    this.associatedType,
    required this.icon,
    required this.color,
    this.parentCategoryId,
    this.isDeleted = false,
    required this.createdAt,
    required this.modifiedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.associatedType == associatedType &&
        other.icon == icon &&
        other.color == color &&
        other.parentCategoryId == parentCategoryId &&
        other.isDeleted == isDeleted &&
        other.createdAt == createdAt &&
        other.modifiedAt == modifiedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        associatedType.hashCode ^
        icon.hashCode ^
        color.hashCode ^
        parentCategoryId.hashCode ^
        isDeleted.hashCode ^
        createdAt.hashCode ^
        modifiedAt.hashCode;
  }

  Category copyWith({
    String? id,
    String? name,
    CategoryType? associatedType,
    String? icon,
    String? color,
    String? parentCategoryId,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      associatedType: associatedType ?? this.associatedType,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
