import '../entities/account.dart';
import '../entities/category.dart';
import '../entities/tag.dart';
import '../entities/transaction.dart';
import '../entities/period_summary.dart';
import '../entities/category_statistic.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';

/// Immutable result returned by every export method.
/// Contains the raw bytes of the generated file and its saved filename/path.
class ExportResult {
  final List<int> bytes;
  final String filename;
  final String mimeType;
  final String? filePath; // Path where the file was saved

  const ExportResult({
    required this.bytes,
    required this.filename,
    required this.mimeType,
    this.filePath,
  });
}

/// Contract for the service that converts domain data into exportable formats.
abstract class IExportService {
  Future<ExportResult> generateCsv(
    List<Transaction> transactions, {
    List<Account> accounts = const [],
    List<Category> categories = const [],
  });

  Future<ExportResult> generateEncryptedJson({
    required List<Account> accounts,
    required List<Category> categories,
    required List<Tag> tags,
    required List<Transaction> transactions,
    required String password,
  });

  Future<String> decryptJsonPayload(
    List<int> encryptedBytes, {
    required String password,
  });

  Future<ExportResult> generateMonthlyPdf(
    List<Transaction> transactions, {
    required PeriodSummary summary,
    required DateTime month,
    required AppLocalizations l10n,
    List<Account> accounts = const [],
    List<Category> categories = const [],
    List<CategoryStatistic> topExpenseCategories = const [],
    List<CategoryStatistic> topIncomeCategories = const [],
    String defaultCurrency = 'EUR',
  });
}
