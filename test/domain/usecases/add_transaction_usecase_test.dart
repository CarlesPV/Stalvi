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

Account _buildAccount({String id = 'account_1', String currency = 'EUR'}) {
  return Account(
    id: id,
    userId: 'user_1',
    name: 'Mi Cartera',
    type: AccountType.cash,
    initialBalance: 5000.0,
    currency: currency,
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

ExchangeRate _buildExchangeRate({String base = 'EUR'}) {
  return ExchangeRate(
    baseCurrency: base,
    date: _now,
    rates: {'USD': 1.08, 'GBP': 0.85},
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
  });

  setUp(() {
    mockTransactionRepo = MockTransactionRepository();
    mockAccountRepo = MockAccountRepository();
    mockProfileRepo = MockProfileRepository();
    mockExchangeRateRepo = MockExchangeRateRepository();
    usecase = AddTransactionUseCase(
      mockTransactionRepo,
      mockAccountRepo,
      mockProfileRepo,
      mockExchangeRateRepo,
    );
  });

  group('AddTransactionUseCase', () {
    group('success cases', () {
      test('should create transaction without conversion when currencies match',
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

        verifyZeroInteractions(mockExchangeRateRepo);
        verify(() => mockTransactionRepo.createTransaction(any())).called(1);
      });

      test('should calculate convertedAmount when currencies differ', () async {
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

        verify(() => mockExchangeRateRepo.getLatestRates(baseCurrency: 'EUR'))
            .called(1);
      });
    });

    group('failure cases', () {
      test('should throw ValidationException when amount <= 0', () async {
        final call = usecase.execute(_incomeParams(amount: 0));
        await expectLater(() => call, throwsA(isA<ValidationException>()));
      });

      test('should throw ValidationException when date in future', () async {
        final call = usecase
            .execute(_incomeParams(date: _now.add(const Duration(days: 1))));
        await expectLater(() => call, throwsA(isA<ValidationException>()));
      });

      test('should throw NotFoundException when account not found', () async {
        when(() => mockAccountRepo.getAccountById(any()))
            .thenAnswer((_) async => null);
        final call = usecase.execute(_incomeParams());
        await expectLater(() => call, throwsA(isA<NotFoundException>()));
      });

      test('should throw NotFoundException when profile not found', () async {
        final account = _buildAccount();
        when(() => mockAccountRepo.getAccountById(any()))
            .thenAnswer((_) async => account);
        when(() => mockProfileRepo.getProfileById(any()))
            .thenAnswer((_) async => null);
        final call = usecase.execute(_incomeParams());
        await expectLater(() => call, throwsA(isA<NotFoundException>()));
      });

      test('should throw ValidationException when rate not found for currency',
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
