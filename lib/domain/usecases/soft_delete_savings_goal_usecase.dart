import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_savings_goal_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:uuid/uuid.dart';

class SoftDeleteSavingsGoalUseCase {
  final ISavingsGoalRepository _savingsGoalRepository;
  final ITransactionRepository _transactionRepository;

  static const _uuid = Uuid();

  SoftDeleteSavingsGoalUseCase(
    this._savingsGoalRepository,
    this._transactionRepository,
  );

  Future<void> execute(String goalId) async {
    // 1. Fetch the goal
    final goal = await _savingsGoalRepository.getSavingsGoalById(goalId);
    if (goal == null) {
      throw NotFoundException(
        message: 'Savings goal with id "$goalId" not found',
        code: 'GOAL_NOT_FOUND',
      );
    }

    // 2. Mark as soft-deleted
    await _savingsGoalRepository.deleteSavingsGoal(goalId);

    // 3. Find all transfer transactions directed to this goal
    // Note: The watchFilteredTransactions doesn't filter by savingsGoalId natively in the DAO yet,
    // so we fetch all transfers and filter in memory, or if the filter is updated, we use it.
    // For now we get all transfers and filter.
    final transactionsStream = _transactionRepository.watchAllTransactions();
    final allTransactions = await transactionsStream.first;

    final goalTransfers = allTransactions
        .where(
          (tx) =>
              tx.type == TransactionType.transfer && tx.savingsGoalId == goalId,
        )
        .toList();

    // 4. Create compensatory transactions (refund)
    final now = DateTime.now();
    for (final tx in goalTransfers) {
      // The original transaction was an outflow from the origin account, so amount was positive (but debited in repo).
      // Wait, in AddTransactionUseCase we created it with params.amount, and it was debited.
      // To refund it, we create an inflow (income) transaction.
      // Wait, if we use TransactionType.transfer without transferId, it will act as an origin leg and debit it again!
      // To credit the account, we should create an `income` transaction or a `transfer` destination leg.
      // Creating an `income` transaction is safer to just credit the account back.

      final refundTx = Transaction(
        id: _uuid.v4(),
        amount: tx.amount,
        date: now,
        type: TransactionType.income, // Refund is income
        accountId: tx.accountId,
        categoryId: tx.categoryId,
        notes: 'Refund from deleted goal: ${goal.name}',
        originalCurrency: tx.originalCurrency,
        convertedAmount: tx.convertedAmount,
        exchangeRate: tx.exchangeRate,
        exchangeRateSnapshot: tx.exchangeRateSnapshot,
        createdAt: now,
        modifiedAt: now,
      );

      await _transactionRepository.createTransaction(refundTx);
    }
  }
}
