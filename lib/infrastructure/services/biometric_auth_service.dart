import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';

class BiometricAuthService {
  BiometricAuthService(this._localAuth, this._secureStorage);

  final LocalAuthentication _localAuth;
  final SecureStorageManager _secureStorage;

  Future<bool> isBiometricAvailable() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;

      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;

      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({
    required String localizedReason,
    required String lockedOutMessage,
    required String authFailedMessage,
    required String unknownErrorMessage,
    String? signInTitle,
    String? cancelButton,
    String? signInHint,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: signInTitle,
            cancelButton: cancelButton,
            signInHint: signInHint ?? '',
          ),
          IOSAuthMessages(cancelButton: cancelButton),
        ],
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (e) {
      if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        throw BiometricLockedOutException(lockedOutMessage);
      }
      throw BiometricException(authFailedMessage, e);
    } catch (e) {
      throw BiometricException(unknownErrorMessage, e);
    }
  }

  Future<void> enableBiometrics() async {
    await _secureStorage.setBiometricsEnabled(true);
  }

  Future<void> disableBiometrics() async {
    await _secureStorage.setBiometricsEnabled(false);
  }

  Future<bool> isBiometricsEnabled() async {
    return _secureStorage.isBiometricsEnabled();
  }
}

class BiometricLockedOutException implements Exception {
  BiometricLockedOutException(this.message);
  final String message;
  @override
  String toString() => 'BiometricLockedOutException: $message';
}

class BiometricException implements Exception {
  BiometricException(this.message, [this.cause]);
  final String message;
  final Object? cause;
  @override
  String toString() => 'BiometricException: $message ($cause)';
}

final localAuthProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  final localAuth = ref.watch(localAuthProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return BiometricAuthService(localAuth, secureStorage);
});
