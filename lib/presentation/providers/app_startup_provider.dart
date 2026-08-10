import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/domain/usecases/auto_purge_usecase.dart';
import 'package:stalvi/domain/usecases/sync_exchange_rates_usecase.dart';
import 'package:stalvi/infrastructure/services/notification_service.dart';
import 'locale_provider.dart';
import 'repository_providers.dart';

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
  final trashRepo = ref.watch(trashRepositoryProvider);
  return AutoPurgeUseCase(trashRepo);
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

  // Initialize notification service and request permissions asynchronously
  try {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize();
    final isGranted = await notificationService.requestPermissions();
    if (isGranted) {
      final settingsRepo = ref.read(settingsRepositoryProvider);
      await settingsRepo.setNotificationsEnabled(true);
    }
  } catch (_) {}

  // Auto-purge old trash items
  try {
    await ref.read(autoPurgeUseCaseProvider).execute();
  } catch (_) {}

  // Sync and update/translate default categories/tags on startup if profile exists
  try {
    final profile = await ref.read(defaultProfileProvider.future);
    final locale = ref.read(localeProvider);
    final initializeDefaultDataUseCase = ref.read(
      initializeDefaultDataUseCaseProvider,
    );
    await initializeDefaultDataUseCase.execute(
      userId: profile.id,
      locale: locale.languageCode,
    );

    // Run silent background sync for exchange rates
    final syncRatesUseCase = SyncExchangeRatesUseCase(
      ref.read(exchangeRateRepositoryProvider),
    );
    // Note: this deliberately runs without awaiting it to avoid blocking startup
    syncRatesUseCase.execute(baseCurrency: profile.defaultCurrency);
  } catch (_) {}
});
