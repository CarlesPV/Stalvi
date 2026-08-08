import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:stalvi/core/utils/currency_converter.dart';
import 'package:stalvi/infrastructure/services/fallback_exchange_rates.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
// ignore: depend_onreferenced_packages
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// Import sqlcipher_flutter_libs to ensure the SQLCipher native library is
// bundled and loaded at runtime. The package replaces the default sqlite3
// library with one that includes SQLCipher support.

import 'package:uuid/uuid.dart';

import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'tables/profile_table.dart';
import 'tables/account_table.dart';
import 'tables/category_table.dart';
import 'tables/tag_table.dart';
import 'tables/transaction_table.dart';
import 'tables/budget_table.dart';
import 'tables/savings_goal_table.dart';
import 'daos/account_dao.dart';
import 'daos/statistics_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/trash_dao.dart';
import 'tables/exchange_rate_table.dart';
import 'daos/exchange_rate_dao.dart';
import 'daos/budget_dao.dart';
import 'daos/savings_goal_dao.dart';
import 'tables/automatic_transaction_table.dart';
import 'daos/automatic_transaction_dao.dart';
import 'package:stalvi/domain/entities/recurrence_type.dart';

part 'app_database.g.dart';

/// The base Drift database for Stalvi.
///
/// Uses SQLCipher (via [sqlcipher_flutter_libs]) to encrypt the database file
/// at rest. The cipher key is sourced from [SecureStorageManager], which keeps
/// it in the platform's secure keystore.
///
/// The database currently models the full financial schema: Accounts, Transactions,
/// Categories, Tags, Budgets, Savings Goals, Exchange Rates, and Automatic Transactions.
///
/// Usage:
/// ```dart
/// final db = await AppDatabase.create();
/// ```
@DriftDatabase(
  tables: [
    Profiles,
    Accounts,
    Categories,
    Tags,
    Transactions,
    Budgets,
    SavingsGoals,
    ExchangeRates,
    AutomaticTransactions,
  ],
  daos: [
    AccountDao,
    TransactionDao,
    StatisticsDao,
    TrashDao,
    ExchangeRateDao,
    BudgetDao,
    SavingsGoalDao,
    AutomaticTransactionDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Private constructor — use the [create] factory instead.
  AppDatabase._(super.executor);

  @visibleForTesting
  factory AppDatabase.forTesting(QueryExecutor e) => AppDatabase._(e);

  /// Async factory that retrieves the encryption key from secure storage
  /// before constructing the synchronous [QueryExecutor].
  ///
  /// [secureStorageManager] can be injected for testing; otherwise the
  /// default production instance is used.
  static Future<AppDatabase> create({
    SecureStorageManager? secureStorageManager,
  }) async {
    final manager = secureStorageManager ?? SecureStorageManager();
    final cipherKey = await manager.getOrCreateEncryptionKey();
    final executor = await _openEncryptedDatabase(cipherKey);
    return AppDatabase._(executor);
  }

  /// Bump this version whenever you add, modify, or remove tables.
  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();

        final now = DateTime.now();
        const uuid = Uuid();
        final defaultUserId = uuid.v4();

        // Seed Anonymous Profile
        await into(profiles).insert(
          ProfilesCompanion.insert(
            id: defaultUserId,
            name: 'Anonymous',
            username: 'anonymous',
            password: '',
            defaultCurrency: const Value('EUR'),
            createdAt: now,
            modifiedAt: now,
          ),
        );

        // Seed Default Functional Categories
        await into(categories).insert(
          CategoriesCompanion.insert(
            id: uuid.v4(),
            name: 'Food',
            associatedType: const Value(CategoryAssociatedType.expense),
            icon: 'restaurant',
            color: '#FF9800',
            createdAt: now,
            modifiedAt: now,
          ),
        );

        await into(categories).insert(
          CategoriesCompanion.insert(
            id: uuid.v4(),
            name: 'Transport',
            associatedType: const Value(CategoryAssociatedType.expense),
            icon: 'directions_car',
            color: '#2196F3',
            createdAt: now,
            modifiedAt: now,
          ),
        );

        await into(categories).insert(
          CategoriesCompanion.insert(
            id: uuid.v4(),
            name: 'Salary',
            associatedType: const Value(CategoryAssociatedType.income),
            icon: 'attach_money',
            color: '#4CAF50',
            createdAt: now,
            modifiedAt: now,
          ),
        );

        await _seedFallbackExchangeRates();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        bool createdTransactions = false;
        bool createdSavingsGoals = false;
        bool createdAutomaticTransactions = false;

        if (from < 2) {
          await m.createTable(transactions);
          createdTransactions = true;
        }
        if (from < 3) {
          await m.createTable(budgets);
          await m.createTable(savingsGoals);
          createdSavingsGoals = true;
        }
        if (from < 4) {
          if (!createdTransactions) {
            await m.addColumn(transactions, transactions.isDeleted);
          }
        }
        if (from < 5) {
          if (!createdTransactions) {
            await m.addColumn(transactions, transactions.transferId);
          }
        }
        if (from < 6) {
          await m.createTable(exchangeRates);
          if (!createdTransactions) {
            await m.addColumn(transactions, transactions.exchangeRateSnapshot);
          }
        }
        if (from < 7) {
          final existingRates = await select(exchangeRates).get();
          String fallbackJson = '{"EUR": 1.0}';
          if (existingRates.isNotEmpty) {
            fallbackJson = existingRates.first.rates;
          }
          await customStatement(
            'UPDATE transactions SET exchange_rate_snapshot = ? WHERE exchange_rate_snapshot IS NULL',
            [Variable.withString(fallbackJson)],
          );
        }
        if (from < 8) {
          if (!createdSavingsGoals) {
            await m.addColumn(savingsGoals, savingsGoals.currency);
          }
        }
        if (from < 9) {
          await m.createTable(automaticTransactions);
          createdAutomaticTransactions = true;
        }
        if (from < 10) {
          if (!createdAutomaticTransactions) {
            await m.addColumn(
              automaticTransactions,
              automaticTransactions.name,
            );
            await m.addColumn(
              automaticTransactions,
              automaticTransactions.currency,
            );
          }
        }
        if (from < 11) {
          if (!createdAutomaticTransactions) {
            await m.addColumn(
              automaticTransactions,
              automaticTransactions.labelId,
            );
          }
        }

        await _seedFallbackExchangeRates();
      },
    );
  }

  /// Populates the exchange rates table with fallback rates ONLY IF the table is empty.
  Future<void> _seedFallbackExchangeRates() async {
    final existingRates = await select(exchangeRates).get();
    if (existingRates.isEmpty) {
      final now = DateTime.now();
      for (final baseCurrency in CurrencyConverter.supportedCurrencies) {
        final ratesMap = FallbackExchangeRates.getFallbackRates(baseCurrency);
        await into(exchangeRates).insertOnConflictUpdate(
          ExchangeRatesCompanion.insert(
            baseCurrency: baseCurrency,
            date: now,
            rates: jsonEncode(ratesMap),
          ),
        );
      }
    }
  }

  /// Opens (or creates) the encrypted database file.
  ///
  /// The [cipherKey] is applied via `PRAGMA key` immediately after opening the
  /// connection, before any other SQL statement is executed – this is required
  /// by the SQLCipher protocol.
  static Future<QueryExecutor> _openEncryptedDatabase(
    String cipherKey,
  ) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'stalvi.db'));

    // CRITICAL FIX: Use NativeDatabase instead of NativeDatabase.createInBackground.
    // createInBackground spawns an isolate that does not inherit the open.overrideFor
    // FFI configuration, causing the dynamic library loader to fail.
    return NativeDatabase(
      dbFile,
      setup: (rawDb) {
        rawDb.execute("PRAGMA key = \"x'$cipherKey'\";");
        rawDb.execute('SELECT count(*) FROM sqlite_master;');
      },
    );
  }
}
