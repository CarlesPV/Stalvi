import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:stalvi/presentation/providers/app_startup_provider.dart';
import 'package:stalvi/presentation/providers/automatic_transactions_providers.dart';

const String executeRecurringTransactionsTask =
    "executeRecurringTransactionsTask";
const String _periodicTaskUniqueName = 'stalvi.executeRecurringTransactions';
const String _reconciliationTaskUniqueName =
    'stalvi.executeRecurringTransactionsReconciliation';

@pragma('vm:entry-point')
void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().executeTask((task, inputData) async {
    ProviderContainer? container;
    try {
      debugPrint(
        '[BackgroundExecutionService] "$task" started at ${DateTime.now().toUtc().toIso8601String()}',
      );

      container = ProviderContainer();

      // Ensure Drift DB is fully initialized before accessing repositories
      await container.read(appDatabaseProvider.future);

      if (task == executeRecurringTransactionsTask ||
          task == Workmanager.iOSBackgroundTask) {
        final useCase =
            container.read(executeRecurringTransactionsUseCaseProvider);
        await useCase.execute();
        debugPrint(
          '[BackgroundExecutionService] "$task" completed successfully.',
        );
      } else {
        debugPrint(
          '[BackgroundExecutionService] Unknown task "$task" — skipping.',
        );
      }

      return true;
    } catch (e, st) {
      debugPrint('[BackgroundExecutionService] "$task" FAILED: $e\n$st');
      return false;
    } finally {
      container?.dispose();
    }
  });
}

class BackgroundExecutionService {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> registerPeriodicTasks() async {
    final now = DateTime.now().toUtc();

    // Target 00:00 UTC+2, which is 22:00 UTC on the previous day.
    var targetPrimary = DateTime.utc(now.year, now.month, now.day, 22, 0, 0);
    if (!now.isBefore(targetPrimary)) {
      targetPrimary = targetPrimary.add(const Duration(days: 1));
    }
    final delayPrimary = targetPrimary.difference(now);

    // Target 01:00 UTC+2, which is 23:00 UTC on the previous day.
    var targetReconciliation =
        DateTime.utc(now.year, now.month, now.day, 23, 0, 0);
    if (!now.isBefore(targetReconciliation)) {
      targetReconciliation = targetReconciliation.add(const Duration(days: 1));
    }
    final delayReconciliation = targetReconciliation.difference(now);

    final constraints = Constraints(
      networkType: NetworkType.notRequired,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    );

    debugPrint(
      '[BackgroundExecutionService] Registering primary periodic task. '
      'Next target: ${targetPrimary.toIso8601String()} UTC '
      '(initialDelay: ${delayPrimary.inMinutes} min).',
    );

    await Workmanager().registerPeriodicTask(
      _periodicTaskUniqueName,
      executeRecurringTransactionsTask,
      frequency: const Duration(hours: 24),
      initialDelay: delayPrimary,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: constraints,
    );

    debugPrint(
      '[BackgroundExecutionService] Registering reconciliation periodic task. '
      'Next target: ${targetReconciliation.toIso8601String()} UTC '
      '(initialDelay: ${delayReconciliation.inMinutes} min).',
    );

    await Workmanager().registerPeriodicTask(
      _reconciliationTaskUniqueName,
      executeRecurringTransactionsTask,
      frequency: const Duration(hours: 24),
      initialDelay: delayReconciliation,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: constraints,
    );
  }
}
