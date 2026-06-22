import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/repositories/i_import_service.dart';

/// Use case that restores the entire Konta database from an encrypted
/// JSON backup file previously produced by [ExportEncryptedJsonUseCase].
///
/// ⚠️  **Destructive operation**: all existing data is overwritten.
/// The caller is responsible for obtaining explicit user consent and
/// authenticating the user (PIN / biometrics) before invoking this use case.
class ImportEncryptedJsonUseCase {
  final IImportService _importService;

  const ImportEncryptedJsonUseCase({required IImportService importService})
      : _importService = importService;

  /// Restores the database from [fileBytes] using [password].
  ///
  /// Throws a [ValidationException] if [password] is empty.
  /// Throws an [AppException] subclass on decrypt or DB write failure.
  Future<void> call(
    List<int> fileBytes, {
    required String password,
  }) async {
    if (password.isEmpty) {
      throw const ValidationException(
        message: 'A password is required to restore a backup',
        code: 'EMPTY_PASSWORD',
      );
    }

    if (fileBytes.isEmpty) {
      throw const ValidationException(
        message: 'Backup file is empty',
        code: 'EMPTY_FILE',
      );
    }

    await _importService.restoreFromEncryptedJson(
      fileBytes,
      password: password,
    );
  }
}
