import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/usecases/update_account_usecase.dart';

class MockAccountRepository extends Mock implements IAccountRepository {}

class FakeAccount extends Fake implements Account {}

void main() {
  late UpdateAccountUseCase useCase;
  late MockAccountRepository mockAccountRepository;

  setUpAll(() {
    registerFallbackValue(FakeAccount());
  });

  setUp(() {
    mockAccountRepository = MockAccountRepository();
    useCase = UpdateAccountUseCase(mockAccountRepository);
  });

  group('UpdateAccountUseCase Unit Tests', () {
    final existingAccount = Account(
      id: 'acc1',
      userId: 'user1',
      name: 'Main Wallet',
      type: AccountType.cash,
      initialBalance: 100.0,
      currency: 'USD',
      color: '#000000',
      icon: 'wallet',
      isDefault: true,
      isDeleted: false,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );

    test('should successfully update allowed fields', () async {
      // Arrange
      final params = UpdateAccountParams(
        id: existingAccount.id,
        name: 'Updated Wallet',
        type: AccountType.bank,
        color: '#FFFFFF',
        icon: 'bank',
        isDefault: true,
      );

      when(
        () => mockAccountRepository.getAccountById(existingAccount.id),
      ).thenAnswer((_) async => existingAccount);
      when(() => mockAccountRepository.updateAccount(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Account,
      );

      // Act
      final result = await useCase.execute(params);

      // Assert
      expect(result.name, 'Updated Wallet');
      expect(result.type, AccountType.bank);
      expect(result.color, '#FFFFFF');
      expect(result.icon, 'bank');
      // Immutable fields must remain unchanged
      expect(result.initialBalance, existingAccount.initialBalance);
      expect(result.currency, existingAccount.currency);
      verify(
        () => mockAccountRepository.getAccountById(existingAccount.id),
      ).called(1);
      verify(() => mockAccountRepository.updateAccount(any())).called(1);
    });

    test('should throw ValidationException if account name is empty', () async {
      // Arrange
      final params = UpdateAccountParams(
        id: existingAccount.id,
        name: '   ',
        type: AccountType.bank,
        color: '#FFFFFF',
        icon: 'bank',
        isDefault: true,
      );

      // Act & Assert
      expect(
        () => useCase.execute(params),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'INVALID_NAME',
          ),
        ),
      );
      verifyNever(() => mockAccountRepository.getAccountById(any()));
      verifyNever(() => mockAccountRepository.updateAccount(any()));
    });

    test('should throw NotFoundException if account does not exist', () async {
      // Arrange
      final params = UpdateAccountParams(
        id: existingAccount.id,
        name: 'Updated Wallet',
        type: AccountType.bank,
        color: '#FFFFFF',
        icon: 'bank',
        isDefault: true,
      );

      when(
        () => mockAccountRepository.getAccountById(existingAccount.id),
      ).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => useCase.execute(params),
        throwsA(
          isA<NotFoundException>().having(
            (e) => e.code,
            'code',
            'ACCOUNT_NOT_FOUND',
          ),
        ),
      );
      verify(
        () => mockAccountRepository.getAccountById(existingAccount.id),
      ).called(1);
      verifyNever(() => mockAccountRepository.updateAccount(any()));
    });

    test(
        'should throw ValidationException with DEFAULT_ACCOUNT_REQUIRED when attempting to unset default account',
        () async {
      // Arrange
      final params = UpdateAccountParams(
        id: existingAccount.id,
        name: 'Updated Wallet',
        type: AccountType.bank,
        color: '#FFFFFF',
        icon: 'bank',
        isDefault: false,
      );

      when(
        () => mockAccountRepository.getAccountById(existingAccount.id),
      ).thenAnswer((_) async => existingAccount);

      // Act & Assert
      expect(
        () => useCase.execute(params),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'DEFAULT_ACCOUNT_REQUIRED',
          ),
        ),
      );
      verify(
        () => mockAccountRepository.getAccountById(existingAccount.id),
      ).called(1);
      verifyNever(() => mockAccountRepository.updateAccount(any()));
    });
  });
}
