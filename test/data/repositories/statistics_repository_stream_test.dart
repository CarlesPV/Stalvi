import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/data/database/daos/statistics_dao.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart' as db_table;
import 'package:stalvi/data/repositories/statistics_repository_impl.dart';
import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/entities/transaction_type.dart' as domain;

class MockStatisticsDao extends Mock implements StatisticsDao {}

void main() {
  late MockStatisticsDao mockDao;
  late StatisticsRepositoryImpl repo;

  setUp(() {
    mockDao = MockStatisticsDao();
    repo = StatisticsRepositoryImpl(mockDao);
  });

  group('StatisticsRepositoryImpl — watchPeriodSummary', () {
    test('emits PeriodSummary from DAO stream', () async {
      const summary = PeriodSummary(totalIncome: 500, totalExpense: 200);
      when(
        () => mockDao.watchPeriodSummaryAggregates(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          targetCurrency: any(named: 'targetCurrency'),
          accountId: any(named: 'accountId'),
        ),
      ).thenAnswer((_) => Stream.value(summary));

      final result = await repo.watchPeriodSummary(targetCurrency: 'EUR').first;

      expect(result.totalIncome, 500);
      expect(result.totalExpense, 200);
    });

    test('forwards multiple emissions from DAO stream', () async {
      const summary1 = PeriodSummary(totalIncome: 100, totalExpense: 50);
      const summary2 = PeriodSummary(totalIncome: 300, totalExpense: 150);

      when(
        () => mockDao.watchPeriodSummaryAggregates(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          targetCurrency: any(named: 'targetCurrency'),
          accountId: any(named: 'accountId'),
        ),
      ).thenAnswer((_) => Stream.fromIterable([summary1, summary2]));

      final results =
          await repo.watchPeriodSummary(targetCurrency: 'USD').toList();

      expect(results.length, 2);
      expect(results[0].totalIncome, 100);
      expect(results[1].totalIncome, 300);
    });

    test('passes accountId filter to DAO', () async {
      const summary = PeriodSummary(totalIncome: 0, totalExpense: 0);
      when(
        () => mockDao.watchPeriodSummaryAggregates(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          targetCurrency: 'EUR',
          accountId: 'acc-42',
        ),
      ).thenAnswer((_) => Stream.value(summary));

      await repo
          .watchPeriodSummary(targetCurrency: 'EUR', accountId: 'acc-42')
          .first;

      verify(
        () => mockDao.watchPeriodSummaryAggregates(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          targetCurrency: 'EUR',
          accountId: 'acc-42',
        ),
      ).called(1);
    });
  });

  group('StatisticsRepositoryImpl — watchTopCategories', () {
    final start = DateTime(2024, 1, 1);
    final end = DateTime(2024, 1, 31);

    test('emits category list from DAO stream', () async {
      final categories = [
        const CategoryStatistic(
          categoryId: 'cat1',
          categoryName: 'Food',
          categoryIcon: 'food_icon',
          categoryColor: '#FF0000',
          totalAmount: 120,
        ),
      ];

      when(
        () => mockDao.watchTopCategoriesAggregates(
          start,
          end,
          'EUR',
          type: db_table.TransactionType.expense,
          accountId: any(named: 'accountId'),
        ),
      ).thenAnswer((_) => Stream.value(categories));

      final result = await repo
          .watchTopCategories(
            startDate: start,
            endDate: end,
            targetCurrency: 'EUR',
          )
          .first;

      expect(result.length, 1);
      expect(result.first.categoryName, 'Food');
      expect(result.first.totalAmount, 120);
    });

    test('passes income type to DAO', () async {
      when(
        () => mockDao.watchTopCategoriesAggregates(
          start,
          end,
          'EUR',
          type: db_table.TransactionType.income,
          accountId: any(named: 'accountId'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      await repo
          .watchTopCategories(
            startDate: start,
            endDate: end,
            targetCurrency: 'EUR',
            type: domain.TransactionType.income,
          )
          .first;

      verify(
        () => mockDao.watchTopCategoriesAggregates(
          start,
          end,
          'EUR',
          type: db_table.TransactionType.income,
          accountId: any(named: 'accountId'),
        ),
      ).called(1);
    });

    test('emits empty list when no categories exist', () async {
      when(
        () => mockDao.watchTopCategoriesAggregates(
          start,
          end,
          'EUR',
          type: db_table.TransactionType.expense,
          accountId: any(named: 'accountId'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      final result = await repo
          .watchTopCategories(
            startDate: start,
            endDate: end,
            targetCurrency: 'EUR',
          )
          .first;

      expect(result, isEmpty);
    });
  });
}
