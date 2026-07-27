import 'package:stalvi/core/errors/app_exceptions.dart';
import '../entities/account.dart';
import '../entities/account_type.dart';
import '../repositories/i_account_repository.dart';

/// Parameters required to create a new financial account.
class CreateAccountParams {
  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final double? initialBalance;
  final String currency;
  final String color;
  final String icon;
  final bool isDefault;

  const CreateAccountParams({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.initialBalance,
    required this.currency,
    required this.color,
    required this.icon,
    this.isDefault = false,
  });
}

/// Use case that validates and creates a new [Account].
///
/// Ensures mandatory initial balance constraints and persists the entity
/// via [IAccountRepository].
class CreateAccountUseCase {
  final IAccountRepository _repository;

  CreateAccountUseCase(this._repository);

  Future<Account> execute(CreateAccountParams params) async {
    if (params.initialBalance == null) {
      throw const ValidationException(
        message: 'initial_balance is required and cannot be null',
      );
    }

    final now = DateTime.now();

    final account = Account(
      id: params.id,
      userId: params.userId,
      name: params.name,
      type: params.type,
      initialBalance: params.initialBalance!,
      currency: params.currency,
      color: params.color,
      icon: params.icon,
      isDefault: params.isDefault,
      isDeleted: false,
      createdAt: now,
      modifiedAt: now,
    );

    return _repository.createAccount(account);
  }
}
