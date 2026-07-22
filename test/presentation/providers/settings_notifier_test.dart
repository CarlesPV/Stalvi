import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/repositories/i_settings_repository.dart';
import 'package:stalvi/infrastructure/services/notification_service.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:stalvi/presentation/providers/settings_notifier.dart';

class FakeSettingsRepository implements ISettingsRepository {
  bool notificationsEnabled;

  FakeSettingsRepository({this.notificationsEnabled = true});

  @override
  Future<bool> getNotificationsEnabled() async {
    return notificationsEnabled;
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    notificationsEnabled = enabled;
  }
}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late FakeSettingsRepository fakeSettingsRepo;
  late MockNotificationService mockNotificationService;
  late ProviderContainer container;

  setUp(() {
    fakeSettingsRepo = FakeSettingsRepository(notificationsEnabled: true);
    mockNotificationService = MockNotificationService();

    container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('SettingsNotifier', () {
    test('initial state defaults to false (OFF)', () async {
      final state = container.read(settingsNotifierProvider);
      expect(state, isFalse);
    });

    test('initial state loads persisted false (OFF) from repository', () async {
      fakeSettingsRepo.notificationsEnabled = false;

      final testContainer = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
        ],
      );
      addTearDown(testContainer.dispose);

      testContainer.read(settingsNotifierProvider.notifier);
      await Future.delayed(Duration.zero);

      final state = testContainer.read(settingsNotifierProvider);
      expect(state, isFalse);
    });

    test('toggleNotifications(false) turns toggle OFF and persists false',
        () async {
      final notifier = container.read(settingsNotifierProvider.notifier);

      final result = await notifier.toggleNotifications(false);

      expect(result, NotificationToggleResult.success);
      expect(container.read(settingsNotifierProvider), isFalse);
      expect(fakeSettingsRepo.notificationsEnabled, isFalse);
      verifyNever(() => mockNotificationService.isPermissionGranted());
      verifyNever(() => mockNotificationService.requestPermissions());
    });

    test('toggleNotifications(true) when OS permission is already granted',
        () async {
      fakeSettingsRepo.notificationsEnabled = false;
      when(() => mockNotificationService.isPermissionGranted())
          .thenAnswer((_) async => true);

      final notifier = container.read(settingsNotifierProvider.notifier);
      final result = await notifier.toggleNotifications(true);

      expect(result, NotificationToggleResult.success);
      expect(container.read(settingsNotifierProvider), isTrue);
      expect(fakeSettingsRepo.notificationsEnabled, isTrue);
      verify(() => mockNotificationService.isPermissionGranted()).called(1);
      verifyNever(() => mockNotificationService.requestPermissions());
    });

    test('toggleNotifications(true) when permanently denied', () async {
      fakeSettingsRepo.notificationsEnabled = false;
      when(() => mockNotificationService.isPermissionGranted())
          .thenAnswer((_) async => false);
      when(() => mockNotificationService.isPermissionPermanentlyDenied())
          .thenAnswer((_) async => true);

      final notifier = container.read(settingsNotifierProvider.notifier);
      final result = await notifier.toggleNotifications(true);

      expect(result, NotificationToggleResult.permanentlyDenied);
      expect(container.read(settingsNotifierProvider), isFalse);
      expect(fakeSettingsRepo.notificationsEnabled, isFalse);
      verify(() => mockNotificationService.isPermissionGranted()).called(1);
      verify(() => mockNotificationService.isPermissionPermanentlyDenied())
          .called(1);
      verifyNever(() => mockNotificationService.requestPermissions());
    });

    test(
        'toggleNotifications(true) requests permission if not granted and succeeds if granted by user',
        () async {
      fakeSettingsRepo.notificationsEnabled = false;
      when(() => mockNotificationService.isPermissionGranted())
          .thenAnswer((_) async => false);
      when(() => mockNotificationService.isPermissionPermanentlyDenied())
          .thenAnswer((_) async => false);
      when(() => mockNotificationService.requestPermissions())
          .thenAnswer((_) async => true);

      final notifier = container.read(settingsNotifierProvider.notifier);
      final result = await notifier.toggleNotifications(true);

      expect(result, NotificationToggleResult.success);
      expect(container.read(settingsNotifierProvider), isTrue);
      expect(fakeSettingsRepo.notificationsEnabled, isTrue);
      verify(() => mockNotificationService.isPermissionGranted()).called(1);
      verify(() => mockNotificationService.requestPermissions()).called(1);
    });

    test(
        'toggleNotifications(true) reverts to OFF if user denies notification permission',
        () async {
      fakeSettingsRepo.notificationsEnabled = false;
      when(() => mockNotificationService.isPermissionGranted())
          .thenAnswer((_) async => false);
      when(() => mockNotificationService.isPermissionPermanentlyDenied())
          .thenAnswer((_) async => false);
      when(() => mockNotificationService.requestPermissions())
          .thenAnswer((_) async => false);

      final notifier = container.read(settingsNotifierProvider.notifier);
      final result = await notifier.toggleNotifications(true);

      expect(result, NotificationToggleResult.denied);
      expect(container.read(settingsNotifierProvider), isFalse);
      expect(fakeSettingsRepo.notificationsEnabled, isFalse);
      verify(() => mockNotificationService.isPermissionGranted()).called(1);
      verify(() => mockNotificationService.requestPermissions()).called(1);
    });
  });
}
