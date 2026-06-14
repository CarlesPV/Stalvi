import 'package:konta/domain/entities/tag.dart';
import 'package:konta/data/database/app_database.dart' as db;

extension TagMapper on Tag {
  db.Tag toDb() {
    return db.Tag(
      id: id,
      name: name,
      isDeleted: isDeleted,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
    );
  }
}

extension DbTagMapper on db.Tag {
  Tag toDomain() {
    return Tag(
      id: id,
      name: name,
      isDeleted: isDeleted,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
    );
  }
}
