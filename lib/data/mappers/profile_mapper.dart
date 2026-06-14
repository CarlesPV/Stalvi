import 'package:konta/domain/entities/profile.dart';
import 'package:konta/data/database/app_database.dart' as db;

extension ProfileMapper on Profile {
  db.Profile toDb() {
    return db.Profile(
      id: id,
      name: name,
      username: username,
      password: password,
      defaultCurrency: defaultCurrency,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
    );
  }
}

extension DbProfileMapper on db.Profile {
  Profile toDomain() {
    return Profile(
      id: id,
      name: name,
      username: username,
      password: password,
      defaultCurrency: defaultCurrency,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
    );
  }
}
