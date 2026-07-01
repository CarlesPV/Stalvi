import 'package:stalvi/data/database/tables/transaction_table.dart';
import '../entities/period_summary.dart';
import '../entities/category_statistic.dart';

abstract class IStatisticsRepository {
  Future<PeriodSummary> getPeriodSummary({
    DateTime? startDate,
    DateTime? endDate,
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
