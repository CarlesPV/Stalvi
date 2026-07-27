import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import '../entities/account.dart';
import '../entities/exchange_rate.dart';
import '../entities/savings_goal.dart';
import '../entities/transaction.dart';
import '../entities/transaction_type.dart';
import '../repositories/i_account_repository.dart';
import '../repositories/i_profile_repository.dart';
import '../repositories/i_exchange_rate_repository.dart';
import '../repositories/i_savings_goal_repository.dart';
import '../repositories/i_transaction_repository.dart';
import '../repositories/i_settings_repository.dart';
import '../../infrastructure/services/notification_service.dart';
import 'update_budget_progress_usecase.dart';
import '../services/financial_threshold_service.dart';
import 'package:stalvi/core/utils/input_sanitizer.dart';
import 'package:uuid/uuid.dart';

/// Parameters required to add a new transaction.
///
/// For [TransactionType.transfer], supply both [accountId] (origin) and
/// [destinationAccountId]. The use case will create two mirrored rows
/// atomically.
class AddTransactionParams {
  final String id;
  final int amount; // in cents (minor units)
  final DateTime date;
  final TransactionType type;
  final String accountId;

  /// Required when [type] is [TransactionType.transfer].
  final String? destinationAccountId;

  /// Alternatively, a transfer can go to a Savings Goal.
  final String? destinationSavingsGoalId;

  final String? categoryId;
  final String? notes;
  final String? currency;

  const AddTransactionParams({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.accountId,
    this.destinationAccountId,
    this.destinationSavingsGoalId,
    this.categoryId,
    this.notes,
    this.currency,
  });
}

/// Use case that validates and persists a new [Transaction].
///
/// **Validation rules:**
/// 1. `amount` must be greater than 0.
/// 2. `date` must not be in the future (recommended guard-rail).
/// 3. The referenced `accountId` must exist.
/// 4. For transfers: `destinationAccountId` must be provided, must exist, and
///    must differ from `accountId`.
///
/// **Transfer handling:**
/// When `type == TransactionType.transfer` the use case creates **two** paired
/// [Transaction] rows atomically via [ITransactionRepository.createTransferPair]:
///   - Origin leg  : negative amount (outflow) from the origin account.
///   - Destination : positive amount (inflow) into the destination account.
///
/// Both rows share the same `transferId` (derived from [params.id]) so that
/// the trash / restore logic can always locate the counterpart.
///
/// The method returns the **origin** transaction. Callers that need both legs
/// should use [ITransactionRepository.createTransferPair] directly.
class AddTransactionUseCase {
  final ITransactionRepository _transactionRepository;
  final IAccountRepository _accountRepository;
  final IProfileRepository _profileRepository;
  final IExchangeRateRepository _exchangeRateRepository;
  final ISavingsGoalRepository _savingsGoalRepository;
  final UpdateBudgetProgressUseCase _updateBudgetProgressUseCase;
  final IFinancialThresholdService _financialThresholdService;
  final NotificationService? _notificationService;
  final ISettingsRepository? _settingsRepository;

  static const _uuid = Uuid();

  AddTransactionUseCase(
    this._transactionRepository,
    this._accountRepository,
    this._profileRepository,
    this._exchangeRateRepository,
    this._savingsGoalRepository,
    this._updateBudgetProgressUseCase,
    this._financialThresholdService, [
    this._notificationService,
    this._settingsRepository,
  ]);

  Future<Transaction> execute(AddTransactionParams params) async {
    // Validate: amount must be positive.
    if (params.amount <= 0) {
      throw const ValidationException(
        message: 'Transaction amount must be greater than 0',
        code: 'INVALID_AMOUNT',
      );
    }

    // Validate: date must not be in the future.
    final now = DateTime.now();
    if (params.date.isAfter(now)) {
      throw const ValidationException(
        message: 'Transaction date cannot be in the future',
        code: 'FUTURE_DATE',
      );
    }

    // Validate: referenced account must exist.
    final account = await _accountRepository.getAccountById(params.accountId);
    if (account == null) {
      throw NotFoundException(
        message: 'Account with id "${params.accountId}" not found',
        code: 'ACCOUNT_NOT_FOUND',
      );
    }

    final profile = await _profileRepository.getProfileById(account.userId);
    if (profile == null) {
      throw NotFoundException(
        message: 'Profile with id "${account.userId}" not found',
        code: 'PROFILE_NOT_FOUND',
      );
    }

    Account? destinationAccount;
    SavingsGoal? destinationGoal;
    // Transfer-specific validation.
    if (params.type == TransactionType.transfer) {
      if (params.destinationAccountId == null &&
          params.destinationSavingsGoalId == null) {
        throw const ValidationException(
          message:
              'destinationAccountId or destinationSavingsGoalId is required for transfer transactions',
          code: 'MISSING_DESTINATION',
        );
      }
      if (params.destinationAccountId != null) {
        if (params.destinationAccountId == params.accountId) {
          throw const ValidationException(
            message: 'Origin and destination accounts must be different',
            code: 'SAME_ACCOUNT_TRANSFER',
          );
        }
        destinationAccount = await _accountRepository
            .getAccountById(params.destinationAccountId!);
        if (destinationAccount == null) {
          throw NotFoundException(
            message:
                'Destination account with id "${params.destinationAccountId}" not found',
            code: 'DESTINATION_ACCOUNT_NOT_FOUND',
          );
        }
      } else if (params.destinationSavingsGoalId != null) {
        destinationGoal = await _savingsGoalRepository
            .getSavingsGoalById(params.destinationSavingsGoalId!);
        if (destinationGoal == null) {
          throw NotFoundException(
            message:
                'Destination savings goal with id "${params.destinationSavingsGoalId}" not found',
            code: 'DESTINATION_GOAL_NOT_FOUND',
          );
        }
      }
    }

    int? convertedAmount;
    double? exchangeRate;
    String? exchangeRateSnapshot;
    final String originalCurrency = params.currency ?? account.currency;

    ExchangeRate? effectiveRates;
    try {
      final localRates = await _exchangeRateRepository.getLocalRates(
        baseCurrency: profile.defaultCurrency,
      );
      if (localRates != null) {
        effectiveRates = localRates;
        final ratesMap = Map<String, double>.from(localRates.rates);
        ratesMap[localRates.baseCurrency] = 1.0;
        exchangeRateSnapshot = jsonEncode(ratesMap);
      }
    } catch (_) {}

    if (originalCurrency != profile.defaultCurrency ||
        (params.type == TransactionType.transfer &&
            destinationAccount != null &&
            destinationAccount.currency != originalCurrency)) {
      bool needsLatest = effectiveRates == null;
      if (!needsLatest) {
        if (originalCurrency != profile.defaultCurrency &&
            effectiveRates.rateFor(originalCurrency) == null) {
          needsLatest = true;
        }
        if (params.type == TransactionType.transfer &&
            destinationAccount != null) {
          final dCurr = destinationAccount.currency;
          if (dCurr != originalCurrency &&
              dCurr != profile.defaultCurrency &&
              effectiveRates.rateFor(dCurr) == null) {
            needsLatest = true;
          }
        }
      }

      if (needsLatest) {
        try {
          final rateSnapshot = await _exchangeRateRepository.getLatestRates(
            baseCurrency: profile.defaultCurrency,
          );
          effectiveRates = rateSnapshot;
          if (exchangeRateSnapshot == null) {
            final ratesMap = Map<String, double>.from(rateSnapshot.rates);
            ratesMap[rateSnapshot.baseCurrency] = 1.0;
            exchangeRateSnapshot = jsonEncode(ratesMap);
          }
        } on AppException {
          rethrow;
        } catch (e) {
          throw ValidationException(
            message: 'Failed to convert currency: $e',
            code: 'CONVERSION_FAILED',
          );
        }
      }
    }

    if (originalCurrency != profile.defaultCurrency) {
      exchangeRate = effectiveRates?.rateFor(originalCurrency);
      if (exchangeRate == null) {
        throw const ValidationException(
          message: 'Exchange rate not available for the requested currency',
          code: 'RATE_NOT_FOUND',
        );
      }
      convertedAmount = (params.amount / exchangeRate).round();
    }

    int destinationAmount = params.amount;
    int? destConvertedAmount;
    double? destExchangeRate;

    if (params.type == TransactionType.transfer && destinationAccount != null) {
      final destCurrency = destinationAccount.currency;
      if (destCurrency != originalCurrency) {
        double amountInBase = params.amount.toDouble();
        if (originalCurrency != profile.defaultCurrency) {
          amountInBase = params.amount / exchangeRate!;
        }

        if (destCurrency == profile.defaultCurrency) {
          destinationAmount = amountInBase.round();
          destConvertedAmount = null;
          destExchangeRate = null;
        } else {
          destExchangeRate = effectiveRates?.rateFor(destCurrency);
          if (destExchangeRate == null) {
            throw const ValidationException(
              message: 'Exchange rate not available for destination currency',
              code: 'RATE_NOT_FOUND',
            );
          }
          destinationAmount = (amountInBase * destExchangeRate).round();
          destConvertedAmount = (destinationAmount / destExchangeRate).round();
        }
      } else {
        destConvertedAmount = convertedAmount;
        destExchangeRate = exchangeRate;
      }
    }

    String? sanitizedNotes;
    if (params.notes != null) {
      sanitizedNotes = InputSanitizer.sanitizeToPlainText(params.notes!);
      if (sanitizedNotes.length > 20) {
        sanitizedNotes = sanitizedNotes.substring(0, 20);
      }
    }

    // ── Transfer: create two mirrored legs atomically ─────────────────────────
    if (params.type == TransactionType.transfer) {
      if (destinationGoal != null) {
        // Single leg transfer to a savings goal
        final originTxn = Transaction(
          id: params.id,
          amount: params.amount, // Origin leg (will be debited)
          date: params.date,
          type: TransactionType.transfer,
          accountId: params.accountId,
          categoryId: params.categoryId,
          savingsGoalId: params.destinationSavingsGoalId,
          notes: sanitizedNotes,
          originalCurrency: originalCurrency,
          convertedAmount: convertedAmount,
          exchangeRate: exchangeRate,
          exchangeRateSnapshot: exchangeRateSnapshot,
          createdAt: now,
          modifiedAt: now,
        );

        final savedTxn =
            await _transactionRepository.createTransaction(originTxn);

        int goalAmount = convertedAmount ?? params.amount;
        final newGoalAmount = destinationGoal.currentAmount + goalAmount;
        final isCompleted = newGoalAmount >= destinationGoal.targetAmount;

        await _savingsGoalRepository.updateSavingsGoal(
          destinationGoal.copyWith(
            currentAmount: newGoalAmount,
            isCompleted: isCompleted,
          ),
        );

        if (savedTxn.type == TransactionType.expense) {
          await _updateBudgetProgressUseCase.execute(transaction: savedTxn);
        }
        final thresholds =
            await _financialThresholdService.evaluateThresholds([savedTxn]);
        await _handleThresholdNotifications(thresholds);
        return savedTxn;
      }

      // A shared transferId links the two rows; derived deterministically from
      // the origin id so callers can recreate it if needed.
      final transferId = _uuid.v5(Namespace.url.value, params.id);
      final destinationTxnId = '${params.id}_dst';

      final originTxn = Transaction(
        id: params.id,
        amount: params.amount,
        date: params.date,
        type: TransactionType.transfer,
        accountId: params.accountId,
        categoryId: params.categoryId,
        notes: sanitizedNotes,
        originalCurrency: originalCurrency,
        convertedAmount: convertedAmount,
        exchangeRate: exchangeRate,
        exchangeRateSnapshot: exchangeRateSnapshot,
        createdAt: now,
        modifiedAt: now,
        transferId: transferId,
      );

      final destinationTxn = Transaction(
        id: destinationTxnId,
        amount: destinationAmount,
        date: params.date,
        type: TransactionType.transfer,
        accountId: params.destinationAccountId!,
        categoryId: params.categoryId,
        notes: sanitizedNotes,
        originalCurrency: destinationAccount!.currency,
        convertedAmount: destConvertedAmount,
        exchangeRate: destExchangeRate,
        exchangeRateSnapshot: exchangeRateSnapshot,
        createdAt: now,
        modifiedAt: now,
        transferId: transferId,
      );

      final pair = await _transactionRepository.createTransferPair(
        originTransaction: originTxn,
        destinationTransaction: destinationTxn,
      );
      final thresholds = await _financialThresholdService
          .evaluateThresholds([pair.origin, pair.destination]);
      await _handleThresholdNotifications(thresholds);
      return pair.origin;
    }

    // ── Standard income / expense ─────────────────────────────────────────────
    final transaction = Transaction(
      id: params.id,
      amount: params.amount,
      date: params.date,
      type: params.type,
      accountId: params.accountId,
      categoryId: params.categoryId,
      notes: sanitizedNotes,
      originalCurrency: originalCurrency,
      convertedAmount: convertedAmount,
      exchangeRate: exchangeRate,
      exchangeRateSnapshot: exchangeRateSnapshot,
      createdAt: now,
      modifiedAt: now,
    );

    final savedTxn =
        await _transactionRepository.createTransaction(transaction);
    if (savedTxn.type == TransactionType.expense) {
      await _updateBudgetProgressUseCase.execute(transaction: savedTxn);
    }
    final thresholds =
        await _financialThresholdService.evaluateThresholds([savedTxn]);
    await _handleThresholdNotifications(thresholds);
    return savedTxn;
  }

  Future<void> _handleThresholdNotifications(
    List<ThresholdResult> thresholdResults,
  ) async {
    if (_notificationService == null || thresholdResults.isEmpty) return;
    try {
      final notificationsEnabled =
          await _settingsRepository?.getNotificationsEnabled() ?? true;
      if (!notificationsEnabled) return;

      String? languageCode;
      try {
        languageCode = await SecureStorageManager().getUserLocale();
      } catch (_) {}
      languageCode ??= PlatformDispatcher.instance.locale.languageCode;

      for (final result in thresholdResults) {
        if (result.isBudgetExceeded) {
          await _notificationService.showBudgetExceededNotification(
            languageCode: languageCode,
          );
        }
        if (result.isSavingsGoalReached) {
          await _notificationService.showGoalReachedNotification(
            languageCode: languageCode,
          );
        }
      }
    } catch (_) {}
  }
}
