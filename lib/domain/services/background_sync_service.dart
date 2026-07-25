/// Domain interface defining the contract for background synchronization services.
///
/// Implementations (such as Workmanager-backed services) register periodic
/// background tasks to evaluate recurring transactions and synchronize data.
abstract class BackgroundSyncService {
  /// Initializes the background synchronization service.
  Future<void> initialize();

  /// Registers periodic tasks to run in the background.
  Future<void> registerPeriodicTasks();
}
