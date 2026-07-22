import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:uuid/uuid.dart';
import '../entities/automatic_transaction.dart';
import '../entities/recurrence_type.dart';
import '../entities/transaction.dart' as dtxn;
import '../repositories/i_account_repository.dart';
import '../repositories/i_automatic_transaction_repository.dart';
import '../repositories/i_exchange_rate_repository.dart';
import '../repositories/i_profile_repository.dart';
import '../repositories/i_transaction_repository.dart';
import '../repositories/i_settings_repository.dart';
import '../../infrastructure/services/notification_service.dart';

class ExecuteRecurringTransactionsUseCase {
  final IAutomaticTransactionRepository automaticRepo;
  final ITransactionRepository transactionRepo;
  final IAccountRepository accountRepo;
  final IProfileRepository profileRepo;
  final IExchangeRateRepository exchangeRateRepo;
  final NotificationService? notificationService;
  final ISettingsRepository? settingsRepo;

  ExecuteRecurringTransactionsUseCase(
    this.automaticRepo,
    this.transactionRepo,
    this.accountRepo,
    this.profileRepo,
    this.exchangeRateRepo, [
    this.notificationService,
    this.settingsRepo,
  ]);

  Future<void> execute() async {
    final nowUtc = DateTime.now().toUtc();
    final nowUtcPlus2 = nowUtc.add(const Duration(hours: 2));
    final todayUtcPlus2 =
        DateTime.utc(nowUtcPlus2.year, nowUtcPlus2.month, nowUtcPlus2.day);

    final automaticTxns = await automaticRepo.getAllAutomaticTransactions();

    for (final autoTxn in automaticTxns) {
      if (autoTxn.isDeleted || !autoTxn.isActive || autoTxn.deletedAt != null) {
        continue;
      }

      var currentAutoTxn = autoTxn;

      while (true) {
        final nextDateUtc = currentAutoTxn.nextExecutionDate.toUtc();
        final nextDateUtcPlus2Instant =
            nextDateUtc.add(const Duration(hours: 2));
        final nextDateUtcPlus2 = DateTime.utc(
          nextDateUtcPlus2Instant.year,
          nextDateUtcPlus2Instant.month,
          nextDateUtcPlus2Instant.day,
        );

        if (nextDateUtcPlus2.isBefore(todayUtcPlus2) ||
            nextDateUtcPlus2.isAtSameMomentAs(todayUtcPlus2)) {
          try {
            await _fireTransaction(currentAutoTxn, nowUtc, nextDateUtcPlus2);

            final nextDate = calculateNextTriggerDateUtcPlus2(
              currentAutoTxn.nextExecutionDate,
              currentAutoTxn.recurrenceType,
              currentAutoTxn.recurrenceDays,
            );

            if (!nextDate.isAfter(currentAutoTxn.nextExecutionDate)) {
              break;
            }

            currentAutoTxn =
                currentAutoTxn.copyWith(nextExecutionDate: nextDate);
          } catch (_) {
            break;
          }
        } else {
          break;
        }
      }
    }
  }

  Future<void> _fireTransaction(
    AutomaticTransaction autoTxn,
    DateTime nowUtc,
    DateTime executionCycleDateUtcPlus2,
  ) async {
    final idempotencyKey =
        'stalvi://autotxn/${autoTxn.id}/${executionCycleDateUtcPlus2.year}-${executionCycleDateUtcPlus2.month.toString().padLeft(2, '0')}-${executionCycleDateUtcPlus2.day.toString().padLeft(2, '0')}';
    final deterministicId =
        const Uuid().v5(Namespace.url.value, idempotencyKey);

    final existingTxn =
        await transactionRepo.getTransactionById(deterministicId);

    if (existingTxn == null) {
      final account = await accountRepo.getAccountById(autoTxn.accountId);
      final profile = account != null
          ? await profileRepo.getProfileById(account.userId)
          : null;

      final String originalCurrency = autoTxn.currency;
      final String defaultCurrency =
          profile?.defaultCurrency ?? originalCurrency;

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
        id: deterministicId,
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

      if (notificationService != null) {
        try {
          final notificationsEnabled =
              await settingsRepo?.getNotificationsEnabled() ?? true;
          if (notificationsEnabled) {
            String? languageCode;
            try {
              languageCode = await SecureStorageManager().getUserLocale();
            } catch (_) {}
            languageCode ??= PlatformDispatcher.instance.locale.languageCode;

            await notificationService!.showAutomaticTransactionNotification(
              transactionName: autoTxn.name,
              languageCode: languageCode,
            );
          }
        } catch (_) {}
      }
    }

    final nextDate = calculateNextTriggerDateUtcPlus2(
      autoTxn.nextExecutionDate,
      autoTxn.recurrenceType,
      autoTxn.recurrenceDays,
    );
    final updatedAutoTxn = autoTxn.copyWith(nextExecutionDate: nextDate);
    await automaticRepo.updateAutomaticTransaction(updatedAutoTxn);
  }

  /// Pure function that calculates the exact next trigger date in UTC+2 (truncating time to 00:00:00).
  /// Returns the corresponding instant (which is 22:00:00 UTC of the previous day).
  static DateTime calculateNextTriggerDateUtcPlus2(
    DateTime fromDate,
    RecurrenceType type,
    int recurrenceDays,
  ) {
    final fromUtc = fromDate.toUtc();
    final fromUtcPlus2 = fromUtc.add(const Duration(hours: 2));
    final fromUtc2 =
        DateTime.utc(fromUtcPlus2.year, fromUtcPlus2.month, fromUtcPlus2.day);

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
        final lastDayThisMonth =
            DateTime.utc(fromUtc2.year, fromUtc2.month + 1, 0).day;
        final targetDayThisMonth = recurrenceDays.clamp(1, lastDayThisMonth);
        if (fromUtc2.day < targetDayThisMonth) {
          nextDate =
              DateTime.utc(fromUtc2.year, fromUtc2.month, targetDayThisMonth);
        } else {
          nextDate = _advanceByMonths(fromUtc2, 1, recurrenceDays);
        }
        break;
    }

    return nextDate.subtract(const Duration(hours: 2));
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
