import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/usecases/create_account_usecase.dart';
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

/// Use case responsible for creating or updating a user profile during
/// onboarding.
///
/// **Default account creation contract:**
/// - The default account is created ONLY after the profile has been
///   successfully persisted.
/// - It uses [CreateProfileParams.defaultCurrency] so that the account's
///   currency always matches what the user selected.
/// - The account name is resolved from the application's localization system
///   using [CreateProfileParams.locale], with a safe fallback to English.
class CreateProfileUseCase {
  final IProfileRepository _profileRepository;
  final SecureStorageManager _secureStorageManager;
  final CreateAccountUseCase _createAccountUseCase;
  final InitializeDefaultDataUseCase _initializeDefaultDataUseCase;

  CreateProfileUseCase(
    this._profileRepository,
    this._secureStorageManager,
    this._createAccountUseCase,
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

    // 6. Create the default account using the user's chosen currency.
    //    This happens explicitly here — AFTER the profile exists — so the
    //    account's currency is guaranteed to match the profile's currency.
    await _createDefaultAccount(
      userId: profile.id,
      currency: profile.defaultCurrency,
      locale: params.locale,
    );

    // 7. Seed default categories and tags (no account creation).
    await _initializeDefaultDataUseCase.execute(
      userId: profile.id,
      locale: params.locale,
    );

    return profile;
  }

  /// Creates the default "main wallet" account for a newly created profile.
  ///
  /// The account name is resolved from the l10n system.  If the locale lookup
  /// fails (e.g. unsupported locale), it falls back to the English string.
  Future<void> _createDefaultAccount({
    required String userId,
    required String currency,
    required String locale,
  }) async {
    // Resolve the localized wallet name.
    var walletName = 'Main Account';
    try {
      final langCode = locale.split('_').first.split('-').first.toLowerCase();
      walletName = lookupAppLocalizations(Locale(langCode)).defaultAccountName;
    } catch (_) {
      // Keep the English fallback set above.
    }

    final params = CreateAccountParams(
      id: const Uuid().v4(),
      userId: userId,
      name: walletName,
      type: AccountType.cash,
      initialBalance: 0.0,
      currency: currency,
      color: '#4CAF50',
      icon: 'wallet',
      isDefault: true,
    );

    await _createAccountUseCase.execute(params);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
