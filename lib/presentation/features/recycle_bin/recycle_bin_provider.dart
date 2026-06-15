import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/trash_item.dart';
import '../../../domain/usecases/trash_usecases.dart';
import '../../providers/repository_providers.dart';

final recycleBinProvider =
    StateNotifierProvider<RecycleBinNotifier, AsyncValue<List<TrashItem>>>(
        (ref) {
  return RecycleBinNotifier(ref.watch(trashUsecasesProvider));
});

class RecycleBinNotifier extends StateNotifier<AsyncValue<List<TrashItem>>> {
  final TrashUsecases _trashUsecases;

  RecycleBinNotifier(this._trashUsecases) : super(const AsyncValue.loading()) {
    loadItems();
  }

  Future<void> loadItems() async {
    state = const AsyncValue.loading();
    try {
      final items = await _trashUsecases.getTrashItems();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> restoreItem(String id, TrashItemType type) async {
    try {
      await _trashUsecases.restoreItem(id, type);
      await loadItems(); // Refresh the list
    } catch (e, st) {
      // Typically, one might handle the error with a snackbar or similar.
      // For this implementation, we just set the error state.
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteItemPermanently(String id, TrashItemType type) async {
    try {
      await _trashUsecases.deleteItemPermanently(id, type);
      await loadItems(); // Refresh the list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
