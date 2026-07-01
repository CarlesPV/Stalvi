import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/usecases/automatic_transactions/crud_automatic_transactions_usecase.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';

final createAutomaticTransactionUseCaseProvider = Provider((ref) {
  final repo = ref.watch(automaticTransactionRepositoryProvider);
  return CreateAutomaticTransactionUseCase(repo);
});

final readAutomaticTransactionUseCaseProvider = Provider((ref) {
  final repo = ref.watch(automaticTransactionRepositoryProvider);
  return ReadAutomaticTransactionUseCase(repo);
});

final updateAutomaticTransactionUseCaseProvider = Provider((ref) {
  final repo = ref.watch(automaticTransactionRepositoryProvider);
  return UpdateAutomaticTransactionUseCase(repo);
});

final deleteAutomaticTransactionUseCaseProvider = Provider((ref) {
  final repo = ref.watch(automaticTransactionRepositoryProvider);
  return DeleteAutomaticTransactionUseCase(repo);
});

final restoreAutomaticTransactionUseCaseProvider = Provider((ref) {
  final repo = ref.watch(automaticTransactionRepositoryProvider);
  return RestoreAutomaticTransactionUseCase(repo);
});

/// Reactive stream of non-deleted automatic transactions.
///
/// Backed by a Drift stream so any create / update / delete on the table
/// triggers an automatic re-emission without manual [ref.invalidate] calls.
final automaticTransactionsListProvider =
    StreamProvider<List<AutomaticTransaction>>((ref) {
  final repo = ref.watch(automaticTransactionRepositoryProvider);
  return repo.watchAllAutomaticTransactions().map(
        (all) => all.where((txn) => !txn.isDeleted).toList(),
      );
});
