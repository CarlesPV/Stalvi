import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/repositories/i_export_service.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/repositories/i_tag_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';

/// Use case that collects all user data (Accounts, Categories, Tags,
/// Transactions) and produces an AES-256-CBC-encrypted JSON backup
/// secured by a user-supplied [password].
///
/// The password should be derived from or validated against the user's
/// current PIN / biometric auth flow before calling this use case.
class ExportEncryptedJsonUseCase {
  final IProfileRepository _profileRepository;
  final IAccountRepository _accountRepository;
  final ICategoryRepository _categoryRepository;
  final ITagRepository _tagRepository;
  final ITransactionRepository _transactionRepository;
  final IExportService _exportService;

  const ExportEncryptedJsonUseCase({
    required IProfileRepository profileRepository,
    required IAccountRepository accountRepository,
    required ICategoryRepository categoryRepository,
    required ITagRepository tagRepository,
    required ITransactionRepository transactionRepository,
    required IExportService exportService,
  })  : _profileRepository = profileRepository,
        _accountRepository = accountRepository,
        _categoryRepository = categoryRepository,
        _tagRepository = tagRepository,
        _transactionRepository = transactionRepository,
        _exportService = exportService;

  /// Fetches all data and generates an encrypted full-backup JSON.
  ///
  /// Throws a [ValidationException] if [password] is empty.
  /// Throws an [AppException] subclass on any other failure.
  Future<ExportResult> call({required String password}) async {
    if (password.isEmpty) {
      throw const ValidationException(
        message: 'A password is required for encrypted export',
        code: 'EMPTY_PASSWORD',
      );
    }

    // Resolve profile to get the user ID for account lookup
    final profile = await _profileRepository.getFirstProfile();
    if (profile == null) {
      throw const ValidationException(
        message: 'No profile found',
        code: 'NO_PROFILE',
      );
    }

    // Fetch all entities in parallel
    final results = await Future.wait([
      _accountRepository.getAccountsByUserId(profile.id),
      _categoryRepository.getAllCategories(),
      _tagRepository.getAllTags(),
    ]);

    final accounts = results[0] as dynamic;
    final categories = results[1] as dynamic;
    final tags = results[2] as dynamic;

    // Transactions across ALL accounts
    final allTransactions =
        await _transactionRepository.watchAllTransactions().first;

    return _exportService.generateEncryptedJson(
      accounts: accounts,
      categories: categories,
      tags: tags,
      transactions: allTransactions,
      password: password,
    );
  }
}
