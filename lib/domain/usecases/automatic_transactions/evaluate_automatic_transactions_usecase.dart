import '../../entities/automatic_transaction.dart';
import '../../entities/transaction.dart' as dtxn;
import '../../entities/recurrence_type.dart';
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
      if (autoTxn.isDeleted || !autoTxn.isActive || autoTxn.deletedAt != null) {
        continue;
      }

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
        DateTime nextDate;
        if (autoTxn.recurrenceType == RecurrenceType.intervalDays) {
          nextDate = autoTxn.nextExecutionDate
              .add(Duration(days: autoTxn.recurrenceDays));
        } else {
          int nextMonth = autoTxn.nextExecutionDate.month + 1;
          int nextYear = autoTxn.nextExecutionDate.year;
          if (nextMonth > 12) {
            nextMonth = 1;
            nextYear++;
          }
          int targetDay = autoTxn.recurrenceDays;
          int lastDayOfNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
          if (targetDay > lastDayOfNextMonth) {
            targetDay = lastDayOfNextMonth;
          }
          nextDate = DateTime(
            nextYear,
            nextMonth,
            targetDay,
            autoTxn.nextExecutionDate.hour,
            autoTxn.nextExecutionDate.minute,
            autoTxn.nextExecutionDate.second,
          );
        }

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
          recurrenceType: autoTxn.recurrenceType,
          recurrenceDays: autoTxn.recurrenceDays,
          nextExecutionDate: nextDate,
          createdAt: autoTxn.createdAt,
        );
        await automaticRepo.updateAutomaticTransaction(updatedAutoTxn);
      }
    }
  }
}
