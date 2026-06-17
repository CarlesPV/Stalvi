import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/core/utils/input_sanitizer.dart';

/// Parameters required to add a new transaction.
class AddTransactionParams {
  final String id;
  final int amount; // in cents (minor units)
  final DateTime date;
  final TransactionType type;
  final String accountId;
  final String? categoryId;
  final String? notes;
  final String? currency;

  const AddTransactionParams({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.accountId,
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
///
/// If validation passes, the transaction is delegated to
/// [ITransactionRepository.createTransaction], which handles the atomic
/// balance update internally.
class AddTransactionUseCase {
  final ITransactionRepository _transactionRepository;
  final IAccountRepository _accountRepository;
  final IProfileRepository _profileRepository;
  final IExchangeRateRepository _exchangeRateRepository;

  AddTransactionUseCase(
    this._transactionRepository,
    this._accountRepository,
    this._profileRepository,
    this._exchangeRateRepository,
  );

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

    int? convertedAmount;
    double? exchangeRate;
    final String originalCurrency = params.currency ?? account.currency;

    if (originalCurrency != profile.defaultCurrency) {
      try {
        final rateSnapshot = await _exchangeRateRepository.getLatestRates(
          baseCurrency: profile.defaultCurrency,
        );
        exchangeRate = rateSnapshot.rateFor(originalCurrency);
        if (exchangeRate == null) {
          throw const ValidationException(
            message: 'Exchange rate not available for the requested currency',
            code: 'RATE_NOT_FOUND',
          );
        }
        convertedAmount = (params.amount / exchangeRate).round();
      } on AppException {
        rethrow;
      } catch (e) {
        throw ValidationException(
          message: 'Failed to convert currency: $e',
          code: 'CONVERSION_FAILED',
        );
      }
    }

    String? sanitizedNotes;
    if (params.notes != null) {
      sanitizedNotes = InputSanitizer.sanitizeToPlainText(params.notes!);
      if (sanitizedNotes.length > 20) {
        sanitizedNotes = sanitizedNotes.substring(0, 20);
      }
    }

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
      createdAt: now,
      modifiedAt: now,
    );

    return _transactionRepository.createTransaction(transaction);
  }
}
