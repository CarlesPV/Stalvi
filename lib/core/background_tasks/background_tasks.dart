import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:stalvi/presentation/providers/app_startup_provider.dart';
import 'package:stalvi/presentation/providers/automatic_transactions_providers.dart';

const String evaluateAutomaticTransactionsTask =
    "evaluateAutomaticTransactionsTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      final container = ProviderContainer();

      // Initialize the database to ensure it's open before accessing repositories
      await container.read(appDatabaseProvider.future);

      if (task == evaluateAutomaticTransactionsTask) {
        final useCase =
            container.read(evaluateAutomaticTransactionsUseCaseProvider);
        await useCase.execute();
      }

      container.dispose();
      return Future.value(true);
    } catch (e) {
      debugPrint("Background task failed: $e");
      return Future.value(false);
    }
  });
}

class BackgroundTasks {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  static void registerPeriodicTasks() {
    // Schedule to run every 24 hours. The Workmanager minimum periodic interval is 15 minutes.
    // To target 0:00 UTC+2 approximately, we would need to calculate initial delay,
    // but the OS determines exact execution time anyway. Running it daily is sufficient
    // since the use case checks if the execution date is due.
    final now = DateTime.now().toUtc();
    // UTC+2 means midnight is at 22:00 UTC.
    var target = DateTime.utc(now.year, now.month, now.day, 22, 0);
    if (now.isAfter(target)) {
      target = target.add(const Duration(days: 1));
    }
    final initialDelay = target.difference(now);

    Workmanager().registerPeriodicTask(
      "1",
      evaluateAutomaticTransactionsTask,
      frequency: const Duration(hours: 24),
      initialDelay: initialDelay,
    );
  }
}
