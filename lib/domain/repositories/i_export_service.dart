import '../entities/account.dart';
import '../entities/category.dart';
import '../entities/tag.dart';
import '../entities/transaction.dart';
import '../entities/period_summary.dart';

/// Immutable result returned by every export method.
/// Contains the raw bytes of the generated file and its suggested filename.
class ExportResult {
  final List<int> bytes;
  final String filename;
  final String mimeType;

  const ExportResult({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  });
}

/// Contract for the service that converts domain data into exportable formats.
///
/// Implementations live in the *data* layer and must NOT perform any file-system
/// or share operations — those concerns belong to [TempFileManager] and the
/// presentation layer respectively. This keeps generation logic purely testable.
abstract class IExportService {
  /// Generates a CSV string from the given [transactions] with enriched fields:
  /// Date, Type, Account, Category, Amount, Currency, and Notes.
  ///
  /// [accounts] and [categories] are used for name resolution.
  /// All amounts are expressed in major currency units (e.g. 10.00 for 1000¢).
  /// The CSV follows RFC 4180 with a header row.
  Future<ExportResult> generateCsv(
    List<Transaction> transactions, {
    List<Account> accounts = const [],
    List<Category> categories = const [],
  });

  /// Serialises ALL domain data (Accounts, Categories, Tags, Transactions) to
  /// JSON and encrypts the payload with AES-256-CBC using a PBKDF2-derived key
  /// from [password].
  ///
  /// The returned bytes are a self-contained envelope:
  /// `salt (16 bytes) || iv (16 bytes) || ciphertext`.
  /// Only someone who knows [password] can decrypt the file.
  Future<ExportResult> generateEncryptedJson({
    required List<Account> accounts,
    required List<Category> categories,
    required List<Tag> tags,
    required List<Transaction> transactions,
    required String password,
  });

  /// Decrypts an envelope produced by [generateEncryptedJson] and returns the
  /// raw JSON payload as a [String].
  ///
  /// Throws if [password] is wrong or the envelope is malformed.
  Future<String> decryptJsonPayload(
    List<int> encryptedBytes, {
    required String password,
  });

  /// Builds a PDF report summarising the current month's [transactions] against
  /// the provided [summary] totals. Includes Account and Category columns.
  Future<ExportResult> generateMonthlyPdf(
    List<Transaction> transactions, {
    required PeriodSummary summary,
    required DateTime month,
    List<Account> accounts = const [],
    List<Category> categories = const [],
  });
}
