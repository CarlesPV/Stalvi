import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/use_cases/statistics/get_period_summary_use_case.dart';

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockExchangeRateRepository extends Mock
    implements IExchangeRateRepository {}

class FakeTransactionQueryFilter extends Fake
    implements TransactionQueryFilter {}

void main() {
  late GetPeriodSummaryUseCase useCase;
  late MockTransactionRepository mockTransactionRepository;
  late MockExchangeRateRepository mockExchangeRateRepository;

  setUpAll(() {
    registerFallbackValue(FakeTransactionQueryFilter());
  });

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    mockExchangeRateRepository = MockExchangeRateRepository();
    useCase = GetPeriodSummaryUseCase(
      mockTransactionRepository,
      mockExchangeRateRepository,
    );
  });

  test(
    'should calculate correct PeriodSummary given transactions in USD, EUR, GBP to JPY',
    () async {
      // Arrange
      final startDate = DateTime(2023, 1, 1);
      final endDate = DateTime(2023, 1, 31);

      // Transactions:
      // 1. 100 USD Income
      // 2. 50 EUR Expense
      // 3. 20 GBP Income
      final transactions = [
        Transaction(
          id: '1',
          amount: 10000, // 100.00
          date: startDate,
          type: TransactionType.income,
          accountId: 'a1',
          originalCurrency: 'USD',
          createdAt: startDate,
          modifiedAt: startDate,
        ),
        Transaction(
          id: '2',
          amount: 5000, // 50.00
          date: startDate,
          type: TransactionType.expense,
          accountId: 'a1',
          originalCurrency: 'EUR',
          createdAt: startDate,
          modifiedAt: startDate,
        ),
        Transaction(
          id: '3',
          amount: 2000, // 20.00
          date: startDate,
          type: TransactionType.income,
          accountId: 'a1',
          originalCurrency: 'GBP',
          createdAt: startDate,
          modifiedAt: startDate,
        ),
      ];

      when(
        () => mockTransactionRepository.watchFilteredTransactions(any()),
      ).thenAnswer((_) => Stream.value(transactions));

      // Rates base=JPY
      // Let's say:
      // 1 JPY = 0.0067 USD -> 1 USD = 150 JPY => rate is 0.006666
      // 1 JPY = 0.0062 EUR -> 1 EUR = 160 JPY => rate is 0.00625
      // 1 JPY = 0.0053 GBP -> 1 GBP = 190 JPY => rate is 0.005263
      final ratesMap = {'USD': 0.00666666, 'EUR': 0.00625, 'GBP': 0.00526315};

      when(
        () => mockExchangeRateRepository.getLocalRates(baseCurrency: 'JPY'),
      ).thenAnswer(
        (_) async => ExchangeRate(
          baseCurrency: 'JPY',
          date: DateTime.now(),
          rates: ratesMap,
        ),
      );

      // Act
      final result = await useCase.execute(
        startDate: startDate,
        endDate: endDate,
        targetCurrency: 'JPY',
      );

      // Assert
      // Income: 100 USD = 100 / 0.00666666 = 15000 JPY (cents: 1500001.5 -> 1500002 roughly)
      // Income: 20 GBP = 20 / 0.00526315 = 3800 JPY (cents: 380000.5)
      // Total Income = 1880002 cents

      // Expense: 50 EUR = 50 / 0.00625 = 8000 JPY (cents: 800000)

      expect(result.totalIncome, 1880002);
      expect(result.totalExpense, 800000);
    },
  );
}
