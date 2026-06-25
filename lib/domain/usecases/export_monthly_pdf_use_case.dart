import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/repositories/i_export_service.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';

import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/use_cases/statistics/get_period_summary_use_case.dart';
import 'package:stalvi/domain/use_cases/statistics/get_top_categories_use_case.dart';

/// Use case that generates a PDF summary report for the **current calendar month**.
///
/// It fetches all transactions that fall within the current month across all
/// accounts, resolves Account and Category names, and delegates PDF generation
/// to [IExportService]. The generated PDF includes columns:
/// Date, Type, Account, Category, Amount, Currency, and Notes.
class ExportMonthlyPdfUseCase {
  final IProfileRepository _profileRepository;
  final IAccountRepository _accountRepository;
  final ICategoryRepository _categoryRepository;
  final ITransactionRepository _transactionRepository;
  final IExchangeRateRepository _exchangeRateRepository;
  final GetPeriodSummaryUseCase _getPeriodSummaryUseCase;
  final GetTopCategoriesUseCase _getTopCategoriesUseCase;
  final IExportService _exportService;

  const ExportMonthlyPdfUseCase({
    required IProfileRepository profileRepository,
    required IAccountRepository accountRepository,
    required ICategoryRepository categoryRepository,
    required ITransactionRepository transactionRepository,
    required IExchangeRateRepository exchangeRateRepository,
    required GetPeriodSummaryUseCase getPeriodSummaryUseCase,
    required GetTopCategoriesUseCase getTopCategoriesUseCase,
    required IExportService exportService,
  })  : _profileRepository = profileRepository,
        _accountRepository = accountRepository,
        _categoryRepository = categoryRepository,
        _transactionRepository = transactionRepository,
        _exchangeRateRepository = exchangeRateRepository,
        _getPeriodSummaryUseCase = getPeriodSummaryUseCase,
        _getTopCategoriesUseCase = getTopCategoriesUseCase,
        _exportService = exportService;

  /// Generates a monthly PDF report.
  ///
  /// Optionally pass a custom [month] — defaults to the current month.
  Future<ExportResult> call({
    required String targetCurrency,
    required AppLocalizations l10n,
    DateTime? month,
  }) async {
    final now = DateTime.now();
    final targetMonth = month ?? DateTime(now.year, now.month);

    final startDate = DateTime(targetMonth.year, targetMonth.month, 1);
    final endDate = DateTime(
      targetMonth.year,
      targetMonth.month + 1,
      0,
      23,
      59,
      59,
    );

    // Resolve profile for account lookup
    final profile = await _profileRepository.getFirstProfile();
    final userId = profile?.id ?? '';

    final results = await Future.wait([
      _accountRepository.getAccountsByUserId(userId),
      _categoryRepository.getAllCategories(),
      _getPeriodSummaryUseCase.execute(
        startDate: startDate,
        endDate: endDate,
        targetCurrency: targetCurrency,
      ),
      _getTopCategoriesUseCase.execute(
        startDate: startDate,
        endDate: endDate,
        targetCurrency: targetCurrency,
        type: TransactionType.expense,
      ),
      _getTopCategoriesUseCase.execute(
        startDate: startDate,
        endDate: endDate,
        targetCurrency: targetCurrency,
        type: TransactionType.income,
      ),
    ]);

    final accounts = results[0] as dynamic;
    final categories = results[1] as dynamic;
    final summary = results[2] as dynamic;
    final topExpenseCategories = results[3] as dynamic;
    final topIncomeCategories = results[4] as dynamic;

    // Fetch and filter transactions to target month
    final allTransactions =
        await _transactionRepository.watchAllTransactions().first;

    await _exchangeRateRepository.getLatestRates(
      baseCurrency: targetCurrency,
    );

    final monthTransactions = allTransactions.where((tx) {
      return !tx.date.isBefore(startDate) && !tx.date.isAfter(endDate);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return _exportService.generateMonthlyPdf(
      monthTransactions,
      summary: summary,
      month: targetMonth,
      l10n: l10n,
      accounts: accounts,
      categories: categories,
      topExpenseCategories: topExpenseCategories,
      topIncomeCategories: topIncomeCategories,
      defaultCurrency: targetCurrency,
    );
  }
}
