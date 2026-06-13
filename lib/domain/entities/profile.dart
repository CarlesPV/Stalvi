class Profile {
  final String id;
  final String name;
  final String username;
  final String password;
  final String defaultCurrency;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const Profile({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.defaultCurrency,
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
      other.defaultCurrency == defaultCurrency &&
      other.createdAt == createdAt &&
      other.modifiedAt == modifiedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      username.hashCode ^
      password.hashCode ^
      defaultCurrency.hashCode ^
      createdAt.hashCode ^
      modifiedAt.hashCode;
  }

  Profile copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    String? defaultCurrency,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
