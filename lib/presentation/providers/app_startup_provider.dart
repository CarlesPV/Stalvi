import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/domain/usecases/auto_purge_usecase.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';

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

/// Provides the [AutoPurgeUseCase] instance.
final autoPurgeUseCaseProvider = Provider<AutoPurgeUseCase>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  return AutoPurgeUseCase(db.trashDao);
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

  // Auto-purge old trash items
  try {
    await ref.read(autoPurgeUseCaseProvider).execute();
  } catch (e) {
    // If the database is still initializing or there's an error, log it but don't crash startup.
    debugPrint('AutoPurge failed during startup: $e');
  }

  // Sync and update/translate default categories/tags on startup if profile exists
  try {
    final profile = await ref.read(defaultProfileProvider.future);
    final locale = ref.read(localeProvider);
    final initializeDefaultDataUseCase =
        ref.read(initializeDefaultDataUseCaseProvider);
    await initializeDefaultDataUseCase.execute(
      userId: profile.id,
      currency: profile.defaultCurrency,
      locale: locale.languageCode,
    );
  } catch (e) {
    // Safe to ignore if profile is not setup yet (e.g., first launch)
    debugPrint(
      'Default data synchronization skipped or failed during startup: $e',
    );
  }
});
