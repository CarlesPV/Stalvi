import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/core/security/secure_storage_manager.dart';
import 'package:konta/domain/entities/profile.dart';
import 'package:konta/domain/repositories/i_profile_repository.dart';
import 'package:konta/domain/usecases/create_profile_usecase.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

class MockSecureStorageManager extends Mock implements SecureStorageManager {}

class FakeProfile extends Fake implements Profile {}

void main() {
  late CreateProfileUseCase usecase;
  late MockProfileRepository mockProfileRepository;
  late MockSecureStorageManager mockSecureStorageManager;

  setUpAll(() {
    registerFallbackValue(FakeProfile());
  });

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    mockSecureStorageManager = MockSecureStorageManager();
    usecase =
        CreateProfileUseCase(mockProfileRepository, mockSecureStorageManager);
  });

  const defaultParams = CreateProfileParams(
    name: 'Carles',
    username: 'carlespv',
    pin: '1234',
    defaultCurrency: 'EUR',
  );

  String calculateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  group('CreateProfileUseCase Unit Tests', () {
    test(
        'should successfully hash PIN, save it, and create a new profile when database is empty',
        () async {
      // Arrange
      final expectedPinHash = calculateHash('1234');
      when(() => mockSecureStorageManager.savePinHash(any()))
          .thenAnswer((_) async {});
      when(() => mockProfileRepository.getFirstProfile())
          .thenAnswer((_) async => null);
      when(() => mockProfileRepository.createProfile(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Profile,
      );

      // Act
      final result = await usecase.execute(defaultParams);

      // Assert
      expect(result.name, defaultParams.name);
      expect(result.username, defaultParams.username);
      expect(result.defaultCurrency, defaultParams.defaultCurrency);
      expect(result.password, ''); // Kept empty in DB

      verify(() => mockSecureStorageManager.savePinHash(expectedPinHash))
          .called(1);
      verify(() => mockProfileRepository.getFirstProfile()).called(1);
      verify(() => mockProfileRepository.createProfile(any())).called(1);
      verifyNever(() => mockProfileRepository.updateProfile(any()));
    });

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
      when(() => mockSecureStorageManager.savePinHash(any()))
          .thenAnswer((_) async {});
      when(() => mockProfileRepository.getFirstProfile())
          .thenAnswer((_) async => existingProfile);
      when(() => mockProfileRepository.updateProfile(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Profile,
      );

      // Act
      final result = await usecase.execute(defaultParams);

      // Assert
      expect(result.id,
          existingProfile.id); // Must retain the same ID to protect references
      expect(result.name, defaultParams.name);
      expect(result.username, defaultParams.username);
      expect(result.defaultCurrency, defaultParams.defaultCurrency);

      verify(() => mockSecureStorageManager.savePinHash(expectedPinHash))
          .called(1);
      verify(() => mockProfileRepository.getFirstProfile()).called(1);
      verify(() => mockProfileRepository.updateProfile(any())).called(1);
      verifyNever(() => mockProfileRepository.createProfile(any()));
    });

    test('should throw ValidationException when PIN is too short (< 4 digits)',
        () async {
      // Arrange
      final params = CreateProfileParams(
        name: 'Carles',
        username: 'carlespv',
        pin: '123',
        defaultCurrency: 'EUR',
      );

      // Act & Assert
      expect(
        () => usecase.execute(params),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('PIN must be between 4 and 8 digits'),
        )),
      );
      verifyZeroInteractions(mockSecureStorageManager);
      verifyZeroInteractions(mockProfileRepository);
    });

    test('should throw ValidationException when PIN is too long (> 8 digits)',
        () async {
      // Arrange
      final params = CreateProfileParams(
        name: 'Carles',
        username: 'carlespv',
        pin: '123456789',
        defaultCurrency: 'EUR',
      );

      // Act & Assert
      expect(
        () => usecase.execute(params),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('PIN must be between 4 and 8 digits'),
        )),
      );
      verifyZeroInteractions(mockSecureStorageManager);
      verifyZeroInteractions(mockProfileRepository);
    });

    test(
        'should throw ValidationException when PIN contains non-numeric characters',
        () async {
      // Arrange
      final params = CreateProfileParams(
        name: 'Carles',
        username: 'carlespv',
        pin: '12a4',
        defaultCurrency: 'EUR',
      );

      // Act & Assert
      expect(
        () => usecase.execute(params),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('PIN must contain only numeric digits'),
        )),
      );
      verifyZeroInteractions(mockSecureStorageManager);
      verifyZeroInteractions(mockProfileRepository);
    });

    test('should throw ValidationException when Name is empty', () async {
      // Arrange
      final params = CreateProfileParams(
        name: '   ',
        username: 'carlespv',
        pin: '1234',
        defaultCurrency: 'EUR',
      );

      // Act & Assert
      expect(
        () => usecase.execute(params),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('Name cannot be empty'),
        )),
      );
      verifyZeroInteractions(mockSecureStorageManager);
      verifyZeroInteractions(mockProfileRepository);
    });

    test('should throw ValidationException when Username is empty', () async {
      // Arrange
      final params = CreateProfileParams(
        name: 'Carles',
        username: '',
        pin: '1234',
        defaultCurrency: 'EUR',
      );

      // Act & Assert
      expect(
        () => usecase.execute(params),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('Username cannot be empty'),
        )),
      );
      verifyZeroInteractions(mockSecureStorageManager);
      verifyZeroInteractions(mockProfileRepository);
    });
  });
}
