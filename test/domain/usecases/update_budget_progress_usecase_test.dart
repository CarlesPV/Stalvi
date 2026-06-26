import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/budget.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_budget_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/usecases/update_budget_progress_usecase.dart';

class MockBudgetRepository extends Mock implements IBudgetRepository {}

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockExchangeRateRepository extends Mock
    implements IExchangeRateRepository {}

class FakeTransactionQueryFilter extends Fake
    implements TransactionQueryFilter {}

class FakeBudget extends Fake implements Budget {}

void main() {
  late MockBudgetRepository mockBudgetRepo;
  late MockTransactionRepository mockTransactionRepo;
  late MockAccountRepository mockAccountRepo;
  late MockExchangeRateRepository mockExchangeRateRepo;
  late UpdateBudgetProgressUseCase usecase;

  setUpAll(() {
    registerFallbackValue(FakeTransactionQueryFilter());
    registerFallbackValue(FakeBudget());
  });

  setUp(() {
    mockBudgetRepo = MockBudgetRepository();
    mockTransactionRepo = MockTransactionRepository();
    mockAccountRepo = MockAccountRepository();
    mockExchangeRateRepo = MockExchangeRateRepository();

    usecase = UpdateBudgetProgressUseCase(
      mockBudgetRepo,
      mockTransactionRepo,
      mockAccountRepo,
      mockExchangeRateRepo,
    );
  });

  final testBudget = Budget(
    id: 'b1',
    accountId: 'acc1',
    categoryId: 'cat1',
    targetAmount: 50000,
    currentAmount: 0,
    startDate: DateTime(2023, 1, 1),
    endDate: DateTime(2023, 1, 31),
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
  );

  final testAccount = Account(
    id: 'acc1',
    name: 'Test Account',
    type: AccountType.cash,
    currency: 'USD',
    color: '#000000',
    icon: 'wallet',
    initialBalance: 0,
    isDefault: false,
    isDeleted: false,
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
    userId: 'u1',
  );

  test('calculates budget progress with currency conversion', () async {
    when(() => mockBudgetRepo.getBudgetsByCategoryId('cat1'))
        .thenAnswer((_) async => [testBudget]);

    final tx1 = Transaction(
      id: 'tx1',
      amount: 1000, // 10 USD
      date: DateTime(2023, 1, 15),
      type: TransactionType.expense,
      accountId: 'acc1',
      categoryId: 'cat1',
      originalCurrency: 'USD',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );

    final tx2 = Transaction(
      id: 'tx2',
      amount: 2000, // 20 EUR
      date: DateTime(2023, 1, 16),
      type: TransactionType.expense,
      accountId: 'acc1',
      categoryId: 'cat1',
      originalCurrency: 'EUR',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );

    when(() => mockTransactionRepo.watchFilteredTransactions(any()))
        .thenAnswer((_) => Stream.value([tx1, tx2]));

    when(() => mockAccountRepo.getAccountById('acc1'))
        .thenAnswer((_) async => testAccount);

    when(() => mockExchangeRateRepo.getLocalRates(baseCurrency: 'USD'))
        .thenAnswer(
      (_) async => ExchangeRate(
        baseCurrency: 'USD',
        date: DateTime.now(),
        rates: {'EUR': 0.8}, // 1 USD = 0.8 EUR. 20 EUR = 25 USD
      ),
    );

    when(() => mockBudgetRepo.updateBudget(any())).thenAnswer((_) async {});

    await usecase.execute(categoryId: 'cat1');

    // Expected: tx1 (1000 USD) + tx2 (2000 EUR / 0.8 = 2500 USD) = 3500 USD
    verify(
      () => mockBudgetRepo.updateBudget(
        any(that: predicate<Budget>((b) => b.currentAmount == 3500)),
      ),
    ).called(1);
  });

  test('recalculates budget correctly when a transaction is deleted', () async {
    final currentBudget = testBudget.copyWith(currentAmount: 3500);
    when(() => mockBudgetRepo.getBudgetsByCategoryId('cat1'))
        .thenAnswer((_) async => [currentBudget]);

    final tx1 = Transaction(
      id: 'tx1',
      amount: 1000,
      date: DateTime(2023, 1, 15),
      type: TransactionType.expense,
      accountId: 'acc1',
      categoryId: 'cat1',
      originalCurrency: 'USD',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );

    // Simulate tx2 being deleted by having watchFilteredTransactions return only tx1
    when(() => mockTransactionRepo.watchFilteredTransactions(any()))
        .thenAnswer((_) => Stream.value([tx1]));

    when(() => mockAccountRepo.getAccountById('acc1'))
        .thenAnswer((_) async => testAccount);

    when(() => mockExchangeRateRepo.getLocalRates(baseCurrency: 'USD'))
        .thenAnswer(
      (_) async => ExchangeRate(
        baseCurrency: 'USD',
        date: DateTime.now(),
        rates: {'EUR': 0.8},
      ),
    );

    when(() => mockBudgetRepo.updateBudget(any())).thenAnswer((_) async {});

    await usecase.execute(categoryId: 'cat1');

    // Expected: Only tx1 remains (1000 USD)
    verify(
      () => mockBudgetRepo.updateBudget(
        any(that: predicate<Budget>((b) => b.currentAmount == 1000)),
      ),
    ).called(1);
  });
}
