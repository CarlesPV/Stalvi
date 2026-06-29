import 'package:stalvi/core/errors/app_exceptions.dart';
import '../repositories/i_account_repository.dart';
import '../repositories/i_category_repository.dart';
import '../repositories/i_export_service.dart';
import '../repositories/i_profile_repository.dart';
import '../repositories/i_transaction_repository.dart';

/// Use case that retrieves **all non-deleted transactions** across every
/// account and packages them into a CSV [ExportResult].
///
/// The CSV includes the required columns:
/// Date, Type, Account, Category, Amount, Currency, and Notes.
class ExportTransactionsCsvUseCase {
  final IProfileRepository _profileRepository;
  final IAccountRepository _accountRepository;
  final ICategoryRepository _categoryRepository;
  final ITransactionRepository _transactionRepository;
  final IExportService _exportService;

  const ExportTransactionsCsvUseCase({
    required IProfileRepository profileRepository,
    required IAccountRepository accountRepository,
    required ICategoryRepository categoryRepository,
    required ITransactionRepository transactionRepository,
    required IExportService exportService,
  })  : _profileRepository = profileRepository,
        _accountRepository = accountRepository,
        _categoryRepository = categoryRepository,
        _transactionRepository = transactionRepository,
        _exportService = exportService;

  /// Fetches all transactions and generates a CSV export.
  ///
  /// Throws an [AppException] subclass on failure.
  Future<ExportResult> call() async {
    final profile = await _profileRepository.getFirstProfile();
    if (profile == null) {
      throw const ValidationException(
        message: 'No profile found',
        code: 'NO_PROFILE',
      );
    }

    // Fetch in parallel for performance
    final results = await Future.wait([
      _accountRepository.getAccountsByUserId(profile.id),
      _categoryRepository.getAllCategories(),
    ]);

    final accounts = results[0] as dynamic;
    final categories = results[1] as dynamic;

    final transactions =
        await _transactionRepository.watchAllTransactions().first;

    return _exportService.generateCsv(
      transactions,
      accounts: accounts,
      categories: categories,
    );
  }
}
