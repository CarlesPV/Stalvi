import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/transaction_table.dart';
import '../tables/category_table.dart';
import '../tables/account_table.dart';
import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/entities/period_summary.dart';

part 'statistics_dao.g.dart';

class TransactionWithCategory {
  final Transaction transaction;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;

  TransactionWithCategory({
    required this.transaction,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  });
}

@DriftAccessor(tables: [Transactions, Categories, Accounts])
class StatisticsDao extends DatabaseAccessor<AppDatabase>
    with _$StatisticsDaoMixin {
  StatisticsDao(super.db);

  CustomExpression<double> _convertedAmountExpr(String targetCurrency) {
    return CustomExpression<double>('''
      CASE 
        WHEN transactions.original_currency = '$targetCurrency' THEN CAST(transactions.amount AS REAL)
        WHEN transactions.exchange_rate_snapshot IS NOT NULL THEN 
          (CAST(transactions.amount AS REAL) / COALESCE(CAST(json_extract(transactions.exchange_rate_snapshot, '\$.rates.' || transactions.original_currency) AS REAL), 1.0)) * 
          COALESCE(CAST(json_extract(transactions.exchange_rate_snapshot, '\$.rates.$targetCurrency') AS REAL), 1.0)
        ELSE 
          CAST(COALESCE(transactions.converted_amount, transactions.amount) AS REAL)
      END
    ''');
  }

  Stream<double> watchGlobalBalance(String targetCurrency) {
    final convertedExpr = _convertedAmountExpr(targetCurrency);
    final balanceExpr = CustomExpression<double>('''
      SUM(
        CASE 
          WHEN transactions.type = ${TransactionType.income.index} THEN (${convertedExpr.content})
          WHEN transactions.type = ${TransactionType.expense.index} THEN -(${convertedExpr.content})
          ELSE 0 
        END
      )
    ''');

    final query = selectOnly(transactions).join([
      innerJoin(
        accounts,
        accounts.id.equalsExp(transactions.accountId),
      ),
    ])
      ..where(
        transactions.isDeleted.equals(false) & accounts.isDeleted.equals(false),
      )
      ..addColumns([balanceExpr]);

    return query.watchSingle().map((row) {
      return (row.read(balanceExpr) ?? 0.0) / 100.0;
    });
  }

  Future<PeriodSummary> getPeriodSummaryAggregates(
    DateTime startDate,
    DateTime endDate,
    String targetCurrency, {
    String? accountId,
  }) async {
    var queryConditions =
        transactions.date.isBetweenValues(startDate, endDate) &
            transactions.isDeleted.equals(false) &
            accounts.isDeleted.equals(false);

    if (accountId != null) {
      queryConditions =
          queryConditions & transactions.accountId.equals(accountId);
    }

    final convertedExpr = _convertedAmountExpr(targetCurrency);

    final incomeSumExpr = CustomExpression<double>('''
      SUM(
        CASE WHEN transactions.type = ${TransactionType.income.index} THEN 
          (${convertedExpr.content})
        ELSE 0 END
      )
    ''');

    final expenseSumExpr = CustomExpression<double>('''
      SUM(
        CASE WHEN transactions.type = ${TransactionType.expense.index} THEN 
          (${convertedExpr.content})
        ELSE 0 END
      )
    ''');

    final query = selectOnly(transactions).join([
      innerJoin(
        accounts,
        accounts.id.equalsExp(transactions.accountId),
      ),
    ])
      ..where(queryConditions)
      ..addColumns([incomeSumExpr, expenseSumExpr]);

    final result = await query.getSingle();
    return PeriodSummary(
      totalIncome: (result.read(incomeSumExpr) ?? 0.0).round(),
      totalExpense: (result.read(expenseSumExpr) ?? 0.0).round(),
    );
  }

  Future<List<CategoryStatistic>> getTopCategoriesAggregates(
    DateTime startDate,
    DateTime endDate,
    String targetCurrency, {
    TransactionType type = TransactionType.expense,
    String? accountId,
  }) async {
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

    final convertedExpr = _convertedAmountExpr(targetCurrency);
    final sumExpr = CustomExpression<double>('SUM(${convertedExpr.content})');

    final query = selectOnly(transactions).join([
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
      ..addColumns([
        categories.id,
        categories.name,
        categories.icon,
        categories.color,
        sumExpr,
      ])
      ..groupBy([categories.id])
      ..orderBy([OrderingTerm(expression: sumExpr, mode: OrderingMode.desc)]);

    final results = await query.get();

    return results.map((row) {
      return CategoryStatistic(
        categoryId: row.read(categories.id)!,
        categoryName: row.read(categories.name)!,
        categoryIcon: row.read(categories.icon)!,
        categoryColor: row.read(categories.color)!,
        totalAmount: (row.read(sumExpr) ?? 0.0).round(),
      );
    }).toList();
  }

  Future<List<Transaction>> getTransactionsForPeriod(
    DateTime startDate,
    DateTime endDate, {
    String? accountId,
  }) async {
    var queryConditions =
        transactions.date.isBetweenValues(startDate, endDate) &
            transactions.isDeleted.equals(false) &
            accounts.isDeleted.equals(false);

    if (accountId != null) {
      queryConditions =
          queryConditions & transactions.accountId.equals(accountId);
    }

    final query = select(transactions).join([
      innerJoin(
        accounts,
        accounts.id.equalsExp(transactions.accountId),
      ),
    ])
      ..where(queryConditions);

    final results = await query.get();
    return results.map((row) => row.readTable(transactions)).toList();
  }

  Future<List<TransactionWithCategory>> getTransactionsWithCategoryForPeriod(
    DateTime startDate,
    DateTime endDate, {
    TransactionType type = TransactionType.expense,
    String? accountId,
  }) async {
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

    final query = select(transactions).join([
      innerJoin(
        categories,
        categories.id.equalsExp(transactions.categoryId),
      ),
      innerJoin(
        accounts,
        accounts.id.equalsExp(transactions.accountId),
      ),
    ])
      ..where(queryConditions);

    final results = await query.get();

    return results.map((row) {
      final transaction = row.readTable(transactions);
      final category = row.readTable(categories);
      return TransactionWithCategory(
        transaction: transaction,
        categoryId: category.id,
        categoryName: category.name,
        categoryIcon: category.icon,
        categoryColor: category.color,
      );
    }).toList();
  }
}
