import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/domain/entities/trash_item.dart';
import 'package:stalvi/domain/usecases/trash_usecases.dart';
import '../../providers/repository_providers.dart';
import '../../providers/statistics_providers.dart';

final recycleBinProvider = StateNotifierProvider.autoDispose<RecycleBinNotifier,
    AsyncValue<List<TrashItem>>>((ref) {
  return RecycleBinNotifier(ref.watch(trashUsecasesProvider), ref);
});

class RecycleBinNotifier extends StateNotifier<AsyncValue<List<TrashItem>>> {
  final TrashUsecases _trashUsecases;
  final Ref ref;

  RecycleBinNotifier(this._trashUsecases, this.ref)
      : super(const AsyncValue.loading()) {
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
      ref.invalidate(accountsListProvider);
      ref.invalidate(transactionsStreamProvider);
      ref.invalidate(periodSummaryProvider);
      ref.invalidate(topExpenseCategoriesProvider);
      ref.invalidate(topIncomeCategoriesProvider);
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
      ref.invalidate(accountsListProvider);
      ref.invalidate(transactionsStreamProvider);
      ref.invalidate(periodSummaryProvider);
      ref.invalidate(topExpenseCategoriesProvider);
      ref.invalidate(topIncomeCategoriesProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> emptyTrash() async {
    try {
      await _trashUsecases.emptyTrash();
      await loadItems();
      ref.invalidate(accountsListProvider);
      ref.invalidate(transactionsStreamProvider);
      ref.invalidate(periodSummaryProvider);
      ref.invalidate(topExpenseCategoriesProvider);
      ref.invalidate(topIncomeCategoriesProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
