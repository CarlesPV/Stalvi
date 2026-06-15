import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/core/security/secure_storage_manager.dart';

class UpdateCredentialsParams {
  final String oldPin;
  final String newPin;

  const UpdateCredentialsParams({
    required this.oldPin,
    required this.newPin,
  });
}

class UpdateCredentialsUseCase {
  final SecureStorageManager _secureStorageManager;

  UpdateCredentialsUseCase(this._secureStorageManager);

  Future<void> execute(UpdateCredentialsParams params) async {
    // 1. Validate old PIN against stored hash
    final storedHash = await _secureStorageManager.getPinHash();
    if (storedHash == null) {
      throw const ValidationException(message: 'No PIN is currently set.');
    }

    final oldPinHash = _hashPin(params.oldPin);
    if (oldPinHash != storedHash) {
      throw const ValidationException(message: 'Incorrect Old PIN.');
    }

    // 2. Validate new PIN length and numeric format
    final newPin = params.newPin;
    if (newPin.length < 4 || newPin.length > 8) {
      throw const ValidationException(
        message: 'New PIN must be between 4 and 8 digits.',
      );
    }
    if (int.tryParse(newPin) == null) {
      throw const ValidationException(
        message: 'New PIN must contain only numeric digits.',
      );
    }

    // 3. Hash new PIN and save
    final newPinHash = _hashPin(newPin);
    await _secureStorageManager.savePinHash(newPinHash);
    await _secureStorageManager.savePinLength(newPin.length);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
