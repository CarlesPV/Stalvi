import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/usecases/initialize_default_data_usecase.dart';

class CreateProfileParams {
  final String name;
  final String username;
  final String pin;
  final String defaultCurrency;
  final String locale;
  final bool acceptedTerms;

  const CreateProfileParams({
    required this.name,
    required this.username,
    required this.pin,
    required this.defaultCurrency,
    required this.locale,
    required this.acceptedTerms,
  });
}

class CreateProfileUseCase {
  final IProfileRepository _profileRepository;
  final SecureStorageManager _secureStorageManager;
  final InitializeDefaultDataUseCase _initializeDefaultDataUseCase;

  CreateProfileUseCase(
    this._profileRepository,
    this._secureStorageManager,
    this._initializeDefaultDataUseCase,
  );

  Future<Profile> execute(CreateProfileParams params) async {
    // 1. Terms acceptance check
    if (!params.acceptedTerms) {
      throw const ValidationException(
        message: 'You must accept the Terms & Conditions to proceed.',
      );
    }

    // 2. PIN length and numeric validation
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

    // 3. Hash PIN with SHA-256
    final pinHash = _hashPin(pin);

    // 4. Save PIN hash, user locale, and PIN length in secure storage
    await _secureStorageManager.savePinHash(pinHash);
    await _secureStorageManager.setUserLocale(params.locale);
    await _secureStorageManager.savePinLength(pin.length);

    // 5. Update seeded profile or create a new one
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

    // 6. Initialize default data (account, categories, tags)
    await _initializeDefaultDataUseCase.execute(
      userId: profile.id,
      currency: profile.defaultCurrency,
      locale: params.locale,
    );

    return profile;
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
