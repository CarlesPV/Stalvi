import "package:flutter/foundation.dart" hide Category;
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/entities/tag.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_export_service.dart';

class ExportServiceImpl implements IExportService {
  Future<String> _saveFile(List<int> bytes, String filename) async {
    if (Platform.isAndroid) {
      // In Android 13+, WRITE_EXTERNAL_STORAGE is deprecated and not needed for Downloads if using MediaStore,
      // but to use File IO in /storage/emulated/0/Download we might need it or just try without.
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    }

    Directory? dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        dir = await getExternalStorageDirectory();
      }
    } else {
      dir = await getDownloadsDirectory();
      dir ??= await getApplicationDocumentsDirectory();
    }

    if (dir == null) {
      throw const ExportException(
        message: 'Could not find a directory to save the file',
        code: 'NO_DIRECTORY',
      );
    }

    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Future<ExportResult> generateCsv(
    List<Transaction> transactions, {
    List<Account> accounts = const [],
    List<Category> categories = const [],
  }) async {
    try {
      final buffer = StringBuffer();
      final accountMap = {for (final a in accounts) a.id: a.name};
      final categoryMap = {for (final c in categories) c.id: c.name};

      buffer.writeln(
        'Date,Type,Account,Category,Amount,Currency,Notes,converted_amount,exchange_rate,exchange_rate_snapshot,id,created_at,modified_at,transfer_id',
      );

      final dateFormat = DateFormat('yyyy-MM-dd');

      for (final tx in transactions) {
        buffer.writeln(
          [
            _csvField(dateFormat.format(tx.date)),
            _csvField(tx.type.name),
            _csvField(accountMap[tx.accountId] ?? tx.accountId),
            _csvField(
              tx.categoryId != null
                  ? (categoryMap[tx.categoryId!] ?? tx.categoryId!)
                  : '',
            ),
            _csvField(_centsToDecimal(tx.amount)),
            _csvField(tx.originalCurrency),
            _csvField(tx.notes ?? ''),
            _csvField(
              tx.convertedAmount != null
                  ? _centsToDecimal(tx.convertedAmount!)
                  : '',
            ),
            _csvField(tx.exchangeRate?.toString() ?? ''),
            _csvField(tx.exchangeRateSnapshot ?? ''),
            _csvField(tx.id),
            _csvField(tx.createdAt.toIso8601String()),
            _csvField(tx.modifiedAt.toIso8601String()),
            _csvField(tx.transferId ?? ''),
          ].join(','),
        );
      }

      final bytes = utf8.encode(buffer.toString());
      final filename =
          'Stalvi_Export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final savedPath = await _saveFile(bytes, filename);

      return ExportResult(
        bytes: bytes,
        filename: filename,
        mimeType: 'text/csv',
        filePath: savedPath,
      );
    } catch (e) {
      throw ExportException(
        message: 'Failed to generate CSV export',
        code: 'CSV_GENERATION_FAILED',
        details: e,
      );
    }
  }

  @override
  Future<ExportResult> generateEncryptedJson({
    required List<Account> accounts,
    required List<Category> categories,
    required List<Tag> tags,
    required List<Transaction> transactions,
    required String password,
  }) async {
    if (password.isEmpty) {
      throw const ExportException(
        message: 'Password must not be empty for encrypted export',
        code: 'EMPTY_PASSWORD',
      );
    }

    try {
      final payload = jsonEncode({
        'exportedAt': DateTime.now().toIso8601String(),
        'version': 2,
        'accounts': accounts.map(_accountToMap).toList(),
        'categories': categories.map(_categoryToMap).toList(),
        'tags': tags.map(_tagToMap).toList(),
        'transactions': transactions.map(_transactionToMap).toList(),
      });

      final salt = _generateRandomBytes(16);
      final derivedKey = _deriveKey(password, salt);

      final iv = enc.IV.fromSecureRandom(16);
      final encrypter = enc.Encrypter(
        enc.AES(enc.Key(derivedKey), mode: enc.AESMode.cbc),
      );
      final encrypted = encrypter.encrypt(payload, iv: iv);

      final envelope = Uint8List(16 + 16 + encrypted.bytes.length);
      envelope.setRange(0, 16, salt);
      envelope.setRange(16, 32, iv.bytes);
      envelope.setRange(32, envelope.length, encrypted.bytes);

      // Ensures "Stalvi_Export" in filename per requirements
      final filename =
          'Stalvi_Export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.kbak';
      final savedPath = await _saveFile(envelope, filename);

      return ExportResult(
        bytes: envelope,
        filename: filename,
        mimeType: 'application/octet-stream',
        filePath: savedPath,
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

  @override
  Future<String> decryptJsonPayload(
    List<int> encryptedBytes, {
    required String password,
  }) async {
    if (password.isEmpty) {
      throw const ExportException(
        message: 'Password must not be empty for decryption',
        code: 'EMPTY_PASSWORD',
      );
    }

    try {
      if (encryptedBytes.length < 33) {
        throw const ExportException(
          message: 'File is too short to be a valid Stalvi backup',
          code: 'INVALID_ENVELOPE',
        );
      }

      final bytes = Uint8List.fromList(encryptedBytes);
      final salt = bytes.sublist(0, 16);
      final ivBytes = bytes.sublist(16, 32);
      final ciphertext = bytes.sublist(32);

      final derivedKey = _deriveKey(password, salt);
      final iv = enc.IV(ivBytes);
      final encrypter = enc.Encrypter(
        enc.AES(enc.Key(derivedKey), mode: enc.AESMode.cbc),
      );

      final decrypted = encrypter.decrypt(
        enc.Encrypted(Uint8List.fromList(ciphertext)),
        iv: iv,
      );

      return decrypted;
    } on ExportException {
      rethrow;
    } catch (e) {
      throw ExportException(
        message: 'Failed to decrypt backup. Check your password and try again.',
        code: 'DECRYPTION_FAILED',
        details: e,
      );
    }
  }

  @override
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
    Map<String, String> transferDestinations = const {},
  }) async {
    try {
      await initializeDateFormatting(l10n.localeName);
      final accountMap = {for (final a in accounts) a.id: a.name};
      final categoryMap = {for (final c in categories) c.id: c.name};

      final monthLabel = DateFormat.yMMMM(l10n.localeName).format(month);
      final pdf = pw.Document();
      final symbol = _getCurrencySymbol(defaultCurrency);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${l10n.appTitle} - ${l10n.overview}',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(monthLabel, style: const pw.TextStyle(fontSize: 14)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  _pdfSummaryItem(
                    l10n.income,
                    '$symbol ${_centsToDecimal(summary.totalIncome, l10n.localeName)} $defaultCurrency',
                    PdfColors.green800,
                  ),
                  _pdfSummaryItem(
                    l10n.expenses,
                    '$symbol ${_centsToDecimal(summary.totalExpense, l10n.localeName)} $defaultCurrency',
                    PdfColors.red800,
                  ),
                  _pdfSummaryItem(
                    l10n.statisticsNetBalance,
                    '$symbol ${_centsToDecimal(
                      summary.totalIncome - summary.totalExpense,
                      l10n.localeName,
                    )} $defaultCurrency',
                    summary.totalIncome >= summary.totalExpense
                        ? PdfColors.green800
                        : PdfColors.red800,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              l10n.transactions,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              headers: [
                l10n.labelDate,
                l10n.filterSheetType,
                l10n.labelAccount,
                l10n.labelCategory,
                l10n.labelAmount,
                l10n.labelCurrency,
                l10n.labelNotes,
              ],
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.center,
                6: pw.Alignment.centerLeft,
              },
              data: transactions.map((tx) {
                return [
                  DateFormat(l10n.pdfDateFormat).format(tx.date),
                  tx.type == TransactionType.income
                      ? l10n.income
                      : tx.type == TransactionType.expense
                          ? l10n.expense
                          : l10n.filterTransfer,
                  tx.type == TransactionType.transfer &&
                          transferDestinations.containsKey(tx.id)
                      ? transferDestinations[tx.id]!
                      : (accountMap[tx.accountId] ?? tx.accountId),
                  tx.categoryId != null
                      ? (categoryMap[tx.categoryId!] ?? '')
                      : '-',
                  '${_getCurrencySymbol(tx.originalCurrency)} ${_centsToDecimal(tx.amount, l10n.localeName)}',
                  tx.originalCurrency,
                  tx.notes ?? '-',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),

            // Income vs Expense Chart
            _buildIncomeExpenseChart(summary, l10n),

            // Top Spending Categories Chart
            if (topExpenseCategories.isNotEmpty)
              _buildCategorySection(
                l10n.statisticsTopSpending,
                topExpenseCategories,
                symbol,
                l10n,
              ),

            // Top Income Categories Chart
            if (topIncomeCategories.isNotEmpty)
              _buildCategorySection(
                l10n.statisticsTopIncome,
                topIncomeCategories,
                symbol,
                l10n,
              ),

            pw.SizedBox(height: 12),
            pw.Text(
              l10n.pdfGeneratedOn(
                l10n.appTitle,
                DateFormat(l10n.pdfDateTimeFormat).format(DateTime.now()),
              ),
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();
      final filename =
          'Stalvi_Export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final savedPath = await _saveFile(bytes, filename);

      return ExportResult(
        bytes: bytes,
        filename: filename,
        mimeType: 'application/pdf',
        filePath: savedPath,
      );
    } catch (e) {
      throw ExportException(
        message: 'Failed to generate PDF report',
        code: 'PDF_GENERATION_FAILED',
        details: e,
      );
    }
  }

  static String _csvField(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static String _centsToDecimal(int cents, [String? locale]) {
    final double val = cents / 100.0;
    if (locale == null) {
      final major = cents ~/ 100;
      final minor = (cents.abs() % 100).toString().padLeft(2, '0');
      return '$major.$minor';
    }
    final format = NumberFormat.decimalPattern(locale);
    format.minimumFractionDigits = 2;
    format.maximumFractionDigits = 2;
    return format.format(val);
  }

  static Map<String, dynamic> _accountToMap(Account a) => {
        'id': a.id,
        'user_id': a.userId,
        'name': a.name,
        'type': a.type.name,
        'initial_balance': a.initialBalance,
        'currency': a.currency,
        'color': a.color,
        'icon': a.icon,
        'is_default': a.isDefault,
        'is_deleted': a.isDeleted,
        'created_at': a.createdAt.toIso8601String(),
        'modified_at': a.modifiedAt.toIso8601String(),
      };

  static Map<String, dynamic> _categoryToMap(Category c) => {
        'id': c.id,
        'name': c.name,
        'associated_type': c.associatedType?.name,
        'icon': c.icon,
        'color': c.color,
        'parent_category_id': c.parentCategoryId,
        'is_deleted': c.isDeleted,
        'created_at': c.createdAt.toIso8601String(),
        'modified_at': c.modifiedAt.toIso8601String(),
      };

  static Map<String, dynamic> _tagToMap(Tag t) => {
        'id': t.id,
        'name': t.name,
        'is_deleted': t.isDeleted,
        'created_at': t.createdAt.toIso8601String(),
        'modified_at': t.modifiedAt.toIso8601String(),
      };

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
        'exchange_rate_snapshot': tx.exchangeRateSnapshot,
        'transfer_id': tx.transferId,
        'created_at': tx.createdAt.toIso8601String(),
        'modified_at': tx.modifiedAt.toIso8601String(),
      };

  static Uint8List _deriveKey(String password, Uint8List salt) {
    const iterations = 100000;
    const keyLength = 32;

    final passwordBytes = utf8.encode(password);
    var block = Uint8List(keyLength);

    final hmac = Hmac(sha256, passwordBytes);

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

  static Uint8List _generateRandomBytes(int length) {
    final rng = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rng.nextInt(256)),
    );
  }

  @visibleForTesting
  static Uint8List deriveKeyForTest(String password, Uint8List salt) =>
      _deriveKey(password, salt);

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

  static String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'JPY':
      case 'CNY':
        return '¥';
      case 'CAD':
        return 'CA\$';
      case 'AUD':
        return 'A\$';
      default:
        return currencyCode;
    }
  }

  static pw.Widget _buildIncomeExpenseChart(
    PeriodSummary summary,
    AppLocalizations l10n,
  ) {
    final double maxVal = max(
      1.0,
      max(
        summary.totalIncome.toDouble(),
        summary.totalExpense.toDouble(),
      ),
    );
    final double incomeHeight = (summary.totalIncome / maxVal) * 80.0;
    final double expenseHeight = (summary.totalExpense / maxVal) * 80.0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              l10n.expense_vs_income,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              l10n.chart_scale,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Column(
            children: [
              pw.SizedBox(
                width: 300,
                height: 120,
                child: pw.Stack(
                  children: [
                    pw.Positioned.fill(
                      child: pw.CustomPaint(
                        painter: (PdfGraphics canvas, PdfPoint size) {
                          // Draw grid lines
                          canvas
                            ..setStrokeColor(PdfColors.grey300)
                            ..setLineWidth(0.5)
                            // Grid line at 50%
                            ..moveTo(20, 50)
                            ..lineTo(280, 50)
                            // Grid line at 100%
                            ..moveTo(20, 90)
                            ..lineTo(280, 90)
                            ..strokePath();

                          // Draw Income Bar (Green)
                          canvas
                            ..setFillColor(PdfColors.green700)
                            ..drawRect(60, 10, 40, incomeHeight)
                            ..fillPath();

                          // Draw Expense Bar (Red)
                          canvas
                            ..setFillColor(PdfColors.red700)
                            ..drawRect(180, 10, 40, expenseHeight)
                            ..fillPath();

                          // Draw baseline
                          canvas
                            ..setStrokeColor(PdfColors.grey400)
                            ..setLineWidth(1)
                            ..moveTo(20, 10)
                            ..lineTo(280, 10)
                            ..strokePath();
                        },
                      ),
                    ),
                    pw.Positioned(
                      left: 0,
                      bottom: 86,
                      child: pw.Text(
                        _centsToDecimal(maxVal.toInt(), l10n.localeName),
                        style: const pw.TextStyle(
                            fontSize: 6, color: PdfColors.grey600),
                      ),
                    ),
                    pw.Positioned(
                      left: 0,
                      bottom: 46,
                      child: pw.Text(
                        _centsToDecimal(maxVal.toInt() ~/ 2, l10n.localeName),
                        style: const pw.TextStyle(
                            fontSize: 6, color: PdfColors.grey600),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.SizedBox(width: 40),
                  pw.Container(
                    width: 80,
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      l10n.income,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 40),
                  pw.Container(
                    width: 80,
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      l10n.expenses,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 40),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildCategorySection(
    String title,
    List<CategoryStatistic> categories,
    String symbol,
    AppLocalizations l10n,
  ) {
    if (categories.isEmpty) return pw.SizedBox();

    final totalAmount =
        categories.fold<double>(0, (sum, cat) => sum + cat.totalAmount);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.SizedBox(
          height: 150,
          child: pw.Chart(
            grid: pw.PieGrid(),
            datasets: categories.map((cat) {
              final colorHex = cat.categoryColor.replaceFirst('#', '');
              final color = colorHex.length == 6 || colorHex.length == 8
                  ? PdfColor.fromHex(colorHex)
                  : PdfColors.grey;
              return pw.PieDataSet(
                value: cat.totalAmount,
                color: color,
                drawBorder: true,
                drawSurface: true,
              );
            }).toList(),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          columnWidths: {
            0: const pw.FixedColumnWidth(30),
            1: const pw.FlexColumnWidth(),
            2: const pw.FixedColumnWidth(50),
            3: const pw.FixedColumnWidth(80),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    '',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    l10n.labelCategory,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    '%',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    l10n.labelAmount,
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            ...categories.map((cat) {
              final colorHex = cat.categoryColor.replaceFirst('#', '');
              final color = colorHex.length == 6 || colorHex.length == 8
                  ? PdfColor.fromHex(colorHex)
                  : PdfColors.grey;
              final percentage =
                  totalAmount > 0 ? (cat.totalAmount / totalAmount * 100) : 0.0;
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Container(
                        width: 10,
                        height: 10,
                        color: color,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      cat.categoryName,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      '${percentage.toStringAsFixed(1)}%',
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      '$symbol ${_centsToDecimal(cat.totalAmount.toInt(), l10n.localeName)}',
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }
}
