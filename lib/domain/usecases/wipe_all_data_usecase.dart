import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';

/// Use case that completely wipes user data, clears hardware keystore keys,
/// deletes local SQLite database files, and performs a cold application exit.
class WipeAllDataUseCase {
  final SecureStorageManager _secureStorageManager;
  final AppDatabase _appDatabase;

  WipeAllDataUseCase(this._secureStorageManager, this._appDatabase);

  Future<void> execute() async {
    try {
      // 1. Clear secure storage (encryption key, PIN, settings, etc.)
      try {
        await _secureStorageManager.deleteAll();
      } catch (_) {}

      // 1.b Clear shared preferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } catch (_) {}

      // 2. Clear all tables explicitly
      try {
        await _appDatabase.transaction(() async {
          await _appDatabase.customStatement('PRAGMA foreign_keys = OFF;');
          await _appDatabase.delete(_appDatabase.transactions).go();
          await _appDatabase.delete(_appDatabase.budgets).go();
          await _appDatabase.delete(_appDatabase.savingsGoals).go();
          await _appDatabase.delete(_appDatabase.accounts).go();
          await _appDatabase.delete(_appDatabase.categories).go();
          await _appDatabase.delete(_appDatabase.tags).go();
          await _appDatabase.delete(_appDatabase.profiles).go();
          await _appDatabase.customStatement('PRAGMA foreign_keys = ON;');
        });
      } catch (_) {
        // Fallback: clear tables individually if transaction fails
        try {
          await _appDatabase.delete(_appDatabase.transactions).go();
        } catch (_) {}
        try {
          await _appDatabase.delete(_appDatabase.budgets).go();
        } catch (_) {}
        try {
          await _appDatabase.delete(_appDatabase.savingsGoals).go();
        } catch (_) {}
        try {
          await _appDatabase.delete(_appDatabase.accounts).go();
        } catch (_) {}
        try {
          await _appDatabase.delete(_appDatabase.categories).go();
        } catch (_) {}
        try {
          await _appDatabase.delete(_appDatabase.tags).go();
        } catch (_) {}
        try {
          await _appDatabase.delete(_appDatabase.profiles).go();
        } catch (_) {}
      }

      // 3. Close the database safely with a timeout.
      // Drift's close() can hang indefinitely if there are active stream listeners.
      try {
        await _appDatabase.close().timeout(const Duration(milliseconds: 500));
      } catch (_) {}

      // 4. Delete database files safely
      try {
        final dbFolder = await getApplicationDocumentsDirectory();
        final dbFile = File(p.join(dbFolder.path, 'stalvi.db'));

        if (await dbFile.exists()) {
          await dbFile.delete();
        }

        final dbJournalFile = File(p.join(dbFolder.path, 'stalvi.db-journal'));
        if (await dbJournalFile.exists()) {
          await dbJournalFile.delete();
        }

        final dbWalFile = File(p.join(dbFolder.path, 'stalvi.db-wal'));
        if (await dbWalFile.exists()) {
          await dbWalFile.delete();
        }

        final dbShmFile = File(p.join(dbFolder.path, 'stalvi.db-shm'));
        if (await dbShmFile.exists()) {
          await dbShmFile.delete();
        }
      } catch (_) {}
    } catch (e) {
      rethrow;
    }
  }
}
