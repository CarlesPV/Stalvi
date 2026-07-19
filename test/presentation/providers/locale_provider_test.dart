import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';

class MockSecureStorageManager extends Mock implements SecureStorageManager {}

void main() {
  late MockSecureStorageManager mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockSecureStorageManager();
  });

  ProviderContainer createContainer({
    List overrides = const [],
  }) {
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(mockSecureStorage),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('LocaleNotifier Unit Tests', () {
    test('defaults to system locale or en when secure storage is empty',
        () async {
      when(() => mockSecureStorage.getUserLocale())
          .thenAnswer((_) async => null);

      final container = createContainer();

      // Initially it should return a valid locale (system locale or fallback 'en')
      final initialLocale = container.read(localeProvider);
      expect(initialLocale, isA<Locale>());

      // Let the microtasks / async loads finish
      await Future.delayed(const Duration(milliseconds: 10));

      final currentLocale = container.read(localeProvider);
      expect(currentLocale.languageCode, anyOf('en', 'es', 'ca'));
    });

    test('loads persisted locale from secure storage if present', () async {
      when(() => mockSecureStorage.getUserLocale())
          .thenAnswer((_) async => 'es');

      final container = createContainer();

      // Initialize the provider by reading it first
      container.read(localeProvider);

      // Wait for the async loading method inside the provider to complete
      await Future.delayed(const Duration(milliseconds: 20));

      final currentLocale = container.read(localeProvider);
      expect(currentLocale.languageCode, equals('es'));
    });

    test('setLocale updates state and persists to secure storage', () async {
      when(() => mockSecureStorage.getUserLocale())
          .thenAnswer((_) async => null);
      when(() => mockSecureStorage.setUserLocale('ca'))
          .thenAnswer((_) async {});

      final container = createContainer();

      await container
          .read(localeProvider.notifier)
          .setLocale(const Locale('ca'));

      final currentLocale = container.read(localeProvider);
      expect(currentLocale.languageCode, equals('ca'));
      verify(() => mockSecureStorage.setUserLocale('ca')).called(1);
    });

    test('setLocale rejects unsupported languages', () async {
      when(() => mockSecureStorage.getUserLocale())
          .thenAnswer((_) async => 'en');

      final container = createContainer();

      await container
          .read(localeProvider.notifier)
          .setLocale(const Locale('fr'));

      final currentLocale = container.read(localeProvider);
      expect(currentLocale.languageCode, equals('en'));
      verifyNever(() => mockSecureStorage.setUserLocale(any()));
    });
  });
}
