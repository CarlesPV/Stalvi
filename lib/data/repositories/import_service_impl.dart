import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/data/database/app_database.dart' as db;
import 'package:stalvi/data/database/tables/account_table.dart'
    as account_table;
import 'package:stalvi/data/database/tables/category_table.dart'
    as category_table;
import 'package:stalvi/data/database/tables/transaction_table.dart' as tx_table;
import 'package:stalvi/domain/repositories/i_export_service.dart';
import 'package:stalvi/domain/repositories/i_import_service.dart';

/// Concrete implementation of [IImportService].
///
/// Flow:
///   1. Decrypt the envelope via [IExportService.decryptJsonPayload].
///   2. Parse JSON and validate the version field.
///   3. Inside a single Drift `.transaction()`:
///      a. Wipe all current data (FK order: transactions → accounts →
///         categories → tags → profiles untouched).
///      b. Insert Accounts, Categories, Tags in FK-safe order.
///      c. Insert Transactions.
class ImportServiceImpl implements IImportService {
  final db.AppDatabase _database;
  final IExportService _exportService;

  ImportServiceImpl({
    required db.AppDatabase database,
    required IExportService exportService,
  })  : _database = database,
        _exportService = exportService;

  @override
  Future<void> restoreFromEncryptedJson(
    List<int> encryptedBytes, {
    required String password,
  }) async {
    try {
      // 1. Decrypt
      final jsonPayload = await _exportService.decryptJsonPayload(
        encryptedBytes,
        password: password,
      );

      // 2. Parse JSON
      final Map<String, dynamic> data;
      try {
        data = jsonDecode(jsonPayload) as Map<String, dynamic>;
      } catch (e) {
        throw ImportException(
          message: 'Backup file is corrupted or not a valid Konta backup.',
          code: 'JSON_PARSE_FAILED',
          details: e,
        );
      }

      final version = data['version'] as int? ?? 1;
      if (version < 1 || version > 2) {
        throw ImportException(
          message: 'Unsupported backup version: $version.',
          code: 'UNSUPPORTED_VERSION',
        );
      }

      // 3. Parse entity lists
      final accountsJson = (data['accounts'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final categoriesJson = (data['categories'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final tagsJson =
          (data['tags'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      final transactionsJson = (data['transactions'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      // 4. Atomic restore inside a Drift transaction
      await _database.transaction(() async {
        // Disable FK checks temporarily so we can drop tables in any order.
        await _database.customStatement('PRAGMA foreign_keys = OFF;');

        // Wipe in reverse-FK order
        await _database.delete(_database.transactions).go();
        await _database.delete(_database.accounts).go();
        await _database.delete(_database.categories).go();
        await _database.delete(_database.tags).go();

        // Re-enable FK checks before inserting
        await _database.customStatement('PRAGMA foreign_keys = ON;');

        // Insert categories first (transactions reference them)
        for (final cat in categoriesJson) {
          await _database.into(_database.categories).insertOnConflictUpdate(
                db.CategoriesCompanion.insert(
                  id: cat['id'] as String,
                  name: cat['name'] as String,
                  associatedType: Value(
                    _parseCategoryType(cat['associated_type'] as String?),
                  ),
                  icon: cat['icon'] as String,
                  color: cat['color'] as String,
                  parentCategoryId: Value(cat['parent_category_id'] as String?),
                  isDeleted: Value((cat['is_deleted'] as bool?) ?? false),
                  createdAt: DateTime.parse(cat['created_at'] as String),
                  modifiedAt: DateTime.parse(cat['modified_at'] as String),
                ),
              );
        }

        // Insert tags
        for (final tag in tagsJson) {
          await _database.into(_database.tags).insertOnConflictUpdate(
                db.TagsCompanion.insert(
                  id: tag['id'] as String,
                  name: tag['name'] as String,
                  isDeleted: Value((tag['is_deleted'] as bool?) ?? false),
                  createdAt: DateTime.parse(tag['created_at'] as String),
                  modifiedAt: DateTime.parse(tag['modified_at'] as String),
                ),
              );
        }

        // Insert accounts (reference profiles via user_id — profile rows are NOT wiped)
        for (final acc in accountsJson) {
          await _database.into(_database.accounts).insertOnConflictUpdate(
                db.AccountsCompanion.insert(
                  id: acc['id'] as String,
                  userId: acc['user_id'] as String,
                  name: acc['name'] as String,
                  type: _parseAccountType(acc['type'] as String),
                  initialBalance: (acc['initial_balance'] as num).toDouble(),
                  currency: acc['currency'] as String,
                  color: acc['color'] as String,
                  icon: acc['icon'] as String,
                  isDefault: Value((acc['is_default'] as bool?) ?? false),
                  isDeleted: Value((acc['is_deleted'] as bool?) ?? false),
                  createdAt: DateTime.parse(acc['created_at'] as String),
                  modifiedAt: DateTime.parse(acc['modified_at'] as String),
                ),
              );
        }

        // Insert transactions
        for (final tx in transactionsJson) {
          await _database.into(_database.transactions).insertOnConflictUpdate(
                db.TransactionsCompanion.insert(
                  id: tx['id'] as String,
                  amount: tx['amount'] as int,
                  date: DateTime.parse(tx['date'] as String),
                  type: _parseTransactionType(tx['type'] as String),
                  accountId: tx['account_id'] as String,
                  categoryId: Value(tx['category_id'] as String?),
                  notes: Value(tx['notes'] as String?),
                  originalCurrency: tx['original_currency'] as String,
                  convertedAmount: Value(tx['converted_amount'] as int?),
                  exchangeRate: Value(
                    (tx['exchange_rate'] as num?)?.toDouble(),
                  ),
                  exchangeRateSnapshot:
                      Value(tx['exchange_rate_snapshot'] as String?),
                  transferId: Value(tx['transfer_id'] as String?),
                  isDeleted: const Value(false),
                  createdAt: DateTime.parse(tx['created_at'] as String),
                  modifiedAt: DateTime.parse(tx['modified_at'] as String),
                ),
              );
        }
      });
    } on ImportException {
      rethrow;
    } on ExportException catch (e) {
      throw ImportException(
        message: e.message,
        code: e.code ?? 'IMPORT_FAILED',
        details: e.details,
      );
    } catch (e) {
      throw ImportException(
        message: 'Failed to restore backup.',
        code: 'IMPORT_FAILED',
        details: e,
      );
    }
  }

  // ──────────────────────── Enum parsers ────────────────────────────────────

  static category_table.CategoryAssociatedType? _parseCategoryType(
    String? raw,
  ) {
    if (raw == null) return null;
    switch (raw) {
      case 'income':
        return category_table.CategoryAssociatedType.income;
      case 'expense':
        return category_table.CategoryAssociatedType.expense;
      default:
        return null;
    }
  }

  static account_table.AccountType _parseAccountType(String raw) {
    switch (raw) {
      case 'bank':
        return account_table.AccountType.bank;
      case 'savings':
        return account_table.AccountType.savings;
      case 'card':
        return account_table.AccountType.card;
      case 'other':
        return account_table.AccountType.other;
      case 'cash':
      default:
        return account_table.AccountType.cash;
    }
  }

  static tx_table.TransactionType _parseTransactionType(String raw) {
    switch (raw) {
      case 'income':
        return tx_table.TransactionType.income;
      case 'transfer':
        return tx_table.TransactionType.transfer;
      case 'expense':
      default:
        return tx_table.TransactionType.expense;
    }
  }
}
