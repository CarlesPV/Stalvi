import 'package:stalvi/core/errors/app_exceptions.dart';
import '../entities/tag.dart';
import '../repositories/i_account_repository.dart';
import '../repositories/i_category_repository.dart';
import '../repositories/i_export_service.dart';
import '../repositories/i_profile_repository.dart';
import '../repositories/i_tag_repository.dart';
import '../repositories/i_transaction_repository.dart';

/// Use case that retrieves **all non-deleted transactions** across every
/// account and packages them into a CSV [ExportResult].
///
/// The CSV includes the required columns:
/// Date, Type, Account, Category, Label, Amount, Currency, and Notes.
class ExportTransactionsCsvUseCase {
  final IProfileRepository _profileRepository;
  final IAccountRepository _accountRepository;
  final ICategoryRepository _categoryRepository;
  final ITagRepository? _tagRepository;
  final ITransactionRepository _transactionRepository;
  final IExportService _exportService;

  const ExportTransactionsCsvUseCase({
    required IProfileRepository profileRepository,
    required IAccountRepository accountRepository,
    required ICategoryRepository categoryRepository,
    ITagRepository? tagRepository,
    required ITransactionRepository transactionRepository,
    required IExportService exportService,
  })  : _profileRepository = profileRepository,
        _accountRepository = accountRepository,
        _categoryRepository = categoryRepository,
        _tagRepository = tagRepository,
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
      _tagRepository != null
          ? _tagRepository.getAllTags()
          : Future.value(<Tag>[]),
    ]);

    final accounts = results[0] as dynamic;
    final categories = results[1] as dynamic;
    final tags = results[2] as dynamic;

    final transactions =
        await _transactionRepository.watchAllTransactions().first;
    final allRawTransactions =
        await _transactionRepository.watchRawTransactions().first;

    return _exportService.generateCsv(
      transactions,
      accounts: accounts,
      categories: categories,
      tags: tags,
      allRawTransactions: allRawTransactions,
    );
  }
}
