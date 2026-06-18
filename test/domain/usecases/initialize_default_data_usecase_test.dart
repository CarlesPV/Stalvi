import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/usecases/initialize_default_data_usecase.dart';

import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/category_type.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/entities/tag.dart';
import 'package:stalvi/domain/repositories/i_tag_repository.dart';

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockCategoryRepository extends Mock implements ICategoryRepository {}

class MockTagRepository extends Mock implements ITagRepository {}

class FakeAccount extends Fake implements Account {}

class FakeCategory extends Fake implements Category {}

class FakeTag extends Fake implements Tag {}

void main() {
  late InitializeDefaultDataUseCase useCase;
  late MockAccountRepository mockAccountRepository;
  late MockCategoryRepository mockCategoryRepository;
  late MockTagRepository mockTagRepository;

  setUpAll(() {
    registerFallbackValue(FakeAccount());
    registerFallbackValue(FakeCategory());
    registerFallbackValue(FakeTag());
  });

  setUp(() {
    mockAccountRepository = MockAccountRepository();
    mockCategoryRepository = MockCategoryRepository();
    mockTagRepository = MockTagRepository();
    useCase = InitializeDefaultDataUseCase(
      mockAccountRepository,
      mockCategoryRepository,
      mockTagRepository,
    );

    // Default stubbing for category calls to make existing tests pass without modification
    when(() => mockCategoryRepository.getAllCategories())
        .thenAnswer((_) async => <Category>[]);
    when(() => mockCategoryRepository.getCategoryById(any()))
        .thenAnswer((_) async => null);
    when(() => mockCategoryRepository.deleteCategory(any()))
        .thenAnswer((_) async {});
    when(() => mockCategoryRepository.createCategory(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments[0] as Category,
    );
    when(() => mockCategoryRepository.updateCategory(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments[0] as Category,
    );

    // Default stubbing for tag calls
    when(() => mockTagRepository.getAllTags()).thenAnswer((_) async => <Tag>[]);
    when(() => mockTagRepository.getTagById(any()))
        .thenAnswer((_) async => null);
    when(() => mockTagRepository.deleteTag(any())).thenAnswer((_) async {});
    when(() => mockTagRepository.createTag(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments[0] as Tag,
    );
    when(() => mockTagRepository.updateTag(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments[0] as Tag,
    );
    when(() => mockCategoryRepository.deleteCategoryPermanently(any()))
        .thenAnswer((_) async {});
    when(() => mockTagRepository.deleteTagPermanently(any()))
        .thenAnswer((_) async {});
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
        (invocation) async => invocation.positionalArguments[0] as Account,
      );

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
        'should resolve localized wallet name to "Default Wallet" when locale is "en"',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'USD';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Account,
      );

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
      expect(capturedAccount.name, 'Default Wallet');
    });

    test(
        'should resolve localized wallet name to "Moneder Principal" when locale is "ca"',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'EUR';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Account,
      );

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
      expect(capturedAccount.name, 'Moneder Principal');
    });

    test(
        'should resolve localized wallet name to "Monedero Principal" when locale is "es"',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'EUR';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Account,
      );

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
      expect(capturedAccount.name, 'Monedero Principal');
    });

    test(
        'should fallback to default "Default Wallet" when locale is unsupported',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'EUR';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Account,
      );

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
      expect(capturedAccount.name, 'Default Wallet');
    });

    test(
        'should fallback to default "Default Wallet" when locale is null and walletName is null',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'EUR';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Account,
      );

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
      expect(capturedAccount.name, 'Default Wallet');
    });

    test(
        'should seed default typical categories and typical tags in selected locale',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'EUR';
      const locale = 'es';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Account,
      );

      // Act
      await useCase.execute(
        userId: userId,
        currency: currency,
        locale: locale,
      );

      // Assert
      final capturedCategories =
          verify(() => mockCategoryRepository.createCategory(captureAny()))
              .captured;
      expect(capturedCategories.length, 13);

      final names =
          capturedCategories.map((c) => (c as Category).name).toList();
      expect(names, contains('Comida'));
      expect(names, contains('Transporte'));
      expect(names, contains('Salario'));
      expect(names, contains('Vivienda'));
      expect(names, contains('Servicios'));
      expect(names, contains('Entretenimiento'));
      expect(names, contains('Compras'));
      expect(names, contains('Salud'));
      expect(names, contains('Educación'));
      expect(names, contains('Suscripciones'));
      expect(names, contains('Viajes'));
      expect(names, contains('Inversiones'));
      expect(names, contains('Regalos'));

      final capturedTags =
          verify(() => mockTagRepository.createTag(captureAny())).captured;
      expect(capturedTags.length, 6);

      final tagNames = capturedTags.map((t) => (t as Tag).name).toList();
      expect(tagNames, contains('Viaje de verano'));
      expect(tagNames, contains('Evento'));
      expect(tagNames, contains('Proyecto'));
      expect(tagNames, contains('Boda'));
      expect(tagNames, contains('Cumpleaños'));
      expect(tagNames, contains('Viaje de negocios'));
    });

    test(
        'should catch and silence exceptions during initialization to prevent app lockup',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'EUR';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);

      // Throw exception for first category, but succeed for others
      int categoryCallCount = 0;
      when(() => mockCategoryRepository.createCategory(any())).thenAnswer(
        (invocation) async {
          categoryCallCount++;
          if (categoryCallCount == 1) {
            throw Exception('Already exists');
          }
          return invocation.positionalArguments[0] as Category;
        },
      );

      when(() => mockAccountRepository.createAccount(any()))
          .thenThrow(Exception('Account exists'));

      when(() => mockTagRepository.createTag(any()))
          .thenThrow(Exception('Tag exists'));

      // Act
      // If it throws, the test will fail. If it succeeds, it means exceptions were silenced.
      await useCase.execute(
        userId: userId,
        currency: currency,
      );

      // Assert
      verify(() => mockAccountRepository.createAccount(any())).called(1);
      // English is default: 13 categories and 6 tags
      verify(() => mockCategoryRepository.createCategory(any())).called(13);
      verify(() => mockTagRepository.createTag(any())).called(6);
    });

    test(
        'should permanently delete duplicate/old default categories and tags instead of soft-deleting them (ensuring clean recycle bin)',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'EUR';

      // Setup duplicate categories and tags
      final oldCategory = Category(
        id: 'old-random-uuid-cat',
        name: 'Food',
        associatedType: CategoryType.expense,
        icon: 'restaurant',
        color: '#FF9800',
        isDeleted: false,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      final oldTag = Tag(
        id: 'old-random-uuid-tag',
        name: 'Summer Trip',
        isDeleted: false,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Account,
      );

      when(() => mockCategoryRepository.getAllCategories())
          .thenAnswer((_) async => [oldCategory]);
      when(() => mockTagRepository.getAllTags())
          .thenAnswer((_) async => [oldTag]);

      // Act
      await useCase.execute(
        userId: userId,
        currency: currency,
        locale: 'en',
      );

      // Assert
      // Verify no soft deletes were called
      verifyNever(() => mockCategoryRepository.deleteCategory(any()));
      verifyNever(() => mockTagRepository.deleteTag(any()));

      // Verify permanent deletes were called instead
      verify(() => mockCategoryRepository
          .deleteCategoryPermanently('old-random-uuid-cat')).called(1);
      verify(() =>
              mockTagRepository.deleteTagPermanently('old-random-uuid-tag'))
          .called(1);
    });

    test(
        'should resolve localized wallet name to "Moneder Principal" when locale is "ca_ES" (with country code)',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'EUR';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Account,
      );

      // Act
      await useCase.execute(
        userId: userId,
        currency: currency,
        locale: 'ca_ES',
      );

      // Assert
      final capturedAccount =
          verify(() => mockAccountRepository.createAccount(captureAny()))
              .captured
              .first as Account;
      expect(capturedAccount.name, 'Moneder Principal');
    });

    test(
        'should resolve localized wallet name to "Monedero Principal" when locale is "es_US" (with country code)',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'EUR';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Account,
      );

      // Act
      await useCase.execute(
        userId: userId,
        currency: currency,
        locale: 'es_US',
      );

      // Assert
      final capturedAccount =
          verify(() => mockAccountRepository.createAccount(captureAny()))
              .captured
              .first as Account;
      expect(capturedAccount.name, 'Monedero Principal');
    });

    test(
        'should resolve localized wallet name to "Default Wallet" when locale is "en_GB" (with country code)',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'EUR';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Account,
      );

      // Act
      await useCase.execute(
        userId: userId,
        currency: currency,
        locale: 'en_GB',
      );

      // Assert
      final capturedAccount =
          verify(() => mockAccountRepository.createAccount(captureAny()))
              .captured
              .first as Account;
      expect(capturedAccount.name, 'Default Wallet');
    });

    test(
        'should ensure absolutely no categories, tags, or accounts have isDeleted: true during setup',
        () async {
      // Arrange
      const userId = 'user_123';
      const currency = 'EUR';

      when(() => mockAccountRepository.getAccountsByUserId(userId))
          .thenAnswer((_) async => <Account>[]);
      when(() => mockAccountRepository.createAccount(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Account,
      );

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
      expect(capturedAccount.isDeleted, isFalse);

      final capturedCategories =
          verify(() => mockCategoryRepository.createCategory(captureAny()))
              .captured;
      for (final cat in capturedCategories) {
        expect((cat as Category).isDeleted, isFalse);
      }

      final capturedTags =
          verify(() => mockTagRepository.createTag(captureAny())).captured;
      for (final tag in capturedTags) {
        expect((tag as Tag).isDeleted, isFalse);
      }
    });
  });
}
