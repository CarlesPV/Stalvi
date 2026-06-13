import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:konta/domain/usecases/create_account_usecase.dart';
import 'package:konta/domain/repositories/i_account_repository.dart';
import 'package:konta/domain/entities/account.dart';
import 'package:konta/domain/entities/account_type.dart';
import 'package:konta/core/errors/app_exceptions.dart';

class MockAccountRepository extends Mock implements IAccountRepository {}

class FakeAccount extends Fake implements Account {}

void main() {
  late CreateAccountUseCase usecase;
  late MockAccountRepository mockAccountRepository;

  setUpAll(() {
    registerFallbackValue(FakeAccount());
  });

  setUp(() {
    mockAccountRepository = MockAccountRepository();
    usecase = CreateAccountUseCase(mockAccountRepository);
  });

  const defaultParams = CreateAccountParams(
    id: 'test_id',
    userId: 'user_1',
    name: 'Main Savings',
    type: AccountType.savings,
    initialBalance: 1000.0,
    currency: 'USD',
    color: '#00FF00',
    icon: 'savings_icon',
  );

  group('CreateAccountUseCase', () {
    test('should successfully create an account when all parameters are valid',
        () async {
      // Arrange
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
          (invocation) async => invocation.positionalArguments[0] as Account,);

      // Act
      final result = await usecase.execute(defaultParams);

      // Assert
      expect(result.id, defaultParams.id);
      expect(result.userId, defaultParams.userId);
      expect(result.name, defaultParams.name);
      expect(result.initialBalance, defaultParams.initialBalance);
      verify(() => mockAccountRepository.createAccount(any())).called(1);
      verifyNoMoreInteractions(mockAccountRepository);
    });

    test('should throw ValidationException when initial_balance is null',
        () async {
      // Arrange
      const invalidParams = CreateAccountParams(
        id: 'test_id',
        userId: 'user_1',
        name: 'Main Savings',
        type: AccountType.savings,
        initialBalance: null, // Null balance should trigger exception
        currency: 'USD',
        color: '#00FF00',
        icon: 'savings_icon',
      );

      // Act
      final call = usecase.execute(invalidParams);

      // Assert
      await expectLater(
        () => call,
        throwsA(isA<ValidationException>()),
      );
      verifyZeroInteractions(mockAccountRepository);
    });

    test('should set isDeleted to false and createdAt/modifiedAt properly',
        () async {
      // Arrange
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
          (invocation) async => invocation.positionalArguments[0] as Account,);

      // Act
      final result = await usecase.execute(defaultParams);

      // Assert
      expect(result.isDeleted, false);
      expect(result.createdAt, isA<DateTime>());
      expect(result.modifiedAt, isA<DateTime>());
    });
  });
}
