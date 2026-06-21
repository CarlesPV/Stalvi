import 'package:stalvi/data/database/tables/transaction_table.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/entities/category_statistic.dart';

abstract class IStatisticsRepository {
  Future<PeriodSummary> getPeriodSummary({
    required DateTime startDate,
    required DateTime endDate,
    required String targetCurrency,
    String? accountId,
  });

  Future<List<CategoryStatistic>> getTopCategories({
    required DateTime startDate,
    required DateTime endDate,
    required String targetCurrency,
    TransactionType type = TransactionType.expense,
    String? accountId,
  });
}
