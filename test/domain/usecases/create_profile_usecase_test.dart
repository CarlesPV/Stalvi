import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/usecases/create_profile_usecase.dart';
import 'package:stalvi/domain/usecases/create_account_usecase.dart';
import 'package:stalvi/domain/usecases/initialize_default_data_usecase.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

class MockSecureStorageManager extends Mock implements SecureStorageManager {}

class MockCreateAccountUseCase extends Mock implements CreateAccountUseCase {}

class MockInitializeDefaultDataUseCase extends Mock
    implements InitializeDefaultDataUseCase {}

class FakeProfile extends Fake implements Profile {}

class FakeCreateAccountParams extends Fake implements CreateAccountParams {}

void main() {
  late CreateProfileUseCase usecase;
  late MockProfileRepository mockProfileRepository;
  late MockSecureStorageManager mockSecureStorageManager;
  late MockCreateAccountUseCase mockCreateAccountUseCase;
  late MockInitializeDefaultDataUseCase mockInitializeDefaultDataUseCase;

  setUpAll(() {
    registerFallbackValue(FakeProfile());
    registerFallbackValue(FakeCreateAccountParams());
  });

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    mockSecureStorageManager = MockSecureStorageManager();
    mockCreateAccountUseCase = MockCreateAccountUseCase();
    mockInitializeDefaultDataUseCase = MockInitializeDefaultDataUseCase();
    usecase = CreateProfileUseCase(
      mockProfileRepository,
      mockSecureStorageManager,
      mockCreateAccountUseCase,
      mockInitializeDefaultDataUseCase,
    );
  });

  const defaultParams = CreateProfileParams(
    name: 'Carles',
    username: 'carlespv',
    pin: '1234',
    defaultCurrency: 'EUR',
    locale: 'es',
    acceptedTerms: true,
  );

  String calculateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  group('CreateProfileUseCase Unit Tests', () {
    test(
      'should successfully hash PIN, save PIN and locale, create a new profile, and create default account when database is empty',
      () async {
        // Arrange
        final expectedPinHash = calculateHash('1234');
        when(
          () => mockSecureStorageManager.savePinHash(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockSecureStorageManager.setUserLocale(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockSecureStorageManager.savePinLength(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockProfileRepository.getFirstProfile(),
        ).thenAnswer((_) async => null);
        when(() => mockProfileRepository.createProfile(any())).thenAnswer(
          (invocation) async => invocation.positionalArguments[0] as Profile,
        );
        when(() => mockCreateAccountUseCase.execute(any())).thenAnswer(
          (_) async => Account(
            id: 'acc1',
            userId: 'user1',
            name: 'Main Account',
            type: AccountType.cash,
            initialBalance: 0.0,
            currency: 'EUR',
            color: '#4CAF50',
            icon: 'wallet',
            isDefault: true,
            isDeleted: false,
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
        );
        when(
          () => mockInitializeDefaultDataUseCase.execute(
            userId: any(named: 'userId'),
            locale: any(named: 'locale'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await usecase.execute(defaultParams);

        // Assert
        expect(result.name, defaultParams.name);
        expect(result.username, defaultParams.username);
        expect(result.defaultCurrency, defaultParams.defaultCurrency);
        expect(result.password, ''); // Kept empty in DB

        verify(
          () => mockSecureStorageManager.savePinHash(expectedPinHash),
        ).called(1);
        verify(() => mockSecureStorageManager.setUserLocale('es')).called(1);
        verify(() => mockSecureStorageManager.savePinLength(4)).called(1);
        verify(() => mockProfileRepository.getFirstProfile()).called(1);
        verify(() => mockProfileRepository.createProfile(any())).called(1);
        verifyNever(() => mockProfileRepository.updateProfile(any()));

        // Verify default account was created with user's chosen currency
        final capturedAccountParams = verify(
          () => mockCreateAccountUseCase.execute(captureAny()),
        ).captured.first as CreateAccountParams;
        expect(capturedAccountParams.userId, result.id);
        expect(capturedAccountParams.currency, 'EUR');
        expect(capturedAccountParams.isDefault, isTrue);

        verify(
          () => mockInitializeDefaultDataUseCase.execute(
            userId: result.id,
            locale: 'es',
          ),
        ).called(1);
      },
    );

    test(
      'should update existing profile (retaining its ID) when profile already exists in database',
      () async {
        // Arrange
        final existingProfile = Profile(
          id: 'existing_user_uuid',
          name: 'Anonymous',
          username: 'anonymous',
          password: '',
          defaultCurrency: 'EUR',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          modifiedAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        final expectedPinHash = calculateHash('1234');
        when(
          () => mockSecureStorageManager.savePinHash(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockSecureStorageManager.setUserLocale(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockSecureStorageManager.savePinLength(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockProfileRepository.getFirstProfile(),
        ).thenAnswer((_) async => existingProfile);
        when(() => mockProfileRepository.updateProfile(any())).thenAnswer(
          (invocation) async => invocation.positionalArguments[0] as Profile,
        );
        when(() => mockCreateAccountUseCase.execute(any())).thenAnswer(
          (_) async => Account(
            id: 'acc1',
            userId: existingProfile.id,
            name: 'Main Account',
            type: AccountType.cash,
            initialBalance: 0.0,
            currency: 'EUR',
            color: '#4CAF50',
            icon: 'wallet',
            isDefault: true,
            isDeleted: false,
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
        );
        when(
          () => mockInitializeDefaultDataUseCase.execute(
            userId: any(named: 'userId'),
            locale: any(named: 'locale'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await usecase.execute(defaultParams);

        // Assert
        expect(
          result.id,
          existingProfile.id,
        ); // Must retain the same ID to protect references
        expect(result.name, defaultParams.name);
        expect(result.username, defaultParams.username);
        expect(result.defaultCurrency, defaultParams.defaultCurrency);

        verify(
          () => mockSecureStorageManager.savePinHash(expectedPinHash),
        ).called(1);
        verify(() => mockSecureStorageManager.setUserLocale('es')).called(1);
        verify(() => mockSecureStorageManager.savePinLength(4)).called(1);
        verify(() => mockProfileRepository.getFirstProfile()).called(1);
        verify(() => mockProfileRepository.updateProfile(any())).called(1);
        verifyNever(() => mockProfileRepository.createProfile(any()));

        verify(() => mockCreateAccountUseCase.execute(any())).called(1);
      },
    );

    test(
      'should throw ValidationException when acceptedTerms is false',
      () async {
        // Arrange
        const params = CreateProfileParams(
          name: 'Carles',
          username: 'carlespv',
          pin: '1234',
          defaultCurrency: 'EUR',
          locale: 'es',
          acceptedTerms: false,
        );

        // Act & Assert
        expect(
          () => usecase.execute(params),
          throwsA(
            isA<ValidationException>().having(
              (e) => e.message,
              'message',
              contains('You must accept the Terms & Conditions to proceed.'),
            ),
          ),
        );
        verifyZeroInteractions(mockSecureStorageManager);
        verifyZeroInteractions(mockProfileRepository);
      },
    );

    test(
      'should throw ValidationException when PIN is too short (< 4 digits)',
      () async {
        // Arrange
        const params = CreateProfileParams(
          name: 'Carles',
          username: 'carlespv',
          pin: '123',
          defaultCurrency: 'EUR',
          locale: 'es',
          acceptedTerms: true,
        );

        // Act & Assert
        expect(
          () => usecase.execute(params),
          throwsA(
            isA<ValidationException>().having(
              (e) => e.message,
              'message',
              contains('PIN must be between 4 and 8 digits'),
            ),
          ),
        );
        verifyZeroInteractions(mockSecureStorageManager);
        verifyZeroInteractions(mockProfileRepository);
      },
    );

    test(
      'should throw ValidationException when PIN is too long (> 8 digits)',
      () async {
        // Arrange
        const params = CreateProfileParams(
          name: 'Carles',
          username: 'carlespv',
          pin: '123456789',
          defaultCurrency: 'EUR',
          locale: 'es',
          acceptedTerms: true,
        );

        // Act & Assert
        expect(
          () => usecase.execute(params),
          throwsA(
            isA<ValidationException>().having(
              (e) => e.message,
              'message',
              contains('PIN must be between 4 and 8 digits'),
            ),
          ),
        );
        verifyZeroInteractions(mockSecureStorageManager);
        verifyZeroInteractions(mockProfileRepository);
      },
    );

    test(
      'should throw ValidationException when PIN contains non-numeric characters',
      () async {
        // Arrange
        const params = CreateProfileParams(
          name: 'Carles',
          username: 'carlespv',
          pin: '12a4',
          defaultCurrency: 'EUR',
          locale: 'es',
          acceptedTerms: true,
        );

        // Act & Assert
        expect(
          () => usecase.execute(params),
          throwsA(
            isA<ValidationException>().having(
              (e) => e.message,
              'message',
              contains('PIN must contain only numeric digits'),
            ),
          ),
        );
        verifyZeroInteractions(mockSecureStorageManager);
        verifyZeroInteractions(mockProfileRepository);
      },
    );

    test('should throw ValidationException when Name is empty', () async {
      // Arrange
      const params = CreateProfileParams(
        name: '   ',
        username: 'carlespv',
        pin: '1234',
        defaultCurrency: 'EUR',
        locale: 'es',
        acceptedTerms: true,
      );

      // Act & Assert
      expect(
        () => usecase.execute(params),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Name cannot be empty'),
          ),
        ),
      );
      verifyZeroInteractions(mockSecureStorageManager);
      verifyZeroInteractions(mockProfileRepository);
    });

    test(
      'should throw ValidationException when Name exceeds 25 characters',
      () async {
        // Arrange
        const params = CreateProfileParams(
          name: 'ThisIsAVeryLongNameThatExceeds25Chars',
          username: 'carlespv',
          pin: '1234',
          defaultCurrency: 'EUR',
          locale: 'es',
          acceptedTerms: true,
        );

        // Act & Assert
        expect(
          () => usecase.execute(params),
          throwsA(
            isA<ValidationException>().having(
              (e) => e.message,
              'message',
              contains('Name cannot exceed 25 characters'),
            ),
          ),
        );
        verifyZeroInteractions(mockSecureStorageManager);
        verifyZeroInteractions(mockProfileRepository);
      },
    );

    test(
      'should throw ValidationException when Name contains emojis',
      () async {
        // Arrange
        const params = CreateProfileParams(
          name: 'Carles 😀',
          username: 'carlespv',
          pin: '1234',
          defaultCurrency: 'EUR',
          locale: 'es',
          acceptedTerms: true,
        );

        // Act & Assert
        expect(
          () => usecase.execute(params),
          throwsA(
            isA<ValidationException>().having(
              (e) => e.message,
              'message',
              contains('Name cannot contain emojis'),
            ),
          ),
        );
        verifyZeroInteractions(mockSecureStorageManager);
        verifyZeroInteractions(mockProfileRepository);
      },
    );

    test('should throw ValidationException when Username is empty', () async {
      // Arrange
      const params = CreateProfileParams(
        name: 'Carles',
        username: '',
        pin: '1234',
        defaultCurrency: 'EUR',
        locale: 'es',
        acceptedTerms: true,
      );

      // Act & Assert
      expect(
        () => usecase.execute(params),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Username cannot be empty'),
          ),
        ),
      );
      verifyZeroInteractions(mockSecureStorageManager);
      verifyZeroInteractions(mockProfileRepository);
    });

    test(
      'should throw ValidationException when Username exceeds 25 characters',
      () async {
        // Arrange
        const params = CreateProfileParams(
          name: 'Carles',
          username: 'ThisIsAVeryLongUsernameThatExceeds25Chars',
          pin: '1234',
          defaultCurrency: 'EUR',
          locale: 'es',
          acceptedTerms: true,
        );

        // Act & Assert
        expect(
          () => usecase.execute(params),
          throwsA(
            isA<ValidationException>().having(
              (e) => e.message,
              'message',
              contains('Username cannot exceed 25 characters'),
            ),
          ),
        );
        verifyZeroInteractions(mockSecureStorageManager);
        verifyZeroInteractions(mockProfileRepository);
      },
    );

    test(
      'should throw ValidationException when Username contains emojis',
      () async {
        // Arrange
        const params = CreateProfileParams(
          name: 'Carles',
          username: 'carlespv🚀',
          pin: '1234',
          defaultCurrency: 'EUR',
          locale: 'es',
          acceptedTerms: true,
        );

        // Act & Assert
        expect(
          () => usecase.execute(params),
          throwsA(
            isA<ValidationException>().having(
              (e) => e.message,
              'message',
              contains('Username cannot contain emojis'),
            ),
          ),
        );
        verifyZeroInteractions(mockSecureStorageManager);
        verifyZeroInteractions(mockProfileRepository);
      },
    );
  });
}
