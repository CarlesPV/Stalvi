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

class ImportServiceImpl implements IImportService {
  final db.AppDatabase _database;
  final IExportService _exportService;
  final void Function()? _onImportSuccess;

  ImportServiceImpl({
    required db.AppDatabase database,
    required IExportService exportService,
    void Function()? onImportSuccess,
  })  : _database = database,
        _exportService = exportService,
        _onImportSuccess = onImportSuccess;

  @override
  Future<void> restoreFromEncryptedJson(
    List<int> encryptedBytes, {
    required String password,
  }) async {
    try {
      final jsonPayload = await _exportService.decryptJsonPayload(
        encryptedBytes,
        password: password,
      );

      final Map<String, dynamic> data;
      try {
        data = jsonDecode(jsonPayload) as Map<String, dynamic>;
      } catch (e) {
        throw ImportException(
          message: 'Backup file is corrupted or not a valid Stalvi backup.',
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

      final accountsJson = (data['accounts'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final categoriesJson = (data['categories'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final tagsJson =
          (data['tags'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      final transactionsJson = (data['transactions'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      // Sort categories so parents are inserted before children to satisfy self-referencing FKs
      categoriesJson.sort((a, b) {
        final parentA = a['parent_category_id'];
        final parentB = b['parent_category_id'];
        if (parentA == null && parentB != null) return -1;
        if (parentA != null && parentB == null) return 1;
        return 0;
      });

      await _database.transaction(() async {
        // Safely wipe data
        // Transactions depend on accounts, categories, tags. Delete them first.
        await _database.delete(_database.transactions).go();

        // Wipe Accounts and Tags
        await _database.delete(_database.accounts).go();
        await _database.delete(_database.tags).go();

        // Categories have self-referencing FKs (parent_category_id).
        // We nullify the parent pointers before deleting to avoid constraint errors.
        await _database
            .customStatement('UPDATE categories SET parent_category_id = NULL');
        await _database.delete(_database.categories).go();

        // Ensure we assign accounts to the CURRENT device profile
        final currentProfile = await (_database.select(_database.profiles)
              ..limit(1))
            .getSingleOrNull();
        final currentUserId = currentProfile?.id;

        // Insert Accounts
        for (final acc in accountsJson) {
          await _database.into(_database.accounts).insertOnConflictUpdate(
                db.AccountsCompanion.insert(
                  id: acc['id'] as String,
                  userId: currentUserId ??
                      (acc['user_id']
                          as String), // Map to current device profile
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

        // Insert Categories
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

        // Insert Tags
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

        // Finally, insert Transactions
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
                  exchangeRate:
                      Value((tx['exchange_rate'] as num?)?.toDouble()),
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
      _onImportSuccess?.call();
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
