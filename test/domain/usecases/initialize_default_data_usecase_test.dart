import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:konta/domain/entities/account.dart';
import 'package:konta/domain/entities/account_type.dart';
import 'package:konta/domain/repositories/i_account_repository.dart';
import 'package:konta/domain/usecases/initialize_default_data_usecase.dart';

class MockAccountRepository extends Mock implements IAccountRepository {}

class FakeAccount extends Fake implements Account {}

void main() {
  late InitializeDefaultDataUseCase useCase;
  late MockAccountRepository mockAccountRepository;

  setUpAll(() {
    registerFallbackValue(FakeAccount());
  });

  setUp(() {
    mockAccountRepository = MockAccountRepository();
    useCase = InitializeDefaultDataUseCase(mockAccountRepository);
  });

  group('InitializeDefaultDataUseCase Unit Tests', () {
    test(
        'should create default wallet named "Mi cartera" with 0.0 balance if user has no existing accounts',
        () async {
      // Arrange
      const userId = 'user_123';
      const walletName = 'Mi cartera';
      const currency = 'EUR';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);

      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
          (invocation) async => invocation.positionalArguments[0] as Account);

      // Act
      await useCase.execute(
        userId: userId,
        walletName: walletName,
        currency: currency,
      );

      // Assert
      verify(() => mockAccountRepository.getAccountsByUserId(userId)).called(1);

      final capturedAccount =
          verify(() => mockAccountRepository.createAccount(captureAny()))
              .captured
              .first as Account;
      expect(capturedAccount.userId, userId);
      expect(capturedAccount.name, walletName);
      expect(capturedAccount.type, AccountType.cash);
      expect(capturedAccount.initialBalance, 0.0);
      expect(capturedAccount.currency, currency);
      expect(capturedAccount.color, '#4CAF50');
      expect(capturedAccount.icon, 'wallet');
      expect(capturedAccount.isDefault, true);
      expect(capturedAccount.isDeleted, false);
      expect(capturedAccount.createdAt, isA<DateTime>());
      expect(capturedAccount.modifiedAt, isA<DateTime>());

      verifyNoMoreInteractions(mockAccountRepository);
    });

    test(
        'should return early and NOT create default wallet if user already has accounts',
        () async {
      // Arrange
      const userId = 'user_123';
      const walletName = 'Mi cartera';
      const currency = 'EUR';

      final existingAccount = Account(
        id: 'acc_existing',
        userId: userId,
        name: 'Savings',
        type: AccountType.savings,
        initialBalance: 100.0,
        currency: currency,
        color: '#123456',
        icon: 'savings',
        isDefault: true,
        isDeleted: false,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[existingAccount]);

      // Act
      await useCase.execute(
        userId: userId,
        walletName: walletName,
        currency: currency,
      );

      // Assert
      verify(() => mockAccountRepository.getAccountsByUserId(userId)).called(1);
      verifyNever(() => mockAccountRepository.createAccount(any()));
      verifyNoMoreInteractions(mockAccountRepository);
    });
  });
}
