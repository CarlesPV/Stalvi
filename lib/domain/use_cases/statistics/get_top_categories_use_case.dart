import 'package:stalvi/data/database/tables/transaction_table.dart';
import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/repositories/i_statistics_repository.dart';

class GetTopCategoriesUseCase {
  final IStatisticsRepository _repository;

  GetTopCategoriesUseCase(this._repository);

  Future<List<CategoryStatistic>> execute({
    required DateTime startDate,
    required DateTime endDate,
    TransactionType type = TransactionType.expense,
  }) {
    return _repository.getTopCategories(
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }
}
