import 'dart:async';
import 'package:stalvi/domain/entities/trash_item.dart';
import '../../providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recycle_bin_provider.g.dart';

@riverpod
class RecycleBinNotifier extends _$RecycleBinNotifier {
  StreamSubscription<List<TrashItem>>? _subscription;

  @override
  AsyncValue<List<TrashItem>> build() {
    final trashUsecases = ref.watch(trashUsecasesProvider);

    _subscription = trashUsecases.watchTrashItems().listen(
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

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return const AsyncValue.loading();
  }

  Future<void> restoreItem(String id, TrashItemType type) async {
    try {
      await ref.read(trashUsecasesProvider).restoreItem(id, type);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteItemPermanently(String id, TrashItemType type) async {
    try {
      await ref.read(trashUsecasesProvider).deleteItemPermanently(id, type);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> emptyTrash() async {
    try {
      await ref.read(trashUsecasesProvider).emptyTrash();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
