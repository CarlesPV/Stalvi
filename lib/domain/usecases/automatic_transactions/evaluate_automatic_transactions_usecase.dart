import 'dart:convert';

import '../../entities/automatic_transaction.dart';
import '../../entities/transaction.dart' as dtxn;
import '../../repositories/i_account_repository.dart';
import '../../repositories/i_automatic_transaction_repository.dart';
import '../../repositories/i_exchange_rate_repository.dart';
import '../../repositories/i_profile_repository.dart';
import '../../repositories/i_transaction_repository.dart';
import 'package:uuid/uuid.dart';

/// Evaluates all active [AutomaticTransaction]s and fires any that are due,
/// creating real [Transaction]s with correct currency and exchange rate data.
///
/// **Execution contract**:
/// - Runs daily at 00:00 UTC+2 (22:00 UTC) via WorkManager.
/// - Uses the automatic transaction's stored [AutomaticTransaction.currency]
///   as the `originalCurrency`, mirroring manual transaction behaviour.
/// - Fetches local exchange rates first; falls back to remote only when a
///   currency conversion is required and local rates are unavailable.
/// - Advances [AutomaticTransaction.nextExecutionDate] by exactly one
///   recurrence period after each firing so the next evaluation knows
///   whether to fire again.
class EvaluateAutomaticTransactionsUseCase {
  final IAutomaticTransactionRepository automaticRepo;
  final ITransactionRepository transactionRepo;
  final IAccountRepository accountRepo;
  final IProfileRepository profileRepo;
  final IExchangeRateRepository exchangeRateRepo;

  EvaluateAutomaticTransactionsUseCase(
    this.automaticRepo,
    this.transactionRepo,
    this.accountRepo,
    this.profileRepo,
    this.exchangeRateRepo,
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
        await _fireTransaction(autoTxn, now);
      }
    }
  }

  Future<void> _fireTransaction(
    AutomaticTransaction autoTxn,
    DateTime now,
  ) async {
    // ── Currency resolution ──────────────────────────────────────────────────
    final account = await accountRepo.getAccountById(autoTxn.accountId);
    final profile = account != null
        ? await profileRepo.getProfileById(account.userId)
        : null;

    final String originalCurrency = autoTxn.currency;
    final String defaultCurrency = profile?.defaultCurrency ?? originalCurrency;

    int? convertedAmount;
    double? exchangeRate;
    String? exchangeRateSnapshot;

    // Always try to attach a rate snapshot for auditability.
    try {
      final localRates = await exchangeRateRepo.getLocalRates(
        baseCurrency: defaultCurrency,
      );
      if (localRates != null) {
        final ratesMap = Map<String, double>.from(localRates.rates);
        ratesMap[localRates.baseCurrency] = 1.0;
        exchangeRateSnapshot = jsonEncode(ratesMap);

        if (originalCurrency != defaultCurrency) {
          exchangeRate = localRates.rateFor(originalCurrency);
        }
      }
    } catch (_) {}

    // If we need conversion and still lack a rate, fetch from remote.
    if (originalCurrency != defaultCurrency && exchangeRate == null) {
      try {
        final remoteRates = await exchangeRateRepo.getLatestRates(
          baseCurrency: defaultCurrency,
        );
        final ratesMap = Map<String, double>.from(remoteRates.rates);
        ratesMap[remoteRates.baseCurrency] = 1.0;
        exchangeRateSnapshot ??= jsonEncode(ratesMap);
        exchangeRate = remoteRates.rateFor(originalCurrency);
      } catch (_) {}
    }

    if (originalCurrency != defaultCurrency && exchangeRate != null) {
      convertedAmount = (autoTxn.amount / exchangeRate).round();
    }

    // ── Create the real transaction ──────────────────────────────────────────
    final newTxn = dtxn.Transaction(
      id: const Uuid().v4(),
      amount: autoTxn.amount,
      date: now,
      type: autoTxn.type,
      accountId: autoTxn.accountId,
      categoryId: autoTxn.categoryId,
      notes: autoTxn.notes,
      originalCurrency: originalCurrency,
      convertedAmount: convertedAmount,
      exchangeRate: exchangeRate,
      exchangeRateSnapshot: exchangeRateSnapshot,
      createdAt: now,
      modifiedAt: now,
    );

    await transactionRepo.createTransaction(newTxn);

    // ── Advance next execution date ──────────────────────────────────────────
    // Always advance from the stored nextExecutionDate (not `now`) so that
    // calendar-based recurrences (monthly, yearly, specificDayOfMonth) land
    // on the correct date even when the task fires slightly late.
    final nextDate =
        autoTxn.calculateNextExecutionDate(autoTxn.nextExecutionDate);

    final updatedAutoTxn = autoTxn.copyWith(nextExecutionDate: nextDate);
    await automaticRepo.updateAutomaticTransaction(updatedAutoTxn);
  }
}
