import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/use_cases/statistics/get_top_categories_use_case.dart';

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockCategoryRepository extends Mock implements ICategoryRepository {}

class MockExchangeRateRepository extends Mock
    implements IExchangeRateRepository {}

class FakeTransactionQueryFilter extends Fake
    implements TransactionQueryFilter {}

void main() {
  late GetTopCategoriesUseCase useCase;
  late MockTransactionRepository mockTransactionRepository;
  late MockCategoryRepository mockCategoryRepository;
  late MockExchangeRateRepository mockExchangeRateRepository;

  setUpAll(() {
    registerFallbackValue(FakeTransactionQueryFilter());
  });

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    mockCategoryRepository = MockCategoryRepository();
    mockExchangeRateRepository = MockExchangeRateRepository();
    useCase = GetTopCategoriesUseCase(
      mockTransactionRepository,
      mockCategoryRepository,
      mockExchangeRateRepository,
    );
  });

  test('should return a list of CategoryStatistic with converted currency',
      () async {
    // Arrange
    final startDate = DateTime(2023, 1, 1);
    final endDate = DateTime(2023, 1, 31);

    final transactions = [
      Transaction(
        id: '1',
        amount: 10000, // 100.00 USD
        date: startDate,
        type: TransactionType.expense,
        accountId: 'a1',
        categoryId: 'cat1',
        originalCurrency: 'USD',
        createdAt: startDate,
        modifiedAt: startDate,
      ),
      Transaction(
        id: '2',
        amount: 5000, // 50.00 EUR
        date: startDate,
        type: TransactionType.expense,
        accountId: 'a1',
        categoryId: 'cat1',
        originalCurrency: 'EUR',
        createdAt: startDate,
        modifiedAt: startDate,
      ),
    ];

    when(() => mockTransactionRepository.watchFilteredTransactions(any()))
        .thenAnswer((_) => Stream.value(transactions));

    final categories = [
      Category(
        id: 'cat1',
        name: 'Food',
        icon: 'food_icon',
        color: '#FF0000',
        createdAt: startDate,
        modifiedAt: startDate,
      )
    ];

    when(() => mockCategoryRepository.watchAllCategories())
        .thenAnswer((_) => Stream.value(categories));

    final ratesMap = {
      'USD': 0.00666666,
      'EUR': 0.00625,
    };

    when(() => mockExchangeRateRepository.getLocalRates(baseCurrency: 'JPY'))
        .thenAnswer((_) async => ExchangeRate(
              baseCurrency: 'JPY',
              date: DateTime.now(),
              rates: ratesMap,
            ));

    // Act
    final result = await useCase.execute(
      startDate: startDate,
      endDate: endDate,
      targetCurrency: 'JPY',
      type: TransactionType.expense,
    );

    // Assert
    // 100 USD = 100 / 0.00666666 = 15000 JPY (1500001.5 cents)
    // 50 EUR = 50 / 0.00625 = 8000 JPY (800000 cents)
    // Total for cat1 = 2300002 cents

    expect(result.length, 1);
    expect(result.first.categoryId, 'cat1');
    expect(result.first.totalAmount, 2300002);
  });
}
