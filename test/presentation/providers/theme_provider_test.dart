import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';
import 'package:stalvi/presentation/providers/theme_provider.dart';

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

  group('ThemeNotifier Unit Tests', () {
    test('defaults to ThemeMode.system when secure storage is empty', () async {
      when(() => mockSecureStorage.getThemeMode())
          .thenAnswer((_) async => null);

      final container = createContainer();

      // Initially it should return default ThemeMode.system
      final initialTheme = container.read(themeProvider);
      expect(initialTheme, equals(ThemeMode.system));

      // Let the microtasks / async loads finish
      await Future.delayed(const Duration(milliseconds: 10));

      final currentTheme = container.read(themeProvider);
      expect(currentTheme, equals(ThemeMode.system));
    });

    test('loads persisted theme mode from secure storage if present', () async {
      when(() => mockSecureStorage.getThemeMode())
          .thenAnswer((_) async => 'dark');

      final container = createContainer();

      // Initialize the provider by reading it first
      container.read(themeProvider);

      // Wait for the async loading method inside the provider to complete
      await Future.delayed(const Duration(milliseconds: 20));

      final currentTheme = container.read(themeProvider);
      expect(currentTheme, equals(ThemeMode.dark));
    });

    test('setThemeMode updates state and persists to secure storage', () async {
      when(() => mockSecureStorage.getThemeMode())
          .thenAnswer((_) async => null);
      when(() => mockSecureStorage.setThemeMode('light'))
          .thenAnswer((_) async {});

      final container = createContainer();

      await container
          .read(themeProvider.notifier)
          .setThemeMode(ThemeMode.light);

      final currentTheme = container.read(themeProvider);
      expect(currentTheme, equals(ThemeMode.light));
      verify(() => mockSecureStorage.setThemeMode('light')).called(1);
    });
  });
}
