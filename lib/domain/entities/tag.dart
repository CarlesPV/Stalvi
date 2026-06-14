class Tag {
  final String id;
  final String name;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const Tag({
    required this.id,
    required this.name,
    this.isDeleted = false,
    required this.createdAt,
    required this.modifiedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Tag &&
        other.id == id &&
        other.name == name &&
        other.isDeleted == isDeleted &&
        other.createdAt == createdAt &&
        other.modifiedAt == modifiedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        isDeleted.hashCode ^
        createdAt.hashCode ^
        modifiedAt.hashCode;
  }

  Tag copyWith({
    String? id,
    String? name,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
