import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/infrastructure/services/biometric_auth_service.dart';

import 'package:stalvi/domain/usecases/create_profile_usecase.dart';
import 'locale_provider.dart';
import 'repository_providers.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/utils/input_sanitizer.dart';

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

  /// PIN was exhausted – a 30-second brute-force cooldown is running.
  pinLockedOut,
}

/// Duration of the PIN brute-force lockout in seconds.
const int kPinLockoutSeconds = 30;

/// [AsyncNotifier] that manages PIN validation, profile setup, and biometric
/// authentication, including brute-force protection with a 30-second cooldown.
class AuthNotifier extends AsyncNotifier<AuthStatus> {
  // ─── Public observable state ────────────────────────────────────────────────

  /// Number of PIN attempts still allowed.  Starts at 5 and counts down.
  int remainingPinAttempts = 5;

  /// Seconds remaining in the current PIN lockout. 0 means no lockout.
  int pinLockoutSecondsRemaining = 0;

  // ─── Private state ──────────────────────────────────────────────────────────

  Timer? _lockoutTimer;
  int _lockoutStartEpochMs = 0;

  // ─── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  Future<AuthStatus> build() async {
    // Cancel any running timer when the notifier is rebuilt/disposed.
    ref.onDispose(() => _lockoutTimer?.cancel());

    final secureStorage = ref.watch(secureStorageProvider);

    // Check if the user has already configured a PIN.
    final hasPin = await secureStorage.hasPin();
    if (!hasPin) {
      return AuthStatus.setupRequired;
    }

    // ── Restore persisted lockout (survives app restart) ─────────────────────
    final storedTs = await secureStorage.getLockoutTimestamp();
    if (storedTs != null) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - storedTs;
      final elapsedSeconds = elapsed ~/ 1000;
      if (elapsedSeconds < kPinLockoutSeconds) {
        // Lockout is still active – resume the countdown.
        _lockoutStartEpochMs = storedTs;
        remainingPinAttempts = 0;
        pinLockoutSecondsRemaining = kPinLockoutSeconds - elapsedSeconds;
        Future.microtask(_startLockoutCountdown);
        return AuthStatus.pinLockedOut;
      } else {
        // Lockout already expired while the app was closed – grant 1 attempt
        // for this cycle. A wrong entry will trigger a fresh 30 s lockout.
        await secureStorage.deleteLockoutTimestamp();
        remainingPinAttempts = 1;
        return AuthStatus.unauthenticated;
      }
    }

    // ── Biometric auto-login ─────────────────────────────────────────────────
    final biometricService = ref.read(biometricAuthServiceProvider);
    final isEnabled = await biometricService.isBiometricsEnabled();
    final isAvailable = await biometricService.isBiometricAvailable();

    if (isEnabled && isAvailable) {
      Future.microtask(() => _authenticateOnStartup());
      return AuthStatus.authenticating;
    }

    return AuthStatus.unauthenticated;
  }

  // ─── Public API ─────────────────────────────────────────────────────────────

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
      final locale = ref.read(localeProvider);
      final l10n = lookupAppLocalizations(locale);
      final authenticated = await biometricService.authenticate(
        localizedReason: l10n.authVerifyMessage,
        lockedOutMessage: l10n.authLockedTitle,
        authFailedMessage: l10n.authError,
        unknownErrorMessage: l10n.unexpectedError,
        signInTitle: l10n.authSignInTitle,
        cancelButton: l10n.btnCancel,
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
    final currentStatus = state.value;

    if (currentStatus == AuthStatus.authenticated ||
        currentStatus == AuthStatus.lockedOut ||
        currentStatus == AuthStatus.setupRequired ||
        currentStatus == AuthStatus.pinLockedOut ||
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

      final locale = ref.read(localeProvider);
      final l10n = lookupAppLocalizations(locale);
      final didAuthenticate = await biometricService.authenticate(
        localizedReason: l10n.authVerifyMessage,
        lockedOutMessage: l10n.authLockedTitle,
        authFailedMessage: l10n.authError,
        unknownErrorMessage: l10n.unexpectedError,
        signInTitle: l10n.authSignInTitle,
        cancelButton: l10n.btnCancel,
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

  /// Validates inputs, hashes the PIN, and invokes [CreateProfileUseCase] to
  /// create/update the profile.
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
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      state = AsyncValue.error(
        'Please enter a name.',
        StackTrace.current,
      );
      return;
    }
    if (trimmedName.length > 25) {
      state = AsyncValue.error(
        'Name cannot exceed 25 characters.',
        StackTrace.current,
      );
      return;
    }
    if (InputSanitizer.containsEmoji(name)) {
      state = AsyncValue.error(
        'Name cannot contain emojis.',
        StackTrace.current,
      );
      return;
    }

    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) {
      state = AsyncValue.error(
        'Please enter a username.',
        StackTrace.current,
      );
      return;
    }
    if (trimmedUsername.length > 25) {
      state = AsyncValue.error(
        'Username cannot exceed 25 characters.',
        StackTrace.current,
      );
      return;
    }
    if (InputSanitizer.containsEmoji(username)) {
      state = AsyncValue.error(
        'Username cannot contain emojis.',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final locale = ref.read(localeProvider);
      final createProfileUseCase = ref.read(createProfileUseCaseProvider);
      await createProfileUseCase.execute(
        CreateProfileParams(
          name: name,
          username: username,
          pin: pin,
          defaultCurrency: defaultCurrency,
          locale: locale.languageCode,
          acceptedTerms: acceptTerms,
        ),
      );

      ref.invalidate(defaultProfileProvider);

      state = const AsyncValue.data(AuthStatus.authenticated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Enables biometrics, prompts for registration, and completes the opt-in
  /// flow.
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
  ///
  /// Brute-force protection rules (unlimited cycles):
  ///  1. First 5 wrong attempts   → decrement [remainingPinAttempts], show error.
  ///  2. On the 5th wrong attempt → persist lockout timestamp, start 30 s timer.
  ///  3. After 30 s               → grant exactly **1** attempt for this cycle.
  ///  4. If that attempt is wrong → trigger another 30 s lockout (step 2 again).
  ///  The cycle repeats indefinitely and survives app restarts.
  Future<bool> verifyPin(String pin) async {
    final currentStatus = state.value;
    if (currentStatus == AuthStatus.authenticated ||
        currentStatus == AuthStatus.lockedOut ||
        currentStatus == AuthStatus.pinLockedOut ||
        state.isLoading) {
      return false;
    }

    if (remainingPinAttempts <= 0) {
      // Should not normally be reached – guard anyway.
      _triggerPinLockout();
      return false;
    }

    state = const AsyncValue.loading();
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final storedHash = await secureStorage.getPinHash();
      final inputHash = _hashPin(pin);

      if (storedHash == inputHash) {
        // ── Success ───────────────────────────────────────────────────────────
        remainingPinAttempts = 5;
        pinLockoutSecondsRemaining = 0;
        _lockoutTimer?.cancel();
        await secureStorage.deleteLockoutTimestamp();
        state = const AsyncValue.data(AuthStatus.authenticated);
        return true;
      } else {
        // ── Wrong PIN ─────────────────────────────────────────────────────────
        remainingPinAttempts--;

        if (remainingPinAttempts <= 0) {
          // Attempts exhausted – start a fresh 30 s lockout cycle.
          await _triggerPinLockout();
        } else {
          state = AsyncValue.error('Incorrect PIN.', StackTrace.current);
        }
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

  /// Retrieves the required PIN length from secure storage, defaulting to 4 if
  /// not set.
  Future<int> getRequiredPinLength() async {
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final length = await secureStorage.getPinLength();
      return length ?? 4;
    } catch (_) {
      return 4;
    }
  }

  // ─── Lockout helpers ────────────────────────────────────────────────────────

  /// Starts the 30-second PIN lockout: persists the timestamp, updates state,
  /// and kicks off the countdown ticker.
  Future<void> _triggerPinLockout() async {
    _lockoutStartEpochMs = DateTime.now().millisecondsSinceEpoch;
    pinLockoutSecondsRemaining = kPinLockoutSeconds;

    try {
      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.saveLockoutTimestamp(_lockoutStartEpochMs);
    } catch (_) {
      // Non-fatal – in-memory timer still protects the session.
    }

    state = const AsyncValue.data(AuthStatus.pinLockedOut);
    _startLockoutCountdown();
  }

  /// Ticks every second, updating [pinLockoutSecondsRemaining].
  /// When the countdown reaches zero, 1 attempt is granted for the next cycle.
  /// A wrong entry will trigger a fresh lockout, cycling indefinitely.
  void _startLockoutCountdown() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (pinLockoutSecondsRemaining > 1) {
        pinLockoutSecondsRemaining--;
        // Notify listeners so the UI can refresh the countdown.
        state = const AsyncValue.data(AuthStatus.pinLockedOut);
      } else {
        // ── Lockout expired ───────────────────────────────────────────────────
        timer.cancel();
        pinLockoutSecondsRemaining = 0;
        remainingPinAttempts = 1; // one attempt for this cycle
        try {
          final secureStorage = ref.read(secureStorageProvider);
          await secureStorage.deleteLockoutTimestamp();
        } catch (_) {
          // Non-fatal.
        }
        state = const AsyncValue.data(AuthStatus.unauthenticated);
      }
    });
  }

  // ─── Private helpers ────────────────────────────────────────────────────────

  Future<void> _authenticateOnStartup() async {
    state = const AsyncValue.loading();
    try {
      final biometricService = ref.read(biometricAuthServiceProvider);
      final locale = ref.read(localeProvider);
      final l10n = lookupAppLocalizations(locale);
      final didAuthenticate = await biometricService.authenticate(
        localizedReason: l10n.authVerifyMessage,
        lockedOutMessage: l10n.authLockedTitle,
        authFailedMessage: l10n.authError,
        unknownErrorMessage: l10n.unexpectedError,
        signInTitle: l10n.authSignInTitle,
        cancelButton: l10n.btnCancel,
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

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Global Riverpod provider for [AuthNotifier].
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthStatus>(AuthNotifier.new);
