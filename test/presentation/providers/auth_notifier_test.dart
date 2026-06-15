import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:konta/core/security/secure_storage_manager.dart';
import 'package:konta/infrastructure/services/biometric_auth_service.dart';
import 'package:konta/domain/entities/profile.dart';
import 'package:konta/domain/usecases/create_profile_usecase.dart';
import 'package:konta/domain/usecases/initialize_default_data_usecase.dart';
import 'package:konta/presentation/providers/auth_notifier.dart';
import 'package:konta/presentation/providers/locale_provider.dart';
import 'package:konta/presentation/providers/repository_providers.dart';

class MockSecureStorageManager extends Mock implements SecureStorageManager {}

class MockCreateProfileUseCase extends Mock implements CreateProfileUseCase {}

class MockInitializeDefaultDataUseCase extends Mock
    implements InitializeDefaultDataUseCase {}

class MockBiometricAuthService extends Mock implements BiometricAuthService {}

class FakeCreateProfileParams extends Fake implements CreateProfileParams {}

void main() {
  late MockSecureStorageManager mockSecureStorage;
  late MockCreateProfileUseCase mockCreateProfileUseCase;
  late MockInitializeDefaultDataUseCase mockInitializeDefaultDataUseCase;
  late MockBiometricAuthService mockBiometricAuth;

  setUpAll(() {
    registerFallbackValue(FakeCreateProfileParams());
  });

  setUp(() {
    mockSecureStorage = MockSecureStorageManager();
    mockCreateProfileUseCase = MockCreateProfileUseCase();
    mockInitializeDefaultDataUseCase = MockInitializeDefaultDataUseCase();
    mockBiometricAuth = MockBiometricAuthService();

    // Default stubbing
    when(() => mockBiometricAuth.isBiometricAvailable())
        .thenAnswer((_) async => false);
    when(() => mockBiometricAuth.isBiometricsEnabled())
        .thenAnswer((_) async => false);
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(mockSecureStorage),
        createProfileUseCaseProvider
            .overrideWithValue(mockCreateProfileUseCase),
        initializeDefaultDataUseCaseProvider
            .overrideWithValue(mockInitializeDefaultDataUseCase),
        biometricAuthServiceProvider.overrideWithValue(mockBiometricAuth),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  String calculateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  group('AuthNotifier Unit Tests', () {
    test(
        'initializes to setupRequired if no PIN is registered in secure storage',
        () async {
      // Arrange
      when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => false);

      final container = createContainer();

      // Initially it should be loading
      expect(
        container.read(authNotifierProvider),
        const AsyncValue<AuthStatus>.loading(),
      );

      // Wait for build() to complete
      await container.read(authNotifierProvider.future);

      // Assert state matches setupRequired
      final state = container.read(authNotifierProvider);
      expect(state.value, equals(AuthStatus.setupRequired));
    });

    test(
        'initializes to unauthenticated if a PIN is registered in secure storage',
        () async {
      // Arrange
      when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => true);

      final container = createContainer();

      await container.read(authNotifierProvider.future);

      // Assert state matches unauthenticated
      final state = container.read(authNotifierProvider);
      expect(state.value, equals(AuthStatus.unauthenticated));
    });

    group('setupProfile Validations', () {
      test('sets error state if PIN is less than 4 digits', () async {
        when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => false);

        final container = createContainer();
        await container.read(authNotifierProvider.future);

        await container.read(authNotifierProvider.notifier).setupProfile(
              name: 'Carles',
              username: 'carlespv',
              pin: '123',
              confirmPin: '123',
              acceptTerms: true,
              defaultCurrency: 'EUR',
            );

        final state = container.read(authNotifierProvider);
        expect(state.hasError, true);
        expect(
          state.error.toString(),
          contains('PIN must be between 4 and 8 digits'),
        );
      });

      test('sets error state if PIN is more than 8 digits', () async {
        when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => false);

        final container = createContainer();
        await container.read(authNotifierProvider.future);

        await container.read(authNotifierProvider.notifier).setupProfile(
              name: 'Carles',
              username: 'carlespv',
              pin: '123456789',
              confirmPin: '123456789',
              acceptTerms: true,
              defaultCurrency: 'EUR',
            );

        final state = container.read(authNotifierProvider);
        expect(state.hasError, true);
        expect(
          state.error.toString(),
          contains('PIN must be between 4 and 8 digits'),
        );
      });

      test('sets error state if PIN contains non-numeric characters', () async {
        when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => false);

        final container = createContainer();
        await container.read(authNotifierProvider.future);

        await container.read(authNotifierProvider.notifier).setupProfile(
              name: 'Carles',
              username: 'carlespv',
              pin: '12a4',
              confirmPin: '12a4',
              acceptTerms: true,
              defaultCurrency: 'EUR',
            );

        final state = container.read(authNotifierProvider);
        expect(state.hasError, true);
        expect(
          state.error.toString(),
          contains('PIN must contain only numeric digits'),
        );
      });

      test('sets error state if PINs do not match', () async {
        when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => false);

        final container = createContainer();
        await container.read(authNotifierProvider.future);

        await container.read(authNotifierProvider.notifier).setupProfile(
              name: 'Carles',
              username: 'carlespv',
              pin: '1234',
              confirmPin: '1235',
              acceptTerms: true,
              defaultCurrency: 'EUR',
            );

        final state = container.read(authNotifierProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('PINs do not match'));
      });

      test('sets error state if Terms & Conditions are not accepted', () async {
        when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => false);

        final container = createContainer();
        await container.read(authNotifierProvider.future);

        await container.read(authNotifierProvider.notifier).setupProfile(
              name: 'Carles',
              username: 'carlespv',
              pin: '1234',
              confirmPin: '1234',
              acceptTerms: false,
              defaultCurrency: 'EUR',
            );

        final state = container.read(authNotifierProvider);
        expect(state.hasError, true);
        expect(
          state.error.toString(),
          contains('accept the Terms & Conditions'),
        );
      });

      test('sets error state if Name is empty', () async {
        when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => false);

        final container = createContainer();
        await container.read(authNotifierProvider.future);

        await container.read(authNotifierProvider.notifier).setupProfile(
              name: '   ',
              username: 'carlespv',
              pin: '1234',
              confirmPin: '1234',
              acceptTerms: true,
              defaultCurrency: 'EUR',
            );

        final state = container.read(authNotifierProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('enter a name'));
      });

      test('sets error state if Username is empty', () async {
        when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => false);

        final container = createContainer();
        await container.read(authNotifierProvider.future);

        await container.read(authNotifierProvider.notifier).setupProfile(
              name: 'Carles',
              username: '',
              pin: '1234',
              confirmPin: '1234',
              acceptTerms: true,
              defaultCurrency: 'EUR',
            );

        final state = container.read(authNotifierProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('enter a username'));
      });
    });

    test(
        'setupProfile successfully executes usecase and transitions to authenticated state',
        () async {
      // Arrange
      when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => false);
      when(() => mockCreateProfileUseCase.execute(any())).thenAnswer(
        (_) async => Profile(
          id: 'uuid',
          name: 'Carles',
          username: 'carlespv',
          password: '',
          defaultCurrency: 'EUR',
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        ),
      );
      when(
        () => mockInitializeDefaultDataUseCase.execute(
          userId: any(named: 'userId'),
          currency: any(named: 'currency'),
          locale: any(named: 'locale'),
        ),
      ).thenAnswer((_) async => {});

      final container = createContainer();
      await container.read(authNotifierProvider.future);

      // Act
      await container.read(authNotifierProvider.notifier).setupProfile(
            name: 'Carles',
            username: 'carlespv',
            pin: '1234',
            confirmPin: '1234',
            acceptTerms: true,
            defaultCurrency: 'EUR',
          );

      // Assert
      final state = container.read(authNotifierProvider);
      expect(state.value, equals(AuthStatus.authenticated));
      verify(() => mockCreateProfileUseCase.execute(any())).called(1);
      verify(
        () => mockInitializeDefaultDataUseCase.execute(
          userId: 'uuid',
          currency: 'EUR',
          locale: any(named: 'locale'),
        ),
      ).called(1);
    });

    group('verifyPin Login Tests', () {
      test(
          'verifyPin with correct PIN sets state to authenticated and returns true',
          () async {
        // Arrange
        const pin = '1234';
        final pinHash = calculateHash(pin);
        when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => true);
        when(() => mockSecureStorage.getPinHash())
            .thenAnswer((_) async => pinHash);

        final container = createContainer();
        await container.read(authNotifierProvider.future);

        // Act
        final result =
            await container.read(authNotifierProvider.notifier).verifyPin(pin);

        // Assert
        expect(result, true);
        final state = container.read(authNotifierProvider);
        expect(state.value, equals(AuthStatus.authenticated));
      });

      test('verifyPin with incorrect PIN sets error state and returns false',
          () async {
        // Arrange
        const correctPin = '1234';
        final correctPinHash = calculateHash(correctPin);
        when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => true);
        when(() => mockSecureStorage.getPinHash())
            .thenAnswer((_) async => correctPinHash);

        final container = createContainer();
        await container.read(authNotifierProvider.future);

        // Act
        final result = await container
            .read(authNotifierProvider.notifier)
            .verifyPin('1111');

        // Assert
        expect(result, false);
        final state = container.read(authNotifierProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('Incorrect PIN'));
      });
    });

    group('Biometric Flow Tests', () {
      test(
          'setupProfile transitions to authenticated even when biometrics are available',
          () async {
        // Arrange
        when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => false);
        when(() => mockBiometricAuth.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(() => mockCreateProfileUseCase.execute(any())).thenAnswer(
          (_) async => Profile(
            id: 'uuid',
            name: 'Carles',
            username: 'carlespv',
            password: '',
            defaultCurrency: 'EUR',
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
        );
        when(
          () => mockInitializeDefaultDataUseCase.execute(
            userId: any(named: 'userId'),
            currency: any(named: 'currency'),
            locale: any(named: 'locale'),
          ),
        ).thenAnswer((_) async => {});

        final container = createContainer();
        await container.read(authNotifierProvider.future);

        // Act
        await container.read(authNotifierProvider.notifier).setupProfile(
              name: 'Carles',
              username: 'carlespv',
              pin: '1234',
              confirmPin: '1234',
              acceptTerms: true,
              defaultCurrency: 'EUR',
            );

        // Assert
        final state = container.read(authNotifierProvider);
        expect(state.value, equals(AuthStatus.authenticated));
      });

      test(
          'enableBiometricsOptIn calls promptBiometricSetup and transitions to authenticated on success',
          () async {
        // Arrange
        when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => true);
        when(() => mockBiometricAuth.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(
          () => mockBiometricAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
          ),
        ).thenAnswer((_) async => true);
        when(() => mockBiometricAuth.enableBiometrics())
            .thenAnswer((_) async => {});

        final container = createContainer();
        await container.read(authNotifierProvider.future);

        // Act
        await container
            .read(authNotifierProvider.notifier)
            .enableBiometricsOptIn();

        // Assert
        final state = container.read(authNotifierProvider);
        expect(state.value, equals(AuthStatus.authenticated));
        verify(() => mockBiometricAuth.enableBiometrics()).called(1);
      });

      test(
          'skipBiometricOptIn disables biometrics and transitions to authenticated',
          () async {
        // Arrange
        when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => true);
        when(() => mockBiometricAuth.disableBiometrics())
            .thenAnswer((_) async => {});

        final container = createContainer();
        await container.read(authNotifierProvider.future);

        // Act
        await container
            .read(authNotifierProvider.notifier)
            .skipBiometricOptIn();

        // Assert
        final state = container.read(authNotifierProvider);
        expect(state.value, equals(AuthStatus.authenticated));
        verify(() => mockBiometricAuth.disableBiometrics()).called(1);
      });

      test(
          'build initializes to authenticating and triggers authentication on startup if biometrics enabled and available',
          () async {
        // Arrange
        when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => true);
        when(() => mockBiometricAuth.isBiometricsEnabled())
            .thenAnswer((_) async => true);
        when(() => mockBiometricAuth.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(
          () => mockBiometricAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
          ),
        ).thenAnswer((_) async => true);

        final container = createContainer();

        // Act & Assert (initial state returned by build is authenticating)
        final future = container.read(authNotifierProvider.future);
        final initialStatus = await future;
        expect(initialStatus, equals(AuthStatus.authenticating));

        // Let the microtask execute to run _authenticateOnStartup
        await pumpEventQueue();

        final finalState = container.read(authNotifierProvider);
        expect(finalState.value, equals(AuthStatus.authenticated));
      });
    });
  });
}
