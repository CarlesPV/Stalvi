// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/recurrence_type.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_automatic_transaction_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/usecases/automatic_transactions/evaluate_automatic_transactions_usecase.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAutomaticTransactionRepository extends Mock
    implements IAutomaticTransactionRepository {}

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockProfileRepository extends Mock implements IProfileRepository {}

class MockExchangeRateRepository extends Mock
    implements IExchangeRateRepository {}

class FakeTransaction extends Fake implements Transaction {}

class FakeAutomaticTransaction extends Fake implements AutomaticTransaction {}

// ---------------------------------------------------------------------------
// Builders
// ---------------------------------------------------------------------------

final _now = DateTime.now();

AutomaticTransaction _buildAutoTxn({
  String id = '1',
  String currency = 'EUR',
  RecurrenceType recurrenceType = RecurrenceType.intervalDays,
  int recurrenceDays = 30,
  DateTime? nextExecutionDate,
}) {
  final past = _now.subtract(const Duration(hours: 1));
  return AutomaticTransaction(
    id: id,
    name: 'Test',
    amount: 1000,
    currency: currency,
    type: TransactionType.expense,
    accountId: 'acc1',
    categoryId: null,
    tagId: null,
    notes: null,
    recurrenceType: recurrenceType,
    recurrenceDays: recurrenceDays,
    nextExecutionDate: nextExecutionDate ?? past,
    createdAt: past,
  );
}

Account _buildAccount({String currency = 'EUR'}) {
  return Account(
    id: 'acc1',
    userId: 'user1',
    name: 'Wallet',
    type: AccountType.cash,
    initialBalance: 0,
    currency: currency,
    color: '#4CAF50',
    icon: 'wallet',
    isDefault: true,
    isDeleted: false,
    createdAt: _now,
    modifiedAt: _now,
  );
}

Profile _buildProfile({String defaultCurrency = 'EUR'}) {
  return Profile(
    id: 'user1',
    name: 'Test User',
    username: 'test',
    password: '',
    defaultCurrency: defaultCurrency,
    createdAt: _now,
    modifiedAt: _now,
  );
}

ExchangeRate _buildRates({String base = 'EUR'}) {
  return ExchangeRate(
    baseCurrency: base,
    date: _now,
    rates: {'USD': 1.08, 'GBP': 0.85},
  );
}

Transaction _dummyTxn() => Transaction(
      id: 'dummy',
      amount: 1000,
      date: _now,
      type: TransactionType.expense,
      accountId: 'acc1',
      originalCurrency: 'EUR',
      createdAt: _now,
      modifiedAt: _now,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTransaction());
    registerFallbackValue(FakeAutomaticTransaction());
  });

  group('EvaluateAutomaticTransactionsUseCase', () {
    late MockAutomaticTransactionRepository automaticRepo;
    late MockTransactionRepository transactionRepo;
    late MockAccountRepository accountRepo;
    late MockProfileRepository profileRepo;
    late MockExchangeRateRepository exchangeRateRepo;
    late EvaluateAutomaticTransactionsUseCase useCase;

    setUp(() {
      automaticRepo = MockAutomaticTransactionRepository();
      transactionRepo = MockTransactionRepository();
      accountRepo = MockAccountRepository();
      profileRepo = MockProfileRepository();
      exchangeRateRepo = MockExchangeRateRepository();

      useCase = EvaluateAutomaticTransactionsUseCase(
        automaticRepo,
        transactionRepo,
        accountRepo,
        profileRepo,
        exchangeRateRepo,
      );

      // Default stubs — override per-test as needed.
      when(
        () => exchangeRateRepo.getLocalRates(
          baseCurrency: any(named: 'baseCurrency'),
        ),
      ).thenAnswer((_) async => null);
    });

    // ── Skipping inactive / deleted ──────────────────────────────────────────
    test('skips deleted automatic transactions', () async {
      final deletedTxn = _buildAutoTxn().copyWith(
        isDeleted: true,
        deletedAt: _now,
      );
      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [deletedTxn]);

      await useCase.execute();

      verifyNever(() => transactionRepo.createTransaction(any()));
    });

    test('skips inactive automatic transactions', () async {
      final inactiveTxn = _buildAutoTxn().copyWith(isActive: false);
      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [inactiveTxn]);

      await useCase.execute();

      verifyNever(() => transactionRepo.createTransaction(any()));
    });

    test('skips transactions not yet due', () async {
      final futureTxn = _buildAutoTxn(
        nextExecutionDate: _now.add(const Duration(days: 1)),
      );
      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [futureTxn]);

      await useCase.execute();

      verifyNever(() => transactionRepo.createTransaction(any()));
    });

    // ── intervalDays — creates transaction and advances date ─────────────────
    test('creates transaction and advances nextExecutionDate for intervalDays',
        () async {
      final past = _now.subtract(const Duration(days: 1));
      final autoTxn = _buildAutoTxn(
        recurrenceType: RecurrenceType.intervalDays,
        recurrenceDays: 30,
        nextExecutionDate: past,
      );
      final account = _buildAccount();
      final profile = _buildProfile();

      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);
      when(() => accountRepo.getAccountById('acc1'))
          .thenAnswer((_) async => account);
      when(() => profileRepo.getProfileById('user1'))
          .thenAnswer((_) async => profile);
      when(() => transactionRepo.createTransaction(any()))
          .thenAnswer((_) async => _dummyTxn());
      when(() => automaticRepo.updateAutomaticTransaction(any()))
          .thenAnswer((_) async => autoTxn);

      await useCase.execute();

      verify(() => transactionRepo.createTransaction(any())).called(1);

      final captured =
          verify(() => automaticRepo.updateAutomaticTransaction(captureAny()))
              .captured;
      final updated = captured.first as AutomaticTransaction;
      expect(
        updated.nextExecutionDate,
        equals(past.add(const Duration(days: 30))),
      );
    });

    // ── specificDayOfMonth — month-end clamping ──────────────────────────────
    test(
        'advances nextExecutionDate correctly for specificDayOfMonth '
        '(Jan 31 → Feb 28 in non-leap year)', () async {
      final jan31 = DateTime(2026, 1, 31);
      final autoTxn = _buildAutoTxn(
        recurrenceType: RecurrenceType.specificDayOfMonth,
        recurrenceDays: 31,
        nextExecutionDate: jan31,
      );
      final account = _buildAccount();
      final profile = _buildProfile();

      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);
      when(() => accountRepo.getAccountById('acc1'))
          .thenAnswer((_) async => account);
      when(() => profileRepo.getProfileById('user1'))
          .thenAnswer((_) async => profile);
      when(() => transactionRepo.createTransaction(any()))
          .thenAnswer((_) async => _dummyTxn());
      when(() => automaticRepo.updateAutomaticTransaction(any()))
          .thenAnswer((_) async => autoTxn);

      await useCase.execute();

      final captured =
          verify(() => automaticRepo.updateAutomaticTransaction(captureAny()))
              .captured;
      final updated = captured.first as AutomaticTransaction;
      expect(updated.nextExecutionDate.month, 2);
      expect(updated.nextExecutionDate.day, 28);
      expect(updated.nextExecutionDate.year, 2026);
    });

    // ── weekly ────────────────────────────────────────────────────────────────
    test('advances nextExecutionDate by exactly 7 days for weekly', () async {
      final past = _now.subtract(const Duration(hours: 2));
      final autoTxn = _buildAutoTxn(
        recurrenceType: RecurrenceType.weekly,
        nextExecutionDate: past,
      );
      final account = _buildAccount();
      final profile = _buildProfile();

      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);
      when(() => accountRepo.getAccountById('acc1'))
          .thenAnswer((_) async => account);
      when(() => profileRepo.getProfileById('user1'))
          .thenAnswer((_) async => profile);
      when(() => transactionRepo.createTransaction(any()))
          .thenAnswer((_) async => _dummyTxn());
      when(() => automaticRepo.updateAutomaticTransaction(any()))
          .thenAnswer((_) async => autoTxn);

      await useCase.execute();

      final captured =
          verify(() => automaticRepo.updateAutomaticTransaction(captureAny()))
              .captured;
      final updated = captured.first as AutomaticTransaction;
      expect(
        updated.nextExecutionDate,
        equals(past.add(const Duration(days: 7))),
      );
    });

    // ── monthly ───────────────────────────────────────────────────────────────
    test('advances nextExecutionDate by one calendar month for monthly',
        () async {
      final mar15 = DateTime(2026, 3, 15, 9, 0, 0);
      final autoTxn = _buildAutoTxn(
        recurrenceType: RecurrenceType.monthly,
        nextExecutionDate: mar15,
      );
      final account = _buildAccount();
      final profile = _buildProfile();

      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);
      when(() => accountRepo.getAccountById('acc1'))
          .thenAnswer((_) async => account);
      when(() => profileRepo.getProfileById('user1'))
          .thenAnswer((_) async => profile);
      when(() => transactionRepo.createTransaction(any()))
          .thenAnswer((_) async => _dummyTxn());
      when(() => automaticRepo.updateAutomaticTransaction(any()))
          .thenAnswer((_) async => autoTxn);

      await useCase.execute();

      final captured =
          verify(() => automaticRepo.updateAutomaticTransaction(captureAny()))
              .captured;
      final updated = captured.first as AutomaticTransaction;
      expect(updated.nextExecutionDate.year, 2026);
      expect(updated.nextExecutionDate.month, 4);
      expect(updated.nextExecutionDate.day, 15);
    });

    // ── yearly ────────────────────────────────────────────────────────────────
    test('advances nextExecutionDate by one calendar year for yearly',
        () async {
      final jun15 = DateTime(2026, 6, 15, 9, 0, 0);
      final autoTxn = _buildAutoTxn(
        recurrenceType: RecurrenceType.yearly,
        nextExecutionDate: jun15,
      );
      final account = _buildAccount();
      final profile = _buildProfile();

      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);
      when(() => accountRepo.getAccountById('acc1'))
          .thenAnswer((_) async => account);
      when(() => profileRepo.getProfileById('user1'))
          .thenAnswer((_) async => profile);
      when(() => transactionRepo.createTransaction(any()))
          .thenAnswer((_) async => _dummyTxn());
      when(() => automaticRepo.updateAutomaticTransaction(any()))
          .thenAnswer((_) async => autoTxn);

      await useCase.execute();

      final captured =
          verify(() => automaticRepo.updateAutomaticTransaction(captureAny()))
              .captured;
      final updated = captured.first as AutomaticTransaction;
      expect(updated.nextExecutionDate.year, 2027);
      expect(updated.nextExecutionDate.month, 6);
      expect(updated.nextExecutionDate.day, 15);
    });

    // ── Currency: same currency — no conversion ──────────────────────────────
    test(
        'creates transaction with correct originalCurrency from autoTxn; '
        'no conversion when currencies match', () async {
      final autoTxn = _buildAutoTxn(currency: 'EUR');
      final account = _buildAccount(currency: 'EUR');
      final profile = _buildProfile(defaultCurrency: 'EUR');

      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);
      when(() => accountRepo.getAccountById('acc1'))
          .thenAnswer((_) async => account);
      when(() => profileRepo.getProfileById('user1'))
          .thenAnswer((_) async => profile);
      when(() => automaticRepo.updateAutomaticTransaction(any()))
          .thenAnswer((_) async => autoTxn);

      Transaction? createdTxn;
      when(() => transactionRepo.createTransaction(any()))
          .thenAnswer((inv) async {
        createdTxn = inv.positionalArguments[0] as Transaction;
        return createdTxn!;
      });

      await useCase.execute();

      expect(createdTxn, isNotNull);
      expect(createdTxn!.originalCurrency, 'EUR');
      expect(createdTxn!.convertedAmount, isNull);
      expect(createdTxn!.exchangeRate, isNull);
    });

    // ── Currency: USD autoTxn, EUR profile — conversion applied ─────────────
    test(
        'applies currency conversion when autoTxn.currency differs '
        'from profile.defaultCurrency — uses local rates first', () async {
      final autoTxn = _buildAutoTxn(currency: 'USD');
      final account = _buildAccount(currency: 'USD');
      final profile = _buildProfile(defaultCurrency: 'EUR');
      final localRates = _buildRates(base: 'EUR'); // USD rate = 1.08

      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);
      when(() => accountRepo.getAccountById('acc1'))
          .thenAnswer((_) async => account);
      when(() => profileRepo.getProfileById('user1'))
          .thenAnswer((_) async => profile);
      when(
        () => exchangeRateRepo.getLocalRates(baseCurrency: 'EUR'),
      ).thenAnswer((_) async => localRates);
      when(() => automaticRepo.updateAutomaticTransaction(any()))
          .thenAnswer((_) async => autoTxn);

      Transaction? createdTxn;
      when(() => transactionRepo.createTransaction(any()))
          .thenAnswer((inv) async {
        createdTxn = inv.positionalArguments[0] as Transaction;
        return createdTxn!;
      });

      await useCase.execute();

      expect(createdTxn, isNotNull);
      expect(createdTxn!.originalCurrency, 'USD');
      expect(createdTxn!.exchangeRate, 1.08);
      // 1000 cents / 1.08 = 926 cents
      expect(createdTxn!.convertedAmount, (1000 / 1.08).round());

      // Remote rates should NOT be called when local rates are sufficient.
      verifyNever(
        () => exchangeRateRepo.getLatestRates(
          baseCurrency: any(named: 'baseCurrency'),
        ),
      );
    });

    // ── Currency: falls back to remote when local rates unavailable ──────────
    test(
        'falls back to remote rates when local rates unavailable and '
        'conversion is needed', () async {
      final autoTxn = _buildAutoTxn(currency: 'GBP');
      final account = _buildAccount(currency: 'GBP');
      final profile = _buildProfile(defaultCurrency: 'EUR');
      final remoteRates = _buildRates(base: 'EUR'); // GBP rate = 0.85

      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);
      when(() => accountRepo.getAccountById('acc1'))
          .thenAnswer((_) async => account);
      when(() => profileRepo.getProfileById('user1'))
          .thenAnswer((_) async => profile);
      // Local rates return null → trigger remote fallback.
      when(
        () => exchangeRateRepo.getLocalRates(baseCurrency: 'EUR'),
      ).thenAnswer((_) async => null);
      when(
        () => exchangeRateRepo.getLatestRates(baseCurrency: 'EUR'),
      ).thenAnswer((_) async => remoteRates);
      when(() => automaticRepo.updateAutomaticTransaction(any()))
          .thenAnswer((_) async => autoTxn);

      Transaction? createdTxn;
      when(() => transactionRepo.createTransaction(any()))
          .thenAnswer((inv) async {
        createdTxn = inv.positionalArguments[0] as Transaction;
        return createdTxn!;
      });

      await useCase.execute();

      expect(createdTxn, isNotNull);
      expect(createdTxn!.originalCurrency, 'GBP');
      expect(createdTxn!.exchangeRate, 0.85);
      expect(createdTxn!.convertedAmount, (1000 / 0.85).round());

      verify(
        () => exchangeRateRepo.getLatestRates(baseCurrency: 'EUR'),
      ).called(1);
    });

    // ── nextExecutionDate advances from stored date, not from `now` ──────────
    test(
        'nextExecutionDate is computed from the stored nextExecutionDate, '
        'not from the current time (calendar alignment)', () async {
      // The stored date is Mar 15. Even though `now` is different, the next
      // date for a `monthly` transaction should be Apr 15, not "one month
      // from now".
      final mar15 = DateTime(2026, 3, 15, 9, 0, 0);
      final autoTxn = _buildAutoTxn(
        recurrenceType: RecurrenceType.monthly,
        nextExecutionDate: mar15,
      );
      final account = _buildAccount();
      final profile = _buildProfile();

      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);
      when(() => accountRepo.getAccountById('acc1'))
          .thenAnswer((_) async => account);
      when(() => profileRepo.getProfileById('user1'))
          .thenAnswer((_) async => profile);
      when(() => transactionRepo.createTransaction(any()))
          .thenAnswer((_) async => _dummyTxn());
      when(() => automaticRepo.updateAutomaticTransaction(any()))
          .thenAnswer((_) async => autoTxn);

      await useCase.execute();

      final captured =
          verify(() => automaticRepo.updateAutomaticTransaction(captureAny()))
              .captured;
      final updated = captured.first as AutomaticTransaction;

      // Must be Apr 15, not "today + 1 month".
      expect(updated.nextExecutionDate.year, 2026);
      expect(updated.nextExecutionDate.month, 4);
      expect(updated.nextExecutionDate.day, 15);
    });

    // ── Graceful degradation when account/profile not found ──────────────────
    test(
        'still creates transaction with autoTxn.currency even when account '
        'is not found (no conversion applied)', () async {
      final autoTxn = _buildAutoTxn(currency: 'USD');

      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);
      // Account not found → conversion falls back to no-op.
      when(() => accountRepo.getAccountById('acc1'))
          .thenAnswer((_) async => null);
      when(() => automaticRepo.updateAutomaticTransaction(any()))
          .thenAnswer((_) async => autoTxn);

      Transaction? createdTxn;
      when(() => transactionRepo.createTransaction(any()))
          .thenAnswer((inv) async {
        createdTxn = inv.positionalArguments[0] as Transaction;
        return createdTxn!;
      });

      await useCase.execute();

      expect(createdTxn, isNotNull);
      // Original currency must come from the automatic transaction, never hardcoded.
      expect(createdTxn!.originalCurrency, 'USD');
      // No conversion possible without profile.
      expect(createdTxn!.convertedAmount, isNull);
    });

    // ── Exchange rate snapshot is attached when rates are available ──────────
    test('attaches exchangeRateSnapshot when local rates are available',
        () async {
      final autoTxn = _buildAutoTxn(currency: 'EUR');
      final account = _buildAccount(currency: 'EUR');
      final profile = _buildProfile(defaultCurrency: 'EUR');
      final localRates = _buildRates(base: 'EUR');

      when(() => automaticRepo.getAllAutomaticTransactions())
          .thenAnswer((_) async => [autoTxn]);
      when(() => accountRepo.getAccountById('acc1'))
          .thenAnswer((_) async => account);
      when(() => profileRepo.getProfileById('user1'))
          .thenAnswer((_) async => profile);
      when(
        () => exchangeRateRepo.getLocalRates(baseCurrency: 'EUR'),
      ).thenAnswer((_) async => localRates);
      when(() => automaticRepo.updateAutomaticTransaction(any()))
          .thenAnswer((_) async => autoTxn);

      Transaction? createdTxn;
      when(() => transactionRepo.createTransaction(any()))
          .thenAnswer((inv) async {
        createdTxn = inv.positionalArguments[0] as Transaction;
        return createdTxn!;
      });

      await useCase.execute();

      expect(createdTxn!.exchangeRateSnapshot, isNotNull);
    });
  });
}
