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
  /// Generates a CSV string from the given [transactions] and returns it as
  /// UTF-8 encoded bytes ready to be written to a `.csv` file.
  ///
  /// All amounts are expressed in major currency units (e.g. 10.00 for 1000¢).
  /// The CSV follows RFC 4180 with a header row.
  Future<ExportResult> generateCsv(List<Transaction> transactions);

  /// Serialises [transactions] to JSON and encrypts the payload with AES-256-CBC
  /// using a PBKDF2-derived key from [password].
  ///
  /// The returned bytes are a self-contained envelope:
  /// `salt (16 bytes) || iv (16 bytes) || ciphertext`.
  /// Only someone who knows [password] can decrypt the file.
  Future<ExportResult> generateEncryptedJson(
    List<Transaction> transactions, {
    required String password,
  });

  /// Builds a PDF report summarising the current month's [transactions] against
  /// the provided [summary] totals.
  Future<ExportResult> generateMonthlyPdf(
    List<Transaction> transactions, {
    required PeriodSummary summary,
    required DateTime month,
  });
}
