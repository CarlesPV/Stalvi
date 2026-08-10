import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:stalvi/presentation/providers/app_startup_provider.dart';
import 'package:stalvi/presentation/providers/automatic_transactions_providers.dart';

import 'package:stalvi/infrastructure/services/notification_service.dart';
import 'package:stalvi/domain/services/background_sync_service.dart';

/// Task identifier for executing recurring automatic transactions in background.
const String executeRecurringTransactionsTask =
    "executeRecurringTransactionsTask";

/// Unique name for registering periodic background work in Workmanager.
const String _periodicTaskUniqueName = 'stalvi.executeRecurringTransactions';

/// Top-level callback dispatcher for Workmanager background tasks.
///
/// BUSINESS RULES FOR WORKMANAGER BACKGROUND ISOLATE:
/// 1. Runs in a separate Dart isolate initialized by the OS via Workmanager.
/// 2. Ensures `WidgetsFlutterBinding` is initialized before accessing platform channels.
/// 3. Instantiates a dedicated `ProviderContainer` to initialize [NotificationService] and [AppDatabase].
/// 4. Dispatches [ExecuteRecurringTransactionsUseCase] to evaluate pending automatic transactions.
/// 5. Automatically disposes the `ProviderContainer` in the `finally` block to prevent isolate memory leaks.
@pragma('vm:entry-point')
void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().executeTask((task, inputData) async {
    ProviderContainer? container;
    try {
      container = ProviderContainer();

      // Ensure NotificationService and Drift DB are initialized in background isolate
      await container.read(notificationServiceProvider).initialize();
      await container.read(appDatabaseProvider.future);

      if (task == executeRecurringTransactionsTask ||
          task == Workmanager.iOSBackgroundTask) {
        final useCase = container.read(
          executeRecurringTransactionsUseCaseProvider,
        );
        await useCase.execute();
      }

      return Future.value(true);
    } catch (_) {
      return Future.value(false);
    } finally {
      container?.dispose();
    }
  });
}

/// Service in the Infrastructure layer managing Workmanager background task registration and execution.
///
/// BUSINESS RULES FOR WORKMANAGER PERIODIC TASKS:
/// 1. FREQUENCY: Workmanager checks for pending recurring transactions every 3 hours (`Duration(hours: 3)`).
/// 2. CONSTRAINTS: Unrestrictive device constraints (network not required, battery/charging/idle/storage restrictions disabled)
///    to guarantee maximum execution reliability across varied Android OEM battery management policies.
/// 3. WORK POLICY: Uses `ExistingPeriodicWorkPolicy.replace` to ensure updated task configurations are applied cleanly.
/// 4. DUAL-EXECUTION STRATEGY: Pairs periodic Workmanager execution with app startup evaluation on dashboard load,
///    guaranteeing no missed executions even if the OS defers background tasks.
class BackgroundExecutionService implements BackgroundSyncService {
  /// Initializes the Workmanager plugin with the entry-point [callbackDispatcher].
  @override
  Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  /// Registers the periodic Workmanager task for recurring transaction processing.
  @override
  Future<void> registerPeriodicTasks() async {
    final constraints = Constraints(
      networkType: NetworkType.notRequired,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    );

    await Workmanager().registerPeriodicTask(
      _periodicTaskUniqueName,
      executeRecurringTransactionsTask,
      frequency: const Duration(hours: 4),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: constraints,
    );
  }
}
