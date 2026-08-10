import '../database/daos/statistics_dao.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart'
    show TransactionType;
import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/entities/transaction_type.dart' as domain;
import 'package:stalvi/domain/repositories/i_statistics_repository.dart';

class StatisticsRepositoryImpl implements IStatisticsRepository {
  final StatisticsDao _dao;

  StatisticsRepositoryImpl(this._dao);

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
    domain.TransactionType type = domain.TransactionType.expense,
    String? accountId,
  }) async {
    return _dao.getTopCategoriesAggregates(
      startDate,
      endDate,
      targetCurrency,
      type: _mapType(type),
      accountId: accountId,
    );
  }

  @override
  Stream<PeriodSummary> watchPeriodSummary({
    DateTime? startDate,
    DateTime? endDate,
    required String targetCurrency,
    String? accountId,
  }) {
    return _dao.watchPeriodSummaryAggregates(
      startDate: startDate,
      endDate: endDate,
      targetCurrency: targetCurrency,
      accountId: accountId,
    );
  }

  @override
  Stream<List<CategoryStatistic>> watchTopCategories({
    required DateTime startDate,
    required DateTime endDate,
    required String targetCurrency,
    domain.TransactionType type = domain.TransactionType.expense,
    String? accountId,
  }) {
    return _dao.watchTopCategoriesAggregates(
      startDate,
      endDate,
      targetCurrency,
      type: _mapType(type),
      accountId: accountId,
    );
  }

  TransactionType _mapType(domain.TransactionType type) {
    switch (type) {
      case domain.TransactionType.income:
        return TransactionType.income;
      case domain.TransactionType.expense:
        return TransactionType.expense;
      case domain.TransactionType.transfer:
        return TransactionType.transfer;
    }
  }
}
