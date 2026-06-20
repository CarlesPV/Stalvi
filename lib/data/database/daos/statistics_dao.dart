import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/transaction_table.dart';
import '../tables/category_table.dart';
import '../tables/account_table.dart';

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
