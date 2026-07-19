import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the SQLCipher encryption key lifecycle using platform-secure storage.
///
/// The encryption key is a 256-bit (32-byte) random value generated via a
/// cryptographically secure pseudo-random number generator (CSPRNG). It is
/// stored in the platform's secure enclave:
///   - **iOS**: Keychain Services
///   - **Android**: EncryptedSharedPreferences (AES-256-SIV + AES-256-GCM)
///
/// **Security invariants:**
///   - The key is generated exactly once and reused on subsequent launches.
///   - The raw key bytes are never logged, serialised to analytics, or
///     transmitted over the network.
///   - The key is encoded as a hex string for storage (not base64) to avoid
///     accidental truncation by null-byte-sensitive APIs.
class SecureStorageManager {
  SecureStorageManager({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _storage;

  /// Storage key constant – changing this will orphan existing databases.
  static const String _kEncryptionKeyName = 'stalvi_db_cipher_key';

  /// Storage key constant for persisting the user's selected locale language code.
  static const String _kUserLocaleKey = 'stalvi_user_locale';

  /// Storage key constant for persisting the user's PIN hash.
  static const String _kPinHashKey = 'stalvi_pin_hash';

  /// Storage key constant for persisting the user's PIN length.
  static const String _kPinLengthKey = 'stalvi_pin_length';

  /// Storage key constant for persisting biometrics enabled status.
  static const String _kBiometricsEnabledKey = 'stalvi_biometrics_enabled';

  /// Storage key constant for persisting the user's selected theme mode.
  static const String _kThemeModeKey = 'stalvi_theme_mode';

  /// Storage key constant for persisting the PIN brute-force lockout timestamp
  /// (milliseconds since epoch, stored as a decimal string).
  static const String _kPinLockoutTimestampKey = 'stalvi_pin_lockout_ts';

  /// Length of the encryption key in bytes (256 bits).
  static const int _kKeyLengthBytes = 32;

  Future<String?> _readWithRetry(String key) async {
    const retries = 3;
    for (var i = 0; i < retries; i++) {
      try {
        return await _storage.read(key: key);
      } catch (_) {
        if (i == retries - 1) rethrow;
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
    return null;
  }

  Future<void> _writeWithRetry(String key, String value) async {
    const retries = 3;
    for (var i = 0; i < retries; i++) {
      try {
        await _storage.write(key: key, value: value);
        return;
      } catch (_) {
        if (i == retries - 1) rethrow;
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
  }

  Future<void> _deleteWithRetry(String key) async {
    const retries = 3;
    for (var i = 0; i < retries; i++) {
      try {
        await _storage.delete(key: key);
        return;
      } catch (_) {
        if (i == retries - 1) rethrow;
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
  }

  /// Retrieves the existing encryption key, or generates and persists a new one
  /// if no key exists yet.
  ///
  /// Returns the key as a hex-encoded [String] suitable for passing directly
  /// to SQLCipher's `PRAGMA key`.
  ///
  /// Throws a [SecureStorageException] if the platform keystore is
  /// unavailable or the read/write operation fails.
  Future<String> getOrCreateEncryptionKey() async {
    try {
      final existingKey = await _readWithRetry(_kEncryptionKeyName);

      if (existingKey != null && existingKey.isNotEmpty) {
        return existingKey;
      }

      final newKey = _generateSecureKey();
      await _writeWithRetry(_kEncryptionKeyName, newKey);
      return newKey;
    } on Exception catch (e) {
      throw SecureStorageException(
        'Failed to access or create the database encryption key.',
        cause: e,
      );
    }
  }

  /// Checks whether an encryption key already exists in secure storage.
  Future<bool> hasEncryptionKey() async {
    try {
      final key = await _readWithRetry(_kEncryptionKeyName);
      return key != null && key.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Permanently deletes the stored encryption key.
  ///
  /// **⚠️ WARNING**: Calling this will make any existing encrypted database
  /// permanently unreadable. Only use during a full data-wipe / factory-reset
  /// flow.
  Future<void> deleteEncryptionKey() async {
    try {
      await _deleteWithRetry(_kEncryptionKeyName);
    } on Exception catch (e) {
      throw SecureStorageException(
        'Failed to delete database encryption key.',
        cause: e,
      );
    }
  }

  /// Retrieves the saved user locale language code from secure storage.
  /// Returns null if no locale is saved or if an exception occurs.
  Future<String?> getUserLocale() async {
    try {
      return await _readWithRetry(_kUserLocaleKey);
    } on Exception {
      return null;
    }
  }

  /// Persists the user locale language code to secure storage.
  Future<void> setUserLocale(String languageCode) async {
    try {
      await _writeWithRetry(_kUserLocaleKey, languageCode);
    } on Exception catch (e) {
      throw SecureStorageException(
        'Failed to save user locale to secure storage.',
        cause: e,
      );
    }
  }

  /// Saves the user's PIN hash to secure storage.
  Future<void> savePinHash(String pinHash) async {
    try {
      await _writeWithRetry(_kPinHashKey, pinHash);
    } on Exception catch (e) {
      throw SecureStorageException(
        'Failed to save PIN hash to secure storage.',
        cause: e,
      );
    }
  }

  /// Retrieves the saved PIN hash from secure storage.
  Future<String?> getPinHash() async {
    try {
      return await _readWithRetry(_kPinHashKey);
    } on Exception {
      return null;
    }
  }

  /// Checks if a PIN hash exists in secure storage.
  Future<bool> hasPin() async {
    try {
      final pin = await getPinHash();
      return pin != null && pin.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Deletes the PIN hash from secure storage.
  Future<void> deletePinHash() async {
    try {
      await _deleteWithRetry(_kPinHashKey);
    } on Exception catch (e) {
      throw SecureStorageException(
        'Failed to delete PIN hash from secure storage.',
        cause: e,
      );
    }
  }

  /// Saves the user's PIN length to secure storage.
  Future<void> savePinLength(int length) async {
    try {
      await _writeWithRetry(_kPinLengthKey, length.toString());
    } on Exception catch (e) {
      throw SecureStorageException(
        'Failed to save PIN length to secure storage.',
        cause: e,
      );
    }
  }

  /// Retrieves the saved PIN length from secure storage.
  Future<int?> getPinLength() async {
    try {
      final value = await _readWithRetry(_kPinLengthKey);
      if (value != null) {
        return int.tryParse(value);
      }
      return null;
    } on Exception {
      return null;
    }
  }

  /// Deletes the PIN length from secure storage.
  Future<void> deletePinLength() async {
    try {
      await _deleteWithRetry(_kPinLengthKey);
    } on Exception catch (e) {
      throw SecureStorageException(
        'Failed to delete PIN length from secure storage.',
        cause: e,
      );
    }
  }

  /// Persists the biometrics enabled flag to secure storage.
  Future<void> setBiometricsEnabled(bool enabled) async {
    try {
      await _writeWithRetry(_kBiometricsEnabledKey, enabled.toString());
    } on Exception catch (e) {
      throw SecureStorageException(
        'Failed to save biometrics status to secure storage.',
        cause: e,
      );
    }
  }

  /// Checks if biometrics are enabled.
  Future<bool> isBiometricsEnabled() async {
    try {
      final value = await _readWithRetry(_kBiometricsEnabledKey);
      return value == 'true';
    } on Exception {
      return false;
    }
  }

  /// Checks if the biometrics opt-in choice was already made.
  Future<bool> hasBiometricsChoice() async {
    try {
      final value = await _readWithRetry(_kBiometricsEnabledKey);
      return value != null;
    } catch (_) {
      return false;
    }
  }

  /// Retrieves the saved user theme mode from secure storage.
  /// Returns null if no theme is saved or if an exception occurs.
  Future<String?> getThemeMode() async {
    try {
      return await _readWithRetry(_kThemeModeKey);
    } on Exception {
      return null;
    }
  }

  /// Persists the user theme mode to secure storage.
  Future<void> setThemeMode(String themeMode) async {
    try {
      await _writeWithRetry(_kThemeModeKey, themeMode);
    } on Exception catch (e) {
      throw SecureStorageException(
        'Failed to save theme mode to secure storage.',
        cause: e,
      );
    }
  }

  // ── PIN lockout timestamp ─────────────────────────────────────────────────

  /// Persists the epoch timestamp (ms) at which the PIN lockout started.
  Future<void> saveLockoutTimestamp(int epochMs) async {
    try {
      await _writeWithRetry(_kPinLockoutTimestampKey, epochMs.toString());
    } on Exception catch (e) {
      throw SecureStorageException(
        'Failed to save PIN lockout timestamp to secure storage.',
        cause: e,
      );
    }
  }

  /// Retrieves the persisted lockout timestamp in milliseconds since epoch.
  /// Returns [null] if no lockout is currently stored.
  Future<int?> getLockoutTimestamp() async {
    try {
      final value = await _readWithRetry(_kPinLockoutTimestampKey);
      if (value != null) return int.tryParse(value);
      return null;
    } on Exception {
      return null;
    }
  }

  /// Removes the persisted lockout timestamp, effectively clearing any
  /// stored lockout state.
  Future<void> deleteLockoutTimestamp() async {
    try {
      await _deleteWithRetry(_kPinLockoutTimestampKey);
    } on Exception catch (e) {
      throw SecureStorageException(
        'Failed to delete PIN lockout timestamp from secure storage.',
        cause: e,
      );
    }
  }

  /// Generates a 256-bit key using [Random.secure] (CSPRNG) and returns it
  /// as a lowercase hexadecimal string.
  String _generateSecureKey() {
    final random = Random.secure();
    final keyBytes = Uint8List(_kKeyLengthBytes);
    for (var i = 0; i < _kKeyLengthBytes; i++) {
      keyBytes[i] = random.nextInt(256);
    }
    // Encode as hex – avoids null-byte issues that base64 can introduce when
    // passed through C-string APIs (e.g. SQLCipher).
    return keyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Wipes all data stored in secure storage.
  Future<void> deleteAll() async {
    const retries = 3;
    for (var i = 0; i < retries; i++) {
      try {
        await _storage.deleteAll();
        return;
      } catch (_) {
        if (i == retries - 1) {
          throw const SecureStorageException(
            'Failed to delete all secure storage keys.',
          );
        }
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
  }
}

/// Exception thrown when secure storage operations fail.
class SecureStorageException implements Exception {
  const SecureStorageException(this.message, {this.cause});

  /// Human-readable description of the failure.
  final String message;

  /// The original platform exception, if available.
  final Exception? cause;

  @override
  String toString() =>
      'SecureStorageException: $message${cause != null ? ' (cause: $cause)' : ''}';
}
