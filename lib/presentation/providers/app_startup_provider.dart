import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/database/app_database.dart';

/// Provides the singleton [AppDatabase] instance.
///
/// Uses the async [AppDatabase.create] factory which retrieves the
/// SQLCipher encryption key from the platform secure keystore before
/// opening the encrypted database file. The connection is closed gracefully
/// when the provider is disposed (e.g. on hot restart).
final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final db = await AppDatabase.create();
  ref.onDispose(db.close);
  return db;
});

/// App-wide startup gate.
///
/// Resolves to [void] once all critical services are initialised and the
/// application is safe to transition from [SplashScreen] to the auth/dashboard
/// flow.
///
/// To extend the startup sequence (e.g. loading remote config, user prefs, or
/// local environment values), add additional `await` calls inside this provider
/// below the database initialisation.
final appStartupProvider = FutureProvider<void>((ref) async {
  // Critical path — open the encrypted Drift/SQLCipher database.
  await ref.watch(appDatabaseProvider.future);
});
