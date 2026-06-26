import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/utils/navigator_key.dart';
import 'package:stalvi/presentation/features/splash/splash_screen.dart';
import 'package:stalvi/data/repositories/account_repository.dart';
import 'package:stalvi/data/repositories/category_repository.dart';
import 'package:stalvi/data/repositories/tag_repository.dart';
import 'package:stalvi/data/repositories/profile_repository.dart';
import 'package:stalvi/data/repositories/statistics_repository_impl.dart';
import 'package:stalvi/data/repositories/transaction_repository.dart';
import 'package:stalvi/data/repositories/exchange_rate_repository.dart';
import 'package:stalvi/data/repositories/budget_repository.dart';
import 'package:stalvi/data/repositories/savings_goal_repository.dart';
import 'package:stalvi/data/repositories/export_service_impl.dart';
import 'package:stalvi/data/repositories/import_service_impl.dart';
import 'package:stalvi/data/network/exchange_rate_remote_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:stalvi/data/mappers/profile_mapper.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/tag.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/entities/budget.dart';
import 'package:stalvi/domain/entities/savings_goal.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/repositories/i_tag_repository.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/repositories/i_budget_repository.dart';
import 'package:stalvi/domain/repositories/i_savings_goal_repository.dart';
import 'package:stalvi/domain/repositories/i_statistics_repository.dart';
import 'package:stalvi/domain/repositories/i_export_service.dart';
import 'package:stalvi/domain/repositories/i_import_service.dart';
import 'package:stalvi/domain/usecases/add_transaction_usecase.dart';
import 'package:stalvi/domain/usecases/create_profile_usecase.dart';
import 'package:stalvi/domain/usecases/initialize_default_data_usecase.dart';
import 'package:stalvi/domain/usecases/update_credentials_usecase.dart';
import 'package:stalvi/domain/usecases/wipe_all_data_usecase.dart';
import 'package:stalvi/domain/usecases/trash_usecases.dart';
import 'package:stalvi/domain/usecases/create_account_usecase.dart';
import 'package:stalvi/domain/usecases/update_account_usecase.dart';
import 'package:stalvi/domain/usecases/delete_account_usecase.dart';
import 'package:stalvi/domain/usecases/soft_delete_savings_goal_usecase.dart';
import 'package:stalvi/domain/usecases/update_budget_progress_usecase.dart';
import 'package:stalvi/domain/usecases/delete_and_reassign_category_usecase.dart';
import 'package:stalvi/domain/usecases/delete_and_reassign_tag_usecase.dart';
import 'package:stalvi/domain/usecases/export_encrypted_json_use_case.dart';
import 'package:stalvi/domain/usecases/import_encrypted_json_use_case.dart';
import 'package:stalvi/domain/usecases/export_transactions_csv_use_case.dart';
import 'package:stalvi/domain/usecases/export_monthly_pdf_use_case.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/presentation/providers/app_startup_provider.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';
import 'package:stalvi/presentation/providers/statistics_providers.dart';

/// Provides the [IProfileRepository] implementation.
/// Requires the database to be initialized, using [appDatabaseProvider.requireValue].
final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  return ProfileRepository(db);
});

/// Provides the [IAccountRepository] implementation.
final accountRepositoryProvider = Provider<IAccountRepository>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  return AccountRepository(db);
});

/// Provides the [ICategoryRepository] implementation.
final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  return CategoryRepository(db);
});

/// Provides the [ITagRepository] implementation.
final tagRepositoryProvider = Provider<ITagRepository>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  return TagRepository(db);
});

/// Provides the [ITransactionRepository] implementation.
final transactionRepositoryProvider = Provider<ITransactionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  return TransactionRepository(db);
});

/// Provides the [IBudgetRepository] implementation.
final budgetRepositoryProvider = Provider<IBudgetRepository>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  return BudgetRepository(db);
});

/// Provides the [ISavingsGoalRepository] implementation.
final savingsGoalRepositoryProvider = Provider<ISavingsGoalRepository>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  return SavingsGoalRepository(db);
});

/// Provides the [IStatisticsRepository] implementation.
final statisticsRepositoryProvider = Provider<IStatisticsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  return StatisticsRepositoryImpl(db.statisticsDao);
});

/// Provides the [IExchangeRateRepository] implementation.
final exchangeRateRepositoryProvider = Provider<IExchangeRateRepository>((ref) {
  final client = http.Client();
  final remoteDataSource = ExchangeRateRemoteDataSourceImpl(httpClient: client);
  final db = ref.watch(appDatabaseProvider).requireValue;
  return ExchangeRateRepository(
    remoteDataSource: remoteDataSource,
    exchangeRateDao: db.exchangeRateDao,
  );
});

/// Provides the [UpdateBudgetProgressUseCase] instance.
final updateBudgetProgressUseCaseProvider =
    Provider<UpdateBudgetProgressUseCase>((ref) {
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  final accountRepo = ref.watch(accountRepositoryProvider);
  final exchangeRateRepo = ref.watch(exchangeRateRepositoryProvider);
  return UpdateBudgetProgressUseCase(
    budgetRepo,
    transactionRepo,
    accountRepo,
    exchangeRateRepo,
  );
});

/// Provides the [AddTransactionUseCase] instance.
final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  final accountRepo = ref.watch(accountRepositoryProvider);
  final profileRepo = ref.watch(profileRepositoryProvider);
  final exchangeRateRepo = ref.watch(exchangeRateRepositoryProvider);
  return AddTransactionUseCase(
    transactionRepo,
    accountRepo,
    profileRepo,
    exchangeRateRepo,
    ref.watch(savingsGoalRepositoryProvider),
    ref.watch(updateBudgetProgressUseCaseProvider),
  );
});

/// Provides the [CreateProfileUseCase] instance.
final createProfileUseCaseProvider = Provider<CreateProfileUseCase>((ref) {
  final profileRepo = ref.watch(profileRepositoryProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final createAccount = ref.watch(createAccountUseCaseProvider);
  final initDefaultData = ref.watch(initializeDefaultDataUseCaseProvider);
  return CreateProfileUseCase(
    profileRepo,
    secureStorage,
    createAccount,
    initDefaultData,
  );
});

/// Provides the [InitializeDefaultDataUseCase] instance.
///
/// Note: account creation has been removed from this use case. The default
/// account is now created by [CreateProfileUseCase] after the profile is
/// persisted, ensuring the account currency always matches the profile.
final initializeDefaultDataUseCaseProvider =
    Provider<InitializeDefaultDataUseCase>((ref) {
  final categoryRepo = ref.watch(categoryRepositoryProvider);
  final tagRepo = ref.watch(tagRepositoryProvider);
  return InitializeDefaultDataUseCase(categoryRepo, tagRepo);
});

/// Provides the [CreateAccountUseCase] instance.
final createAccountUseCaseProvider = Provider<CreateAccountUseCase>((ref) {
  final accountRepo = ref.watch(accountRepositoryProvider);
  return CreateAccountUseCase(accountRepo);
});

/// Provides the [DeleteAccountUseCase] instance.
final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  final accountRepo = ref.watch(accountRepositoryProvider);
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  return DeleteAccountUseCase(accountRepo, budgetRepo);
});

/// Provides the [UpdateAccountUseCase] instance.
///
/// The use case enforces that [Account.initialBalance] and [Account.currency]
/// are immutable after creation — any attempt to mutate them will throw a
/// [ValidationException] with code `IMMUTABLE_FIELD`.
final updateAccountUseCaseProvider = Provider<UpdateAccountUseCase>((ref) {
  final accountRepo = ref.watch(accountRepositoryProvider);
  return UpdateAccountUseCase(accountRepo);
});

/// Provides the [UpdateCredentialsUseCase] instance.
final updateCredentialsUseCaseProvider =
    Provider<UpdateCredentialsUseCase>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return UpdateCredentialsUseCase(secureStorage);
});

/// Provides the [WipeAllDataUseCase] instance.
final wipeAllDataUseCaseProvider = Provider<WipeAllDataUseCase>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final db = ref.watch(appDatabaseProvider).requireValue;
  return WipeAllDataUseCase(secureStorage, db);
});

/// Provides the [TrashUsecases] instance.
final trashUsecasesProvider = Provider<TrashUsecases>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  final accountRepo = ref.watch(accountRepositoryProvider);
  final updateBudgetProgressUseCase =
      ref.watch(updateBudgetProgressUseCaseProvider);
  return TrashUsecases(
    db.trashDao,
    transactionRepo,
    accountRepo,
    updateBudgetProgressUseCase,
    db.savingsGoalDao,
  );
});

/// Fetches the default profile (usually Anonymous) seeded on DB creation.
final defaultProfileProvider = FutureProvider<Profile>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final rows = await db.select(db.profiles).get();
  if (rows.isEmpty) {
    throw StateError(
      'No profile found. Database initialization seeding may have failed.',
    );
  }
  return rows.first.toDomain();
});

/// Fetches the list of accounts associated with the default profile.
final accountsListProvider = StreamProvider<List<Account>>((ref) async* {
  final profile = await ref.watch(defaultProfileProvider.future);
  final repo = ref.watch(accountRepositoryProvider);
  yield* repo.watchAccountsByUserId(profile.id);
});

/// Fetches the list of all categories.
final categoriesListProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchAllCategories();
});

/// Stream of all active budgets.
final budgetsStreamProvider = StreamProvider<List<Budget>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.watchBudgets();
});

/// Stream of all active savings goals.
final savingsGoalsStreamProvider = StreamProvider<List<SavingsGoal>>((ref) {
  final repo = ref.watch(savingsGoalRepositoryProvider);
  return repo.watchSavingsGoals();
});

/// Stream of all transactions.
final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchAllTransactions();
});

/// Stream of all raw transactions, including all legs of transfers.
final rawTransactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchRawTransactions();
});

/// Fetches the list of all tags.
final tagsListProvider = FutureProvider<List<Tag>>((ref) {
  final repo = ref.watch(tagRepositoryProvider);
  return repo.getAllTags();
});

/// Provides the [DeleteAndReassignCategoryUseCase] instance.
final deleteAndReassignCategoryUseCaseProvider =
    Provider<DeleteAndReassignCategoryUseCase>((ref) {
  final categoryRepo = ref.watch(categoryRepositoryProvider);
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return DeleteAndReassignCategoryUseCase(categoryRepo, transactionRepo);
});

/// Provides the [DeleteAndReassignTagUseCase] instance.
final deleteAndReassignTagUseCaseProvider =
    Provider<DeleteAndReassignTagUseCase>((ref) {
  final tagRepo = ref.watch(tagRepositoryProvider);
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return DeleteAndReassignTagUseCase(tagRepo, transactionRepo);
});

/// Provides the [SoftDeleteSavingsGoalUseCase] instance.
final softDeleteSavingsGoalUseCaseProvider =
    Provider<SoftDeleteSavingsGoalUseCase>((ref) {
  final savingsGoalRepo = ref.watch(savingsGoalRepositoryProvider);
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return SoftDeleteSavingsGoalUseCase(savingsGoalRepo, transactionRepo);
});

/// Provides the [IExportService] implementation.
final exportServiceProvider = Provider<IExportService>((ref) {
  return ExportServiceImpl();
});

/// Provides the [IImportService] implementation.
final importServiceProvider = Provider<IImportService>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final exportService = ref.watch(exportServiceProvider);
  return ImportServiceImpl(
    database: db,
    exportService: exportService,
    onImportSuccess: () {
      // 1. Invalidate Riverpod providers (all data-related ones)
      ref.invalidate(appDatabaseProvider);
      ref.invalidate(appStartupProvider);
      ref.invalidate(defaultProfileProvider);
      ref.invalidate(accountsListProvider);
      ref.invalidate(categoriesListProvider);
      ref.invalidate(budgetsStreamProvider);
      ref.invalidate(savingsGoalsStreamProvider);
      ref.invalidate(transactionsStreamProvider);
      ref.invalidate(rawTransactionsStreamProvider);
      ref.invalidate(tagsListProvider);

      // 2. Clear background memory (image/drawing cache)
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // 3. Restart/redirect to Splash
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (_) => false,
      );
    },
  );
});

/// Provides the [ExportEncryptedJsonUseCase] instance.
final exportEncryptedJsonUseCaseProvider =
    Provider<ExportEncryptedJsonUseCase>((ref) {
  return ExportEncryptedJsonUseCase(
    profileRepository: ref.watch(profileRepositoryProvider),
    accountRepository: ref.watch(accountRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
    tagRepository: ref.watch(tagRepositoryProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
    exportService: ref.watch(exportServiceProvider),
  );
});

/// Provides the [ImportEncryptedJsonUseCase] instance.
final importEncryptedJsonUseCaseProvider =
    Provider<ImportEncryptedJsonUseCase>((ref) {
  return ImportEncryptedJsonUseCase(
    importService: ref.watch(importServiceProvider),
  );
});

/// Provides the [ExportTransactionsCsvUseCase] instance.
final exportTransactionsCsvUseCaseProvider =
    Provider<ExportTransactionsCsvUseCase>((ref) {
  return ExportTransactionsCsvUseCase(
    profileRepository: ref.watch(profileRepositoryProvider),
    accountRepository: ref.watch(accountRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
    exportService: ref.watch(exportServiceProvider),
  );
});

/// Provides the [ExportMonthlyPdfUseCase] instance.
final exportMonthlyPdfUseCaseProvider =
    Provider<ExportMonthlyPdfUseCase>((ref) {
  final locale = ref.watch(localeProvider);
  final l10n = lookupAppLocalizations(locale);
  return ExportMonthlyPdfUseCase(
    profileRepository: ref.watch(profileRepositoryProvider),
    accountRepository: ref.watch(accountRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
    exchangeRateRepository: ref.watch(exchangeRateRepositoryProvider),
    getPeriodSummaryUseCase: ref.watch(getPeriodSummaryUseCaseProvider),
    getTopCategoriesUseCase: ref.watch(getTopCategoriesUseCaseProvider),
    budgetRepository: ref.watch(budgetRepositoryProvider),
    savingsGoalRepository: ref.watch(savingsGoalRepositoryProvider),
    exportService: ref.watch(exportServiceProvider),
    l10n: l10n,
  );
});
