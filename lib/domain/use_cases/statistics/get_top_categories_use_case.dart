import 'package:flutter/material.dart' show DateTimeRange;
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/core/utils/currency_converter.dart';

class GetTopCategoriesUseCase {
  final ITransactionRepository _transactionRepository;
  final ICategoryRepository _categoryRepository;
  final IExchangeRateRepository _exchangeRateRepository;

  GetTopCategoriesUseCase(
    this._transactionRepository,
    this._categoryRepository,
    this._exchangeRateRepository,
  );

  Future<List<CategoryStatistic>> execute({
    required DateTime startDate,
    required DateTime endDate,
    required String targetCurrency,
    TransactionType type = TransactionType.expense,
    String? accountId,
  }) async {
    final filter = TransactionQueryFilter(
      dateRange: DateTimeRange(start: startDate, end: endDate),
      type: type,
      accountId: accountId,
    );
    final transactions =
        await _transactionRepository.watchFilteredTransactions(filter).first;

    final rates = await _exchangeRateRepository.getLocalRates(
      baseCurrency: targetCurrency,
    );

    final categoryTotals = <String, double>{};
    for (final tx in transactions) {
      if (tx.categoryId == null) continue;

      double amount =
          CurrencyConverter.convertAmount(tx, targetCurrency, rates);

      categoryTotals[tx.categoryId!] =
          (categoryTotals[tx.categoryId!] ?? 0) + amount;
    }

    final allCategories = await _categoryRepository.watchAllCategories().first;
    final categoryMap = {for (var c in allCategories) c.id: c};

    final result = <CategoryStatistic>[];
    for (final entry in categoryTotals.entries) {
      final category = categoryMap[entry.key];
      if (category != null) {
        result.add(
          CategoryStatistic(
            categoryId: category.id,
            categoryName: category.name,
            categoryIcon: category.icon,
            categoryColor: category.color,
            totalAmount: entry.value.round(),
          ),
        );
      }
    }

    result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return result;
  }
}
