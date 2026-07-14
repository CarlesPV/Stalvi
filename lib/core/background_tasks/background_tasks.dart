import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:stalvi/presentation/providers/app_startup_provider.dart';
import 'package:stalvi/presentation/providers/automatic_transactions_providers.dart';

const String evaluateAutomaticTransactionsTask =
    "evaluateAutomaticTransactionsTask";

/// Background entry-point registered with WorkManager.
///
/// **Isolation safety**: This function runs in a separate Dart isolate when
/// the host app may be completely terminated. The sequence below ensures the
/// encrypted Drift/SQLCipher database is fully open before any provider that
/// calls `requireValue` on [appDatabaseProvider] is accessed.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    ProviderContainer? container;
    try {
      WidgetsFlutterBinding.ensureInitialized();

      container = ProviderContainer();

      // ── Critical: await full DB initialisation before reading any provider
      // that synchronously calls `requireValue` on appDatabaseProvider.
      await container.read(appDatabaseProvider.future);

      if (task == evaluateAutomaticTransactionsTask) {
        final useCase =
            container.read(evaluateAutomaticTransactionsUseCaseProvider);
        await useCase.execute();
      }

      return true;
    } catch (e, st) {
      debugPrint('Background task "$task" failed: $e\n$st');
      return false;
    } finally {
      container?.dispose();
    }
  });
}

class BackgroundTasks {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  /// Registers a periodic task that targets 00:00 UTC+2 (22:00 UTC) daily.
  ///
  /// WorkManager does not guarantee exact timing, but by computing the
  /// [initialDelay] to the next 22:00 UTC the first invocation is anchored
  /// close to midnight local time (UTC+2). Subsequent 24-hour windows
  /// naturally drift within OS tolerances; the use case guards against
  /// double-firing by comparing [nextExecutionDate] against the current time.
  static void registerPeriodicTasks() {
    final now = DateTime.now().toUtc();
    // UTC+2 midnight = 22:00 UTC.
    var target = DateTime.utc(now.year, now.month, now.day, 22, 0);
    if (now.isAfter(target)) {
      target = target.add(const Duration(days: 1));
    }
    final initialDelay = target.difference(now);

    Workmanager().registerPeriodicTask(
      '1',
      evaluateAutomaticTransactionsTask,
      frequency: const Duration(hours: 24),
      initialDelay: initialDelay,
    );
  }
}
