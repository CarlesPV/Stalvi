import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/repositories/i_export_service.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/use_cases/statistics/get_period_summary_use_case.dart';

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
  final GetPeriodSummaryUseCase _getPeriodSummaryUseCase;
  final IExportService _exportService;

  const ExportMonthlyPdfUseCase({
    required IProfileRepository profileRepository,
    required IAccountRepository accountRepository,
    required ICategoryRepository categoryRepository,
    required ITransactionRepository transactionRepository,
    required GetPeriodSummaryUseCase getPeriodSummaryUseCase,
    required IExportService exportService,
  })  : _profileRepository = profileRepository,
        _accountRepository = accountRepository,
        _categoryRepository = categoryRepository,
        _transactionRepository = transactionRepository,
        _getPeriodSummaryUseCase = getPeriodSummaryUseCase,
        _exportService = exportService;

  /// Generates a monthly PDF report.
  ///
  /// Optionally pass a custom [month] — defaults to the current month.
  Future<ExportResult> call({
    required String targetCurrency,
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

    // Fetch in parallel
    final results = await Future.wait([
      _accountRepository.getAccountsByUserId(userId),
      _categoryRepository.getAllCategories(),
      _getPeriodSummaryUseCase.execute(
        startDate: startDate,
        endDate: endDate,
        targetCurrency: targetCurrency,
      ),
    ]);

    final accounts = results[0] as dynamic;
    final categories = results[1] as dynamic;
    final summary = results[2] as dynamic;

    // Fetch and filter transactions to target month
    final allTransactions =
        await _transactionRepository.watchAllTransactions().first;

    final monthTransactions = allTransactions.where((tx) {
      return !tx.date.isBefore(startDate) && !tx.date.isAfter(endDate);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return _exportService.generateMonthlyPdf(
      monthTransactions,
      summary: summary,
      month: targetMonth,
      accounts: accounts,
      categories: categories,
    );
  }
}
