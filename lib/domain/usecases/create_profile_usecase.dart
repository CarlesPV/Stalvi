import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/core/security/secure_storage_manager.dart';
import 'package:konta/domain/entities/profile.dart';
import 'package:konta/domain/repositories/i_profile_repository.dart';

class CreateProfileParams {
  final String name;
  final String username;
  final String pin;
  final String defaultCurrency;

  const CreateProfileParams({
    required this.name,
    required this.username,
    required this.pin,
    required this.defaultCurrency,
  });
}

class CreateProfileUseCase {
  final IProfileRepository _profileRepository;
  final SecureStorageManager _secureStorageManager;

  CreateProfileUseCase(this._profileRepository, this._secureStorageManager);

  Future<Profile> execute(CreateProfileParams params) async {
    // 1. PIN length and numeric validation
    final pin = params.pin;
    if (pin.length < 4 || pin.length > 8) {
      throw const ValidationException(
        message: 'PIN must be between 4 and 8 digits.',
      );
    }
    if (int.tryParse(pin) == null) {
      throw const ValidationException(
        message: 'PIN must contain only numeric digits.',
      );
    }

    if (params.name.trim().isEmpty) {
      throw const ValidationException(
        message: 'Name cannot be empty.',
      );
    }

    if (params.username.trim().isEmpty) {
      throw const ValidationException(
        message: 'Username cannot be empty.',
      );
    }

    // 2. Hash PIN with SHA-256
    final pinHash = _hashPin(pin);

    // 3. Save PIN hash in secure storage
    await _secureStorageManager.savePinHash(pinHash);

    // 4. Update seeded profile or create a new one
    final existing = await _profileRepository.getFirstProfile();
    final Profile profile;
    final now = DateTime.now();

    if (existing != null) {
      profile = existing.copyWith(
        name: params.name,
        username: params.username,
        defaultCurrency: params.defaultCurrency,
        modifiedAt: now,
      );
      await _profileRepository.updateProfile(profile);
    } else {
      final id = const Uuid().v4();
      profile = Profile(
        id: id,
        name: params.name,
        username: params.username,
        password:
            '', // Kept empty as authentication is managed via secure keystore
        defaultCurrency: params.defaultCurrency,
        createdAt: now,
        modifiedAt: now,
      );
      await _profileRepository.createProfile(profile);
    }

    return profile;
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
