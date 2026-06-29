import '../entities/tag.dart';

abstract class ITagRepository {
  Future<Tag> createTag(Tag tag);
  Future<Tag?> getTagById(String id);
  Future<List<Tag>> getAllTags();
  Future<Tag> updateTag(Tag tag);
  Future<void> deleteTag(String id);
  Future<void> deleteTagPermanently(String id);
}
