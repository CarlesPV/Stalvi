import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/domain/repositories/i_export_service.dart';
import 'package:konta/domain/repositories/i_transaction_repository.dart';

/// Use case that retrieves all transactions for an account and produces an
/// AES-256-CBC-encrypted JSON export secured by a user-supplied [password].
class ExportEncryptedJsonUseCase {
  final ITransactionRepository _repository;
  final IExportService _exportService;

  const ExportEncryptedJsonUseCase({
    required ITransactionRepository repository,
    required IExportService exportService,
  })  : _repository = repository,
        _exportService = exportService;

  /// Fetches all transactions for [accountId] and generates an encrypted JSON
  /// export using [password].
  ///
  /// Throws a [ValidationException] if [password] is empty.
  /// Throws an [AppException] subclass on any other failure.
  Future<ExportResult> call(String accountId,
      {required String password,}) async {
    if (password.isEmpty) {
      throw const ValidationException(
        message: 'A password is required for encrypted export',
        code: 'EMPTY_PASSWORD',
      );
    }

    final transactions =
        await _repository.getTransactionsByAccountId(accountId);

    return _exportService.generateEncryptedJson(
      transactions,
      password: password,
    );
  }
}
