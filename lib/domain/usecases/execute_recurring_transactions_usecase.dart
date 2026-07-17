import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../entities/automatic_transaction.dart';
import '../entities/recurrence_type.dart';
import '../entities/transaction.dart' as dtxn;
import '../repositories/i_account_repository.dart';
import '../repositories/i_automatic_transaction_repository.dart';
import '../repositories/i_exchange_rate_repository.dart';
import '../repositories/i_profile_repository.dart';
import '../repositories/i_transaction_repository.dart';
import 'package:uuid/uuid.dart';

class ExecuteRecurringTransactionsUseCase {
  final IAutomaticTransactionRepository automaticRepo;
  final ITransactionRepository transactionRepo;
  final IAccountRepository accountRepo;
  final IProfileRepository profileRepo;
  final IExchangeRateRepository exchangeRateRepo;

  ExecuteRecurringTransactionsUseCase(
    this.automaticRepo,
    this.transactionRepo,
    this.accountRepo,
    this.profileRepo,
    this.exchangeRateRepo,
  );

  Future<void> execute() async {
    // We execute the check using the current time
    final nowUtc = DateTime.now().toUtc();
    final nowUtcPlus2 = nowUtc.add(const Duration(hours: 2));

    // Truncate to 00:00:00 UTC+2, represented as a UTC DateTime
    // to avoid device-local timezone issues during calculation.
    final todayUtcPlus2 =
        DateTime.utc(nowUtcPlus2.year, nowUtcPlus2.month, nowUtcPlus2.day);

    debugPrint(
      '[ExecuteRecurringTxns] Starting evaluation. Today in UTC+2 is: $todayUtcPlus2',
    );

    final automaticTxns = await automaticRepo.getAllAutomaticTransactions();
    int fired = 0;
    int skipped = 0;

    for (final autoTxn in automaticTxns) {
      if (autoTxn.isDeleted || !autoTxn.isActive || autoTxn.deletedAt != null) {
        skipped++;
        continue;
      }

      // We ensure the nextExecutionDate is also treated as a UTC DateTime
      // representing the date in UTC+2.
      final nextDateUtcPlus2 = DateTime.utc(
        autoTxn.nextExecutionDate.year,
        autoTxn.nextExecutionDate.month,
        autoTxn.nextExecutionDate.day,
      );

      // Trigger if today is exactly the scheduled day, or we are past it
      if (nextDateUtcPlus2.isBefore(todayUtcPlus2) ||
          nextDateUtcPlus2.isAtSameMomentAs(todayUtcPlus2)) {
        try {
          await _fireTransaction(autoTxn, nowUtc, todayUtcPlus2);
          fired++;
        } catch (e, st) {
          debugPrint(
            '[ExecuteRecurringTxns] ERROR firing "${autoTxn.name}": $e\n$st',
          );
        }
      } else {
        skipped++;
      }
    }
    debugPrint('[ExecuteRecurringTxns] Done. fired=$fired skipped=$skipped');
  }

  Future<void> _fireTransaction(
    AutomaticTransaction autoTxn,
    DateTime nowUtc,
    DateTime executionDateUtcPlus2,
  ) async {
    final account = await accountRepo.getAccountById(autoTxn.accountId);
    final profile = account != null
        ? await profileRepo.getProfileById(account.userId)
        : null;

    final String originalCurrency = autoTxn.currency;
    final String defaultCurrency = profile?.defaultCurrency ?? originalCurrency;

    int? convertedAmount;
    double? exchangeRate;
    String? exchangeRateSnapshot;

    try {
      final localRates =
          await exchangeRateRepo.getLocalRates(baseCurrency: defaultCurrency);
      if (localRates != null) {
        final ratesMap = Map<String, double>.from(localRates.rates);
        ratesMap[localRates.baseCurrency] = 1.0;
        exchangeRateSnapshot = jsonEncode(ratesMap);
        if (originalCurrency != defaultCurrency) {
          exchangeRate = localRates.rateFor(originalCurrency);
        }
      }
    } catch (_) {}

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

    final newTxn = dtxn.Transaction(
      id: const Uuid().v4(),
      amount: autoTxn.amount,
      date: nowUtc,
      type: autoTxn.type,
      accountId: autoTxn.accountId,
      categoryId: autoTxn.categoryId,
      notes: autoTxn.notes,
      originalCurrency: originalCurrency,
      convertedAmount: convertedAmount,
      exchangeRate: exchangeRate,
      exchangeRateSnapshot: exchangeRateSnapshot,
      createdAt: nowUtc,
      modifiedAt: nowUtc,
    );

    await transactionRepo.createTransaction(newTxn);

    // Ensure we calculate the next execution date based on the *scheduled* date,
    // not today's date, to avoid drift if a task fires late.
    final nextDate = calculateNextTriggerDateUtcPlus2(
      autoTxn.nextExecutionDate,
      autoTxn.recurrenceType,
      autoTxn.recurrenceDays,
    );
    final updatedAutoTxn = autoTxn.copyWith(nextExecutionDate: nextDate);
    await automaticRepo.updateAutomaticTransaction(updatedAutoTxn);
  }

  /// Pure function that calculates the exact next trigger date in UTC+2 (truncating time to 00:00:00).
  static DateTime calculateNextTriggerDateUtcPlus2(
    DateTime fromDate,
    RecurrenceType type,
    int recurrenceDays,
  ) {
    // Ensure fromDate is treated as a pure Date (00:00:00) in UTC for calculation
    final fromUtc2 = DateTime.utc(fromDate.year, fromDate.month, fromDate.day);
    DateTime nextDate = fromUtc2;

    switch (type) {
      case RecurrenceType.intervalDays:
        nextDate = fromUtc2.add(Duration(days: recurrenceDays));
        break;
      case RecurrenceType.weekly:
        nextDate = fromUtc2.add(const Duration(days: 7));
        break;
      case RecurrenceType.monthly:
        nextDate = _advanceByMonths(fromUtc2, 1, fromUtc2.day);
        break;
      case RecurrenceType.yearly:
        nextDate = _advanceByYears(fromUtc2, 1, fromUtc2.month, fromUtc2.day);
        break;
      case RecurrenceType.specificDayOfMonth:
        nextDate = _advanceByMonths(fromUtc2, 1, recurrenceDays);
        break;
    }
    return nextDate;
  }

  static DateTime _advanceByMonths(DateTime from, int months, int targetDay) {
    int newMonth = from.month + months;
    int newYear = from.year;
    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }
    final lastDay = DateTime.utc(newYear, newMonth + 1, 0).day;
    final day = targetDay.clamp(1, lastDay);
    return DateTime.utc(newYear, newMonth, day);
  }

  static DateTime _advanceByYears(
    DateTime from,
    int years,
    int targetMonth,
    int targetDay,
  ) {
    final newYear = from.year + years;
    final lastDay = DateTime.utc(newYear, targetMonth + 1, 0).day;
    final day = targetDay.clamp(1, lastDay);
    return DateTime.utc(newYear, targetMonth, day);
  }
}
