import 'package:konta/data/database/tables/transaction_table.dart';
import 'package:konta/domain/entities/period_summary.dart';
import 'package:konta/domain/entities/category_statistic.dart';

abstract class IStatisticsRepository {
  Future<PeriodSummary> getPeriodSummary({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<CategoryStatistic>> getTopCategories({
    required DateTime startDate,
    required DateTime endDate,
    TransactionType type = TransactionType.expense,
  });
}
