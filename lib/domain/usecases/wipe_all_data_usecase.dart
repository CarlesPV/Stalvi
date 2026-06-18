import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';

class WipeAllDataUseCase {
  final SecureStorageManager _secureStorageManager;
  final AppDatabase _appDatabase;

  WipeAllDataUseCase(this._secureStorageManager, this._appDatabase);

  Future<void> execute() async {
    // 1. Clear secure storage (encryption key, PIN, settings, etc.)
    await _secureStorageManager.deleteAll();

    // 1.b Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

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

    // 3. Close the database
    await _appDatabase.close();

    // 3. Delete the Drift database file
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'stalvi.db'));

    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    // Also delete any journal files that SQLite might have created
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

    // 4. Close the app
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      if (Platform.isIOS) {
        exit(0);
      } else {
        try {
          await SystemNavigator.pop();
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 300));
        exit(0);
      }
    }
  }
}
