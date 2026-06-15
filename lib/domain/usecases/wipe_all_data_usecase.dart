import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:konta/data/database/app_database.dart';
import 'package:konta/core/security/secure_storage_manager.dart';

class WipeAllDataUseCase {
  final SecureStorageManager _secureStorageManager;
  final AppDatabase _appDatabase;

  WipeAllDataUseCase(this._secureStorageManager, this._appDatabase);

  Future<void> execute() async {
    // 1. Clear secure storage (encryption key, PIN, settings, etc.)
    await _secureStorageManager.deleteAll();

    // 2. Close the database
    await _appDatabase.close();

    // 3. Delete the Drift database file
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'konta.db'));

    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    // Also delete any journal files that SQLite might have created
    final dbJournalFile = File(p.join(dbFolder.path, 'konta.db-journal'));
    if (await dbJournalFile.exists()) {
      await dbJournalFile.delete();
    }

    final dbWalFile = File(p.join(dbFolder.path, 'konta.db-wal'));
    if (await dbWalFile.exists()) {
      await dbWalFile.delete();
    }

    final dbShmFile = File(p.join(dbFolder.path, 'konta.db-shm'));
    if (await dbShmFile.exists()) {
      await dbShmFile.delete();
    }
  }
}
