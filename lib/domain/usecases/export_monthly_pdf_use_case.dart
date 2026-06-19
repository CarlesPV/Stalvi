import 'package:stalvi/domain/repositories/i_export_service.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/repositories/i_statistics_repository.dart';

/// Use case that generates a PDF summary report for the **current calendar month**.
///
/// It fetches all transactions for the given account that fall within the
/// current month, and delegates PDF generation to [IExportService].
class ExportMonthlyPdfUseCase {
  final ITransactionRepository _transactionRepository;
  final IStatisticsRepository _statisticsRepository;
  final IExportService _exportService;

  const ExportMonthlyPdfUseCase({
    required ITransactionRepository transactionRepository,
    required IStatisticsRepository statisticsRepository,
    required IExportService exportService,
  })  : _transactionRepository = transactionRepository,
        _statisticsRepository = statisticsRepository,
        _exportService = exportService;

  /// Generates a monthly PDF report for [accountId].
  ///
  /// Optionally pass a custom [month] — defaults to the current month.
  Future<ExportResult> call(
    String accountId, {
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

    // Fetch all transactions and filter to the target month client-side.
    // For large datasets consider adding a date-range query to the repository.
    final allTransactions =
        await _transactionRepository.getTransactionsByAccountId(accountId);

    final monthTransactions = allTransactions.where((tx) {
      return !tx.date.isBefore(startDate) && !tx.date.isAfter(endDate);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final summary = await _statisticsRepository.getPeriodSummary(
      startDate: startDate,
      endDate: endDate,
    );

    return _exportService.generateMonthlyPdf(
      monthTransactions,
      summary: summary,
      month: targetMonth,
    );
  }
}
