import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/trash_item.dart';
import 'package:stalvi/domain/usecases/trash_usecases.dart';
import 'package:stalvi/presentation/features/recycle_bin/recycle_bin_provider.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';

class MockTrashUsecases extends Mock implements TrashUsecases {}

void main() {
  late MockTrashUsecases mockTrashUsecases;

  setUpAll(() {
    registerFallbackValue(TrashItemType.transaction);
  });

  setUp(() {
    mockTrashUsecases = MockTrashUsecases();
  });

  ProviderContainer createContainer({
    List overrides = const [],
  }) {
    final container = ProviderContainer(
      overrides: [
        trashUsecasesProvider.overrideWithValue(mockTrashUsecases),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('RecycleBinNotifier Unit Tests', () {
    test(
        'initializes and loads trash items dynamically calculating daysRemaining from stream',
        () async {
      final now = DateTime.now();
      final items = [
        TrashItem(
          id: '1',
          name: 'Item 1',
          type: TrashItemType.transaction,
          daysRemaining: 30,
          deletedAt: now.subtract(const Duration(days: 5)),
        ),
      ];

      final streamController = StreamController<List<TrashItem>>();
      when(() => mockTrashUsecases.watchTrashItems())
          .thenAnswer((_) => streamController.stream);

      final container = createContainer();

      // Listen to the provider to keep it alive since it is autoDispose
      final sub = container.listen(recycleBinProvider, (_, __) {});

      // Wait for loading state
      expect(
        container.read(recycleBinProvider),
        const AsyncValue<List<TrashItem>>.loading(),
      );

      // Emit items
      streamController.add(items);
      await Future.delayed(Duration.zero);

      final state = container.read(recycleBinProvider);
      expect(state, isA<AsyncData<List<TrashItem>>>());

      final loadedItems = state.value!;
      expect(loadedItems.length, 1);
      expect(loadedItems[0].id, '1');
      // 30 - 5 = 25 days remaining
      expect(loadedItems[0].daysRemaining, 25);
      verify(() => mockTrashUsecases.watchTrashItems()).called(1);

      sub.close();
      streamController.close();
    });

    test('restoreItem delegates to usecase', () async {
      when(() => mockTrashUsecases.watchTrashItems())
          .thenAnswer((_) => Stream.value([]));
      when(() => mockTrashUsecases.restoreItem(any(), any()))
          .thenAnswer((_) async {});

      final container = createContainer();
      final sub = container.listen(recycleBinProvider, (_, __) {});

      await Future.delayed(Duration.zero);

      await container
          .read(recycleBinProvider.notifier)
          .restoreItem('1', TrashItemType.transaction);

      verify(
        () => mockTrashUsecases.restoreItem('1', TrashItemType.transaction),
      ).called(1);
      sub.close();
    });

    test('deleteItemPermanently delegates to usecase', () async {
      when(() => mockTrashUsecases.watchTrashItems())
          .thenAnswer((_) => Stream.value([]));
      when(() => mockTrashUsecases.deleteItemPermanently(any(), any()))
          .thenAnswer((_) async {});

      final container = createContainer();
      final sub = container.listen(recycleBinProvider, (_, __) {});

      await Future.delayed(Duration.zero);

      await container
          .read(recycleBinProvider.notifier)
          .deleteItemPermanently('1', TrashItemType.transaction);

      verify(
        () => mockTrashUsecases.deleteItemPermanently(
          '1',
          TrashItemType.transaction,
        ),
      ).called(1);
      sub.close();
    });

    test('emptyTrash delegates to usecase', () async {
      when(() => mockTrashUsecases.watchTrashItems())
          .thenAnswer((_) => Stream.value([]));
      when(() => mockTrashUsecases.emptyTrash()).thenAnswer((_) async {});

      final container = createContainer();
      final sub = container.listen(recycleBinProvider, (_, __) {});

      await Future.delayed(Duration.zero);

      await container.read(recycleBinProvider.notifier).emptyTrash();

      verify(() => mockTrashUsecases.emptyTrash()).called(1);
      sub.close();
    });
  });
}
