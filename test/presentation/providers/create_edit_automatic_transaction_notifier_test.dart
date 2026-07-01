import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/category_type.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/recurrence_type.dart';

import 'package:stalvi/domain/usecases/automatic_transactions/crud_automatic_transactions_usecase.dart';
import 'package:stalvi/presentation/providers/create_edit_automatic_transaction_notifier.dart';
import 'package:stalvi/presentation/providers/automatic_transactions_providers.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';

import 'package:stalvi/core/security/secure_storage_manager.dart';

// Mocks & Fakes
class MockCreateAutomaticTransactionUseCase extends Mock
    implements CreateAutomaticTransactionUseCase {}

class MockUpdateAutomaticTransactionUseCase extends Mock
    implements UpdateAutomaticTransactionUseCase {}

class MockSecureStorageManager extends Mock implements SecureStorageManager {}

class FakeAutomaticTransaction extends Fake implements AutomaticTransaction {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAutomaticTransaction());
  });

  late MockCreateAutomaticTransactionUseCase mockCreateUseCase;
  late MockUpdateAutomaticTransactionUseCase mockUpdateUseCase;
  late MockSecureStorageManager mockSecureStorageManager;
  late ProviderContainer container;

  final testAccount = Account(
    id: 'acc_1',
    userId: 'user_1',
    name: 'My Wallet',
    type: AccountType.cash,
    initialBalance: 100.0,
    currency: 'EUR',
    color: '#000000',
    icon: 'wallet',
    isDefault: true,
    isDeleted: false,
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
  );

  final testCategory = Category(
    id: 'cat_1',
    name: 'Food',
    associatedType: CategoryType.expense,
    icon: 'restaurant',
    color: '#FF0000',
    isDeleted: false,
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
  );

  final testProfile = Profile(
    id: 'user_1',
    name: 'Test User',
    username: 'test_user',
    password: '',
    defaultCurrency: 'EUR',
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
  );

  setUp(() {
    mockCreateUseCase = MockCreateAutomaticTransactionUseCase();
    mockUpdateUseCase = MockUpdateAutomaticTransactionUseCase();
    mockSecureStorageManager = MockSecureStorageManager();
    when(() => mockSecureStorageManager.getUserLocale())
        .thenAnswer((_) async => 'en');
  });

  tearDown(() {
    container.dispose();
  });

  void buildContainer({List<Account>? accounts, Profile? profile}) {
    container = ProviderContainer(
      overrides: [
        createAutomaticTransactionUseCaseProvider
            .overrideWithValue(mockCreateUseCase),
        updateAutomaticTransactionUseCaseProvider
            .overrideWithValue(mockUpdateUseCase),
        accountsListProvider
            .overrideWith((ref) => Stream.value(accounts ?? [testAccount])),
        categoriesListProvider
            .overrideWith((ref) => Stream.value([testCategory])),
        defaultProfileProvider.overrideWith((ref) => profile ?? testProfile),
        secureStorageProvider.overrideWith((ref) => mockSecureStorageManager),
      ],
    );
  }

  group('CreateEditAutomaticTransactionNotifier State Management', () {
    test('initializes with default state values', () {
      buildContainer(accounts: []);
      final state =
          container.read(createEditAutomaticTransactionNotifierProvider(null));

      expect(state.name, '');
      expect(state.amountText, '');
      expect(state.type, TransactionType.expense);
      expect(state.accountId, isNull);
      expect(state.categoryId, isNull);
      expect(state.notes, '');
      expect(state.currency, 'EUR');
      expect(state.recurrenceDays, 30);
      expect(state.submissionStatus, const AsyncData<void>(null));
    });

    test('initializes with transaction values when editing', () {
      buildContainer();
      final txn = AutomaticTransaction(
        id: 'txn_1',
        name: 'Rent',
        amount: 50000,
        currency: 'USD',
        type: TransactionType.expense,
        accountId: 'acc_1',
        categoryId: 'cat_1',
        notes: 'Monthly rent',
        recurrenceDays: 14,
        nextExecutionDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final state =
          container.read(createEditAutomaticTransactionNotifierProvider(txn));

      expect(state.id, 'txn_1');
      expect(state.name, 'Rent');
      expect(state.amountText, '500.0');
      expect(state.currency, 'USD');
      expect(state.accountId, 'acc_1');
      expect(state.categoryId, 'cat_1');
      expect(state.notes, 'Monthly rent');
      expect(state.recurrenceDays, 14);
    });
  });

  group('CreateEditAutomaticTransactionNotifier Validation', () {
    test('submit returns false when name is missing', () async {
      buildContainer();
      final notifier = container
          .read(createEditAutomaticTransactionNotifierProvider(null).notifier);

      notifier.updateName('');
      notifier.updateAmount('10.0');
      notifier.updateAccount(testAccount.id);
      notifier.updateCategory(testCategory.id);

      final success = await notifier.submit();
      expect(success, isFalse);

      final state =
          container.read(createEditAutomaticTransactionNotifierProvider(null));
      expect(state.errors.containsKey('name'), isTrue);
      expect(state.errors['name'], 'NAME_REQUIRED');
    });

    test('submit succeeds and calls create use case for new transaction',
        () async {
      buildContainer();
      final notifier = container
          .read(createEditAutomaticTransactionNotifierProvider(null).notifier);

      notifier.updateName('Spotify');
      notifier.updateAmount('9.99');
      notifier.updateAccount(testAccount.id);
      notifier.updateCategory(testCategory.id);
      notifier.updateCurrency('EUR');
      notifier.updateRecurrence(RecurrenceType.intervalDays, 30);

      when(() => mockCreateUseCase.execute(any()))
          .thenAnswer((_) async => FakeAutomaticTransaction());

      final success = await notifier.submit();
      if (!success) {
        // Validation failed
      }

      expect(success, isTrue);
      final captured = verify(() => mockCreateUseCase.execute(captureAny()))
          .captured
          .first as AutomaticTransaction;
      expect(captured.name, 'Spotify');
      expect(captured.amount, 999);
      expect(captured.recurrenceDays, 30);
    });

    test('submit calls update use case when editing existing transaction',
        () async {
      buildContainer();
      final txn = AutomaticTransaction(
        id: 'txn_1',
        name: 'Rent',
        amount: 50000,
        currency: 'USD',
        type: TransactionType.expense,
        accountId: 'acc_1',
        categoryId: 'cat_1',
        notes: '',
        recurrenceDays: 30,
        nextExecutionDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final notifier = container
          .read(createEditAutomaticTransactionNotifierProvider(txn).notifier);

      notifier.updateAmount('550.0'); // changed amount

      when(() => mockUpdateUseCase.execute(any()))
          .thenAnswer((_) async => FakeAutomaticTransaction());

      final success = await notifier.submit();

      expect(success, isTrue);
      final captured = verify(() => mockUpdateUseCase.execute(captureAny()))
          .captured
          .first as AutomaticTransaction;
      expect(captured.id, 'txn_1');
      expect(captured.amount, 55000);
      verifyNever(() => mockCreateUseCase.execute(any()));
    });
  });
}
