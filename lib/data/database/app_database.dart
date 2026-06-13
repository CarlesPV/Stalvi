import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// Import sqlcipher_flutter_libs to ensure the SQLCipher native library is
// bundled and loaded at runtime. The package replaces the default sqlite3
// library with one that includes SQLCipher support.
// ignore: unused_import
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

import 'package:konta/core/security/secure_storage_manager.dart';

part 'app_database.g.dart';

/// The base Drift database for Konta.
///
/// Uses SQLCipher (via [sqlcipher_flutter_libs]) to encrypt the database file
/// at rest. The cipher key is sourced from [SecureStorageManager], which keeps
/// it in the platform's secure keystore.
///
/// **No tables are defined yet** – they will be added incrementally as domain
/// entities are modelled.
///
/// Usage:
/// ```dart
/// final db = await AppDatabase.create();
/// ```
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  /// Private constructor — use the [create] factory instead.
  AppDatabase._(super.executor);

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
  int get schemaVersion => 1;

  /// Opens (or creates) the encrypted database file.
  ///
  /// The [cipherKey] is applied via `PRAGMA key` immediately after opening the
  /// connection, before any other SQL statement is executed – this is required
  /// by the SQLCipher protocol.
  static Future<QueryExecutor> _openEncryptedDatabase(
    String cipherKey,
  ) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'konta.db'));

    return NativeDatabase.createInBackground(
      dbFile,
      setup: (rawDb) {
        // Apply the SQLCipher encryption key. Must be the FIRST statement
        // executed on the connection. The key is hex-encoded, so we use the
        // x'' literal syntax that SQLCipher expects for raw key bytes.
        rawDb.execute("PRAGMA key = \"x'$cipherKey'\";");

        // Verify the key is correct by attempting to read the database.
        // If the key is wrong, this will throw an exception immediately
        // rather than failing silently on the first real query.
        rawDb.execute('SELECT count(*) FROM sqlite_master;');
      },
    );
  }
}
