import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:stalvi/presentation/providers/app_startup_provider.dart';
import 'package:stalvi/presentation/providers/automatic_transactions_providers.dart';

import 'package:stalvi/infrastructure/services/notification_service.dart';

const String executeRecurringTransactionsTask =
    "executeRecurringTransactionsTask";
const String _periodicTaskUniqueName = 'stalvi.executeRecurringTransactions';

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

      // Ensure NotificationService and Drift DB are initialized in background isolate
      await container.read(notificationServiceProvider).initialize();
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
    final constraints = Constraints(
      networkType: NetworkType.notRequired,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    );

    debugPrint(
      '[BackgroundExecutionService] Registering periodic task. '
      'Frequency: 2 hours.',
    );

    await Workmanager().registerPeriodicTask(
      _periodicTaskUniqueName,
      executeRecurringTransactionsTask,
      frequency: const Duration(hours: 2),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: constraints,
    );
  }
}
