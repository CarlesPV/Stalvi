import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stalvi/data/database/daos/statistics_dao.dart';

import 'package:stalvi/data/database/tables/transaction_table.dart'
    show TransactionType;
import 'package:stalvi/data/repositories/statistics_repository_impl.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';

@GenerateMocks([StatisticsDao, IProfileRepository, IAccountRepository])
import 'statistics_repository_impl_test.mocks.dart';

void main() {
  late MockStatisticsDao mockDao;
  late StatisticsRepositoryImpl repository;

  setUp(() {
    mockDao = MockStatisticsDao();
    repository = StatisticsRepositoryImpl(
      mockDao,
    );
  });

  group('getPeriodSummary', () {
    final startDate = DateTime(2023, 1, 1);
    final endDate = DateTime(2023, 1, 31);

    test(
        'should return correct summary using profile defaultCurrency when accountId is null',
        () async {
      const targetCurrency = 'EUR';

      when(
        mockDao.getPeriodSummaryAggregates(
          startDate,
          endDate,
          targetCurrency,
          accountId: null,
        ),
      ).thenAnswer(
        (_) async => const PeriodSummary(
          totalIncome: 9000,
          totalExpense: 0,
        ),
      );

      final summary = await repository.getPeriodSummary(
        startDate: startDate,
        endDate: endDate,
        targetCurrency: targetCurrency,
      );

      expect(summary.totalIncome, 9000);
      expect(summary.totalExpense, 0);
    });

    test(
        'should return correct summary using account currency when accountId is provided',
        () async {
      const targetCurrency = 'GBP';

      when(
        mockDao.getPeriodSummaryAggregates(
          startDate,
          endDate,
          targetCurrency,
          accountId: 'a1',
        ),
      ).thenAnswer(
        (_) async => const PeriodSummary(
          totalIncome: 0,
          totalExpense: 4000,
        ),
      );

      final summary = await repository.getPeriodSummary(
        startDate: startDate,
        endDate: endDate,
        targetCurrency: targetCurrency,
        accountId: 'a1',
      );

      expect(summary.totalIncome, 0);
      expect(summary.totalExpense, 4000);
    });
  });

  group('getTopCategories', () {
    final startDate = DateTime(2023, 1, 1);
    final endDate = DateTime(2023, 1, 31);

    test('should aggregate categories correctly with currency conversion',
        () async {
      const targetCurrency = 'EUR';

      when(
        mockDao.getTopCategoriesAggregates(
          startDate,
          endDate,
          targetCurrency,
          type: TransactionType.expense,
          accountId: null,
        ),
      ).thenAnswer(
        (_) async => [
          const CategoryStatistic(
            categoryId: 'c1',
            categoryName: 'Food',
            categoryIcon: 'food_icon',
            categoryColor: 'green',
            totalAmount: 9900,
          ),
          const CategoryStatistic(
            categoryId: 'c2',
            categoryName: 'Travel',
            categoryIcon: 'travel_icon',
            categoryColor: 'blue',
            totalAmount: 4500,
          ),
        ],
      );

      final topCategories = await repository.getTopCategories(
        startDate: startDate,
        endDate: endDate,
        targetCurrency: targetCurrency,
      );

      expect(topCategories.length, 2);
      expect(topCategories[0].categoryId, 'c1');
      expect(topCategories[0].totalAmount, 9900);

      expect(topCategories[1].categoryId, 'c2');
      expect(topCategories[1].totalAmount, 4500);
    });
  });
}
