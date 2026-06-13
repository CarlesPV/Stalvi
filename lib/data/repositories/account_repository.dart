import 'package:drift/drift.dart';
import 'package:konta/data/database/app_database.dart' as db;
import 'package:konta/data/mappers/account_mapper.dart';
import 'package:konta/domain/entities/account.dart';
import 'package:konta/domain/repositories/i_account_repository.dart';

/// Concrete implementation of [IAccountRepository] backed by Drift.
class AccountRepository implements IAccountRepository {
  final db.AppDatabase _db;

  AccountRepository(this._db);

  @override
  Future<Account> createAccount(Account account) async {
    final dbAccount = account.toDb();
    await _db.into(_db.accounts).insert(dbAccount);
    return account;
  }

  @override
  Future<Account?> getAccountById(String id) async {
    final query = _db.select(_db.accounts)
      ..where((a) => a.id.equals(id));
    final row = await query.getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<List<Account>> getAccountsByUserId(String userId) async {
    final query = _db.select(_db.accounts)
      ..where((a) => a.userId.equals(userId) & a.isDeleted.equals(false))
      ..orderBy([(a) => OrderingTerm(expression: a.name)]);
    final rows = await query.get();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Account> updateAccount(Account account) async {
    final dbAccount = account.toDb();
    await (_db.update(_db.accounts)..where((a) => a.id.equals(account.id)))
        .write(dbAccount.toCompanion(true));
    return account;
  }

  @override
  Future<void> deleteAccount(String id) async {
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id)))
        .write(
      const db.AccountsCompanion(
        isDeleted: Value(true),
      ),
    );
  }
}
