// ignore_for_file: prefer_const_constructors

import "package:flutter/foundation.dart" hide Category;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/utils/currency_formatter.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/budget.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/category_statistic.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/entities/savings_goal.dart';
import 'package:stalvi/domain/entities/tag.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_export_service.dart';

class ExportServiceImpl implements IExportService {
  /// Saves generated file bytes to user-accessible storage adhering to strict priority rules:
  ///
  /// BUSINESS RULES FOR FILE EXPORT DIRECTORY PRIORITIZATION:
  /// 1. PRIORITY 1: /storage/emulated/0/Download
  /// 2. PRIORITY 2: /storage/emulated/0/Downloads
  /// 3. PRIORITY 3: /storage/emulated/0/Documents
  /// 4. PRIORITY 4: /storage/emulated/0/Stalvi
  Future<String> _saveFile(List<int> bytes, String filename) async {
    final targetDirs = <Directory>[];

    if (Platform.isAndroid) {
      targetDirs.add(Directory('/storage/emulated/0/Download'));
      targetDirs.add(Directory('/storage/emulated/0/Downloads'));
      targetDirs.add(Directory('/storage/emulated/0/Documents'));
      targetDirs.add(Directory('/storage/emulated/0/Stalvi'));
    } else {
      try {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          targetDirs.add(downloadsDir);
        }
      } catch (_) {}
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        targetDirs.add(docsDir);
      } catch (_) {}
    }

    for (final dir in targetDirs) {
      final savedPath = await _tryWriteFile(dir, filename, bytes);
      if (savedPath != null) {
        return savedPath;
      }
    }

    // Emergency Fallback: Application documents directory
    final fallbackDir = await getApplicationDocumentsDirectory();
    final file = File('${fallbackDir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<String?> _tryWriteFile(
    Directory dir,
    String filename,
    List<int> bytes,
  ) async {
    try {
      if (!await dir.exists()) {
        final created = await dir
            .create(recursive: true)
            .then((_) => true)
            .catchError((_) => false);
        if (!created) return null;
      }
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ExportResult> generateCsv(
    List<Transaction> transactions, {
    List<Account> accounts = const [],
    List<Category> categories = const [],
    List<Tag> tags = const [],
    List<Transaction> allRawTransactions = const [],
  }) async {
    try {
      final buffer = StringBuffer();
      final accountMap = {for (final a in accounts) a.id: a.name};
      final categoryMap = {for (final c in categories) c.id: c.name};
      final tagMap = {for (final t in tags) t.id: t.name};

      buffer.writeln(
        'Date;Type;Account;Category;Label;Amount;Currency;Notes;converted_amount;exchange_rate;exchange_rate_snapshot;id;created_at;modified_at;transfer_id;source_account;destination_account',
      );

      final dateFormat = DateFormat('yyyy-MM-dd');

      for (final tx in transactions) {
        String sourceAccount = '';
        String destinationAccount = '';

        if (tx.type == TransactionType.transfer) {
          final thisAccountName = accountMap[tx.accountId] ?? tx.accountId;
          if (tx.transferId != null) {
            final otherLeg = allRawTransactions.firstWhere(
              (t) => t.transferId == tx.transferId && t.id != tx.id,
              orElse: () => tx,
            );
            if (otherLeg.id != tx.id) {
              final otherAccountName =
                  accountMap[otherLeg.accountId] ?? otherLeg.accountId;
              if (tx.amount < 0) {
                sourceAccount = thisAccountName;
                destinationAccount = otherAccountName;
              } else {
                sourceAccount = otherAccountName;
                destinationAccount = thisAccountName;
              }
            } else {
              if (tx.amount < 0) {
                sourceAccount = thisAccountName;
              } else {
                destinationAccount = thisAccountName;
              }
            }
          } else {
            if (tx.amount < 0) {
              sourceAccount = thisAccountName;
            } else {
              destinationAccount = thisAccountName;
            }
          }
        }

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
            _csvField(
              tx.tagId != null ? (tagMap[tx.tagId!] ?? tx.tagId!) : '',
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
            _csvField(sourceAccount),
            _csvField(destinationAccount),
          ].join(';'),
        );
      }

      // UTF-8 BOM (\uFEFF) for Excel compatibility with accents, currency symbols and diacritics
      final bytes = utf8.encode('\uFEFF${buffer.toString()}');
      final filename =
          'Stalvi_Table_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
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
    required List<Budget> budgets,
    required List<SavingsGoal> savingsGoals,
    required List<AutomaticTransaction> automaticTransactions,
    required String password,
    required String userName,
    String? username,
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
        'version': 3,
        'user_name': userName,
        if (username != null && username.isNotEmpty) 'username': username,
        'accounts': accounts.map(_accountToMap).toList(),
        'categories': categories.map(_categoryToMap).toList(),
        'tags': tags.map(_tagToMap).toList(),
        'transactions': transactions.map(_transactionToMap).toList(),
        'budgets': budgets.map(_budgetToMap).toList(),
        'savings_goals': savingsGoals.map(_savingsGoalToMap).toList(),
        'automatic_transactions':
            automaticTransactions.map(_automaticTransactionToMap).toList(),
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

      // Ensures "Stalvi_Backup" in filename per requirements
      final filename =
          'Stalvi_Backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.kbak';
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
    List<Tag> tags = const [],
    List<CategoryStatistic> topExpenseCategories = const [],
    List<CategoryStatistic> topIncomeCategories = const [],
    String defaultCurrency = 'EUR',
    Map<String, String> transferDestinations = const {},
    List<Budget> budgets = const [],
    Map<String, String> budgetCategoryNames = const {},
    Map<String, String> budgetCurrencies = const {},
    List<SavingsGoal> savingsGoals = const [],
    String? customMonthLabel,
    String userName = '',
  }) async {
    final incomeCount =
        transactions.where((tx) => tx.type == TransactionType.income).length;
    final expenseCount =
        transactions.where((tx) => tx.type == TransactionType.expense).length;
    try {
      await initializeDateFormatting(l10n.localeName);
      final accountMap = {for (final a in accounts) a.id: a.name};
      final categoryMap = {for (final c in categories) c.id: c.name};
      final tagMap = {for (final t in tags) t.id: t.name};

      final monthLabel =
          customMonthLabel ?? DateFormat.yMMMM(l10n.localeName).format(month);

      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final fontDataBold = await rootBundle.load(
        'assets/fonts/Roboto-Bold.ttf',
      );
      final ttf = pw.Font.ttf(fontData);
      final ttfBold = pw.Font.ttf(fontDataBold);

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
      );
      final symbol = _getCurrencySymbol(defaultCurrency);

      // Filter only active (non-deleted) budgets and savings goals
      final activeBudgets = budgets.where((b) => !b.isDeleted).toList();
      final activeSavingsGoals =
          savingsGoals.where((g) => !g.isDeleted).toList();

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
                    userName.isNotEmpty
                        ? '${l10n.appTitle} - ${l10n.overview} $userName'
                        : '${l10n.appTitle} - ${l10n.overview}',
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
                    l10n.income(incomeCount),
                    '$symbol ${_centsToDecimal(summary.totalIncome, l10n.localeName)} $defaultCurrency',
                    PdfColors.green800,
                  ),
                  _pdfSummaryItem(
                    l10n.expense(expenseCount),
                    '$symbol ${_centsToDecimal(summary.totalExpense, l10n.localeName)} $defaultCurrency',
                    PdfColors.red800,
                  ),
                  _pdfSummaryItem(
                    l10n.statisticsNetBalance,
                    '$symbol ${_centsToDecimal(summary.totalIncome - summary.totalExpense, l10n.localeName)} $defaultCurrency',
                    (summary.totalIncome - summary.totalExpense) == 0
                        ? PdfColors.black
                        : (summary.totalIncome - summary.totalExpense) > 0
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
                l10n.labelTag,
                l10n.labelAmount,
                l10n.labelCurrency,
                l10n.labelNotes,
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              headerAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.centerRight,
                6: pw.Alignment.center,
                7: pw.Alignment.centerLeft,
              },
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.centerRight,
                6: pw.Alignment.center,
                7: pw.Alignment.centerLeft,
              },
              cellBuilder: (col, data, row) {
                // Column 1 is the Type column: style Income in green and Expense in red, Transfer is unchanged
                if (col == 1 && data is String) {
                  if (data == l10n.income(1)) {
                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1.5,
                      ),
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.green50,
                        borderRadius: pw.BorderRadius.all(
                          pw.Radius.circular(3),
                        ),
                      ),
                      child: pw.Text(
                        data,
                        style: pw.TextStyle(
                          color: PdfColors.green800,
                          fontSize: 7.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    );
                  } else if (data == l10n.expense(1)) {
                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1.5,
                      ),
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.red50,
                        borderRadius: pw.BorderRadius.all(
                          pw.Radius.circular(3),
                        ),
                      ),
                      child: pw.Text(
                        data,
                        style: pw.TextStyle(
                          color: PdfColors.red800,
                          fontSize: 7.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  // Transfer is NOT changed (neutral / standard text)
                  return pw.Text(
                    data,
                    style: const pw.TextStyle(fontSize: 8),
                  );
                }
                return null;
              },
              data: transactions.map((tx) {
                // For transfers: show "Origin → Destination" in the account column
                String accountCell;
                if (tx.type == TransactionType.transfer) {
                  final originName = accountMap[tx.accountId] ?? tx.accountId;
                  if (transferDestinations.containsKey(tx.id)) {
                    accountCell = transferDestinations[tx.id]!;
                  } else {
                    accountCell = originName;
                  }
                } else {
                  accountCell = accountMap[tx.accountId] ?? tx.accountId;
                }

                return [
                  DateFormat(l10n.pdfDateFormat).format(tx.date),
                  tx.type == TransactionType.income
                      ? l10n.income(1)
                      : tx.type == TransactionType.expense
                          ? l10n.expense(1)
                          : l10n.filterTransfer,
                  accountCell,
                  tx.categoryId != null
                      ? (categoryMap[tx.categoryId!] ?? '')
                      : '-',
                  tx.tagId != null ? (tagMap[tx.tagId!] ?? tx.tagId!) : '-',
                  '${_getCurrencySymbol(tx.originalCurrency)} ${_centsToDecimal(tx.amount, l10n.localeName)}',
                  tx.originalCurrency,
                  tx.notes ?? '-',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),

            // Income vs Expense Chart with 4 reference lines, labels on left
            _buildIncomeExpenseChart(
              summary,
              l10n,
              symbol,
              defaultCurrency,
              incomeCount: incomeCount,
              expenseCount: expenseCount,
            ),

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

            // Budgets Table
            if (activeBudgets.isNotEmpty)
              _buildBudgetsTable(
                activeBudgets,
                budgetCategoryNames,
                accountMap,
                budgetCurrencies,
                defaultCurrency,
                symbol,
                l10n,
              ),

            // Savings Goals Table
            if (activeSavingsGoals.isNotEmpty)
              _buildSavingsGoalsTable(
                activeSavingsGoals,
                symbol,
                defaultCurrency,
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
          'Stalvi_Overview_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
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
    if (value.contains(';') ||
        value.contains(',') ||
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
        'tag_id': tx.tagId,
        'savings_goal_id': tx.savingsGoalId,
        'notes': tx.notes,
        'original_currency': tx.originalCurrency,
        'converted_amount': tx.convertedAmount,
        'exchange_rate': tx.exchangeRate,
        'exchange_rate_snapshot': tx.exchangeRateSnapshot,
        'transfer_id': tx.transferId,
        'is_deleted': false,
        'created_at': tx.createdAt.toIso8601String(),
        'modified_at': tx.modifiedAt.toIso8601String(),
      };

  static Map<String, dynamic> _budgetToMap(Budget b) => {
        'id': b.id,
        'account_id': b.accountId,
        'category_id': b.categoryId,
        'target_amount': b.targetAmount,
        'current_amount': b.currentAmount,
        'start_date': b.startDate.toIso8601String(),
        'end_date': b.endDate.toIso8601String(),
        'created_at': b.createdAt.toIso8601String(),
        'modified_at': b.modifiedAt.toIso8601String(),
        'deleted_at': b.deletedAt?.toIso8601String(),
        'is_deleted': b.isDeleted,
      };

  static Map<String, dynamic> _savingsGoalToMap(SavingsGoal s) => {
        'id': s.id,
        'name': s.name,
        'target_amount': s.targetAmount,
        'current_amount': s.currentAmount,
        'target_date': s.targetDate?.toIso8601String(),
        'color': s.color,
        'icon': s.icon,
        'created_at': s.createdAt.toIso8601String(),
        'modified_at': s.modifiedAt.toIso8601String(),
        'deleted_at': s.deletedAt?.toIso8601String(),
        'is_deleted': s.isDeleted,
        'is_completed': s.isCompleted,
        'currency': s.currency,
      };

  static Map<String, dynamic> _automaticTransactionToMap(
    AutomaticTransaction a,
  ) =>
      {
        'id': a.id,
        'name': a.name,
        'amount': a.amount,
        'currency': a.currency,
        'type': a.type.name,
        'account_id': a.accountId,
        'category_id': a.categoryId,
        'tag_id': a.tagId,
        'label_id': a.labelId,
        'notes': a.notes,
        'recurrence_type': a.recurrenceType.name,
        'recurrence_days': a.recurrenceDays,
        'next_execution_date': a.nextExecutionDate.toIso8601String(),
        'created_at': a.createdAt.toIso8601String(),
        'is_active': a.isActive,
        'is_deleted': a.isDeleted,
        'deleted_at': a.deletedAt?.toIso8601String(),
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

  /// Builds the Income vs Expenses bar chart.
  ///
  /// Business rules:
  /// - Remove textual scale label (old l10n.chart_scale header removed).
  /// - Draw exactly 4 reference scale lines across the chart.
  /// - Render numerical values (formatted with the user's default currency)
  ///   strictly on the LEFT side of these lines for full visibility.
  static pw.Widget _buildIncomeExpenseChart(
    PeriodSummary summary,
    AppLocalizations l10n,
    String currencySymbol,
    String defaultCurrency, {
    required int incomeCount,
    required int expenseCount,
  }) {
    // Chart drawing area constants
    const double chartLeft = 60.0; // left margin reserved for scale labels
    const double chartRight = 300.0;
    const double chartWidth = chartRight - chartLeft;
    const double chartBottom = 10.0; // baseline y (PDF y-axis grows upward)
    const double chartTop = 100.0; // top of chart area
    const double chartHeight = chartTop - chartBottom;
    const double totalWidth = chartRight + 10.0;
    const double totalHeight = chartTop + 20.0; // extra for x-labels

    final double maxVal = max(
      1.0,
      max(summary.totalIncome.toDouble(), summary.totalExpense.toDouble()),
    );

    // Bar positions (centred in left/right halves of the chart area)
    const double barWidth = 40.0;
    const double incomeCenterX = chartLeft + chartWidth * 0.25;
    const double expenseCenterX = chartLeft + chartWidth * 0.75;

    final double incomeBarHeight = (summary.totalIncome / maxVal) * chartHeight;
    final double expenseBarHeight =
        (summary.totalExpense / maxVal) * chartHeight;

    // 4 reference lines at 25%, 50%, 75%, 100% of maxVal
    const int numLines = 4;
    final List<double> scaleValues = List.generate(
      numLines,
      (i) => maxVal * (i + 1) / numLines,
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          l10n.expense_vs_income,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Column(
            children: [
              pw.SizedBox(
                width: totalWidth,
                height: totalHeight,
                child: pw.Stack(
                  children: [
                    pw.Positioned.fill(
                      child: pw.CustomPaint(
                        painter: (PdfGraphics canvas, PdfPoint size) {
                          // Draw 4 horizontal reference lines
                          for (int i = 0; i < numLines; i++) {
                            final double fraction = (i + 1) / numLines;
                            final double lineY =
                                chartBottom + fraction * chartHeight;

                            canvas
                              ..setStrokeColor(PdfColors.grey300)
                              ..setLineWidth(0.5)
                              ..moveTo(chartLeft, lineY)
                              ..lineTo(chartRight, lineY)
                              ..strokePath();
                          }

                          // Draw Income Bar (Green)
                          canvas
                            ..setFillColor(PdfColors.green700)
                            ..drawRect(
                              incomeCenterX - barWidth / 2,
                              chartBottom,
                              barWidth,
                              incomeBarHeight,
                            )
                            ..fillPath();

                          // Draw Expense Bar (Red)
                          canvas
                            ..setFillColor(PdfColors.red700)
                            ..drawRect(
                              expenseCenterX - barWidth / 2,
                              chartBottom,
                              barWidth,
                              expenseBarHeight,
                            )
                            ..fillPath();

                          // Draw baseline
                          canvas
                            ..setStrokeColor(PdfColors.grey400)
                            ..setLineWidth(1)
                            ..moveTo(chartLeft, chartBottom)
                            ..lineTo(chartRight, chartBottom)
                            ..strokePath();
                        },
                      ),
                    ),

                    // Scale value labels – positioned strictly on the left side
                    ...List.generate(numLines, (i) {
                      final double fraction = (i + 1) / numLines;
                      final double lineY = chartBottom + fraction * chartHeight;
                      // Convert canvas y to Stack bottom offset
                      final double bottomOffset = lineY - 4;
                      final scaleVal = scaleValues[i].toInt();
                      final label =
                          '$currencySymbol ${_centsToDecimal(scaleVal, l10n.localeName)}';
                      return pw.Positioned(
                        left: 0,
                        bottom: bottomOffset,
                        child: pw.Text(
                          label,
                          style: const pw.TextStyle(
                            fontSize: 5,
                            color: PdfColors.grey700,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.SizedBox(width: chartLeft.toDouble()),
                  pw.Container(
                    width: chartWidth / 2,
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      l10n.income(incomeCount),
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Container(
                    width: chartWidth / 2,
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      l10n.expense(expenseCount),
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
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

    final totalAmount = categories.fold<double>(
      0,
      (sum, cat) => sum + cat.totalAmount,
    );

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
                      child: pw.Container(width: 10, height: 10, color: color),
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

  /// Builds the Budgets table section.
  ///
  /// Columns: Category | Account | Date Range | % Spent | Max Value (with currency)
  /// Only active (non-deleted) budgets are included.
  static pw.Widget _buildBudgetsTable(
    List<Budget> budgets,
    Map<String, String> categoryNames,
    Map<String, String> accountNames,
    Map<String, String> budgetCurrencies,
    String defaultCurrency,
    String currencySymbol,
    AppLocalizations l10n,
  ) {
    final dateFormat = DateFormat(l10n.pdfDateFormat);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          l10n.pdfBudgetsTitle,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FixedColumnWidth(55),
            4: const pw.FlexColumnWidth(2),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    l10n.pdfBudgetsColCategory,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    l10n.labelAccount,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    l10n.pdfBudgetsColDateRange,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    l10n.pdfBudgetsColSpent,
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
                    l10n.pdfBudgetsColMaxValue,
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            // Data rows
            ...budgets.map((budget) {
              final categoryName =
                  categoryNames[budget.categoryId] ?? budget.categoryId;
              final accountName =
                  accountNames[budget.accountId] ?? budget.accountId;
              final dateRange =
                  '${dateFormat.format(budget.startDate)} – ${dateFormat.format(budget.endDate)}';
              final spentPct = budget.targetAmount > 0
                  ? (budget.currentAmount / budget.targetAmount * 100)
                  : 0.0;
              final budgetCurrency =
                  budgetCurrencies[budget.id] ?? defaultCurrency;
              final formatter = CurrencyFormatter(currencyCode: budgetCurrency);
              final maxValueLabel = formatter.format(
                budget.targetAmount / 100,
                locale: l10n.localeName,
              );

              // Color-code row background when overspent
              final pw.BoxDecoration? rowDecoration = spentPct > 100
                  ? const pw.BoxDecoration(color: PdfColors.red50)
                  : null;

              return pw.TableRow(
                decoration: rowDecoration,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      categoryName,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      accountName,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      dateRange,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      '${spentPct.toStringAsFixed(1)}%',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 8,
                        color:
                            spentPct > 100 ? PdfColors.red700 : PdfColors.black,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      maxValueLabel,
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

  /// Builds the Savings Goals table section.
  ///
  /// Columns: Name | % Completed | Target Amount (with goal currency)
  /// Only active (non-deleted) goals are included.
  static pw.Widget _buildSavingsGoalsTable(
    List<SavingsGoal> goals,
    String currencySymbol,
    String defaultCurrency,
    AppLocalizations l10n,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          l10n.pdfSavingsGoalsTitle,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FixedColumnWidth(65),
            2: const pw.FlexColumnWidth(2),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    l10n.pdfSavingsColName,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    l10n.pdfSavingsColCompleted,
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
                    l10n.pdfBudgetsColMaxValue,
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            // Data rows
            ...goals.map((goal) {
              final completedPct = goal.targetAmount > 0
                  ? (goal.currentAmount / goal.targetAmount * 100)
                  : 0.0;
              final formatter = CurrencyFormatter(currencyCode: goal.currency);
              final targetLabel = formatter.format(
                goal.targetAmount / 100,
                locale: l10n.localeName,
              );

              // Highlight completed goals
              final pw.BoxDecoration? rowDecoration =
                  goal.isCompleted || completedPct >= 100
                      ? const pw.BoxDecoration(color: PdfColors.green50)
                      : null;

              return pw.TableRow(
                decoration: rowDecoration,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      goal.name,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      '${completedPct.clamp(0.0, 100.0).toStringAsFixed(1)}%',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: (goal.isCompleted || completedPct >= 100)
                            ? PdfColors.green700
                            : PdfColors.black,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      targetLabel,
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
