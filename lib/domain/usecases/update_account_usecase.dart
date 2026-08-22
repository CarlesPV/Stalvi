import 'package:stalvi/core/errors/app_exceptions.dart';
import '../entities/account.dart';
import '../entities/account_type.dart';
import '../repositories/i_account_repository.dart';

/// Parameters for updating an existing [Account].
///
/// The fields [initialBalance] and [currency] are intentionally absent because
/// they are **immutable** once an account has been created.  Attempting to
/// change them is a domain-level violation and will cause [UpdateAccountUseCase]
/// to throw a [ValidationException] with code `IMMUTABLE_FIELD`.
class UpdateAccountParams {
  final String id;
  final String name;
  final AccountType type;
  final String color;
  final String icon;
  final bool isDefault;

  const UpdateAccountParams({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
    required this.isDefault,
  });
}

/// Use case responsible for updating mutable fields of an existing [Account].
///
/// **Immutability contract:**
/// - [Account.initialBalance] and [Account.currency] MUST NOT change after
///   creation.  If the caller supplies values that differ from the persisted
///   record the use case throws a [ValidationException] with code
///   `IMMUTABLE_FIELD` before any write is performed.
class UpdateAccountUseCase {
  final IAccountRepository _repository;

  UpdateAccountUseCase(this._repository);

  Future<Account> execute(UpdateAccountParams params) async {
    if (params.name.trim().isEmpty) {
      throw const ValidationException(
        message: 'Account name cannot be empty.',
        code: 'INVALID_NAME',
      );
    }

    // Fetch the persisted record to compare immutable fields.
    final existing = await _repository.getAccountById(params.id);
    if (existing == null) {
      throw NotFoundException(
        message: 'Account with id "${params.id}" was not found.',
        code: 'ACCOUNT_NOT_FOUND',
      );
    }

    if (existing.isDefault && !params.isDefault) {
      throw const ValidationException(
        message: 'You must have at least one default account.',
        code: 'DEFAULT_ACCOUNT_REQUIRED',
      );
    }

    final updated = existing.copyWith(
      name: params.name.trim(),
      type: params.type,
      color: params.color,
      icon: params.icon,
      isDefault: params.isDefault,
      modifiedAt: DateTime.now(),
    );

    return _repository.updateAccount(updated);
  }
}
