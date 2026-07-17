import '../entities/trash_item.dart';

/// Domain interface for trash (soft-delete recovery) and purge operations.
///
/// Implementations are responsible for querying, restoring, permanently
/// deleting, and purging expired soft-deleted records.
abstract class ITrashRepository {
  /// Returns all soft-deleted items across major entity tables.
  Future<List<TrashItem>> getTrashItems();

  /// Streams all soft-deleted items, re-emitting automatically on changes.
  Stream<List<TrashItem>> watchTrashItems();

  /// Restores a soft-deleted item by its [id] and [type].
  Future<void> restoreItem(String id, TrashItemType type);

  /// Permanently deletes an item from the database by its [id] and [type].
  Future<void> deleteItemPermanently(String id, TrashItemType type);

  /// Hard-deletes all soft-deleted items that were modified before [threshold].
  Future<void> purgeOldItems(DateTime threshold);

  /// Cascade-restores a savings goal and its related transfer transactions,
  /// re-applying the balances to the origin accounts.
  Future<void> cascadeRestoreSavingsGoal(String id);

  /// Cascade-soft-deletes a savings goal and its related transfer transactions,
  /// reverting the balances to the origin accounts.
  Future<void> cascadeSoftDeleteSavingsGoal(String id);
}
