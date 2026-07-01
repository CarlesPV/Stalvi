import '../../entities/automatic_transaction.dart';
import '../../entities/transaction.dart' as dtxn;
import '../../repositories/i_automatic_transaction_repository.dart';
import '../../repositories/i_transaction_repository.dart';
import 'package:uuid/uuid.dart';

class EvaluateAutomaticTransactionsUseCase {
  final IAutomaticTransactionRepository automaticRepo;
  final ITransactionRepository transactionRepo;

  EvaluateAutomaticTransactionsUseCase(
    this.automaticRepo,
    this.transactionRepo,
  );

  Future<void> execute() async {
    final now = DateTime.now();
    final automaticTxns = await automaticRepo.getAllAutomaticTransactions();

    for (final autoTxn in automaticTxns) {
      if (autoTxn.nextExecutionDate.isBefore(now) ||
          autoTxn.nextExecutionDate.isAtSameMomentAs(now)) {
        // Generate actual transaction
        final newTxn = dtxn.Transaction(
          id: const Uuid().v4(),
          amount: autoTxn.amount,
          date: now,
          type: autoTxn.type,
          accountId: autoTxn.accountId,
          categoryId: autoTxn.categoryId,
          notes: autoTxn.notes,
          originalCurrency: 'EUR', // Need to fetch from account ideally
          createdAt: now,
          modifiedAt: now,
        );

        await transactionRepo.createTransaction(newTxn);

        // Update next_execution_date
        final nextDate = autoTxn.nextExecutionDate
            .add(Duration(days: autoTxn.recurrenceDays));
        final updatedAutoTxn = AutomaticTransaction(
          id: autoTxn.id,
          name: autoTxn.name,
          amount: autoTxn.amount,
          currency: autoTxn.currency,
          type: autoTxn.type,
          accountId: autoTxn.accountId,
          categoryId: autoTxn.categoryId,
          tagId: autoTxn.tagId,
          notes: autoTxn.notes,
          recurrenceDays: autoTxn.recurrenceDays,
          nextExecutionDate: nextDate,
          createdAt: autoTxn.createdAt,
        );
        await automaticRepo.updateAutomaticTransaction(updatedAutoTxn);
      }
    }
  }
}
