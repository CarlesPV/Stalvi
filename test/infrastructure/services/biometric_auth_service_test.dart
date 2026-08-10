import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/infrastructure/services/biometric_auth_service.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:local_auth/local_auth.dart';

import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

class MockSecureStorageManager extends Mock implements SecureStorageManager {}

void main() {
  late BiometricAuthService biometricAuthService;
  late MockLocalAuthentication mockLocalAuth;
  late MockSecureStorageManager mockSecureStorage;

  setUpAll(() {
    registerFallbackValue(const AuthenticationOptions());
    registerFallbackValue(<AuthMessages>[]);
  });

  setUp(() {
    mockLocalAuth = MockLocalAuthentication();
    mockSecureStorage = MockSecureStorageManager();
    biometricAuthService = BiometricAuthService(
      mockLocalAuth,
      mockSecureStorage,
    );
  });

  group('isBiometricAvailable', () {
    test('returns true when biometrics are supported and enrolled', () async {
      when(
        () => mockLocalAuth.isDeviceSupported(),
      ).thenAnswer((_) async => true);
      when(
        () => mockLocalAuth.canCheckBiometrics,
      ).thenAnswer((_) async => true);
      when(
        () => mockLocalAuth.getAvailableBiometrics(),
      ).thenAnswer((_) async => [BiometricType.fingerprint]);

      final result = await biometricAuthService.isBiometricAvailable();
      expect(result, isTrue);
    });

    test('returns false when device is not supported', () async {
      when(
        () => mockLocalAuth.isDeviceSupported(),
      ).thenAnswer((_) async => false);

      final result = await biometricAuthService.isBiometricAvailable();
      expect(result, isFalse);
    });

    test('returns false when biometrics cannot be checked', () async {
      when(
        () => mockLocalAuth.isDeviceSupported(),
      ).thenAnswer((_) async => true);
      when(
        () => mockLocalAuth.canCheckBiometrics,
      ).thenAnswer((_) async => false);

      final result = await biometricAuthService.isBiometricAvailable();
      expect(result, isFalse);
    });

    test('returns false when no biometrics are enrolled', () async {
      when(
        () => mockLocalAuth.isDeviceSupported(),
      ).thenAnswer((_) async => true);
      when(
        () => mockLocalAuth.canCheckBiometrics,
      ).thenAnswer((_) async => true);
      when(
        () => mockLocalAuth.getAvailableBiometrics(),
      ).thenAnswer((_) async => []);

      final result = await biometricAuthService.isBiometricAvailable();
      expect(result, isFalse);
    });

    test('returns false on exception', () async {
      when(
        () => mockLocalAuth.isDeviceSupported(),
      ).thenThrow(Exception('Error'));

      final result = await biometricAuthService.isBiometricAvailable();
      expect(result, isFalse);
    });
  });

  group('authenticate', () {
    test('returns true when authentication succeeds', () async {
      when(
        () => mockLocalAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          authMessages: any(named: 'authMessages'),
          biometricOnly: any(named: 'biometricOnly'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenAnswer((_) async => true);

      final result = await biometricAuthService.authenticate(
        localizedReason: 'Test',
        lockedOutMessage: 'Locked out',
        authFailedMessage: 'Auth failed',
        unknownErrorMessage: 'Unknown error',
      );
      expect(result, isTrue);
    });

    test('returns false when authentication fails normally', () async {
      when(
        () => mockLocalAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          authMessages: any(named: 'authMessages'),
          biometricOnly: any(named: 'biometricOnly'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenAnswer((_) async => false);

      final result = await biometricAuthService.authenticate(
        localizedReason: 'Test',
        lockedOutMessage: 'Locked out',
        authFailedMessage: 'Auth failed',
        unknownErrorMessage: 'Unknown error',
      );
      expect(result, isFalse);
    });

    test('throws BiometricLockedOutException when locked out', () async {
      when(
        () => mockLocalAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          authMessages: any(named: 'authMessages'),
          biometricOnly: any(named: 'biometricOnly'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenThrow(PlatformException(code: 'LockedOut', message: 'Locked out'));

      expect(
        () => biometricAuthService.authenticate(
          localizedReason: 'Test',
          lockedOutMessage: 'Locked out',
          authFailedMessage: 'Auth failed',
          unknownErrorMessage: 'Unknown error',
        ),
        throwsA(isA<BiometricLockedOutException>()),
      );
    });

    test('throws BiometricException for other PlatformExceptions', () async {
      when(
        () => mockLocalAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          authMessages: any(named: 'authMessages'),
          biometricOnly: any(named: 'biometricOnly'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenThrow(PlatformException(code: 'other', message: 'Other error'));

      expect(
        () => biometricAuthService.authenticate(
          localizedReason: 'Test',
          lockedOutMessage: 'Locked out',
          authFailedMessage: 'Auth failed',
          unknownErrorMessage: 'Unknown error',
        ),
        throwsA(isA<BiometricException>()),
      );
    });

    test('throws BiometricException for general Exception', () async {
      when(
        () => mockLocalAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          authMessages: any(named: 'authMessages'),
          biometricOnly: any(named: 'biometricOnly'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenThrow(Exception('General error'));

      expect(
        () => biometricAuthService.authenticate(
          localizedReason: 'Test',
          lockedOutMessage: 'Locked out',
          authFailedMessage: 'Auth failed',
          unknownErrorMessage: 'Unknown error',
        ),
        throwsA(isA<BiometricException>()),
      );
    });
  });

  group('biometrics enabled state', () {
    test('enableBiometrics sets state to true', () async {
      when(
        () => mockSecureStorage.setBiometricsEnabled(true),
      ).thenAnswer((_) async {});
      await biometricAuthService.enableBiometrics();
      verify(() => mockSecureStorage.setBiometricsEnabled(true)).called(1);
    });

    test('disableBiometrics sets state to false', () async {
      when(
        () => mockSecureStorage.setBiometricsEnabled(false),
      ).thenAnswer((_) async {});
      await biometricAuthService.disableBiometrics();
      verify(() => mockSecureStorage.setBiometricsEnabled(false)).called(1);
    });

    test('isBiometricsEnabled returns current state', () async {
      when(
        () => mockSecureStorage.isBiometricsEnabled(),
      ).thenAnswer((_) async => true);
      final result = await biometricAuthService.isBiometricsEnabled();
      expect(result, isTrue);
    });
  });
}
