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
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _storage;

  /// Storage key constant – changing this will orphan existing databases.
  static const String _kEncryptionKeyName = 'konta_db_cipher_key';

  /// Storage key constant for persisting the user's selected locale language code.
  static const String _kUserLocaleKey = 'konta_user_locale';

  /// Storage key constant for persisting the user's PIN hash.
  static const String _kPinHashKey = 'konta_pin_hash';

  /// Storage key constant for persisting biometrics enabled status.
  static const String _kBiometricsEnabledKey = 'konta_biometrics_enabled';

  /// Length of the encryption key in bytes (256 bits).
  static const int _kKeyLengthBytes = 32;

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
      final existingKey = await _storage.read(key: _kEncryptionKeyName);

      if (existingKey != null && existingKey.isNotEmpty) {
        return existingKey;
      }

      final newKey = _generateSecureKey();
      await _storage.write(key: _kEncryptionKeyName, value: newKey);
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
    final key = await _storage.read(key: _kEncryptionKeyName);
    return key != null && key.isNotEmpty;
  }

  /// Permanently deletes the stored encryption key.
  ///
  /// **⚠️ WARNING**: Calling this will make any existing encrypted database
  /// permanently unreadable. Only use during a full data-wipe / factory-reset
  /// flow.
  Future<void> deleteEncryptionKey() async {
    await _storage.delete(key: _kEncryptionKeyName);
  }

  /// Retrieves the saved user locale language code from secure storage.
  /// Returns null if no locale is saved or if an exception occurs.
  Future<String?> getUserLocale() async {
    try {
      return await _storage.read(key: _kUserLocaleKey);
    } on Exception {
      return null;
    }
  }

  /// Persists the user locale language code to secure storage.
  Future<void> setUserLocale(String languageCode) async {
    try {
      await _storage.write(key: _kUserLocaleKey, value: languageCode);
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
      await _storage.write(key: _kPinHashKey, value: pinHash);
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
      return await _storage.read(key: _kPinHashKey);
    } on Exception {
      return null;
    }
  }

  /// Checks if a PIN hash exists in secure storage.
  Future<bool> hasPin() async {
    final pin = await getPinHash();
    return pin != null && pin.isNotEmpty;
  }

  /// Deletes the PIN hash from secure storage.
  Future<void> deletePinHash() async {
    try {
      await _storage.delete(key: _kPinHashKey);
    } on Exception catch (e) {
      throw SecureStorageException(
        'Failed to delete PIN hash from secure storage.',
        cause: e,
      );
    }
  }

  /// Persists the biometrics enabled flag to secure storage.
  Future<void> setBiometricsEnabled(bool enabled) async {
    try {
      await _storage.write(
          key: _kBiometricsEnabledKey, value: enabled.toString());
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
      final value = await _storage.read(key: _kBiometricsEnabledKey);
      return value == 'true';
    } on Exception {
      return false;
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
