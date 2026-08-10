import '../entities/account.dart';
import '../repositories/i_account_repository.dart';
import '../repositories/i_budget_repository.dart';
import '../repositories/i_category_repository.dart';
import '../repositories/i_export_service.dart';
import '../repositories/i_profile_repository.dart';
import '../repositories/i_savings_goal_repository.dart';
import '../repositories/i_transaction_repository.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';

import '../entities/budget.dart';
import '../entities/savings_goal.dart';
import '../entities/transaction_type.dart';
import '../repositories/i_exchange_rate_repository.dart';
import '../use_cases/statistics/get_period_summary_use_case.dart';
import '../use_cases/statistics/get_top_categories_use_case.dart';
import 'pdf_export_date_range.dart';

/// Use case that generates a PDF summary report for the **current calendar month**.
///
/// It fetches all transactions that fall within the current month across all
/// accounts, resolves Account and Category names, and delegates PDF generation
/// to [IExportService]. The generated PDF includes columns:
/// Date, Type, Account, Category, Amount, Currency, and Notes.
/// It also includes Budget and Savings Goal summary tables.
class ExportMonthlyPdfUseCase {
  final IProfileRepository _profileRepository;
  final IAccountRepository _accountRepository;
  final ICategoryRepository _categoryRepository;
  final ITransactionRepository _transactionRepository;
  final IExchangeRateRepository _exchangeRateRepository;
  final GetPeriodSummaryUseCase _getPeriodSummaryUseCase;
  final GetTopCategoriesUseCase _getTopCategoriesUseCase;
  final IBudgetRepository _budgetRepository;
  final ISavingsGoalRepository _savingsGoalRepository;
  final IExportService _exportService;
  final AppLocalizations _l10n;

  const ExportMonthlyPdfUseCase({
    required IProfileRepository profileRepository,
    required IAccountRepository accountRepository,
    required ICategoryRepository categoryRepository,
    required ITransactionRepository transactionRepository,
    required IExchangeRateRepository exchangeRateRepository,
    required GetPeriodSummaryUseCase getPeriodSummaryUseCase,
    required GetTopCategoriesUseCase getTopCategoriesUseCase,
    required IBudgetRepository budgetRepository,
    required ISavingsGoalRepository savingsGoalRepository,
    required IExportService exportService,
    required AppLocalizations l10n,
  })  : _profileRepository = profileRepository,
        _accountRepository = accountRepository,
        _categoryRepository = categoryRepository,
        _transactionRepository = transactionRepository,
        _exchangeRateRepository = exchangeRateRepository,
        _getPeriodSummaryUseCase = getPeriodSummaryUseCase,
        _getTopCategoriesUseCase = getTopCategoriesUseCase,
        _budgetRepository = budgetRepository,
        _savingsGoalRepository = savingsGoalRepository,
        _exportService = exportService,
        _l10n = l10n;

  /// Generates a monthly PDF report.
  ///
  /// Optionally pass a custom [month] — defaults to the current month.
  Future<ExportResult> call({
    required String targetCurrency,
    PdfExportDateRange dateRange = PdfExportDateRange.currentMonth,
    DateTime? forceNow,
    String? customMonthLabel,
  }) async {
    final now = forceNow ?? DateTime.now();
    DateTime startDate;
    DateTime endDate;
    DateTime targetMonth = now;

    if (dateRange == PdfExportDateRange.last30Days) {
      startDate = now.subtract(const Duration(days: 30));
      endDate = now;
    } else {
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }

    // Resolve profile for account lookup
    final profile = await _profileRepository.getFirstProfile();
    final userId = profile?.id ?? '';
    final defaultCurrency = profile?.defaultCurrency ?? targetCurrency;

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
      _budgetRepository.getBudgets(),
      _savingsGoalRepository.getSavingsGoals(),
    ]);

    final accounts = results[0] as dynamic;
    final categories = results[1] as dynamic;
    final summary = results[2] as dynamic;
    final topExpenseCategories = results[3] as dynamic;
    final topIncomeCategories = results[4] as dynamic;
    final allBudgets = results[5] as List<Budget>;
    final allSavingsGoals = results[6] as List<SavingsGoal>;

    // Fetch and filter transactions to target month
    final allTransactions =
        await _transactionRepository.watchAllTransactions().first;
    final allRawTransactions =
        await _transactionRepository.watchRawTransactions().first;

    await _exchangeRateRepository.getLatestRates(baseCurrency: targetCurrency);

    final monthTransactions = allTransactions.where((tx) {
      return !tx.date.isBefore(startDate) && !tx.date.isAfter(endDate);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final accountMap = {for (final a in accounts) a.id: a.name};
    final categoryMap = {for (final c in categories) c.id: c.name};

    // Build transfer destination labels for each transfer transaction.
    // Querying raw transactions (which include both legs of a transfer) is necessary
    // because watchAllTransactions() filters out mirror legs to avoid duplicates in listings.
    final Map<String, String> transferDestinations = {};
    for (final tx in monthTransactions) {
      if (tx.type == TransactionType.transfer && tx.transferId != null) {
        final otherLeg = allRawTransactions.firstWhere(
          (t) => t.transferId == tx.transferId && t.id != tx.id,
          orElse: () => tx,
        );
        if (otherLeg.id != tx.id) {
          final thisAccountName = accountMap[tx.accountId] ?? tx.accountId;
          final otherAccountName =
              accountMap[otherLeg.accountId] ?? otherLeg.accountId;

          transferDestinations[tx.id] = '$thisAccountName -> $otherAccountName';
        }
      }
    }

    // Build a category-name map specifically for budgets
    final Map<String, String> budgetCategoryNames = {
      for (final b in allBudgets)
        b.categoryId: categoryMap[b.categoryId] ?? b.categoryId,
    };

    final Map<String, String> budgetCurrencies = {};
    for (final b in allBudgets) {
      final account = (accounts as List<Account>)
          .where((a) => a.id == b.accountId)
          .toList();
      budgetCurrencies[b.id] =
          account.isNotEmpty ? account.first.currency : defaultCurrency;
    }

    // Filter active (non-deleted) budgets and savings goals
    final activeBudgets = allBudgets.where((b) => !b.isDeleted).toList();
    final activeSavingsGoals =
        allSavingsGoals.where((g) => !g.isDeleted).toList();

    final userName = profile?.username ?? profile?.name ?? '';

    return _exportService.generateMonthlyPdf(
      monthTransactions,
      summary: summary,
      month: targetMonth,
      l10n: _l10n,
      accounts: accounts,
      categories: categories,
      topExpenseCategories: topExpenseCategories,
      topIncomeCategories: topIncomeCategories,
      defaultCurrency: defaultCurrency,
      transferDestinations: transferDestinations,
      budgets: activeBudgets,
      budgetCategoryNames: budgetCategoryNames,
      budgetCurrencies: budgetCurrencies,
      savingsGoals: activeSavingsGoals,
      customMonthLabel: customMonthLabel,
      userName: userName,
    );
  }
}
