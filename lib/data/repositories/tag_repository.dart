import 'package:drift/drift.dart';
import 'package:stalvi/data/database/app_database.dart' as db;
import 'package:stalvi/data/mappers/tag_mapper.dart';
import 'package:stalvi/domain/entities/tag.dart';
import 'package:stalvi/domain/repositories/i_tag_repository.dart';

/// Concrete implementation of [ITagRepository] backed by Drift.
class TagRepository implements ITagRepository {
  final db.AppDatabase _db;

  TagRepository(this._db);

  @override
  Future<Tag> createTag(Tag tag) async {
    final dbTag = tag.toDb();
    await _db.into(_db.tags).insert(dbTag);
    return tag;
  }

  @override
  Future<Tag?> getTagById(String id) async {
    final query = _db.select(_db.tags)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<List<Tag>> getAllTags() async {
    final query = _db.select(_db.tags)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    final rows = await query.get();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Tag> updateTag(Tag tag) async {
    final dbTag = tag.toDb();
    await (_db.update(_db.tags)..where((t) => t.id.equals(tag.id)))
        .write(dbTag.toCompanion(true));
    return tag;
  }

  @override
  Future<void> deleteTag(String id) async {
    await (_db.update(_db.tags)..where((t) => t.id.equals(id))).write(
      const db.TagsCompanion(
        isDeleted: Value(true),
      ),
    );
  }
}
