import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/services/background_sync_service.dart';

class MockBackgroundSyncService extends Mock implements BackgroundSyncService {}

void main() {
  group('BackgroundSyncService', () {
    late BackgroundSyncService mockService;

    setUp(() {
      mockService = MockBackgroundSyncService();
    });

    test('should be able to initialize and register periodic tasks', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.registerPeriodicTasks()).thenAnswer((_) async {});

      await mockService.initialize();
      await mockService.registerPeriodicTasks();

      verify(() => mockService.initialize()).called(1);
      verify(() => mockService.registerPeriodicTasks()).called(1);
    });
  });
}
