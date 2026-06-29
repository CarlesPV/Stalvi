import 'package:stalvi/core/errors/app_exceptions.dart';
import '../entities/account.dart';
import '../entities/category.dart';
import '../entities/tag.dart';
import '../repositories/i_account_repository.dart';
import '../repositories/i_category_repository.dart';
import '../repositories/i_export_service.dart';
import '../repositories/i_profile_repository.dart';
import '../repositories/i_tag_repository.dart';
import '../repositories/i_transaction_repository.dart';

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

  Future<ExportResult> call({required String password}) async {
    if (password.isEmpty) {
      throw const ValidationException(
        message: 'A password is required for encrypted export',
        code: 'EMPTY_PASSWORD',
      );
    }

    final profile = await _profileRepository.getFirstProfile();
    if (profile == null) {
      throw const ValidationException(
        message: 'No profile found',
        code: 'NO_PROFILE',
      );
    }

    final results = await Future.wait([
      _accountRepository.getAccountsByUserId(profile.id),
      _categoryRepository.getAllCategories(),
      _tagRepository.getAllTags(),
    ]);

    final accounts = List<Account>.from(results[0] as Iterable);
    final categories = List<Category>.from(results[1] as Iterable);
    final tags = List<Tag>.from(results[2] as Iterable);

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
