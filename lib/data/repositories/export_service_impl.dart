import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/repositories/i_export_service.dart';

/// Concrete implementation of [IExportService].
///
/// Separation of concerns:
/// * This class **only generates bytes** — it never touches the file system.
/// * File writing, sharing, and cleanup are handled by [TempFileManager].
class ExportServiceImpl implements IExportService {
  // ───────────────────────────── CSV ──────────────────────────────────────

  @override
  Future<ExportResult> generateCsv(List<Transaction> transactions) async {
    try {
      final buffer = StringBuffer();

      // Header row
      buffer.writeln(
        'id,date,type,amount,currency,converted_amount,exchange_rate,account_id,category_id,notes,created_at,modified_at',
      );

      final dateFormat = DateFormat('yyyy-MM-dd');

      for (final tx in transactions) {
        buffer.writeln(
          [
            _csvField(tx.id),
            _csvField(dateFormat.format(tx.date)),
            _csvField(tx.type.name),
            _csvField(_centsToDecimal(tx.amount)),
            _csvField(tx.originalCurrency),
            _csvField(
              tx.convertedAmount != null
                  ? _centsToDecimal(tx.convertedAmount!)
                  : '',
            ),
            _csvField(tx.exchangeRate?.toString() ?? ''),
            _csvField(tx.accountId),
            _csvField(tx.categoryId ?? ''),
            _csvField(tx.notes ?? ''),
            _csvField(tx.createdAt.toIso8601String()),
            _csvField(tx.modifiedAt.toIso8601String()),
          ].join(','),
        );
      }

      final bytes = utf8.encode(buffer.toString());

      final filename =
          'stalvi_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';

      return ExportResult(
        bytes: bytes,
        filename: filename,
        mimeType: 'text/csv',
      );
    } catch (e) {
      throw ExportException(
        message: 'Failed to generate CSV export',
        code: 'CSV_GENERATION_FAILED',
        details: e,
      );
    }
  }

  // ──────────────────────── Encrypted JSON ─────────────────────────────────

  @override
  Future<ExportResult> generateEncryptedJson(
    List<Transaction> transactions, {
    required String password,
  }) async {
    if (password.isEmpty) {
      throw const ExportException(
        message: 'Password must not be empty for encrypted export',
        code: 'EMPTY_PASSWORD',
      );
    }

    try {
      // 1. Build the JSON payload
      final payload = jsonEncode({
        'exportedAt': DateTime.now().toIso8601String(),
        'version': 1,
        'transactions': transactions.map(_transactionToMap).toList(),
      });

      // 2. Derive a 32-byte AES key from the password using PBKDF2-HMAC-SHA256
      final salt = _generateRandomBytes(16);
      final derivedKey = _deriveKey(password, salt);

      // 3. Encrypt with AES-256-CBC
      final iv = enc.IV.fromSecureRandom(16);
      final encrypter = enc.Encrypter(
        enc.AES(enc.Key(derivedKey), mode: enc.AESMode.cbc),
      );
      final encrypted = encrypter.encrypt(payload, iv: iv);

      // 4. Build envelope: salt (16) || iv (16) || ciphertext
      final envelope = Uint8List(
        16 + 16 + encrypted.bytes.length,
      );
      envelope.setRange(0, 16, salt);
      envelope.setRange(16, 32, iv.bytes);
      envelope.setRange(32, envelope.length, encrypted.bytes);

      final filename =
          'stalvi_encrypted_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.enc';

      return ExportResult(
        bytes: envelope,
        filename: filename,
        mimeType: 'application/octet-stream',
      );
    } on ExportException {
      rethrow;
    } catch (e) {
      throw ExportException(
        message: 'Failed to generate encrypted JSON export',
        code: 'ENCRYPTED_JSON_GENERATION_FAILED',
        details: e,
      );
    }
  }

  // ─────────────────────────────── PDF ────────────────────────────────────

  @override
  Future<ExportResult> generateMonthlyPdf(
    List<Transaction> transactions, {
    required PeriodSummary summary,
    required DateTime month,
  }) async {
    try {
      final monthLabel = DateFormat('MMMM yyyy').format(month);
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // ── Header ──
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Stalvi – Monthly Report',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    monthLabel,
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // ── Summary box ──
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.all(
                  pw.Radius.circular(4),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  _pdfSummaryItem(
                    'Total Income',
                    _centsToDecimal(summary.totalIncome),
                    PdfColors.green800,
                  ),
                  _pdfSummaryItem(
                    'Total Expenses',
                    _centsToDecimal(summary.totalExpense),
                    PdfColors.red800,
                  ),
                  _pdfSummaryItem(
                    'Net Balance',
                    _centsToDecimal(
                      summary.totalIncome - summary.totalExpense,
                    ),
                    summary.totalIncome >= summary.totalExpense
                        ? PdfColors.green800
                        : PdfColors.red800,
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),
            pw.Text(
              'Transactions',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),

            // ── Transactions table ──
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              headers: ['Date', 'Type', 'Amount', 'Currency', 'Notes'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.center,
                4: pw.Alignment.centerLeft,
              },
              data: transactions.map((tx) {
                return [
                  DateFormat('dd/MM/yyyy').format(tx.date),
                  tx.type.name,
                  _centsToDecimal(tx.amount),
                  tx.originalCurrency,
                  tx.notes ?? '-',
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 12),
            pw.Text(
              'Generated by Stalvi on ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();
      final filename =
          'stalvi_report_${DateFormat('yyyyMM').format(month)}.pdf';

      return ExportResult(
        bytes: bytes,
        filename: filename,
        mimeType: 'application/pdf',
      );
    } catch (e) {
      throw ExportException(
        message: 'Failed to generate PDF report',
        code: 'PDF_GENERATION_FAILED',
        details: e,
      );
    }
  }

  // ─────────────────────────── Private helpers ─────────────────────────────

  /// Wraps a CSV field value: escapes double-quotes and wraps in quotes when
  /// the value contains a comma, newline, or double-quote.
  static String _csvField(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Converts an integer amount stored in cents to a decimal string (e.g. 1050 → "10.50").
  static String _centsToDecimal(int cents) {
    final major = cents ~/ 100;
    final minor = (cents.abs() % 100).toString().padLeft(2, '0');
    return '$major.$minor';
  }

  /// Serialises a [Transaction] to a plain [Map] for JSON encoding.
  static Map<String, dynamic> _transactionToMap(Transaction tx) => {
        'id': tx.id,
        'amount': tx.amount,
        'date': tx.date.toIso8601String(),
        'type': tx.type.name,
        'account_id': tx.accountId,
        'category_id': tx.categoryId,
        'notes': tx.notes,
        'original_currency': tx.originalCurrency,
        'converted_amount': tx.convertedAmount,
        'exchange_rate': tx.exchangeRate,
        'created_at': tx.createdAt.toIso8601String(),
        'modified_at': tx.modifiedAt.toIso8601String(),
      };

  /// Derives a 32-byte key from [password] + [salt] using PBKDF2-HMAC-SHA256
  /// with 100 000 iterations (OWASP minimum recommendation).
  static Uint8List _deriveKey(String password, Uint8List salt) {
    const iterations = 100000;
    const keyLength = 32; // 256 bits for AES-256

    final passwordBytes = utf8.encode(password);
    var block = Uint8List(keyLength);

    // PBKDF2 with a single block (dkLen ≤ hLen, so block index = 1)
    final hmac = Hmac(sha256, passwordBytes);

    // U1 = PRF(password, salt || INT(1))
    final saltWithInt = Uint8List(salt.length + 4);
    saltWithInt.setRange(0, salt.length, salt);
    saltWithInt[salt.length] = 0;
    saltWithInt[salt.length + 1] = 0;
    saltWithInt[salt.length + 2] = 0;
    saltWithInt[salt.length + 3] = 1;

    var u = Uint8List.fromList(hmac.convert(saltWithInt).bytes);
    block = Uint8List.fromList(u);

    for (var i = 1; i < iterations; i++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      for (var j = 0; j < keyLength; j++) {
        block[j] ^= u[j];
      }
    }

    return block;
  }

  /// Generates [length] cryptographically secure random bytes.
  static Uint8List _generateRandomBytes(int length) {
    final rng = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rng.nextInt(256)),
    );
  }

  // ──────────────────────── Test accessor ───────────────────────────────────

  /// Exposed for unit testing only. Allows tests to decrypt the envelope and
  /// verify the round-trip without duplicating the KDF implementation.
  // ignore: invalid_use_of_visible_for_testing_member
  static Uint8List deriveKeyForTest(String password, Uint8List salt) =>
      _deriveKey(password, salt);

  /// Creates a labelled value widget for the PDF summary section.
  static pw.Widget _pdfSummaryItem(
    String label,
    String value,
    PdfColor valueColor,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

/// Exception thrown when an export operation fails.
class ExportException extends AppException {
  const ExportException({
    required super.message,
    super.code,
    super.details,
  });
}
