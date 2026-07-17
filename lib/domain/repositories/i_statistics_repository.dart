import '../entities/period_summary.dart';
import '../entities/category_statistic.dart';
import '../entities/transaction_type.dart';

abstract class IStatisticsRepository {
  /// One-shot fetch (used by PDF export use case).
  Future<PeriodSummary> getPeriodSummary({
    DateTime? startDate,
    DateTime? endDate,
    required String targetCurrency,
    String? accountId,
  });

  /// One-shot fetch (used by PDF export use case).
  Future<List<CategoryStatistic>> getTopCategories({
    required DateTime startDate,
    required DateTime endDate,
    required String targetCurrency,
    TransactionType type = TransactionType.expense,
    String? accountId,
  });

  /// Reactive stream: emits a new [PeriodSummary] whenever the underlying
  /// transaction data changes within the specified date range / account filter.
  Stream<PeriodSummary> watchPeriodSummary({
    DateTime? startDate,
    DateTime? endDate,
    required String targetCurrency,
    String? accountId,
  });

  /// Reactive stream: emits an updated category list whenever transactions
  /// change within the specified date range / account filter.
  Stream<List<CategoryStatistic>> watchTopCategories({
    required DateTime startDate,
    required DateTime endDate,
    required String targetCurrency,
    TransactionType type = TransactionType.expense,
    String? accountId,
  });
}
