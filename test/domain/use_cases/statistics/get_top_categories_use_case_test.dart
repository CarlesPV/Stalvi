import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:konta/data/database/tables/transaction_table.dart';
import 'package:konta/domain/entities/category_statistic.dart';
import 'package:konta/domain/repositories/i_statistics_repository.dart';
import 'package:konta/domain/use_cases/statistics/get_top_categories_use_case.dart';

class MockStatisticsRepository extends Mock implements IStatisticsRepository {}

void main() {
  late GetTopCategoriesUseCase useCase;
  late MockStatisticsRepository mockRepository;

  setUp(() {
    mockRepository = MockStatisticsRepository();
    useCase = GetTopCategoriesUseCase(mockRepository);
  });

  test('should return a list of CategoryStatistic from the repository',
      () async {
    // Arrange
    final startDate = DateTime(2023, 1, 1);
    final endDate = DateTime(2023, 1, 31);
    final expectedCategories = [
      const CategoryStatistic(
        categoryId: 'cat1',
        categoryName: 'Food',
        categoryIcon: 'food_icon',
        categoryColor: '#FF0000',
        totalAmount: 15000,
      ),
    ];

    when(() => mockRepository.getTopCategories(
          startDate: startDate,
          endDate: endDate,
          type: TransactionType.expense,
        ),).thenAnswer((_) async => expectedCategories);

    // Act
    final result = await useCase.execute(
      startDate: startDate,
      endDate: endDate,
      type: TransactionType.expense,
    );

    // Assert
    expect(result, expectedCategories);
    verify(() => mockRepository.getTopCategories(
          startDate: startDate,
          endDate: endDate,
          type: TransactionType.expense,
        ),).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
