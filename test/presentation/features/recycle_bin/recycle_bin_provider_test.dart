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
    List<Override> overrides = const [],
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
        'initializes and loads trash items dynamically calculating daysRemaining',
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

      when(() => mockTrashUsecases.getTrashItems())
          .thenAnswer((_) async => items);

      final container = createContainer();

      // Listen to the provider to keep it alive since it is autoDispose
      final sub = container.listen(recycleBinProvider, (_, __) {});

      // Let the async initialization complete
      await Future.delayed(const Duration(milliseconds: 20));

      final state = container.read(recycleBinProvider);
      expect(state, isA<AsyncData<List<TrashItem>>>());

      final loadedItems = state.value!;
      expect(loadedItems.length, 1);
      expect(loadedItems[0].id, '1');
      // 30 - 5 = 25 days remaining
      expect(loadedItems[0].daysRemaining, 25);
      verify(() => mockTrashUsecases.getTrashItems()).called(1);

      sub.close();
    });

    test('restoreItem delegates to usecase and reloads items', () async {
      when(() => mockTrashUsecases.getTrashItems()).thenAnswer((_) async => []);
      when(() => mockTrashUsecases.restoreItem(any(), any()))
          .thenAnswer((_) async {});

      final container = createContainer();
      final sub = container.listen(recycleBinProvider, (_, __) {});

      await Future.delayed(const Duration(milliseconds: 20));

      await container
          .read(recycleBinProvider.notifier)
          .restoreItem('1', TrashItemType.transaction);

      verify(
        () => mockTrashUsecases.restoreItem('1', TrashItemType.transaction),
      ).called(1);
      verify(() => mockTrashUsecases.getTrashItems()).called(2);
      sub.close();
    });

    test('deleteItemPermanently delegates to usecase and reloads items',
        () async {
      when(() => mockTrashUsecases.getTrashItems()).thenAnswer((_) async => []);
      when(() => mockTrashUsecases.deleteItemPermanently(any(), any()))
          .thenAnswer((_) async {});

      final container = createContainer();
      final sub = container.listen(recycleBinProvider, (_, __) {});

      await Future.delayed(const Duration(milliseconds: 20));

      await container
          .read(recycleBinProvider.notifier)
          .deleteItemPermanently('1', TrashItemType.transaction);

      verify(
        () => mockTrashUsecases.deleteItemPermanently(
          '1',
          TrashItemType.transaction,
        ),
      ).called(1);
      verify(() => mockTrashUsecases.getTrashItems()).called(2);
      sub.close();
    });

    test('emptyTrash delegates to usecase and reloads items', () async {
      when(() => mockTrashUsecases.getTrashItems()).thenAnswer((_) async => []);
      when(() => mockTrashUsecases.emptyTrash()).thenAnswer((_) async {});

      final container = createContainer();
      final sub = container.listen(recycleBinProvider, (_, __) {});

      await Future.delayed(const Duration(milliseconds: 20));

      await container.read(recycleBinProvider.notifier).emptyTrash();

      verify(() => mockTrashUsecases.emptyTrash()).called(1);
      verify(() => mockTrashUsecases.getTrashItems()).called(2);
      sub.close();
    });
  });
}
