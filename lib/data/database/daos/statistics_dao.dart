import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/transaction_table.dart';
import '../tables/category_table.dart';

part 'statistics_dao.g.dart';

class CategoryStatisticResult {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final int totalAmount;

  CategoryStatisticResult({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.totalAmount,
  });
}

@DriftAccessor(tables: [Transactions, Categories])
class StatisticsDao extends DatabaseAccessor<AppDatabase>
    with _$StatisticsDaoMixin {
  StatisticsDao(super.db);

  /// Calculates total income and total expenses within a date range
  Future<(int totalIncome, int totalExpense)> getPeriodSummary(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final incomeSum = transactions.amount.sum();
    final incomeQuery = selectOnly(transactions)
      ..addColumns([incomeSum])
      ..where(
        transactions.date.isBetweenValues(startDate, endDate) &
            transactions.type.equalsValue(TransactionType.income),
      );
    final incomeResult = await incomeQuery.getSingle();
    final totalIncome = incomeResult.read(incomeSum) ?? 0;

    final expenseSum = transactions.amount.sum();
    final expenseQuery = selectOnly(transactions)
      ..addColumns([expenseSum])
      ..where(
        transactions.date.isBetweenValues(startDate, endDate) &
            transactions.type.equalsValue(TransactionType.expense),
      );
    final expenseResult = await expenseQuery.getSingle();
    final totalExpense = expenseResult.read(expenseSum) ?? 0;

    return (totalIncome, totalExpense);
  }

  /// Calculates Top Categories within a Date Range
  Future<List<CategoryStatisticResult>> getTopCategories(
    DateTime startDate,
    DateTime endDate, {
    TransactionType type = TransactionType.expense,
  }) async {
    final amountSum = transactions.amount.sum();

    final query = selectOnly(transactions)
      ..addColumns([
        categories.id,
        categories.name,
        categories.icon,
        categories.color,
        amountSum,
      ])
      ..join([
        innerJoin(
          categories,
          categories.id.equalsExp(transactions.categoryId),
        ),
      ])
      ..where(
        transactions.date.isBetweenValues(startDate, endDate) &
            transactions.type.equalsValue(type) &
            categories.isDeleted.equals(false),
      )
      ..groupBy([categories.id])
      ..orderBy([OrderingTerm(expression: amountSum, mode: OrderingMode.desc)]);

    final results = await query.get();

    return results.map((row) {
      return CategoryStatisticResult(
        categoryId: row.read(categories.id) ?? '',
        categoryName: row.read(categories.name) ?? '',
        categoryIcon: row.read(categories.icon) ?? '',
        categoryColor: row.read(categories.color) ?? '',
        totalAmount: row.read(amountSum) ?? 0,
      );
    }).toList();
  }
}
