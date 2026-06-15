import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/infrastructure/services/biometric_auth_service.dart';

import 'package:konta/domain/usecases/create_profile_usecase.dart';
import 'package:konta/presentation/providers/locale_provider.dart';
import 'package:konta/presentation/providers/repository_providers.dart';

/// Describes the current authentication status for this session.
enum AuthStatus {
  /// The user has not created a profile yet (first launch).
  setupRequired,

  /// Profile setup is currently being processed.
  setupSubmitting,

  /// User is in the post-registration biometric opt-in flow.
  biometricOptIn,

  /// User needs to authenticate (either via PIN or biometrics).
  unauthenticated,

  /// PIN/biometric authentication is in progress.
  authenticating,

  /// User is successfully authenticated for the current session.
  authenticated,

  /// Biometric hardware is temporarily or permanently locked.
  lockedOut,
}

/// [AsyncNotifier] that manages PIN validation, profile setup, and biometric authentication.
class AuthNotifier extends AsyncNotifier<AuthStatus> {
  @override
  Future<AuthStatus> build() async {
    final secureStorage = ref.watch(secureStorageProvider);

    // Check if the user has already configured a PIN.
    final hasPin = await secureStorage.hasPin();
    if (!hasPin) {
      return AuthStatus.setupRequired;
    }

    final biometricService = ref.read(biometricAuthServiceProvider);
    final isEnabled = await biometricService.isBiometricsEnabled();
    final isAvailable = await biometricService.isBiometricAvailable();

    if (isEnabled && isAvailable) {
      Future.microtask(() => _authenticateOnStartup());
      return AuthStatus.authenticating;
    }

    return AuthStatus.unauthenticated;
  }

  /// Checks if biometric authentication is supported and enrolled on the device.
  Future<bool> isBiometricAvailable() async {
    final biometricService = ref.read(biometricAuthServiceProvider);
    return biometricService.isBiometricAvailable();
  }

  /// Prompts the user to enable biometrics right after PIN setup.
  Future<bool> promptBiometricSetup() async {
    final biometricService = ref.read(biometricAuthServiceProvider);

    final isAvailable = await biometricService.isBiometricAvailable();
    if (!isAvailable) {
      return false;
    }

    try {
      final authenticated = await biometricService.authenticate(
        localizedReason: 'Enable biometric authentication for Konta',
      );

      if (authenticated) {
        await biometricService.enableBiometrics();
        return true;
      }
    } on BiometricLockedOutException {
      state = const AsyncValue.data(AuthStatus.lockedOut);
    } catch (_) {
      // Ignore other errors and fallback to PIN
    }
    return false;
  }

  /// Presents the native biometric prompt to authenticate the user.
  Future<void> authenticate() async {
    final currentStatus = state.valueOrNull;

    if (currentStatus == AuthStatus.authenticated ||
        currentStatus == AuthStatus.lockedOut ||
        currentStatus == AuthStatus.setupRequired ||
        state.isLoading) {
      return;
    }

    state = const AsyncValue.loading();

    try {
      final biometricService = ref.read(biometricAuthServiceProvider);

      final isEnabled = await biometricService.isBiometricsEnabled();
      if (!isEnabled) {
        state = const AsyncValue.data(AuthStatus.unauthenticated);
        return;
      }

      final didAuthenticate = await biometricService.authenticate(
        localizedReason: 'Access your Konta financial data securely',
      );

      state = AsyncValue.data(
        didAuthenticate ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      );
    } on BiometricLockedOutException {
      state = const AsyncValue.data(AuthStatus.lockedOut);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Validates inputs, hashes the PIN, and invokes [CreateProfileUseCase] to create/update the profile.
  Future<void> setupProfile({
    required String name,
    required String username,
    required String pin,
    required String confirmPin,
    required bool acceptTerms,
    required String defaultCurrency,
  }) async {
    if (pin.length < 4 || pin.length > 8) {
      state = AsyncValue.error(
        'PIN must be between 4 and 8 digits.',
        StackTrace.current,
      );
      return;
    }
    if (int.tryParse(pin) == null) {
      state = AsyncValue.error(
        'PIN must contain only numeric digits.',
        StackTrace.current,
      );
      return;
    }
    if (pin != confirmPin) {
      state = AsyncValue.error(
        'PINs do not match.',
        StackTrace.current,
      );
      return;
    }
    if (!acceptTerms) {
      state = AsyncValue.error(
        'You must accept the Terms & Conditions to proceed.',
        StackTrace.current,
      );
      return;
    }
    if (name.trim().isEmpty) {
      state = AsyncValue.error(
        'Please enter a name.',
        StackTrace.current,
      );
      return;
    }
    if (username.trim().isEmpty) {
      state = AsyncValue.error(
        'Please enter a username.',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final locale = ref.read(localeProvider);
      final createProfileUseCase = ref.read(createProfileUseCaseProvider);
      final profile = await createProfileUseCase.execute(
        CreateProfileParams(
          name: name,
          username: username,
          pin: pin,
          defaultCurrency: defaultCurrency,
          locale: locale.languageCode,
          acceptedTerms: acceptTerms,
        ),
      );

      final initializeDefaultDataUseCase =
          ref.read(initializeDefaultDataUseCaseProvider);
      await initializeDefaultDataUseCase.execute(
        userId: profile.id,
        currency: defaultCurrency,
        locale: locale.languageCode,
      );

      state = const AsyncValue.data(AuthStatus.authenticated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _authenticateOnStartup() async {
    state = const AsyncValue.loading();
    try {
      final biometricService = ref.read(biometricAuthServiceProvider);
      final didAuthenticate = await biometricService.authenticate(
        localizedReason: 'Access your Konta financial data securely',
      );
      state = AsyncValue.data(
        didAuthenticate ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      );
    } on BiometricLockedOutException {
      state = const AsyncValue.data(AuthStatus.lockedOut);
    } catch (_) {
      state = const AsyncValue.data(AuthStatus.unauthenticated);
    }
  }

  /// Enables biometrics, prompts for registration, and completes the opt-in flow.
  Future<void> enableBiometricsOptIn() async {
    state = const AsyncValue.loading();
    try {
      final success = await promptBiometricSetup();
      if (success) {
        state = const AsyncValue.data(AuthStatus.authenticated);
      } else {
        final biometricService = ref.read(biometricAuthServiceProvider);
        await biometricService.disableBiometrics();
        state = const AsyncValue.data(AuthStatus.authenticated);
      }
    } catch (_) {
      final biometricService = ref.read(biometricAuthServiceProvider);
      await biometricService.disableBiometrics();
      state = const AsyncValue.data(AuthStatus.authenticated);
    }
  }

  /// Disables biometrics and completes the opt-in flow.
  Future<void> skipBiometricOptIn() async {
    state = const AsyncValue.loading();
    try {
      final biometricService = ref.read(biometricAuthServiceProvider);
      await biometricService.disableBiometrics();
      state = const AsyncValue.data(AuthStatus.authenticated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Verifies the entered PIN against the hash stored in secure storage.
  Future<bool> verifyPin(String pin) async {
    final currentStatus = state.valueOrNull;
    if (currentStatus == AuthStatus.authenticated || state.isLoading) {
      return false;
    }

    state = const AsyncValue.loading();
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final storedHash = await secureStorage.getPinHash();
      final inputHash = _hashPin(pin);

      if (storedHash == inputHash) {
        state = const AsyncValue.data(AuthStatus.authenticated);
        return true;
      } else {
        state = AsyncValue.error('Incorrect PIN.', StackTrace.current);
        return false;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Resets the authentication status to unauthenticated (e.g. on manual retry).
  void resetStatus() {
    state = const AsyncValue.data(AuthStatus.unauthenticated);
  }

  /// Retrieves the required PIN length from secure storage, defaulting to 4 if not set.
  Future<int> getRequiredPinLength() async {
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final length = await secureStorage.getPinLength();
      return length ?? 4;
    } catch (_) {
      return 4;
    }
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Global Riverpod provider for [AuthNotifier].
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthStatus>(AuthNotifier.new);
