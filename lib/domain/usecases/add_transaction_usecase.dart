import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
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

  static const _uuid = Uuid();

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

    // Transfer-specific validation.
    if (params.type == TransactionType.transfer) {
      if (params.destinationAccountId == null) {
        throw const ValidationException(
          message: 'destinationAccountId is required for transfer transactions',
          code: 'MISSING_DESTINATION_ACCOUNT',
        );
      }
      if (params.destinationAccountId == params.accountId) {
        throw const ValidationException(
          message: 'Origin and destination accounts must be different',
          code: 'SAME_ACCOUNT_TRANSFER',
        );
      }
      final destinationAccount =
          await _accountRepository.getAccountById(params.destinationAccountId!);
      if (destinationAccount == null) {
        throw NotFoundException(
          message:
              'Destination account with id "${params.destinationAccountId}" not found',
          code: 'DESTINATION_ACCOUNT_NOT_FOUND',
        );
      }
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

    // ── Transfer: create two mirrored legs atomically ─────────────────────────
    if (params.type == TransactionType.transfer) {
      // A shared transferId links the two rows; derived deterministically from
      // the origin id so callers can recreate it if needed.
      final transferId = _uuid.v5(Namespace.url.value, params.id);
      final destinationTxnId =
          _uuid.v5(Namespace.url.value, '${params.id}_dst');

      final originTxn = Transaction(
        id: params.id,
        amount: params.amount,
        date: params.date,
        type: TransactionType.transfer,
        accountId: params.accountId,
        categoryId: params.categoryId,
        // "Transfer" title stored in notes if none supplied, kept ≤ 20 chars.
        notes: sanitizedNotes ?? 'Transfer',
        originalCurrency: originalCurrency,
        convertedAmount: convertedAmount,
        exchangeRate: exchangeRate,
        createdAt: now,
        modifiedAt: now,
        transferId: transferId,
      );

      final destinationTxn = Transaction(
        id: destinationTxnId,
        amount: params.amount,
        date: params.date,
        type: TransactionType.transfer,
        accountId: params.destinationAccountId!,
        categoryId: params.categoryId,
        notes: sanitizedNotes ?? 'Transfer',
        originalCurrency: originalCurrency,
        convertedAmount: convertedAmount,
        exchangeRate: exchangeRate,
        createdAt: now,
        modifiedAt: now,
        transferId: transferId,
      );

      final pair = await _transactionRepository.createTransferPair(
        originTransaction: originTxn,
        destinationTransaction: destinationTxn,
      );
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
      createdAt: now,
      modifiedAt: now,
    );

    return _transactionRepository.createTransaction(transaction);
  }
}
