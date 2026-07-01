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

final automaticTransactionsListProvider =
    FutureProvider<List<AutomaticTransaction>>((ref) async {
  final readUseCase = ref.watch(readAutomaticTransactionUseCaseProvider);
  final all = await readUseCase.executeAll();
  return all.where((txn) => !txn.isDeleted).toList();
});
