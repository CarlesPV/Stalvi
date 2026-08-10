import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/budget.dart';
import 'package:stalvi/domain/entities/savings_goal.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';
import 'package:stalvi/domain/repositories/i_budget_repository.dart';
import 'package:stalvi/domain/repositories/i_savings_goal_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/services/financial_threshold_service.dart';

class MockBudgetRepository extends Mock implements IBudgetRepository {}

class MockSavingsGoalRepository extends Mock
    implements ISavingsGoalRepository {}

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockExchangeRateRepository extends Mock
    implements IExchangeRateRepository {}

class FakeTransactionQueryFilter extends Fake
    implements TransactionQueryFilter {}

void main() {
  late MockBudgetRepository mockBudgetRepo;
  late MockSavingsGoalRepository mockSavingsGoalRepo;
  late MockTransactionRepository mockTransactionRepo;
  late MockAccountRepository mockAccountRepo;
  late MockExchangeRateRepository mockExchangeRateRepo;
  late FinancialThresholdService service;

  setUpAll(() {
    registerFallbackValue(FakeTransactionQueryFilter());
  });

  setUp(() {
    mockBudgetRepo = MockBudgetRepository();
    mockSavingsGoalRepo = MockSavingsGoalRepository();
    mockTransactionRepo = MockTransactionRepository();
    mockAccountRepo = MockAccountRepository();
    mockExchangeRateRepo = MockExchangeRateRepository();

    service = FinancialThresholdService(
      mockBudgetRepo,
      mockSavingsGoalRepo,
      mockTransactionRepo,
      mockAccountRepo,
      mockExchangeRateRepo,
    );
  });

  final now = DateTime.now();

  final defaultBudget = Budget(
    id: 'b1',
    accountId: 'a1',
    categoryId: 'c1',
    targetAmount: 5000, // 50.00
    startDate: now.subtract(const Duration(days: 1)),
    endDate: now.add(const Duration(days: 30)),
    createdAt: now,
    modifiedAt: now,
  );

  final defaultAccount = Account(
    id: 'a1',
    name: 'Main',
    type: AccountType.bank,
    currency: 'USD',
    initialBalance: 0,
    userId: 'u1',
    color: '#000000',
    icon: 'icon',
    isDefault: true,
    isDeleted: false,
    createdAt: now,
    modifiedAt: now,
  );

  final defaultGoal = SavingsGoal(
    id: 'g1',
    name: 'Vacation',
    targetAmount: 10000, // 100.00
    color: '#000000',
    icon: 'icon',
    createdAt: now,
    modifiedAt: now,
    currency: 'USD',
  );

  group('FinancialThresholdService', () {
    test('returns empty if no transactions', () async {
      final result = await service.evaluateThresholds([]);
      expect(result, isEmpty);
    });

    test('budget threshold exceeded', () async {
      when(
        () => mockBudgetRepo.getBudgetsByCategoryId('c1'),
      ).thenAnswer((_) async => [defaultBudget]);

      when(
        () => mockTransactionRepo.watchFilteredTransactions(any()),
      ).thenAnswer(
        (_) => Stream.value([
          Transaction(
            id: 't1',
            amount: 6000,
            date: now,
            type: TransactionType.expense,
            accountId: 'a1',
            categoryId: 'c1',
            originalCurrency: 'USD',
            createdAt: now,
            modifiedAt: now,
          ),
        ]),
      );

      when(
        () => mockAccountRepo.getAccountById('a1'),
      ).thenAnswer((_) async => defaultAccount);

      when(
        () => mockExchangeRateRepo.getLocalRates(baseCurrency: 'USD'),
      ).thenAnswer(
        (_) async =>
            ExchangeRate(baseCurrency: 'USD', date: now, rates: {'EUR': 0.85}),
      );

      final triggerTx = Transaction(
        id: 't_trigger',
        amount: 6000,
        date: now,
        type: TransactionType.expense,
        accountId: 'a1',
        categoryId: 'c1',
        originalCurrency: 'USD',
        createdAt: now,
        modifiedAt: now,
      );

      final result = await service.evaluateThresholds([triggerTx]);

      expect(result.length, 1);
      expect(result.first.isBudgetExceeded, true);
      expect(result.first.budget?.id, 'b1');
    });

    test('budget threshold not exceeded', () async {
      when(
        () => mockBudgetRepo.getBudgetsByCategoryId('c1'),
      ).thenAnswer((_) async => [defaultBudget]); // Target 5000

      when(
        () => mockTransactionRepo.watchFilteredTransactions(any()),
      ).thenAnswer(
        (_) => Stream.value([
          Transaction(
            id: 't1',
            amount: 2000, // less than 5000
            date: now,
            type: TransactionType.expense,
            accountId: 'a1',
            categoryId: 'c1',
            originalCurrency: 'USD',
            createdAt: now,
            modifiedAt: now,
          ),
        ]),
      );

      when(
        () => mockAccountRepo.getAccountById('a1'),
      ).thenAnswer((_) async => defaultAccount);

      when(
        () => mockExchangeRateRepo.getLocalRates(baseCurrency: 'USD'),
      ).thenAnswer(
        (_) async =>
            ExchangeRate(baseCurrency: 'USD', date: now, rates: {'EUR': 0.85}),
      );

      final triggerTx = Transaction(
        id: 't_trigger',
        amount: 2000,
        date: now,
        type: TransactionType.expense,
        accountId: 'a1',
        categoryId: 'c1',
        originalCurrency: 'USD',
        createdAt: now,
        modifiedAt: now,
      );

      final result = await service.evaluateThresholds([triggerTx]);
      expect(result, isEmpty);
    });

    test('savings goal threshold reached', () async {
      when(
        () => mockSavingsGoalRepo.getSavingsGoalById('g1'),
      ).thenAnswer((_) async => defaultGoal); // Target 10000

      when(() => mockTransactionRepo.watchRawTransactions()).thenAnswer(
        (_) => Stream.value([
          Transaction(
            id: 't1',
            amount: 10000, // Reaches target
            date: now,
            type: TransactionType.transfer,
            accountId: 'a1',
            savingsGoalId: 'g1',
            originalCurrency: 'USD',
            createdAt: now,
            modifiedAt: now,
          ),
        ]),
      );

      when(
        () => mockExchangeRateRepo.getLocalRates(baseCurrency: 'USD'),
      ).thenAnswer(
        (_) async =>
            ExchangeRate(baseCurrency: 'USD', date: now, rates: {'EUR': 0.85}),
      );

      final triggerTx = Transaction(
        id: 't_trigger',
        amount: 10000,
        date: now,
        type: TransactionType.transfer,
        accountId: 'a1',
        savingsGoalId: 'g1',
        originalCurrency: 'USD',
        createdAt: now,
        modifiedAt: now,
      );

      final result = await service.evaluateThresholds([triggerTx]);

      expect(result.length, 1);
      expect(result.first.isSavingsGoalReached, true);
      expect(result.first.savingsGoal?.id, 'g1');
    });

    test('savings goal threshold not reached', () async {
      when(
        () => mockSavingsGoalRepo.getSavingsGoalById('g1'),
      ).thenAnswer((_) async => defaultGoal); // Target 10000

      when(() => mockTransactionRepo.watchRawTransactions()).thenAnswer(
        (_) => Stream.value([
          Transaction(
            id: 't1',
            amount: 5000, // Below target
            date: now,
            type: TransactionType.transfer,
            accountId: 'a1',
            savingsGoalId: 'g1',
            originalCurrency: 'USD',
            createdAt: now,
            modifiedAt: now,
          ),
        ]),
      );

      when(
        () => mockExchangeRateRepo.getLocalRates(baseCurrency: 'USD'),
      ).thenAnswer(
        (_) async =>
            ExchangeRate(baseCurrency: 'USD', date: now, rates: {'EUR': 0.85}),
      );

      final triggerTx = Transaction(
        id: 't_trigger',
        amount: 5000,
        date: now,
        type: TransactionType.transfer,
        accountId: 'a1',
        savingsGoalId: 'g1',
        originalCurrency: 'USD',
        createdAt: now,
        modifiedAt: now,
      );

      final result = await service.evaluateThresholds([triggerTx]);
      expect(result, isEmpty);
    });
  });
}
