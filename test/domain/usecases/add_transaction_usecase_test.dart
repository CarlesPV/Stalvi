import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/usecases/add_transaction_usecase.dart';

// ---------------------------------------------------------------------------
// Mocks & Fakes
// ---------------------------------------------------------------------------

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockProfileRepository extends Mock implements IProfileRepository {}

class MockExchangeRateRepository extends Mock
    implements IExchangeRateRepository {}

class FakeTransaction extends Fake implements Transaction {}

class FakeTransferPair extends Fake implements TransferPair {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now();

Profile _buildProfile({String id = 'user_1', String defaultCurrency = 'EUR'}) {
  return Profile(
    id: id,
    name: 'Test',
    username: 'test',
    password: '',
    defaultCurrency: defaultCurrency,
    createdAt: _now,
    modifiedAt: _now,
  );
}

Account _buildAccount({
  String id = 'account_1',
  String currency = 'EUR',
  String userId = 'user_1',
  bool isDefault = true,
}) {
  return Account(
    id: id,
    userId: userId,
    name: 'Mi Cartera',
    type: AccountType.cash,
    initialBalance: 5000.0,
    currency: currency,
    color: '#4CAF50',
    icon: 'wallet',
    isDefault: isDefault,
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

AddTransactionParams _transferParams({
  int amount = 500,
  String originAccountId = 'account_1',
  String destinationAccountId = 'account_2',
  DateTime? date,
}) {
  return AddTransactionParams(
    id: 'txn_transfer_1',
    amount: amount,
    date: date ?? _now.subtract(const Duration(hours: 1)),
    type: TransactionType.transfer,
    accountId: originAccountId,
    destinationAccountId: destinationAccountId,
    notes: 'Transfer test',
  );
}

ExchangeRate _buildExchangeRate({String base = 'EUR'}) {
  return ExchangeRate(
    baseCurrency: base,
    date: _now,
    rates: {'USD': 1.08, 'GBP': 0.85},
  );
}

Transaction _buildTransaction({
  String id = 'txn_1',
  int amount = 1000,
  TransactionType type = TransactionType.income,
  String accountId = 'account_1',
  String? transferId,
}) {
  return Transaction(
    id: id,
    amount: amount,
    date: _now.subtract(const Duration(hours: 1)),
    type: type,
    accountId: accountId,
    originalCurrency: 'EUR',
    createdAt: _now,
    modifiedAt: _now,
    transferId: transferId,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late AddTransactionUseCase usecase;
  late MockTransactionRepository mockTransactionRepo;
  late MockAccountRepository mockAccountRepo;
  late MockProfileRepository mockProfileRepo;
  late MockExchangeRateRepository mockExchangeRateRepo;

  setUpAll(() {
    registerFallbackValue(FakeTransaction());
    registerFallbackValue(FakeTransferPair());
  });

  setUp(() {
    mockTransactionRepo = MockTransactionRepository();
    mockAccountRepo = MockAccountRepository();
    mockProfileRepo = MockProfileRepository();
    mockExchangeRateRepo = MockExchangeRateRepository();

    when(
      () => mockExchangeRateRepo.getLocalRates(
        baseCurrency: any(named: 'baseCurrency'),
      ),
    ).thenAnswer((_) async => null);

    usecase = AddTransactionUseCase(
      mockTransactionRepo,
      mockAccountRepo,
      mockProfileRepo,
      mockExchangeRateRepo,
    );
  });

  group('AddTransactionUseCase', () {
    // ── Income / Expense success ─────────────────────────────────────────────
    group('income/expense — success cases', () {
      test('creates transaction without conversion when currencies match',
          () async {
        final params = _incomeParams();
        final account = _buildAccount();
        final profile = _buildProfile();

        when(() => mockAccountRepo.getAccountById(params.accountId))
            .thenAnswer((_) async => account);
        when(() => mockProfileRepo.getProfileById(account.userId))
            .thenAnswer((_) async => profile);
        when(() => mockTransactionRepo.createTransaction(any())).thenAnswer(
          (inv) async => inv.positionalArguments[0] as Transaction,
        );

        final result = await usecase.execute(params);

        expect(result.originalCurrency, 'EUR');
        expect(result.convertedAmount, isNull);
        expect(result.exchangeRate, isNull);

        verify(() => mockExchangeRateRepo.getLocalRates(baseCurrency: 'EUR'))
            .called(1);
        verifyNever(() => mockExchangeRateRepo.getLatestRates(
            baseCurrency: any(named: 'baseCurrency')));
        verify(() => mockTransactionRepo.createTransaction(any())).called(1);
      });

      test(
          'attaches JSON exchange rate snapshot when local rates are available',
          () async {
        final params = _incomeParams();
        final account = _buildAccount();
        final profile = _buildProfile();
        final localRates =
            _buildExchangeRate(base: 'EUR'); // EUR: {'USD': 1.08, 'GBP': 0.85}

        when(() => mockAccountRepo.getAccountById(params.accountId))
            .thenAnswer((_) async => account);
        when(() => mockProfileRepo.getProfileById(account.userId))
            .thenAnswer((_) async => profile);
        when(() => mockExchangeRateRepo.getLocalRates(baseCurrency: 'EUR'))
            .thenAnswer((_) async => localRates);
        when(() => mockTransactionRepo.createTransaction(any())).thenAnswer(
          (inv) async => inv.positionalArguments[0] as Transaction,
        );

        final result = await usecase.execute(params);

        expect(result.exchangeRateSnapshot, isNotNull);
        final decoded =
            jsonDecode(result.exchangeRateSnapshot!) as Map<String, dynamic>;
        expect(decoded['EUR'], 1.0);
        expect(decoded['USD'], 1.08);
        expect(decoded['GBP'], 0.85);

        verify(() => mockExchangeRateRepo.getLocalRates(baseCurrency: 'EUR'))
            .called(1);
      });

      test('calculates convertedAmount when currencies differ', () async {
        final params = _incomeParams(amount: 1000); // 10.00 USD
        final account = _buildAccount(currency: 'USD');
        final profile = _buildProfile(defaultCurrency: 'EUR');
        final rateSnapshot =
            _buildExchangeRate(base: 'EUR'); // 1 EUR = 1.08 USD

        when(() => mockAccountRepo.getAccountById(params.accountId))
            .thenAnswer((_) async => account);
        when(() => mockProfileRepo.getProfileById(account.userId))
            .thenAnswer((_) async => profile);
        when(() => mockExchangeRateRepo.getLatestRates(baseCurrency: 'EUR'))
            .thenAnswer((_) async => rateSnapshot);
        when(() => mockTransactionRepo.createTransaction(any())).thenAnswer(
          (inv) async => inv.positionalArguments[0] as Transaction,
        );

        final result = await usecase.execute(params);

        expect(result.originalCurrency, 'USD');
        expect(result.exchangeRate, 1.08);
        expect(result.convertedAmount, (1000 / 1.08).round());

        verify(
          () => mockExchangeRateRepo.getLatestRates(baseCurrency: 'EUR'),
        ).called(1);
      });
    });

    // ── Transfer success ─────────────────────────────────────────────────────
    group('transfer — success cases', () {
      test('creates TWO mirrored transactions via createTransferPair',
          () async {
        final params = _transferParams();
        final originAccount = _buildAccount(id: 'account_1');
        final destAccount = _buildAccount(id: 'account_2', isDefault: false);
        final profile = _buildProfile();

        when(() => mockAccountRepo.getAccountById('account_1'))
            .thenAnswer((_) async => originAccount);
        when(() => mockAccountRepo.getAccountById('account_2'))
            .thenAnswer((_) async => destAccount);
        when(() => mockProfileRepo.getProfileById(originAccount.userId))
            .thenAnswer((_) async => profile);

        final fakeOrigin = _buildTransaction(
          id: 'txn_transfer_1',
          type: TransactionType.transfer,
          accountId: 'account_1',
          transferId: 'shared-tid',
        );
        final fakeDest = _buildTransaction(
          id: 'txn_transfer_1_dst',
          type: TransactionType.transfer,
          accountId: 'account_2',
          transferId: 'shared-tid',
        );

        when(
          () => mockTransactionRepo.createTransferPair(
            originTransaction: any(named: 'originTransaction'),
            destinationTransaction: any(named: 'destinationTransaction'),
          ),
        ).thenAnswer(
          (_) async => TransferPair(origin: fakeOrigin, destination: fakeDest),
        );

        final result = await usecase.execute(params);

        // Returns origin leg.
        expect(result.accountId, 'account_1');
        expect(result.type, TransactionType.transfer);
        expect(result.transferId, isNotNull);

        // Verify createTransferPair was called, NOT createTransaction.
        verify(
          () => mockTransactionRepo.createTransferPair(
            originTransaction: any(named: 'originTransaction'),
            destinationTransaction: any(named: 'destinationTransaction'),
          ),
        ).called(1);
        verifyNever(() => mockTransactionRepo.createTransaction(any()));
      });

      test('both legs share the same transferId', () async {
        final params = _transferParams();
        final originAccount = _buildAccount(id: 'account_1');
        final destAccount = _buildAccount(id: 'account_2', isDefault: false);
        final profile = _buildProfile();

        when(() => mockAccountRepo.getAccountById('account_1'))
            .thenAnswer((_) async => originAccount);
        when(() => mockAccountRepo.getAccountById('account_2'))
            .thenAnswer((_) async => destAccount);
        when(() => mockProfileRepo.getProfileById(originAccount.userId))
            .thenAnswer((_) async => profile);

        // Capture both transaction args to verify shared transferId.
        Transaction? capturedOrigin;
        Transaction? capturedDest;

        when(
          () => mockTransactionRepo.createTransferPair(
            originTransaction: any(named: 'originTransaction'),
            destinationTransaction: any(named: 'destinationTransaction'),
          ),
        ).thenAnswer((inv) async {
          capturedOrigin =
              inv.namedArguments[#originTransaction] as Transaction;
          capturedDest =
              inv.namedArguments[#destinationTransaction] as Transaction;
          return TransferPair(
            origin: capturedOrigin!,
            destination: capturedDest!,
          );
        });

        await usecase.execute(params);

        expect(capturedOrigin, isNotNull);
        expect(capturedDest, isNotNull);
        expect(capturedOrigin!.transferId, isNotNull);
        expect(capturedOrigin!.transferId, equals(capturedDest!.transferId));
      });

      test('origin leg has origin accountId, destination has dest accountId',
          () async {
        final params = _transferParams();
        final originAccount = _buildAccount(id: 'account_1');
        final destAccount = _buildAccount(id: 'account_2', isDefault: false);
        final profile = _buildProfile();

        when(() => mockAccountRepo.getAccountById('account_1'))
            .thenAnswer((_) async => originAccount);
        when(() => mockAccountRepo.getAccountById('account_2'))
            .thenAnswer((_) async => destAccount);
        when(() => mockProfileRepo.getProfileById(originAccount.userId))
            .thenAnswer((_) async => profile);

        Transaction? capturedOrigin;
        Transaction? capturedDest;

        when(
          () => mockTransactionRepo.createTransferPair(
            originTransaction: any(named: 'originTransaction'),
            destinationTransaction: any(named: 'destinationTransaction'),
          ),
        ).thenAnswer((inv) async {
          capturedOrigin =
              inv.namedArguments[#originTransaction] as Transaction;
          capturedDest =
              inv.namedArguments[#destinationTransaction] as Transaction;
          return TransferPair(
            origin: capturedOrigin!,
            destination: capturedDest!,
          );
        });

        await usecase.execute(params);

        expect(capturedOrigin!.accountId, 'account_1');
        expect(capturedDest!.accountId, 'account_2');
      });

      test('both legs have the same amount and date', () async {
        final params = _transferParams(amount: 2500);
        final originAccount = _buildAccount(id: 'account_1');
        final destAccount = _buildAccount(id: 'account_2', isDefault: false);
        final profile = _buildProfile();

        when(() => mockAccountRepo.getAccountById('account_1'))
            .thenAnswer((_) async => originAccount);
        when(() => mockAccountRepo.getAccountById('account_2'))
            .thenAnswer((_) async => destAccount);
        when(() => mockProfileRepo.getProfileById(originAccount.userId))
            .thenAnswer((_) async => profile);

        Transaction? capturedOrigin;
        Transaction? capturedDest;

        when(
          () => mockTransactionRepo.createTransferPair(
            originTransaction: any(named: 'originTransaction'),
            destinationTransaction: any(named: 'destinationTransaction'),
          ),
        ).thenAnswer((inv) async {
          capturedOrigin =
              inv.namedArguments[#originTransaction] as Transaction;
          capturedDest =
              inv.namedArguments[#destinationTransaction] as Transaction;
          return TransferPair(
            origin: capturedOrigin!,
            destination: capturedDest!,
          );
        });

        await usecase.execute(params);

        expect(capturedOrigin!.amount, 2500);
        expect(capturedDest!.amount, 2500);
        expect(capturedOrigin!.date, capturedDest!.date);
      });

      test('uses null as default notes when none supplied', () async {
        final params = AddTransactionParams(
          id: 'txn_t',
          amount: 100,
          date: _now.subtract(const Duration(hours: 1)),
          type: TransactionType.transfer,
          accountId: 'account_1',
          destinationAccountId: 'account_2',
          // no notes
        );
        final originAccount = _buildAccount(id: 'account_1');
        final destAccount = _buildAccount(id: 'account_2', isDefault: false);
        final profile = _buildProfile();

        when(() => mockAccountRepo.getAccountById('account_1'))
            .thenAnswer((_) async => originAccount);
        when(() => mockAccountRepo.getAccountById('account_2'))
            .thenAnswer((_) async => destAccount);
        when(() => mockProfileRepo.getProfileById(originAccount.userId))
            .thenAnswer((_) async => profile);

        Transaction? capturedOrigin;
        when(
          () => mockTransactionRepo.createTransferPair(
            originTransaction: any(named: 'originTransaction'),
            destinationTransaction: any(named: 'destinationTransaction'),
          ),
        ).thenAnswer((inv) async {
          capturedOrigin =
              inv.namedArguments[#originTransaction] as Transaction;
          final dest =
              inv.namedArguments[#destinationTransaction] as Transaction;
          return TransferPair(origin: capturedOrigin!, destination: dest);
        });

        await usecase.execute(params);

        expect(capturedOrigin!.notes, isNull);
      });
    });

    // ── Transfer validation failures ─────────────────────────────────────────
    group('transfer — validation failures', () {
      test(
          'throws ValidationException when destinationAccountId is missing for transfer',
          () async {
        final params = AddTransactionParams(
          id: 'txn_t',
          amount: 100,
          date: _now.subtract(const Duration(hours: 1)),
          type: TransactionType.transfer,
          accountId: 'account_1',
          // destinationAccountId omitted
        );
        final account = _buildAccount();
        final profile = _buildProfile();

        when(() => mockAccountRepo.getAccountById(params.accountId))
            .thenAnswer((_) async => account);
        when(() => mockProfileRepo.getProfileById(account.userId))
            .thenAnswer((_) async => profile);

        await expectLater(
          () => usecase.execute(params),
          throwsA(
            isA<ValidationException>()
                .having((e) => e.code, 'code', 'MISSING_DESTINATION_ACCOUNT'),
          ),
        );
      });

      test(
          'throws ValidationException when origin and destination are the same account',
          () async {
        final params = AddTransactionParams(
          id: 'txn_t',
          amount: 100,
          date: _now.subtract(const Duration(hours: 1)),
          type: TransactionType.transfer,
          accountId: 'account_1',
          destinationAccountId: 'account_1', // same!
        );
        final account = _buildAccount();
        final profile = _buildProfile();

        when(() => mockAccountRepo.getAccountById(params.accountId))
            .thenAnswer((_) async => account);
        when(() => mockProfileRepo.getProfileById(account.userId))
            .thenAnswer((_) async => profile);

        await expectLater(
          () => usecase.execute(params),
          throwsA(
            isA<ValidationException>()
                .having((e) => e.code, 'code', 'SAME_ACCOUNT_TRANSFER'),
          ),
        );
      });

      test('throws NotFoundException when destination account does not exist',
          () async {
        final params = _transferParams();
        final originAccount = _buildAccount(id: 'account_1');
        final profile = _buildProfile();

        when(() => mockAccountRepo.getAccountById('account_1'))
            .thenAnswer((_) async => originAccount);
        when(() => mockAccountRepo.getAccountById('account_2'))
            .thenAnswer((_) async => null); // not found
        when(() => mockProfileRepo.getProfileById(originAccount.userId))
            .thenAnswer((_) async => profile);

        await expectLater(
          () => usecase.execute(params),
          throwsA(
            isA<NotFoundException>()
                .having((e) => e.code, 'code', 'DESTINATION_ACCOUNT_NOT_FOUND'),
          ),
        );
      });
    });

    // ── Common validation failures ───────────────────────────────────────────
    group('common — failure cases', () {
      test('throws ValidationException when amount <= 0', () async {
        final call = usecase.execute(_incomeParams(amount: 0));
        await expectLater(() => call, throwsA(isA<ValidationException>()));
      });

      test('throws ValidationException when date in future', () async {
        final call = usecase
            .execute(_incomeParams(date: _now.add(const Duration(days: 1))));
        await expectLater(() => call, throwsA(isA<ValidationException>()));
      });

      test('throws NotFoundException when account not found', () async {
        when(() => mockAccountRepo.getAccountById(any()))
            .thenAnswer((_) async => null);
        final call = usecase.execute(_incomeParams());
        await expectLater(() => call, throwsA(isA<NotFoundException>()));
      });

      test('throws NotFoundException when profile not found', () async {
        final account = _buildAccount();
        when(() => mockAccountRepo.getAccountById(any()))
            .thenAnswer((_) async => account);
        when(() => mockProfileRepo.getProfileById(any()))
            .thenAnswer((_) async => null);
        final call = usecase.execute(_incomeParams());
        await expectLater(() => call, throwsA(isA<NotFoundException>()));
      });

      test('throws ValidationException when rate not found for currency',
          () async {
        final params = _incomeParams();
        final account = _buildAccount(currency: 'JPY'); // Not in rates
        final profile = _buildProfile(defaultCurrency: 'EUR');
        final rateSnapshot = _buildExchangeRate(base: 'EUR');

        when(() => mockAccountRepo.getAccountById(any()))
            .thenAnswer((_) async => account);
        when(() => mockProfileRepo.getProfileById(any()))
            .thenAnswer((_) async => profile);
        when(() => mockExchangeRateRepo.getLatestRates(baseCurrency: 'EUR'))
            .thenAnswer((_) async => rateSnapshot);

        final call = usecase.execute(params);
        await expectLater(
          () => call,
          throwsA(
            isA<ValidationException>()
                .having((e) => e.code, 'code', 'RATE_NOT_FOUND'),
          ),
        );
      });
    });
  });
}
