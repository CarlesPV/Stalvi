import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// Describes the current biometric authentication status for this session.
///
/// The state machine is intentionally linear:
/// ```
/// AsyncLoading → unauthenticated → authenticating → authenticated
///             ↘ unavailable (auto-proceed)
///             ↘ lockedOut   (hard block — no bypass)
/// ```
enum AuthStatus {
  /// Biometrics are available and enrolled but not yet verified this session.
  unauthenticated,

  /// A biometric prompt is actively being presented to the user.
  authenticating,

  /// The user has been successfully authenticated this session.
  authenticated,

  /// The device has no biometric hardware or no biometrics are enrolled.
  /// The application proceeds without biometric protection.
  unavailable,

  /// The biometric sensor is temporarily or permanently locked due to
  /// repeated failures. The user must unlock their device to continue.
  ///
  /// **Security invariant**: This state is NEVER silently bypassed via [skip].
  lockedOut,
}

/// [AsyncNotifier] that manages biometric authentication via [local_auth].
///
/// ---
/// ### Platform setup required
/// - **Android**: Add `USE_BIOMETRIC` and `USE_FINGERPRINT` permissions to
///   `android/app/src/main/AndroidManifest.xml`.
/// - **iOS**: Add `NSFaceIDUsageDescription` to `ios/Runner/Info.plist`.
/// ---
///
/// ### Security invariants
/// - [AuthStatus.lockedOut] cannot be bypassed — [skip] is a strict no-op.
/// - All [PlatformException] error codes are handled explicitly.
/// - Authentication state is NOT persisted; it resets on every cold start.
class AuthNotifier extends AsyncNotifier<AuthStatus> {
  late final LocalAuthentication _localAuth;

  /// Checks hardware & enrollment availability on first access.
  @override
  Future<AuthStatus> build() async {
    _localAuth = LocalAuthentication();

    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return AuthStatus.unavailable;

      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return AuthStatus.unavailable;

      final available = await _localAuth.getAvailableBiometrics();
      if (available.isEmpty) return AuthStatus.unavailable;

      return AuthStatus.unauthenticated;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled ||
          e.code == auth_error.passcodeNotSet) {
        return AuthStatus.unavailable;
      }
      if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        return AuthStatus.lockedOut;
      }
      rethrow;
    }
  }

  /// Presents the native biometric/device-credential prompt.
  ///
  /// State transitions:
  /// - → [AsyncValue.loading] while the prompt is active
  /// - → [AsyncData(authenticated)] on success
  /// - → [AsyncData(unauthenticated)] if the user dismisses without verifying
  /// - → [AsyncData(lockedOut)] on hardware lockout
  /// - → [AsyncValue.error] on unexpected platform errors
  Future<void> authenticate() async {
    final currentStatus = state.valueOrNull;

    // Guard: skip if already in a terminal or in-progress state.
    if (currentStatus == AuthStatus.authenticated ||
        currentStatus == AuthStatus.unavailable ||
        currentStatus == AuthStatus.lockedOut ||
        currentStatus == AuthStatus.authenticating) {
      return;
    }

    state = const AsyncValue.loading();

    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Access your Konta financial data securely',
        options: const AuthenticationOptions(
          // Allow PIN/password as fallback so the user is never fully blocked.
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      state = AsyncValue.data(
        didAuthenticate
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
      );
    } on PlatformException catch (e, st) {
      if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        // Honour hardware lockout — never convert to authenticated.
        state = const AsyncValue.data(AuthStatus.lockedOut);
      } else {
        state = AsyncValue.error(
          e.message ?? 'Authentication failed. Please try again.',
          st,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Bypasses biometric auth for the current session.
  ///
  /// Intended for the "Skip for now" action on devices where biometrics are
  /// inconvenient in the moment. This is a **strict no-op** when the status
  /// is [AuthStatus.lockedOut] — that state can only be cleared by unlocking
  /// the device at the OS level.
  void skip() {
    if (state.valueOrNull == AuthStatus.lockedOut) return;
    state = const AsyncValue.data(AuthStatus.authenticated);
  }
}

/// Global Riverpod provider for [AuthNotifier].
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthStatus>(AuthNotifier.new);
