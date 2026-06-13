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
