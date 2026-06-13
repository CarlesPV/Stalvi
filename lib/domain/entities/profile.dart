class Profile {
  final String id;
  final String name;
  final String username;
  final String password;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const Profile({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.createdAt,
    required this.modifiedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Profile &&
      other.id == id &&
      other.name == name &&
      other.username == username &&
      other.password == password &&
      other.createdAt == createdAt &&
      other.modifiedAt == modifiedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      username.hashCode ^
      password.hashCode ^
      createdAt.hashCode ^
      modifiedAt.hashCode;
  }

  Profile copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
