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
import '../services/financial_threshold_service.dart';

/// Use case that evaluates pending automatic/recurring transaction templates
/// and generates corresponding transaction records deterministically.
///
/// Ensures idempotency via deterministic UUID v5 URL-based keys and performs
/// exact trigger date calculations using the UTC+2 timezone offset.
class ExecuteRecurringTransactionsUseCase {
  final IAutomaticTransactionRepository automaticRepo;
  final ITransactionRepository transactionRepo;
  final IAccountRepository accountRepo;
  final IProfileRepository profileRepo;
  final IExchangeRateRepository exchangeRateRepo;
  final IFinancialThresholdService financialThresholdService;
  final NotificationService? notificationService;
  final ISettingsRepository? settingsRepo;

  ExecuteRecurringTransactionsUseCase(
    this.automaticRepo,
    this.transactionRepo,
    this.accountRepo,
    this.profileRepo,
    this.exchangeRateRepo,
    this.financialThresholdService, [
    this.notificationService,
    this.settingsRepo,
  ]);

  Future<void> execute() async {
    final nowUtc = DateTime.now().toUtc();
    final nowUtcPlus2 = nowUtc.add(const Duration(hours: 2));
    final todayUtcPlus2 =
        DateTime.utc(nowUtcPlus2.year, nowUtcPlus2.month, nowUtcPlus2.day);

    final automaticTxns = await automaticRepo.getAllAutomaticTransactions();

    final pendingTransactions = <dtxn.Transaction>[];
    final updatedAutoTxns = <AutomaticTransaction>[];
    final autoTxnsToNotify = <AutomaticTransaction>[];

    for (final autoTxn in automaticTxns) {
      if (autoTxn.isDeleted || !autoTxn.isActive || autoTxn.deletedAt != null) {
        continue;
      }

      var currentAutoTxn = autoTxn;
      var hasPendingCycles = false;

      // Determine if there are pending cycles
      final initialNextDateUtc = currentAutoTxn.nextExecutionDate.toUtc();
      final initialNextDateUtcPlus2Instant =
          initialNextDateUtc.add(const Duration(hours: 2));
      final initialNextDateUtcPlus2 = DateTime.utc(
        initialNextDateUtcPlus2Instant.year,
        initialNextDateUtcPlus2Instant.month,
        initialNextDateUtcPlus2Instant.day,
      );

      if (initialNextDateUtcPlus2.isBefore(todayUtcPlus2) ||
          initialNextDateUtcPlus2.isAtSameMomentAs(todayUtcPlus2)) {
        hasPendingCycles = true;
      }

      if (!hasPendingCycles) continue;

      // Fetch rates once per autoTxn if needed
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

      bool createdAny = false;

      // Generate all missing cycles
      while (true) {
        final cycleNextDateUtc = currentAutoTxn.nextExecutionDate.toUtc();
        final cycleNextDateUtcPlus2Instant =
            cycleNextDateUtc.add(const Duration(hours: 2));
        final cycleNextDateUtcPlus2 = DateTime.utc(
          cycleNextDateUtcPlus2Instant.year,
          cycleNextDateUtcPlus2Instant.month,
          cycleNextDateUtcPlus2Instant.day,
        );

        if (cycleNextDateUtcPlus2.isBefore(todayUtcPlus2) ||
            cycleNextDateUtcPlus2.isAtSameMomentAs(todayUtcPlus2)) {
          final idempotencyKey =
              'stalvi://autotxn/${autoTxn.id}/${cycleNextDateUtcPlus2.year}-${cycleNextDateUtcPlus2.month.toString().padLeft(2, '0')}-${cycleNextDateUtcPlus2.day.toString().padLeft(2, '0')}';
          final deterministicId =
              const Uuid().v5(Namespace.url.value, idempotencyKey);

          final newTxn = dtxn.Transaction(
            id: deterministicId,
            amount: autoTxn.amount,
            date: cycleNextDateUtc,
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
            parentRecurringId: autoTxn.id,
            expectedExecutionDate: cycleNextDateUtc,
          );

          pendingTransactions.add(newTxn);
          createdAny = true;

          final nextDate = calculateNextTriggerDateUtcPlus2(
            currentAutoTxn.nextExecutionDate,
            currentAutoTxn.recurrenceType,
            currentAutoTxn.recurrenceDays,
          );

          if (!nextDate.isAfter(currentAutoTxn.nextExecutionDate)) {
            // Break safety loop if it doesn't advance
            break;
          }

          currentAutoTxn = currentAutoTxn.copyWith(nextExecutionDate: nextDate);
        } else {
          break; // Catch up to today
        }
      }

      if (createdAny) {
        updatedAutoTxns.add(currentAutoTxn);
        autoTxnsToNotify.add(currentAutoTxn);
      }
    }

    var thresholdResults = <ThresholdResult>[];
    // Batch insert transactions (insertOrIgnore handles existing deterministic IDs or unique constraints)
    if (pendingTransactions.isNotEmpty) {
      await transactionRepo.createTransactions(pendingTransactions);
      thresholdResults = await financialThresholdService
          .evaluateThresholds(pendingTransactions);
    }

    // Update automatic txns
    for (final updatedTxn in updatedAutoTxns) {
      await automaticRepo.updateAutomaticTransaction(updatedTxn);
    }

    // Notifications
    if (notificationService != null &&
        (autoTxnsToNotify.isNotEmpty || thresholdResults.isNotEmpty)) {
      try {
        final notificationsEnabled =
            await settingsRepo?.getNotificationsEnabled() ?? true;
        if (notificationsEnabled) {
          String? languageCode;
          try {
            languageCode = await SecureStorageManager().getUserLocale();
          } catch (_) {}
          languageCode ??= PlatformDispatcher.instance.locale.languageCode;

          for (final autoTxn in autoTxnsToNotify) {
            await notificationService!.showAutomaticTransactionNotification(
              transactionName: autoTxn.name,
              languageCode: languageCode,
            );
          }

          for (final result in thresholdResults) {
            if (result.isBudgetExceeded) {
              await notificationService!.showBudgetExceededNotification(
                languageCode: languageCode,
              );
            }
            if (result.isSavingsGoalReached) {
              await notificationService!.showGoalReachedNotification(
                languageCode: languageCode,
              );
            }
          }
        }
      } catch (_) {}
    }
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
