import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/core/security/secure_storage_manager.dart';

/// Provider for the [SecureStorageManager] dependencies.
/// This is exposed as a separate provider to allow mocking during tests.
final secureStorageProvider = Provider<SecureStorageManager>((ref) {
  return SecureStorageManager();
});

/// A [Notifier] that manages the active [Locale] of the application.
///
/// Initialises using the platform's system locale as a fallback, and then
/// attempts to load any user preference previously saved in secure storage.
class LocaleNotifier extends Notifier<Locale> {
  late final SecureStorageManager _secureStorage;

  static const List<String> supportedLanguages = ['en', 'es', 'ca'];

  @override
  Locale build() {
    _secureStorage = ref.watch(secureStorageProvider);

    // Default to the system's locale language code if it is supported,
    // otherwise fallback to English.
    final systemLocale = PlatformDispatcher.instance.locale;
    final defaultLocale = supportedLanguages.contains(systemLocale.languageCode)
        ? Locale(systemLocale.languageCode)
        : const Locale('en');

    // Trigger an asynchronous read of the persisted locale preference
    _loadPersistedLocale(defaultLocale);

    return defaultLocale;
  }

  /// Asynchronously loads the saved locale from secure storage and updates the state.
  Future<void> _loadPersistedLocale(Locale fallback) async {
    try {
      final savedCode = await _secureStorage.getUserLocale();
      if (savedCode != null && supportedLanguages.contains(savedCode)) {
        state = Locale(savedCode);
      }
    } catch (_) {
      // Secure storage read error; retain the default system locale.
    }
  }

  /// Updates the application's locale state and persists the language code.
  Future<void> setLocale(Locale newLocale) async {
    if (!supportedLanguages.contains(newLocale.languageCode)) {
      return;
    }
    state = newLocale;
    try {
      await _secureStorage.setUserLocale(newLocale.languageCode);
    } catch (_) {
      // Secure storage write error; keep the in-memory state updated regardless.
    }
  }
}

/// Global provider for the active [Locale].
final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
