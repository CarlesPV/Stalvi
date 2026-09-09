import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
// ignore: depend_onreferenced_packages
import 'package:uuid/uuid.dart';
import 'package:stalvi/data/database/app_database.dart' as db_data;
import 'package:stalvi/data/repositories/tag_repository.dart';
import 'package:stalvi/domain/entities/tag.dart';

void main() {
  late db_data.AppDatabase db;
  late TagRepository repository;
  const uuid = Uuid();

  setUp(() {
    db = db_data.AppDatabase.forTesting(NativeDatabase.memory());
    repository = TagRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Tag buildTestTag({
    required String id,
    String name = 'Test Tag',
    bool isDeleted = false,
  }) {
    return Tag(
      id: id,
      name: name,
      isDeleted: isDeleted,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );
  }

  group('TagRepository Tests', () {
    test('createTag saves tag and getTagById retrieves it', () async {
      final id = uuid.v4();
      final tag = buildTestTag(id: id);

      await repository.createTag(tag);
      final retrieved = await repository.getTagById(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, id);
      expect(retrieved.name, 'Test Tag');
    });

    test(
        'getAllTags returns non-deleted tags and sorts them alphabetically and case-insensitively',
        () async {
      final dbTags = await repository.getAllTags();
      for (final tag in dbTags) {
        await repository.deleteTagPermanently(tag.id);
      }

      final tagDeleted =
          buildTestTag(id: uuid.v4(), name: 'Deleted Tag', isDeleted: true);
      await repository.createTag(tagDeleted);

      await repository.createTag(buildTestTag(id: uuid.v4(), name: 'Zebra'));
      await repository.createTag(buildTestTag(id: uuid.v4(), name: 'abril'));
      await repository.createTag(buildTestTag(id: uuid.v4(), name: 'Árbol'));
      await repository.createTag(buildTestTag(id: uuid.v4(), name: 'apple'));

      final list = await repository.getAllTags();
      final names = list.map((t) => t.name).toList();

      expect(names, isNot(contains('Deleted Tag')));
      expect(names, ['abril', 'apple', 'Zebra', 'Árbol']);
    });
  });
}
