import 'package:stalvi/data/database/daos/statistics_dao.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart';
import 'package:stalvi/data/mappers/statistics_mapper.dart';
import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/repositories/i_statistics_repository.dart';

class StatisticsRepositoryImpl implements IStatisticsRepository {
  final StatisticsDao _dao;

  StatisticsRepositoryImpl(this._dao);

  @override
  Future<PeriodSummary> getPeriodSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final (income, expense) = await _dao.getPeriodSummary(startDate, endDate);
    return PeriodSummary(
      totalIncome: income,
      totalExpense: expense,
    );
  }

  @override
  Future<List<CategoryStatistic>> getTopCategories({
    required DateTime startDate,
    required DateTime endDate,
    TransactionType type = TransactionType.expense,
  }) async {
    final results = await _dao.getTopCategories(
      startDate,
      endDate,
      type: type,
    );
    return results.map((r) => r.toDomain()).toList();
  }
}
