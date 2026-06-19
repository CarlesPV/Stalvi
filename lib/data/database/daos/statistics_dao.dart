import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/transaction_table.dart';
import '../tables/category_table.dart';
import '../tables/account_table.dart';

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

@DriftAccessor(tables: [Transactions, Categories, Accounts])
class StatisticsDao extends DatabaseAccessor<AppDatabase>
    with _$StatisticsDaoMixin {
  StatisticsDao(super.db);

  /// Calculates total income and total expenses within a date range
  Future<(int totalIncome, int totalExpense)> getPeriodSummary(
    DateTime startDate,
    DateTime endDate, {
    String? accountId,
  }) async {
    final incomeSum = transactions.amount.sum();
    var incomeConditions =
        transactions.date.isBetweenValues(startDate, endDate) &
            transactions.type.equalsValue(TransactionType.income) &
            transactions.isDeleted.equals(false) &
            accounts.isDeleted.equals(false);
    if (accountId != null) {
      incomeConditions =
          incomeConditions & transactions.accountId.equals(accountId);
    }
    final incomeQuery = selectOnly(transactions)
      ..addColumns([incomeSum])
      ..join([
        innerJoin(
          accounts,
          accounts.id.equalsExp(transactions.accountId),
        ),
      ])
      ..where(incomeConditions);
    final incomeResult = await incomeQuery.getSingle();
    final totalIncome = incomeResult.read(incomeSum) ?? 0;

    final expenseSum = transactions.amount.sum();
    var expenseConditions =
        transactions.date.isBetweenValues(startDate, endDate) &
            transactions.type.equalsValue(TransactionType.expense) &
            transactions.isDeleted.equals(false) &
            accounts.isDeleted.equals(false);
    if (accountId != null) {
      expenseConditions =
          expenseConditions & transactions.accountId.equals(accountId);
    }
    final expenseQuery = selectOnly(transactions)
      ..addColumns([expenseSum])
      ..join([
        innerJoin(
          accounts,
          accounts.id.equalsExp(transactions.accountId),
        ),
      ])
      ..where(expenseConditions);
    final expenseResult = await expenseQuery.getSingle();
    final totalExpense = expenseResult.read(expenseSum) ?? 0;

    return (totalIncome, totalExpense);
  }

  /// Calculates Top Categories within a Date Range
  Future<List<CategoryStatisticResult>> getTopCategories(
    DateTime startDate,
    DateTime endDate, {
    TransactionType type = TransactionType.expense,
    String? accountId,
  }) async {
    final amountSum = transactions.amount.sum();

    var queryConditions =
        transactions.date.isBetweenValues(startDate, endDate) &
            transactions.type.equalsValue(type) &
            transactions.isDeleted.equals(false) &
            categories.isDeleted.equals(false) &
            accounts.isDeleted.equals(false);
    if (accountId != null) {
      queryConditions =
          queryConditions & transactions.accountId.equals(accountId);
    }

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
        innerJoin(
          accounts,
          accounts.id.equalsExp(transactions.accountId),
        ),
      ])
      ..where(queryConditions)
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
