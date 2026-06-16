import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/repositories/account_repository.dart';
import 'package:konta/data/repositories/category_repository.dart';
import 'package:konta/data/repositories/tag_repository.dart';
import 'package:konta/data/repositories/profile_repository.dart';
import 'package:konta/data/repositories/statistics_repository_impl.dart';
import 'package:konta/data/repositories/transaction_repository.dart';
import 'package:konta/data/repositories/exchange_rate_repository.dart';
import 'package:konta/data/repositories/budget_repository.dart';
import 'package:konta/data/repositories/savings_goal_repository.dart';
import 'package:konta/data/network/exchange_rate_remote_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:konta/data/mappers/profile_mapper.dart';
import 'package:konta/domain/entities/account.dart';
import 'package:konta/domain/entities/category.dart';
import 'package:konta/domain/entities/tag.dart';
import 'package:konta/domain/entities/profile.dart';
import 'package:konta/domain/entities/budget.dart';
import 'package:konta/domain/entities/savings_goal.dart';
import 'package:konta/domain/entities/transaction.dart';
import 'package:konta/domain/repositories/i_account_repository.dart';
import 'package:konta/domain/repositories/i_category_repository.dart';
import 'package:konta/domain/repositories/i_tag_repository.dart';
import 'package:konta/domain/repositories/i_profile_repository.dart';
import 'package:konta/domain/repositories/i_transaction_repository.dart';
import 'package:konta/domain/repositories/i_exchange_rate_repository.dart';
import 'package:konta/domain/repositories/i_budget_repository.dart';
import 'package:konta/domain/repositories/i_savings_goal_repository.dart';
import 'package:konta/domain/repositories/i_statistics_repository.dart';
import 'package:konta/domain/usecases/add_transaction_usecase.dart';
import 'package:konta/domain/usecases/create_profile_usecase.dart';
import 'package:konta/domain/usecases/initialize_default_data_usecase.dart';
import 'package:konta/domain/usecases/update_credentials_usecase.dart';
import 'package:konta/domain/usecases/wipe_all_data_usecase.dart';
import 'package:konta/domain/usecases/trash_usecases.dart';
import 'package:konta/presentation/providers/app_startup_provider.dart';
import 'package:konta/presentation/providers/locale_provider.dart';

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
  return ExchangeRateRepository(remoteDataSource: remoteDataSource);
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
  );
});

/// Provides the [CreateProfileUseCase] instance.
final createProfileUseCaseProvider = Provider<CreateProfileUseCase>((ref) {
  final profileRepo = ref.watch(profileRepositoryProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return CreateProfileUseCase(profileRepo, secureStorage);
});

/// Provides the [InitializeDefaultDataUseCase] instance.
final initializeDefaultDataUseCaseProvider =
    Provider<InitializeDefaultDataUseCase>((ref) {
  final accountRepo = ref.watch(accountRepositoryProvider);
  final categoryRepo = ref.watch(categoryRepositoryProvider);
  final tagRepo = ref.watch(tagRepositoryProvider);
  return InitializeDefaultDataUseCase(accountRepo, categoryRepo, tagRepo);
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
  return TrashUsecases(db.trashDao);
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

/// Fetches the list of all tags.
final tagsListProvider = FutureProvider<List<Tag>>((ref) {
  final repo = ref.watch(tagRepositoryProvider);
  return repo.getAllTags();
});
