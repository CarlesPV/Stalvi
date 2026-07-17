import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:stalvi/presentation/providers/app_startup_provider.dart';
import 'package:stalvi/presentation/providers/automatic_transactions_providers.dart';

const String executeRecurringTransactionsTask = "executeRecurringTransactionsTask";
const String _periodicTaskUniqueName = 'stalvi.executeRecurringTransactions';

@pragma('vm:entry-point')
void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().executeTask((task, inputData) async {
    ProviderContainer? container;
    try {
      debugPrint('[BackgroundExecutionService] "$task" started at ${DateTime.now().toUtc().toIso8601String()}');

      container = ProviderContainer();

      // Ensure Drift DB is fully initialized before accessing repositories
      await container.read(appDatabaseProvider.future);

      if (task == executeRecurringTransactionsTask) {
        final useCase = container.read(executeRecurringTransactionsUseCaseProvider);
        await useCase.execute();
        debugPrint('[BackgroundExecutionService] "$task" completed successfully.');
      } else {
        debugPrint('[BackgroundExecutionService] Unknown task "$task" — skipping.');
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
    var target = DateTime.utc(now.year, now.month, now.day, 22, 0, 0);
    if (!now.isBefore(target)) {
      target = target.add(const Duration(days: 1));
    }

    final initialDelay = target.difference(now);

    debugPrint(
      '[BackgroundExecutionService] Registering periodic task. '
      'Next target: ${target.toIso8601String()} UTC '
      '(initialDelay: ${initialDelay.inMinutes} min).',
    );

    await Workmanager().registerPeriodicTask(
      _periodicTaskUniqueName,
      executeRecurringTransactionsTask,
      frequency: const Duration(hours: 24),
      initialDelay: initialDelay,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(
        requiresBatteryNotLow: false,
        networkType: NetworkType.notRequired,
      ),
    );
  }
}
