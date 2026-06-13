import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/domain/entities/transaction.dart';
import 'package:konta/domain/entities/transaction_type.dart';
import 'package:konta/domain/repositories/i_account_repository.dart';
import 'package:konta/domain/repositories/i_transaction_repository.dart';

/// Parameters required to add a new transaction.
class AddTransactionParams {
  final String id;
  final int amount; // in cents (minor units)
  final DateTime date;
  final TransactionType type;
  final String accountId;
  final String? categoryId;
  final String? notes;

  const AddTransactionParams({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.accountId,
    this.categoryId,
    this.notes,
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

  AddTransactionUseCase(this._transactionRepository, this._accountRepository);

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

    final transaction = Transaction(
      id: params.id,
      amount: params.amount,
      date: params.date,
      type: params.type,
      accountId: params.accountId,
      categoryId: params.categoryId,
      notes: params.notes,
      createdAt: now,
      modifiedAt: now,
    );

    return _transactionRepository.createTransaction(transaction);
  }
}
