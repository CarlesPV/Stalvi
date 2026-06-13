import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/domain/entities/account.dart';
import 'package:konta/domain/entities/account_type.dart';
import 'package:konta/domain/entities/transaction.dart';
import 'package:konta/domain/entities/transaction_type.dart';
import 'package:konta/domain/repositories/i_account_repository.dart';
import 'package:konta/domain/repositories/i_transaction_repository.dart';
import 'package:konta/domain/usecases/add_transaction_usecase.dart';

// ---------------------------------------------------------------------------
// Mocks & Fakes
// ---------------------------------------------------------------------------

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockAccountRepository extends Mock implements IAccountRepository {}

class FakeTransaction extends Fake implements Transaction {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now();

Account _buildAccount({String id = 'account_1'}) {
  return Account(
    id: id,
    userId: 'user_1',
    name: 'Mi Cartera',
    type: AccountType.cash,
    initialBalance: 5000.0,
    currency: 'EUR',
    color: '#4CAF50',
    icon: 'wallet',
    isDefault: true,
    isDeleted: false,
    createdAt: _now,
    modifiedAt: _now,
  );
}

AddTransactionParams _incomeParams({
  int amount = 1000,
  DateTime? date,
  String accountId = 'account_1',
}) {
  return AddTransactionParams(
    id: 'txn_income_1',
    amount: amount,
    date: date ?? _now.subtract(const Duration(hours: 1)),
    type: TransactionType.income,
    accountId: accountId,
    categoryId: 'cat_salary',
    notes: 'Monthly salary',
  );
}

AddTransactionParams _expenseParams({
  int amount = 500,
  DateTime? date,
  String accountId = 'account_1',
}) {
  return AddTransactionParams(
    id: 'txn_expense_1',
    amount: amount,
    date: date ?? _now.subtract(const Duration(hours: 1)),
    type: TransactionType.expense,
    accountId: accountId,
    categoryId: 'cat_food',
    notes: 'Grocery shopping',
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late AddTransactionUseCase usecase;
  late MockTransactionRepository mockTransactionRepo;
  late MockAccountRepository mockAccountRepo;

  setUpAll(() {
    registerFallbackValue(FakeTransaction());
  });

  setUp(() {
    mockTransactionRepo = MockTransactionRepository();
    mockAccountRepo = MockAccountRepository();
    usecase = AddTransactionUseCase(mockTransactionRepo, mockAccountRepo);
  });

  group('AddTransactionUseCase', () {
    // -----------------------------------------------------------------------
    // SUCCESS CASES
    // -----------------------------------------------------------------------

    group('success cases', () {
      test(
        'should create an income transaction and call the repository',
        () async {
          // Arrange
          final params = _incomeParams();
          final account = _buildAccount();

          when(() => mockAccountRepo.getAccountById(params.accountId))
              .thenAnswer((_) async => account);
          when(() => mockTransactionRepo.createTransaction(any()))
              .thenAnswer(
            (inv) async => inv.positionalArguments[0] as Transaction,
          );

          // Act
          final result = await usecase.execute(params);

          // Assert
          expect(result.id, params.id);
          expect(result.amount, params.amount);
          expect(result.type, TransactionType.income);
          expect(result.accountId, params.accountId);
          expect(result.categoryId, params.categoryId);
          expect(result.notes, params.notes);
          expect(result.createdAt, isA<DateTime>());
          expect(result.modifiedAt, isA<DateTime>());

          verify(() => mockAccountRepo.getAccountById(params.accountId))
              .called(1);
          verify(() => mockTransactionRepo.createTransaction(any()))
              .called(1);
          verifyNoMoreInteractions(mockTransactionRepo);
        },
      );

      test(
        'should create an expense transaction and call the repository',
        () async {
          // Arrange
          final params = _expenseParams();
          final account = _buildAccount();

          when(() => mockAccountRepo.getAccountById(params.accountId))
              .thenAnswer((_) async => account);
          when(() => mockTransactionRepo.createTransaction(any()))
              .thenAnswer(
            (inv) async => inv.positionalArguments[0] as Transaction,
          );

          // Act
          final result = await usecase.execute(params);

          // Assert
          expect(result.id, params.id);
          expect(result.amount, params.amount);
          expect(result.type, TransactionType.expense);
          expect(result.accountId, params.accountId);

          verify(() => mockAccountRepo.getAccountById(params.accountId))
              .called(1);
          verify(() => mockTransactionRepo.createTransaction(any()))
              .called(1);
        },
      );

      test(
        'should set createdAt and modifiedAt to approximately now',
        () async {
          // Arrange
          final params = _incomeParams();
          final account = _buildAccount();
          final before = DateTime.now();

          when(() => mockAccountRepo.getAccountById(params.accountId))
              .thenAnswer((_) async => account);
          when(() => mockTransactionRepo.createTransaction(any()))
              .thenAnswer(
            (inv) async => inv.positionalArguments[0] as Transaction,
          );

          // Act
          final result = await usecase.execute(params);
          final after = DateTime.now();

          // Assert – timestamps should be between [before, after].
          expect(
            result.createdAt.isAfter(before) ||
                result.createdAt.isAtSameMomentAs(before),
            isTrue,
          );
          expect(
            result.createdAt.isBefore(after) ||
                result.createdAt.isAtSameMomentAs(after),
            isTrue,
          );
          expect(result.createdAt, equals(result.modifiedAt));
        },
      );

      test(
        'should accept a date that is exactly now (not in the future)',
        () async {
          // Arrange
          final params = _incomeParams(date: DateTime.now());
          final account = _buildAccount();

          when(() => mockAccountRepo.getAccountById(params.accountId))
              .thenAnswer((_) async => account);
          when(() => mockTransactionRepo.createTransaction(any()))
              .thenAnswer(
            (inv) async => inv.positionalArguments[0] as Transaction,
          );

          // Act & Assert – no exception thrown
          final result = await usecase.execute(params);
          expect(result, isA<Transaction>());
        },
      );

      test(
        'should allow null categoryId and notes',
        () async {
          // Arrange
          final params = AddTransactionParams(
            id: 'txn_no_extras',
            amount: 300,
            date: _now.subtract(const Duration(minutes: 5)),
            type: TransactionType.expense,
            accountId: 'account_1',
          );
          final account = _buildAccount();

          when(() => mockAccountRepo.getAccountById(params.accountId))
              .thenAnswer((_) async => account);
          when(() => mockTransactionRepo.createTransaction(any()))
              .thenAnswer(
            (inv) async => inv.positionalArguments[0] as Transaction,
          );

          // Act
          final result = await usecase.execute(params);

          // Assert
          expect(result.categoryId, isNull);
          expect(result.notes, isNull);
        },
      );
    });

    // -----------------------------------------------------------------------
    // FAILURE: AMOUNT VALIDATION
    // -----------------------------------------------------------------------

    group('amount validation', () {
      test(
        'should throw ValidationException when amount is 0',
        () async {
          // Arrange
          final params = _incomeParams(amount: 0);

          // Act
          final call = usecase.execute(params);

          // Assert
          await expectLater(
            () => call,
            throwsA(
              isA<ValidationException>().having(
                (e) => e.code,
                'code',
                'INVALID_AMOUNT',
              ),
            ),
          );
          verifyZeroInteractions(mockTransactionRepo);
          verifyZeroInteractions(mockAccountRepo);
        },
      );

      test(
        'should throw ValidationException when amount is negative',
        () async {
          // Arrange
          final params = _expenseParams(amount: -100);

          // Act
          final call = usecase.execute(params);

          // Assert
          await expectLater(
            () => call,
            throwsA(
              isA<ValidationException>().having(
                (e) => e.message,
                'message',
                contains('greater than 0'),
              ),
            ),
          );
          verifyZeroInteractions(mockTransactionRepo);
          verifyZeroInteractions(mockAccountRepo);
        },
      );
    });

    // -----------------------------------------------------------------------
    // FAILURE: DATE VALIDATION
    // -----------------------------------------------------------------------

    group('date validation', () {
      test(
        'should throw ValidationException when date is in the future',
        () async {
          // Arrange
          final futureDate = DateTime.now().add(const Duration(days: 1));
          final params = _incomeParams(date: futureDate);

          // Act
          final call = usecase.execute(params);

          // Assert
          await expectLater(
            () => call,
            throwsA(
              isA<ValidationException>().having(
                (e) => e.code,
                'code',
                'FUTURE_DATE',
              ),
            ),
          );
          verifyZeroInteractions(mockTransactionRepo);
          verifyZeroInteractions(mockAccountRepo);
        },
      );
    });

    // -----------------------------------------------------------------------
    // FAILURE: ACCOUNT NOT FOUND
    // -----------------------------------------------------------------------

    group('account validation', () {
      test(
        'should throw NotFoundException when accountId does not exist',
        () async {
          // Arrange
          final params = _expenseParams(accountId: 'non_existent_account');

          when(() => mockAccountRepo.getAccountById('non_existent_account'))
              .thenAnswer((_) async => null);

          // Act
          final call = usecase.execute(params);

          // Assert
          await expectLater(
            () => call,
            throwsA(
              isA<NotFoundException>().having(
                (e) => e.code,
                'code',
                'ACCOUNT_NOT_FOUND',
              ),
            ),
          );
          verify(() => mockAccountRepo.getAccountById('non_existent_account'))
              .called(1);
          verifyZeroInteractions(mockTransactionRepo);
        },
      );
    });

    // -----------------------------------------------------------------------
    // FAILURE: REPOSITORY PROPAGATION
    // -----------------------------------------------------------------------

    group('repository error propagation', () {
      test(
        'should propagate DatabaseException from the repository',
        () async {
          // Arrange
          final params = _incomeParams();
          final account = _buildAccount();

          when(() => mockAccountRepo.getAccountById(params.accountId))
              .thenAnswer((_) async => account);
          when(() => mockTransactionRepo.createTransaction(any())).thenThrow(
            const DatabaseException(
              message: 'disk full',
              code: 'TRANSACTION_INSERT_FAILED',
            ),
          );

          // Act
          final call = usecase.execute(params);

          // Assert
          await expectLater(
            () => call,
            throwsA(
              isA<DatabaseException>().having(
                (e) => e.code,
                'code',
                'TRANSACTION_INSERT_FAILED',
              ),
            ),
          );
        },
      );
    });
  });
}
