import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/repositories/i_statistics_repository.dart';
import 'package:stalvi/domain/use_cases/statistics/get_period_summary_use_case.dart';

class MockStatisticsRepository extends Mock implements IStatisticsRepository {}

void main() {
  late GetPeriodSummaryUseCase useCase;
  late MockStatisticsRepository mockRepository;

  setUp(() {
    mockRepository = MockStatisticsRepository();
    useCase = GetPeriodSummaryUseCase(mockRepository);
  });

  test('should return PeriodSummary from the repository', () async {
    // Arrange
    final startDate = DateTime(2023, 1, 1);
    final endDate = DateTime(2023, 1, 31);
    const expectedSummary =
        PeriodSummary(totalIncome: 150000, totalExpense: 50000);

    when(
      () => mockRepository.getPeriodSummary(
        startDate: startDate,
        endDate: endDate,
        targetCurrency: 'EUR',
      ),
    ).thenAnswer((_) async => expectedSummary);

    // Act
    final result = await useCase.execute(
      startDate: startDate,
      endDate: endDate,
      targetCurrency: 'EUR',
    );

    // Assert
    expect(result, expectedSummary);
    verify(
      () => mockRepository.getPeriodSummary(
        startDate: startDate,
        endDate: endDate,
        targetCurrency: 'EUR',
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
