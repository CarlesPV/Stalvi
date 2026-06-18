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
    return _db.transaction(() async {
      if (account.isDefault) {
        final now = DateTime.now();
        await (_db.update(_db.accounts)
              ..where((a) =>
                  a.userId.equals(account.userId) & a.isDefault.equals(true)))
            .write(
          db.AccountsCompanion(
            isDefault: const Value(false),
            modifiedAt: Value(now),
          ),
        );
      }
      final dbAccount = account.toDb();
      await _db.into(_db.accounts).insert(dbAccount);
      return account;
    });
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
    return _db.transaction(() async {
      if (account.isDefault) {
        final now = DateTime.now();
        await (_db.update(_db.accounts)
              ..where((a) =>
                  a.userId.equals(account.userId) & a.isDefault.equals(true)))
            .write(
          db.AccountsCompanion(
            isDefault: const Value(false),
            modifiedAt: Value(now),
          ),
        );
      }
      final dbAccount = account.toDb();
      await (_db.update(_db.accounts)..where((a) => a.id.equals(account.id)))
          .write(dbAccount.toCompanion(true));
      return account;
    });
  }

  @override
  Future<void> deleteAccount(String id) async {
    await _db.transaction(() async {
      final accountToDelete = await getAccountById(id);
      if (accountToDelete == null) return;

      final remainingAccounts = await (_db.select(_db.accounts)
            ..where((a) =>
                a.userId.equals(accountToDelete.userId) &
                a.id.isNotValue(id) &
                a.isDeleted.equals(false)))
          .get();

      if (remainingAccounts.isEmpty) {
        throw Exception('Cannot delete the last existing account');
      }

      if (accountToDelete.isDefault) {
        final newDefault = remainingAccounts.first;
        await (_db.update(_db.accounts)
              ..where((a) => a.id.equals(newDefault.id)))
            .write(const db.AccountsCompanion(isDefault: Value(true)));
      }

      await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
        const db.AccountsCompanion(
          isDeleted: Value(true),
        ),
      );
    });
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
