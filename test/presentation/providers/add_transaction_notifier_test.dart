import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/domain/entities/account.dart';
import 'package:konta/domain/entities/account_type.dart';
import 'package:konta/domain/entities/category.dart';
import 'package:konta/domain/entities/category_type.dart';
import 'package:konta/domain/entities/transaction.dart';
import 'package:konta/domain/entities/transaction_type.dart';
import 'package:konta/domain/usecases/add_transaction_usecase.dart';
import 'package:konta/presentation/providers/add_transaction_notifier.dart';
import 'package:konta/presentation/providers/repository_providers.dart';

// Mocks & Fakes
class MockAddTransactionUseCase extends Mock implements AddTransactionUseCase {}

class FakeAddTransactionParams extends Fake implements AddTransactionParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAddTransactionParams());
  });

  late MockAddTransactionUseCase mockUseCase;
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

  setUp(() {
    mockUseCase = MockAddTransactionUseCase();
  });

  tearDown(() {
    container.dispose();
  });

  void buildContainer({List<Account>? accounts}) {
    container = ProviderContainer(
      overrides: [
        addTransactionUseCaseProvider.overrideWithValue(mockUseCase),
        accountsListProvider
            .overrideWith((ref) async => accounts ?? [testAccount]),
        categoriesListProvider.overrideWith((ref) async => [testCategory]),
      ],
    );
  }

  group('AddTransactionNotifier State Management', () {
    test('initializes with default state values', () {
      buildContainer(accounts: []);

      final state = container.read(addTransactionNotifierProvider);

      expect(state.amountText, '');
      expect(state.type, TransactionType.expense);
      expect(state.accountId, isNull);
      expect(state.categoryId, isNull);
      expect(state.notes, '');
      expect(state.date, isA<DateTime>());
      expect(state.submissionStatus, const AsyncData<void>(null));
    });

    test(
        'initializes with the default account ID when accounts are already loaded',
        () async {
      buildContainer(accounts: [testAccount]);

      // Wait for accounts list to resolve to populate notifier's listener
      await container.read(accountsListProvider.future);

      final state = container.read(addTransactionNotifierProvider);
      expect(state.accountId, testAccount.id);
    });

    test('updates amount, notes, and date correctly', () {
      buildContainer();

      final notifier = container.read(addTransactionNotifierProvider.notifier);

      notifier.updateAmount('55.42');
      notifier.updateNotes('Electricity bill');
      final newDate = DateTime(2026, 6, 1);
      notifier.updateDate(newDate);

      final state = container.read(addTransactionNotifierProvider);
      expect(state.amountText, '55.42');
      expect(state.notes, 'Electricity bill');
      expect(state.date, newDate);
    });

    test('updates account and category correctly', () {
      buildContainer();

      final notifier = container.read(addTransactionNotifierProvider.notifier);

      notifier.updateAccount('acc_custom');
      notifier.updateCategory('cat_custom');

      final state = container.read(addTransactionNotifierProvider);
      expect(state.accountId, 'acc_custom');
      expect(state.categoryId, 'cat_custom');
    });

    test('resets category selection when transaction type changes', () {
      buildContainer();

      final notifier = container.read(addTransactionNotifierProvider.notifier);

      notifier.updateType(TransactionType.expense);
      notifier.updateCategory('cat_expense');

      // Verify category is set
      expect(
        container.read(addTransactionNotifierProvider).categoryId,
        'cat_expense',
      );

      // Change type to income
      notifier.updateType(TransactionType.income);

      // Verify type changed and category got reset to null
      final state = container.read(addTransactionNotifierProvider);
      expect(state.type, TransactionType.income);
      expect(state.categoryId, isNull);
    });

    test('does not reset category if type changes to the same value', () {
      buildContainer();

      final notifier = container.read(addTransactionNotifierProvider.notifier);

      notifier.updateType(TransactionType.expense);
      notifier.updateCategory('cat_expense');

      notifier.updateType(TransactionType.expense);

      final state = container.read(addTransactionNotifierProvider);
      expect(state.categoryId, 'cat_expense');
    });
  });

  group('AddTransactionNotifier Validation & Form Submission', () {
    test(
        'submit returns false and sets validation error on invalid amount format',
        () async {
      buildContainer();

      final notifier = container.read(addTransactionNotifierProvider.notifier);
      notifier.updateAmount('not-a-number');
      notifier.updateAccount(testAccount.id);

      final success = await notifier.submit();

      expect(success, isFalse);
      final status =
          container.read(addTransactionNotifierProvider).submissionStatus;
      expect(status.hasError, isTrue);
      expect(status.error, isA<ValidationException>());
      expect((status.error as ValidationException).code, 'INVALID_AMOUNT');
      verifyZeroInteractions(mockUseCase);
    });

    test(
        'submit returns false and sets validation error on negative/zero amount',
        () async {
      buildContainer();

      final notifier = container.read(addTransactionNotifierProvider.notifier);
      notifier.updateAmount('-12.50');
      notifier.updateAccount(testAccount.id);

      final success = await notifier.submit();

      expect(success, isFalse);
      final status =
          container.read(addTransactionNotifierProvider).submissionStatus;
      expect(status.hasError, isTrue);
      expect(status.error, isA<ValidationException>());
      verifyZeroInteractions(mockUseCase);
    });

    test(
        'submit returns false and sets validation error when account is missing',
        () async {
      buildContainer(accounts: []);

      final notifier = container.read(addTransactionNotifierProvider.notifier);
      notifier.updateAmount('10.00');

      final success = await notifier.submit();

      expect(success, isFalse);
      final status =
          container.read(addTransactionNotifierProvider).submissionStatus;
      expect(status.hasError, isTrue);
      expect(status.error, isA<ValidationException>());
      expect((status.error as ValidationException).code, 'ACCOUNT_REQUIRED');
      verifyZeroInteractions(mockUseCase);
    });

    test(
        'submit calls usecase and transitions to success when inputs are valid',
        () async {
      buildContainer();

      final notifier = container.read(addTransactionNotifierProvider.notifier);
      notifier.updateAmount('150.00');
      notifier.updateAccount(testAccount.id);
      notifier.updateCategory(testCategory.id);
      notifier.updateNotes('   Weekly grocery   ');

      when(() => mockUseCase.execute(any())).thenAnswer(
        (_) async => Transaction(
          id: 'txn_generated',
          amount: 15000,
          date: DateTime.now(),
          type: TransactionType.expense,
          accountId: testAccount.id,
          categoryId: testCategory.id,
          notes: 'Weekly grocery',
          originalCurrency: 'EUR',
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        ),
      );

      final success = await notifier.submit();

      expect(success, isTrue);
      final finalState = container.read(addTransactionNotifierProvider);
      expect(finalState.submissionStatus.isLoading, isFalse);
      expect(finalState.submissionStatus.hasError, isFalse);

      final captured = verify(() => mockUseCase.execute(captureAny()))
          .captured
          .first as AddTransactionParams;
      expect(captured.amount, 15000); // 150.00 converted to cents
      expect(captured.accountId, testAccount.id);
      expect(captured.categoryId, testCategory.id);
      expect(captured.notes, 'Weekly grocery'); // Trimmed notes
    });

    test('submit sets error when usecase throws an exception', () async {
      buildContainer();

      final notifier = container.read(addTransactionNotifierProvider.notifier);
      notifier.updateAmount('10.00');
      notifier.updateAccount(testAccount.id);

      const testException =
          DatabaseException(message: 'Disk error', code: 'WRITE_ERROR');
      when(() => mockUseCase.execute(any())).thenThrow(testException);

      final success = await notifier.submit();

      expect(success, isFalse);
      final finalState = container.read(addTransactionNotifierProvider);
      expect(finalState.submissionStatus.hasError, isTrue);
      expect(finalState.submissionStatus.error, testException);
    });
  });
}
