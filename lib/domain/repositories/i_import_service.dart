/// Contract for the service that restores a full Konta backup from an
/// encrypted JSON envelope previously produced by [IExportService.generateEncryptedJson].
///
/// The implementation lives in the *data* layer and is responsible for:
///   1. Decrypting the envelope with the user-supplied [password].
///   2. Parsing the JSON payload.
///   3. Clearing all existing Drift tables inside a single atomic transaction.
///   4. Re-inserting Accounts, Categories, Tags, and Transactions in FK order.
abstract class IImportService {
  /// Restores the database from [encryptedBytes] using [password].
  ///
  /// On success the database will contain exactly the data captured at export
  /// time. On any failure the database is left in its pre-import state (the
  /// Drift transaction is rolled back).
  ///
  /// Throws an [ImportException] (subclass of [AppException]) on:
  ///   - Wrong password / corrupted file.
  ///   - JSON parsing errors.
  ///   - Database write failures.
  Future<void> restoreFromEncryptedJson(
    List<int> encryptedBytes, {
    required String password,
  });
}
