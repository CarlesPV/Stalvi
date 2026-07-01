import '../database/daos/statistics_dao.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart'
    show TransactionType;
import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/repositories/i_statistics_repository.dart';

class StatisticsRepositoryImpl implements IStatisticsRepository {
  final StatisticsDao _dao;

  StatisticsRepositoryImpl(
    this._dao,
  );

  @override
  Future<PeriodSummary> getPeriodSummary({
    DateTime? startDate,
    DateTime? endDate,
    required String targetCurrency,
    String? accountId,
  }) async {
    return _dao.getPeriodSummaryAggregates(
      startDate: startDate,
      endDate: endDate,
      targetCurrency: targetCurrency,
      accountId: accountId,
    );
  }

  @override
  Future<List<CategoryStatistic>> getTopCategories({
    required DateTime startDate,
    required DateTime endDate,
    required String targetCurrency,
    TransactionType type = TransactionType.expense,
    String? accountId,
  }) async {
    return _dao.getTopCategoriesAggregates(
      startDate,
      endDate,
      targetCurrency,
      type: type,
      accountId: accountId,
    );
  }
}
