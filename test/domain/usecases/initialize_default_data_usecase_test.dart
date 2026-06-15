import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:konta/domain/entities/account.dart';
import 'package:konta/domain/entities/account_type.dart';
import 'package:konta/domain/repositories/i_account_repository.dart';
import 'package:konta/domain/usecases/initialize_default_data_usecase.dart';

import 'package:konta/domain/entities/category.dart';
import 'package:konta/domain/repositories/i_category_repository.dart';

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockCategoryRepository extends Mock implements ICategoryRepository {}

class FakeAccount extends Fake implements Account {}

class FakeCategory extends Fake implements Category {}

void main() {
  late InitializeDefaultDataUseCase useCase;
  late MockAccountRepository mockAccountRepository;
  late MockCategoryRepository mockCategoryRepository;

  setUpAll(() {
    registerFallbackValue(FakeAccount());
    registerFallbackValue(FakeCategory());
  });

  setUp(() {
    mockAccountRepository = MockAccountRepository();
    mockCategoryRepository = MockCategoryRepository();
    useCase = InitializeDefaultDataUseCase(
        mockAccountRepository, mockCategoryRepository);

    // Default stubbing for category calls to make existing tests pass without modification
    when(() => mockCategoryRepository.getAllCategories())
        .thenAnswer((_) async => <Category>[]);
    when(() => mockCategoryRepository.createCategory(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Category);
    when(() => mockCategoryRepository.updateCategory(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Category);
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

    test(
        'should resolve localized wallet name to "My Wallet" when locale is "en"',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'USD';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
          (invocation) async => invocation.positionalArguments[0] as Account);

      // Act
      await useCase.execute(
        userId: userId,
        currency: currency,
        locale: 'en',
      );

      // Assert
      final capturedAccount =
          verify(() => mockAccountRepository.createAccount(captureAny()))
              .captured
              .first as Account;
      expect(capturedAccount.name, 'My Wallet');
    });

    test(
        'should resolve localized wallet name to "La meva cartera" when locale is "ca"',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'EUR';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
          (invocation) async => invocation.positionalArguments[0] as Account);

      // Act
      await useCase.execute(
        userId: userId,
        currency: currency,
        locale: 'ca',
      );

      // Assert
      final capturedAccount =
          verify(() => mockAccountRepository.createAccount(captureAny()))
              .captured
              .first as Account;
      expect(capturedAccount.name, 'La meva cartera');
    });

    test(
        'should resolve localized wallet name to "Mi cartera" when locale is "es"',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'EUR';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
          (invocation) async => invocation.positionalArguments[0] as Account);

      // Act
      await useCase.execute(
        userId: userId,
        currency: currency,
        locale: 'es',
      );

      // Assert
      final capturedAccount =
          verify(() => mockAccountRepository.createAccount(captureAny()))
              .captured
              .first as Account;
      expect(capturedAccount.name, 'Mi cartera');
    });

    test('should fallback to default "Mi cartera" when locale is unsupported',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'EUR';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
          (invocation) async => invocation.positionalArguments[0] as Account);

      // Act
      await useCase.execute(
        userId: userId,
        currency: currency,
        locale:
            'fr', // French is not supported, should trigger exception fallback
      );

      // Assert
      final capturedAccount =
          verify(() => mockAccountRepository.createAccount(captureAny()))
              .captured
              .first as Account;
      expect(capturedAccount.name, 'Mi cartera');
    });

    test(
        'should fallback to default "Mi cartera" when locale is null and walletName is null',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'EUR';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
          (invocation) async => invocation.positionalArguments[0] as Account);

      // Act
      await useCase.execute(
        userId: userId,
        currency: currency,
      );

      // Assert
      final capturedAccount =
          verify(() => mockAccountRepository.createAccount(captureAny()))
              .captured
              .first as Account;
      expect(capturedAccount.name, 'Mi cartera');
    });
  });
}
