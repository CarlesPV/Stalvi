import 'package:stalvi/data/database/daos/statistics_dao.dart';
import 'package:stalvi/domain/entities/category_statistic.dart';

extension CategoryStatisticResultMapper on CategoryStatisticResult {
  CategoryStatistic toDomain() {
    return CategoryStatistic(
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
      totalAmount: totalAmount,
    );
  }
}
