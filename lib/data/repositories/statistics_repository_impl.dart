import 'dart:convert';
import 'package:stalvi/data/database/daos/statistics_dao.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart'
    show TransactionType;
import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/repositories/i_statistics_repository.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';

class StatisticsRepositoryImpl implements IStatisticsRepository {
  final StatisticsDao _dao;
  final IProfileRepository _profileRepository;
  final IAccountRepository _accountRepository;

  StatisticsRepositoryImpl(
    this._dao,
    this._profileRepository,
    this._accountRepository,
  );

  Future<String> _getTargetCurrency(String? accountId) async {
    if (accountId != null) {
      final account = await _accountRepository.getAccountById(accountId);
      if (account != null) {
        return account.currency;
      }
    }
    final profile = await _profileRepository.getFirstProfile();
    return profile?.defaultCurrency ?? 'EUR';
  }

  int _calculateConvertedAmount(
      Transaction transaction, String targetCurrency) {
    if (transaction.originalCurrency == targetCurrency) {
      return transaction.amount;
    }

    if (transaction.exchangeRateSnapshot != null) {
      try {
        final Map<String, dynamic> snapshot =
            jsonDecode(transaction.exchangeRateSnapshot!);
        if (snapshot.containsKey('rates')) {
          final rates = snapshot['rates'] as Map<String, dynamic>;

          final transactionCurrencyRate =
              (rates[transaction.originalCurrency] as num?)?.toDouble() ?? 1.0;
          final targetCurrencyRate =
              (rates[targetCurrency] as num?)?.toDouble() ?? 1.0;

          final convertedAmount =
              (transaction.amount / transactionCurrencyRate) *
                  targetCurrencyRate;
          return convertedAmount.round();
        }
      } catch (e) {
        // Fallback to existing convertedAmount or amount if JSON parsing fails
      }
    }

    // Fallback if snapshot is missing or fails to provide the rates
    if (transaction.convertedAmount != null &&
        targetCurrency != transaction.originalCurrency) {
      // Assuming existing convertedAmount is in default currency. We can't guarantee it matches
      // the requested targetCurrency if it's not the default currency, but we fallback gracefully.
      return transaction.convertedAmount!;
    }

    return transaction.amount;
  }

  @override
  Future<PeriodSummary> getPeriodSummary({
    required DateTime startDate,
    required DateTime endDate,
    String? accountId,
  }) async {
    final transactions = await _dao.getTransactionsForPeriod(
      startDate,
      endDate,
      accountId: accountId,
    );

    final targetCurrency = await _getTargetCurrency(accountId);

    int totalIncome = 0;
    int totalExpense = 0;

    for (final transaction in transactions) {
      final amount = _calculateConvertedAmount(transaction, targetCurrency);
      if (transaction.type == TransactionType.income) {
        totalIncome += amount;
      } else if (transaction.type == TransactionType.expense) {
        totalExpense += amount;
      }
    }

    return PeriodSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
    );
  }

  @override
  Future<List<CategoryStatistic>> getTopCategories({
    required DateTime startDate,
    required DateTime endDate,
    TransactionType type = TransactionType.expense,
    String? accountId,
  }) async {
    final results = await _dao.getTransactionsWithCategoryForPeriod(
      startDate,
      endDate,
      type: type,
      accountId: accountId,
    );

    final targetCurrency = await _getTargetCurrency(accountId);

    final Map<String, CategoryStatistic> categoryMap = {};

    for (final result in results) {
      final amount =
          _calculateConvertedAmount(result.transaction, targetCurrency);

      if (categoryMap.containsKey(result.categoryId)) {
        final existing = categoryMap[result.categoryId]!;
        categoryMap[result.categoryId] = CategoryStatistic(
          categoryId: existing.categoryId,
          categoryName: existing.categoryName,
          categoryIcon: existing.categoryIcon,
          categoryColor: existing.categoryColor,
          totalAmount: existing.totalAmount + amount,
        );
      } else {
        categoryMap[result.categoryId] = CategoryStatistic(
          categoryId: result.categoryId,
          categoryName: result.categoryName,
          categoryIcon: result.categoryIcon,
          categoryColor: result.categoryColor,
          totalAmount: amount,
        );
      }
    }

    final sortedCategories = categoryMap.values.toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return sortedCategories;
  }
}
