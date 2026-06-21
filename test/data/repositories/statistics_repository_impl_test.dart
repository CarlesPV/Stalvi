import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stalvi/data/database/daos/statistics_dao.dart';
import 'package:stalvi/data/database/app_database.dart' hide Profile, Account;
import 'package:stalvi/data/database/tables/transaction_table.dart'
    show TransactionType;
import 'package:stalvi/data/repositories/statistics_repository_impl.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';

@GenerateMocks([StatisticsDao, IProfileRepository, IAccountRepository])
import 'statistics_repository_impl_test.mocks.dart';

void main() {
  late MockStatisticsDao mockDao;
  late StatisticsRepositoryImpl repository;

  setUp(() {
    mockDao = MockStatisticsDao();
    repository = StatisticsRepositoryImpl(
      mockDao,
    );
  });

  group('getPeriodSummary', () {
    final startDate = DateTime(2023, 1, 1);
    final endDate = DateTime(2023, 1, 31);

    test(
        'should return correct summary using profile defaultCurrency when accountId is null',
        () async {
      final targetCurrency = 'EUR';

      final snapshot = jsonEncode({
        'rates': {
          'USD': 1.0,
          'EUR': 0.9,
        },
      });

      final transactions = [
        Transaction(
          id: 't1',
          amount: 10000, // 100 USD
          date: DateTime.now(),
          type: TransactionType.income,
          accountId: 'a1',
          categoryId: 'c1',
          notes: null,
          originalCurrency: 'USD',
          convertedAmount: null,
          exchangeRate: null,
          exchangeRateSnapshot: snapshot,
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
          isDeleted: false,
          transferId: null,
        ),
      ];

      when(mockDao.getTransactionsForPeriod(startDate, endDate,
              accountId: null))
          .thenAnswer((_) async => transactions);

      final summary = await repository.getPeriodSummary(
          startDate: startDate,
          endDate: endDate,
          targetCurrency: targetCurrency);

      // (10000 / 1.0) * 0.9 = 9000 EUR cents
      expect(summary.totalIncome, 9000);
      expect(summary.totalExpense, 0);
    });

    test(
        'should return correct summary using account currency when accountId is provided',
        () async {
      final targetCurrency = 'GBP';

      final snapshot = jsonEncode({
        'rates': {
          'USD': 1.0,
          'GBP': 0.8,
        },
      });

      final transactions = [
        Transaction(
          id: 't1',
          amount: 5000, // 50 USD
          date: DateTime.now(),
          type: TransactionType.expense,
          accountId: 'a1',
          categoryId: 'c1',
          notes: null,
          originalCurrency: 'USD',
          convertedAmount: null,
          exchangeRate: null,
          exchangeRateSnapshot: snapshot,
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
          isDeleted: false,
          transferId: null,
        ),
      ];

      when(mockDao.getTransactionsForPeriod(startDate, endDate,
              accountId: 'a1'))
          .thenAnswer((_) async => transactions);

      final summary = await repository.getPeriodSummary(
          startDate: startDate,
          endDate: endDate,
          targetCurrency: targetCurrency,
          accountId: 'a1');

      // (5000 / 1.0) * 0.8 = 4000 GBP cents
      expect(summary.totalIncome, 0);
      expect(summary.totalExpense, 4000);
    });
  });

  group('getTopCategories', () {
    final startDate = DateTime(2023, 1, 1);
    final endDate = DateTime(2023, 1, 31);

    test('should aggregate categories correctly with currency conversion',
        () async {
      final targetCurrency = 'EUR';

      final snapshot = jsonEncode({
        'rates': {
          'USD': 1.0,
          'EUR': 0.9,
          'JPY': 150.0,
        },
      });

      final results = [
        TransactionWithCategory(
          transaction: Transaction(
            id: 't1',
            amount: 10000, // 100 USD
            date: DateTime.now(),
            type: TransactionType.expense,
            accountId: 'a1',
            categoryId: 'c1',
            notes: null,
            originalCurrency: 'USD',
            convertedAmount: null,
            exchangeRate: null,
            exchangeRateSnapshot: snapshot,
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
            isDeleted: false,
            transferId: null,
          ),
          categoryId: 'c1',
          categoryName: 'Food',
          categoryIcon: 'food_icon',
          categoryColor: 'green',
        ),
        TransactionWithCategory(
          transaction: Transaction(
            id: 't2',
            amount: 150000, // 1500 JPY
            date: DateTime.now(),
            type: TransactionType.expense,
            accountId: 'a1',
            categoryId: 'c1',
            notes: null,
            originalCurrency: 'JPY',
            convertedAmount: null,
            exchangeRate: null,
            exchangeRateSnapshot: snapshot,
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
            isDeleted: false,
            transferId: null,
          ),
          categoryId: 'c1',
          categoryName: 'Food',
          categoryIcon: 'food_icon',
          categoryColor: 'green',
        ),
        TransactionWithCategory(
          transaction: Transaction(
            id: 't3',
            amount: 5000, // 50 USD
            date: DateTime.now(),
            type: TransactionType.expense,
            accountId: 'a1',
            categoryId: 'c2',
            notes: null,
            originalCurrency: 'USD',
            convertedAmount: null,
            exchangeRate: null,
            exchangeRateSnapshot: snapshot,
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
            isDeleted: false,
            transferId: null,
          ),
          categoryId: 'c2',
          categoryName: 'Travel',
          categoryIcon: 'travel_icon',
          categoryColor: 'blue',
        ),
      ];

      when(mockDao.getTransactionsWithCategoryForPeriod(startDate, endDate,
              type: TransactionType.expense, accountId: null))
          .thenAnswer((_) async => results);

      final topCategories = await repository.getTopCategories(
          startDate: startDate,
          endDate: endDate,
          targetCurrency: targetCurrency);

      // t1: (10000 / 1.0) * 0.9 = 9000 EUR
      // t2: (150000 / 150.0) * 0.9 = 1000 * 0.9 = 900 EUR. Total c1 = 9900 EUR
      // t3: (5000 / 1.0) * 0.9 = 4500 EUR. Total c2 = 4500 EUR

      expect(topCategories.length, 2);
      expect(topCategories[0].categoryId, 'c1');
      expect(topCategories[0].totalAmount, 9900);

      expect(topCategories[1].categoryId, 'c2');
      expect(topCategories[1].totalAmount, 4500);
    });
  });
}
