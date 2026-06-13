import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/repositories/account_repository.dart';
import 'package:konta/data/repositories/category_repository.dart';
import 'package:konta/data/repositories/profile_repository.dart';
import 'package:konta/data/repositories/transaction_repository.dart';
import 'package:konta/data/mappers/profile_mapper.dart';
import 'package:konta/domain/entities/account.dart';
import 'package:konta/domain/entities/category.dart';
import 'package:konta/domain/entities/profile.dart';
import 'package:konta/domain/repositories/i_account_repository.dart';
import 'package:konta/domain/repositories/i_category_repository.dart';
import 'package:konta/domain/repositories/i_profile_repository.dart';
import 'package:konta/domain/repositories/i_transaction_repository.dart';
import 'package:konta/domain/usecases/add_transaction_usecase.dart';
import 'package:konta/presentation/providers/app_startup_provider.dart';

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

/// Provides the [ITransactionRepository] implementation.
final transactionRepositoryProvider = Provider<ITransactionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  return TransactionRepository(db);
});

/// Provides the [AddTransactionUseCase] instance.
final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  final accountRepo = ref.watch(accountRepositoryProvider);
  return AddTransactionUseCase(transactionRepo, accountRepo);
});

/// Fetches the default profile (usually Anonymous) seeded on DB creation.
final defaultProfileProvider = FutureProvider<Profile>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final rows = await db.select(db.profiles).get();
  if (rows.isEmpty) {
    throw StateError('No profile found. Database initialization seeding may have failed.');
  }
  return rows.first.toDomain();
});

/// Fetches the list of accounts associated with the default profile.
final accountsListProvider = FutureProvider<List<Account>>((ref) async {
  final profile = await ref.watch(defaultProfileProvider.future);
  final repo = ref.watch(accountRepositoryProvider);
  return repo.getAccountsByUserId(profile.id);
});

/// Fetches the list of all categories.
final categoriesListProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getAllCategories();
});
