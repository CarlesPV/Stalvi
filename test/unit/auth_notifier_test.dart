// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:stalvi/infrastructure/services/biometric_auth_service.dart';
import 'package:stalvi/presentation/providers/auth_notifier.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart'
    show secureStorageProvider;

import 'auth_notifier_test.mocks.dart';

// ─── Mock generation ──────────────────────────────────────────────────────────

@GenerateMocks([SecureStorageManager, BiometricAuthService])
// ─── Private helpers ──────────────────────────────────────────────────────────
String _hash(String pin) => sha256.convert(utf8.encode(pin)).toString();

/// Creates a [ProviderContainer] wired with fake storage and biometrics.
ProviderContainer _buildContainer({
  required MockSecureStorageManager storage,
  required MockBiometricAuthService biometrics,
}) {
  return ProviderContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(storage),
      biometricAuthServiceProvider.overrideWithValue(biometrics),
    ],
  );
}

/// Stubs [storage] so that a PIN exists and there is no active lockout.
void _stubNoPinLockout(
  MockSecureStorageManager storage, {
  String pinHash = '',
}) {
  when(storage.hasPin()).thenAnswer((_) async => true);
  when(storage.getLockoutTimestamp()).thenAnswer((_) async => null);
  when(storage.getPinHash()).thenAnswer((_) async => pinHash);
  when(storage.getPinLength()).thenAnswer((_) async => 4);
  when(storage.saveLockoutTimestamp(any)).thenAnswer((_) async {});
  when(storage.deleteLockoutTimestamp()).thenAnswer((_) async {});
}

/// Stubs biometrics as disabled/unavailable.
void _stubBiometricsDisabled(MockBiometricAuthService biometrics) {
  when(biometrics.isBiometricsEnabled()).thenAnswer((_) async => false);
  when(biometrics.isBiometricAvailable()).thenAnswer((_) async => false);
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSecureStorageManager mockStorage;
  late MockBiometricAuthService mockBiometrics;

  setUp(() {
    mockStorage = MockSecureStorageManager();
    mockBiometrics = MockBiometricAuthService();
    _stubBiometricsDisabled(mockBiometrics);
  });

  // ─── Build / initial state ──────────────────────────────────────────────────

  group('AuthNotifier build()', () {
    test('returns unauthenticated when PIN exists and no lockout', () async {
      _stubNoPinLockout(mockStorage, pinHash: _hash('1234'));
      final container = _buildContainer(
        storage: mockStorage,
        biometrics: mockBiometrics,
      );
      addTearDown(container.dispose);

      final status = await container.read(authNotifierProvider.future);
      expect(status, AuthStatus.unauthenticated);
    });

    test('returns setupRequired when no PIN exists', () async {
      when(mockStorage.hasPin()).thenAnswer((_) async => false);
      final container = _buildContainer(
        storage: mockStorage,
        biometrics: mockBiometrics,
      );
      addTearDown(container.dispose);

      final status = await container.read(authNotifierProvider.future);
      expect(status, AuthStatus.setupRequired);
    });

    test(
      'resumes pinLockedOut when lockout timestamp is still active',
      () async {
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        when(mockStorage.hasPin()).thenAnswer((_) async => true);
        // Lockout started 5 seconds ago → 25 seconds remaining.
        when(
          mockStorage.getLockoutTimestamp(),
        ).thenAnswer((_) async => nowMs - 5000);
        when(mockStorage.saveLockoutTimestamp(any)).thenAnswer((_) async {});
        when(mockStorage.deleteLockoutTimestamp()).thenAnswer((_) async {});

        final container = _buildContainer(
          storage: mockStorage,
          biometrics: mockBiometrics,
        );
        addTearDown(container.dispose);

        final status = await container.read(authNotifierProvider.future);
        expect(status, AuthStatus.pinLockedOut);

        final notifier = container.read(authNotifierProvider.notifier);
        expect(notifier.pinLockoutSecondsRemaining, greaterThanOrEqualTo(24));
      },
    );

    test(
      'grants 1 extra attempt when lockout expired while app was closed',
      () async {
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        when(mockStorage.hasPin()).thenAnswer((_) async => true);
        // Lockout started 35 seconds ago → already expired.
        when(
          mockStorage.getLockoutTimestamp(),
        ).thenAnswer((_) async => nowMs - 35000);
        when(mockStorage.deleteLockoutTimestamp()).thenAnswer((_) async {});

        final container = _buildContainer(
          storage: mockStorage,
          biometrics: mockBiometrics,
        );
        addTearDown(container.dispose);

        final status = await container.read(authNotifierProvider.future);
        expect(status, AuthStatus.unauthenticated);

        final notifier = container.read(authNotifierProvider.notifier);
        expect(notifier.remainingPinAttempts, 1);
      },
    );
  });

  // ─── verifyPin – correct PIN ────────────────────────────────────────────────

  group('AuthNotifier.verifyPin() — correct PIN', () {
    test('authenticates on first correct attempt', () async {
      const pin = '1234';
      _stubNoPinLockout(mockStorage, pinHash: _hash(pin));
      final container = _buildContainer(
        storage: mockStorage,
        biometrics: mockBiometrics,
      );
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.future);

      final ok =
          await container.read(authNotifierProvider.notifier).verifyPin(pin);

      expect(ok, isTrue);
      expect(
        container.read(authNotifierProvider).value,
        AuthStatus.authenticated,
      );
    });

    test(
      'resets remainingPinAttempts to 5 after successful verification',
      () async {
        const goodPin = '1234';
        const badPin = '0000';
        _stubNoPinLockout(mockStorage, pinHash: _hash(badPin));
        final container = _buildContainer(
          storage: mockStorage,
          biometrics: mockBiometrics,
        );
        addTearDown(container.dispose);

        await container.read(authNotifierProvider.future);
        final notifier = container.read(authNotifierProvider.notifier);

        // 3 wrong attempts.
        for (var i = 0; i < 3; i++) {
          await notifier.verifyPin(goodPin);
        }
        expect(notifier.remainingPinAttempts, 2);

        // Correct PIN.
        when(mockStorage.getPinHash()).thenAnswer((_) async => _hash(goodPin));
        final ok = await notifier.verifyPin(goodPin);
        expect(ok, isTrue);
        expect(notifier.remainingPinAttempts, 5);
      },
    );
  });

  // ─── verifyPin – wrong PIN ──────────────────────────────────────────────────

  group('AuthNotifier.verifyPin() — wrong PIN brute-force protection', () {
    test('decrements remainingPinAttempts on each wrong attempt', () async {
      _stubNoPinLockout(mockStorage, pinHash: _hash('correct'));
      final container = _buildContainer(
        storage: mockStorage,
        biometrics: mockBiometrics,
      );
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.future);
      final notifier = container.read(authNotifierProvider.notifier);

      expect(notifier.remainingPinAttempts, 5);

      for (var expected = 4; expected >= 1; expected--) {
        await notifier.verifyPin('wrong');
        expect(notifier.remainingPinAttempts, expected);
        expect(
          container.read(authNotifierProvider).hasError,
          isTrue,
          reason: 'should emit error state after wrong attempt',
        );
      }
    });

    test('triggers pinLockedOut after the 5th wrong attempt', () async {
      _stubNoPinLockout(mockStorage, pinHash: _hash('correct'));
      final container = _buildContainer(
        storage: mockStorage,
        biometrics: mockBiometrics,
      );
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.future);
      final notifier = container.read(authNotifierProvider.notifier);

      for (var i = 0; i < 5; i++) {
        await notifier.verifyPin('wrong');
      }

      expect(notifier.remainingPinAttempts, 0);
      expect(
        container.read(authNotifierProvider).value,
        AuthStatus.pinLockedOut,
      );
      verify(mockStorage.saveLockoutTimestamp(any)).called(1);
    });

    test(
      'pinLockoutSecondsRemaining equals 30 immediately after lockout',
      () async {
        _stubNoPinLockout(mockStorage, pinHash: _hash('correct'));
        final container = _buildContainer(
          storage: mockStorage,
          biometrics: mockBiometrics,
        );
        addTearDown(container.dispose);

        await container.read(authNotifierProvider.future);
        final notifier = container.read(authNotifierProvider.notifier);

        for (var i = 0; i < 5; i++) {
          await notifier.verifyPin('wrong');
        }

        expect(notifier.pinLockoutSecondsRemaining, kPinLockoutSeconds);
      },
    );

    test('verifyPin is a no-op when already pinLockedOut', () async {
      _stubNoPinLockout(mockStorage, pinHash: _hash('correct'));
      final container = _buildContainer(
        storage: mockStorage,
        biometrics: mockBiometrics,
      );
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.future);
      final notifier = container.read(authNotifierProvider.notifier);

      for (var i = 0; i < 5; i++) {
        await notifier.verifyPin('wrong');
      }
      expect(
        container.read(authNotifierProvider).value,
        AuthStatus.pinLockedOut,
      );

      // Further calls must not change state.
      final result = await notifier.verifyPin('1234');
      expect(result, isFalse);
      expect(
        container.read(authNotifierProvider).value,
        AuthStatus.pinLockedOut,
      );
    });
  });

  // ─── Lockout countdown & extra attempt ─────────────────────────────────────

  group('AuthNotifier lockout countdown and extra attempt logic', () {
    test(
      'transitions to unauthenticated with 1 remaining attempt after 30 s',
      () async {
        _stubNoPinLockout(mockStorage, pinHash: _hash('correct'));
        final container = _buildContainer(
          storage: mockStorage,
          biometrics: mockBiometrics,
        );
        addTearDown(container.dispose);

        await container.read(authNotifierProvider.future);
        final notifier = container.read(authNotifierProvider.notifier);

        // Trigger lockout.
        for (var i = 0; i < 5; i++) {
          await notifier.verifyPin('wrong');
        }
        expect(notifier.pinLockoutSecondsRemaining, kPinLockoutSeconds);

        // Fast-forward: set remaining to 1 so the next timer tick fires expiry.
        notifier.pinLockoutSecondsRemaining = 1;
        // Wait for the timer to tick once (~1 second).
        await Future<void>.delayed(const Duration(milliseconds: 1200));

        expect(notifier.remainingPinAttempts, 1);
        expect(
          container.read(authNotifierProvider).value,
          AuthStatus.unauthenticated,
        );
        verify(mockStorage.deleteLockoutTimestamp()).called(greaterThan(0));
      },
    );

    test(
      'wrong entry after grace attempt triggers a second 30 s lockout',
      () async {
        _stubNoPinLockout(mockStorage, pinHash: _hash('correct'));
        final container = _buildContainer(
          storage: mockStorage,
          biometrics: mockBiometrics,
        );
        addTearDown(container.dispose);

        await container.read(authNotifierProvider.future);
        final notifier = container.read(authNotifierProvider.notifier);

        // Trigger the initial 5-attempt lockout.
        for (var i = 0; i < 5; i++) {
          await notifier.verifyPin('wrong');
        }
        expect(
          container.read(authNotifierProvider).value,
          AuthStatus.pinLockedOut,
        );

        // Fast-forward the countdown so the timer fires.
        notifier.pinLockoutSecondsRemaining = 1;
        await Future<void>.delayed(const Duration(milliseconds: 1200));

        // Grace attempt granted.
        expect(notifier.remainingPinAttempts, 1);
        expect(
          container.read(authNotifierProvider).value,
          AuthStatus.unauthenticated,
        );

        // One wrong grace attempt → NOT permanent lockedOut, but a NEW 30 s cycle.
        await notifier.verifyPin('wrong');

        expect(
          container.read(authNotifierProvider).value,
          AuthStatus.pinLockedOut,
          reason:
              'A second 30 s lockout cycle should begin, not permanent lock.',
        );
        expect(notifier.pinLockoutSecondsRemaining, kPinLockoutSeconds);
      },
    );
  });

  // ─── resetStatus ───────────────────────────────────────────────────────────

  group('AuthNotifier.resetStatus()', () {
    test('transitions from error to unauthenticated', () async {
      _stubNoPinLockout(mockStorage, pinHash: _hash('correct'));
      final container = _buildContainer(
        storage: mockStorage,
        biometrics: mockBiometrics,
      );
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.future);

      await container.read(authNotifierProvider.notifier).verifyPin('bad');
      expect(container.read(authNotifierProvider).hasError, isTrue);

      container.read(authNotifierProvider.notifier).resetStatus();

      expect(
        container.read(authNotifierProvider).value,
        AuthStatus.unauthenticated,
      );
    });
  });
}
