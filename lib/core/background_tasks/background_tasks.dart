import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:stalvi/presentation/providers/app_startup_provider.dart';
import 'package:stalvi/presentation/providers/automatic_transactions_providers.dart';

const String evaluateAutomaticTransactionsTask =
    "evaluateAutomaticTransactionsTask";

/// Unique WorkManager task name.  Using a constant prevents duplicate
/// registrations and allows [ExistingPeriodicWorkPolicy.keep] to work
/// correctly — the OS will ignore re-registration calls when the task is
/// already enqueued with this name.
const String _periodicTaskUniqueName = 'stalvi.evaluateAutomaticTransactions';

/// Background entry-point registered with WorkManager.
///
/// **Isolation safety**: This function runs in a separate Dart isolate when
/// the host app may be completely terminated.  The sequence below ensures:
///
/// 1. Flutter engine bindings are initialised synchronously before the
///    [Workmanager.executeTask] callback is registered.
/// 2. [AppDatabase] is fully open (awaiting [appDatabaseProvider.future])
///    before any repository provider that calls `requireValue` is read.
/// 3. Any unexpected error is caught, logged, and returns `false` so that
///    WorkManager can apply its configured retry policy.
@pragma('vm:entry-point')
void callbackDispatcher() {
  // ── Step 1: Initialise Flutter bindings synchronously ─────────────────────
  // Must happen before executeTask so that platform-channel plugins (e.g.
  // flutter_secure_storage used by AppDatabase.create) are available.
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().executeTask((task, inputData) async {
    ProviderContainer? container;
    try {
      debugPrint(
        '[BackgroundTask] "$task" started at ${DateTime.now().toUtc().toIso8601String()}',
      );

      container = ProviderContainer();

      // ── Step 2: Await full DB initialisation ──────────────────────────────
      // Repositories backed by appDatabaseProvider call requireValue which
      // throws a StateError when the AsyncValue is still loading.  We must
      // resolve the future first.
      await container.read(appDatabaseProvider.future);

      // ── Step 3: Execute the relevant task ─────────────────────────────────
      if (task == evaluateAutomaticTransactionsTask) {
        final useCase =
            container.read(evaluateAutomaticTransactionsUseCaseProvider);
        await useCase.execute();
        debugPrint('[BackgroundTask] "$task" completed successfully.');
      } else {
        debugPrint('[BackgroundTask] Unknown task "$task" — skipping.');
      }

      return true;
    } catch (e, st) {
      // Log structured error so it can be captured by crash-reporting tools.
      debugPrint('[BackgroundTask] "$task" FAILED: $e\n$st');
      return false;
    } finally {
      container?.dispose();
    }
  });
}

class BackgroundTasks {
  /// Initialises the WorkManager plugin.
  ///
  /// [isInDebugMode] controls whether WorkManager logs verbose output.  Pass
  /// `kDebugMode` from `package:flutter/foundation.dart` so release builds
  /// are silent.
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  /// Registers a periodic task that targets 00:00 UTC+2 (= 22:00 UTC) daily.
  ///
  /// **Algorithm**
  /// 1. Obtain the current UTC time.
  /// 2. Compute the next 22:00 UTC wall-clock moment (today or tomorrow).
  ///    22:00 UTC equals 00:00 UTC+2 (CET) and 00:00 UTC+2 (CEST) — both
  ///    offsets share the same UTC target, so this is DST-safe.
  /// 3. Pass the resulting duration as [initialDelay].
  ///    Subsequent 24-hour windows automatically maintain the same anchor
  ///    because WorkManager fires relative to the first execution.
  ///
  /// [ExistingPeriodicWorkPolicy.keep] is used so that re-launching the app
  /// does **not** reset the delay window.  The task is only registered once;
  /// subsequent calls are no-ops from WorkManager's perspective.
  ///
  /// The evaluate use case itself is idempotent — it checks
  /// [AutomaticTransaction.nextExecutionDate] before firing — so even if the
  /// OS fires the task slightly early or late, no duplicate transactions are
  /// created.
  static Future<void> registerPeriodicTasks() async {
    final now = DateTime.now().toUtc();

    // UTC+2 midnight = 22:00 UTC on the *previous* calendar day.
    // We target 22:00 UTC today, then advance to tomorrow if already past.
    var target = DateTime.utc(now.year, now.month, now.day, 22, 0, 0);
    if (!now.isBefore(target)) {
      target = target.add(const Duration(days: 1));
    }

    final initialDelay = target.difference(now);

    debugPrint(
      '[BackgroundTasks] Registering periodic task. '
      'Next target: ${target.toIso8601String()} UTC '
      '(initialDelay: ${initialDelay.inMinutes} min).',
    );

    await Workmanager().registerPeriodicTask(
      _periodicTaskUniqueName,
      evaluateAutomaticTransactionsTask,
      frequency: const Duration(hours: 24),
      initialDelay: initialDelay,
      // Keep an already-enqueued task so app restarts don't reset the delay.
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(
        // Allow execution on battery (not just when charging).
        requiresBatteryNotLow: false,
        // No network required — exchange-rate fetch has a graceful fallback.
        networkType: NetworkType.notRequired,
      ),
    );
  }
}
