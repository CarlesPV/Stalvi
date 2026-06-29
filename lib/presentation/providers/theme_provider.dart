import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'locale_provider.dart';

/// A [Notifier] that manages the active [ThemeMode] of the application.
///
/// Initialises with [ThemeMode.system] as the default/fallback, and then
/// attempts to load any user preference previously saved in secure storage.
class ThemeNotifier extends Notifier<ThemeMode> {
  late final SecureStorageManager _secureStorage;

  @override
  ThemeMode build() {
    _secureStorage = ref.watch(secureStorageProvider);

    // Default to system theme mode
    const defaultMode = ThemeMode.system;

    // Trigger an asynchronous read of the persisted theme preference
    _loadPersistedTheme(defaultMode);

    return defaultMode;
  }

  /// Asynchronously loads the saved theme from secure storage and updates the state.
  Future<void> _loadPersistedTheme(ThemeMode fallback) async {
    try {
      final savedThemeName = await _secureStorage.getThemeMode();
      if (savedThemeName != null) {
        final matchedMode = ThemeMode.values.firstWhere(
          (mode) => mode.name == savedThemeName,
          orElse: () => fallback,
        );
        state = matchedMode;
      }
    } catch (_) {
      // Secure storage read error; retain the default theme mode.
    }
  }

  /// Updates the application's theme mode state and persists the choice.
  Future<void> setThemeMode(ThemeMode newMode) async {
    state = newMode;
    try {
      await _secureStorage.setThemeMode(newMode.name);
    } catch (_) {
      // Secure storage write error; keep the in-memory state updated regardless.
    }
  }
}

/// Global provider for the active [ThemeMode].
final themeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
