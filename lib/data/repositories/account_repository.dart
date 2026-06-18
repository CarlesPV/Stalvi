import 'package:drift/drift.dart';
import 'package:stalvi/data/database/app_database.dart' as db;
import 'package:stalvi/data/database/daos/account_dao.dart';
import 'package:stalvi/data/mappers/account_mapper.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';

/// Concrete implementation of [IAccountRepository] backed by Drift.
class AccountRepository implements IAccountRepository {
  final db.AppDatabase _db;

  AccountRepository(this._db);

  AccountDao get _accountDao => _db.accountDao;

  @override
  Future<Account> createAccount(Account account) async {
    final dbAccount = account.toDb();
    await _db.into(_db.accounts).insert(dbAccount);
    return account;
  }

  @override
  Future<Account?> getAccountById(String id) async {
    final query = _db.select(_db.accounts)..where((a) => a.id.equals(id));
    final row = await query.getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<List<Account>> getAccountsByUserId(String userId) async {
    final rows = await _accountDao.getAccountsByUserId(userId);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Stream<List<Account>> watchAccountsByUserId(String userId) {
    return _accountDao
        .watchAccountsByUserId(userId)
        .map((rows) => rows.map((r) => r.toDomain()).toList());
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
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      const db.AccountsCompanion(
        isDeleted: Value(true),
      ),
    );
  }

  @override
  Future<Account?> getDefaultAccount(String userId) async {
    final row = await _accountDao.getDefaultAccount(userId);
    return row?.toDomain();
  }

  @override
  Future<void> setDefaultAccount(String accountId) {
    return _accountDao.setDefaultAccount(accountId);
  }
}
