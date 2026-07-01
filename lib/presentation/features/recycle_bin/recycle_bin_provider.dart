import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/domain/entities/trash_item.dart';
import 'package:stalvi/domain/usecases/trash_usecases.dart';
import '../../providers/repository_providers.dart';

final recycleBinProvider = StateNotifierProvider.autoDispose<RecycleBinNotifier,
    AsyncValue<List<TrashItem>>>((ref) {
  return RecycleBinNotifier(ref.watch(trashUsecasesProvider));
});

class RecycleBinNotifier extends StateNotifier<AsyncValue<List<TrashItem>>> {
  final TrashUsecases _trashUsecases;
  StreamSubscription<List<TrashItem>>? _subscription;

  RecycleBinNotifier(this._trashUsecases) : super(const AsyncValue.loading()) {
    _subscription = _trashUsecases.watchTrashItems().listen(
      (items) {
        final now = DateTime.now();
        final updatedItems = items.map((item) {
          final remaining = 30 - now.difference(item.deletedAt).inDays;
          return TrashItem(
            id: item.id,
            name: item.name,
            type: item.type,
            daysRemaining: remaining,
            deletedAt: item.deletedAt,
            metadata: item.metadata,
          );
        }).toList();
        state = AsyncValue.data(updatedItems);
      },
      onError: (e, st) {
        state = AsyncValue.error(e, st);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> restoreItem(String id, TrashItemType type) async {
    try {
      await _trashUsecases.restoreItem(id, type);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteItemPermanently(String id, TrashItemType type) async {
    try {
      await _trashUsecases.deleteItemPermanently(id, type);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> emptyTrash() async {
    try {
      await _trashUsecases.emptyTrash();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
