import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/domain/repositories/i_export_service.dart';
import 'package:konta/domain/repositories/i_transaction_repository.dart';

/// Use case that retrieves **all non-deleted transactions** and packages them
/// into a CSV [ExportResult].
///
/// Callers should pass the [accountId] to export per-account, or implement a
/// repository method that fetches across all accounts as needed.
class ExportTransactionsCsvUseCase {
  final ITransactionRepository _repository;
  final IExportService _exportService;

  const ExportTransactionsCsvUseCase({
    required ITransactionRepository repository,
    required IExportService exportService,
  })  : _repository = repository,
        _exportService = exportService;

  /// Fetches all transactions for [accountId] and generates a CSV export.
  ///
  /// Throws an [AppException] subclass on failure.
  Future<ExportResult> call(String accountId) async {
    final transactions =
        await _repository.getTransactionsByAccountId(accountId);
    return _exportService.generateCsv(transactions);
  }
}
