import 'package:drift/drift.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import '../database/app_database.dart' as db;
import '../database/daos/account_dao.dart';
import '../mappers/account_mapper.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';

/// Concrete implementation of [IAccountRepository] backed by Drift.
///
/// **Cascade rule:**
/// - [deleteAccount] soft-deletes the account **and** all associated
///   transactions inside a single Drift `.transaction()` block.
/// - [hardDeleteAccount] permanently removes the account row **and** all its
///   transaction rows atomically (called from the trash purge flow).
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
              ..where(
                (a) =>
                    a.userId.equals(account.userId) & a.isDefault.equals(true),
              ))
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
              ..where(
                (a) =>
                    a.userId.equals(account.userId) & a.isDefault.equals(true),
              ))
            .write(
          db.AccountsCompanion(
            isDefault: const Value(false),
            modifiedAt: Value(now),
          ),
        );
      }
      final dbAccount = account.toDb();
      await (_db.update(_db.accounts)..where((a) => a.id.equals(account.id)))
          .write(dbAccount.toCompanion(false));
      return account;
    });
  }

  /// Soft-deletes the account **and** all its associated transactions.
  ///
  /// Business rules enforced inside the transaction:
  /// 1. The account must not be the last non-deleted account for its owner.
  /// 2. If the account is the default, the next available account is promoted.
  /// 3. All active transactions for this account are soft-deleted atomically.
  @override
  Future<void> deleteAccount(String id) async {
    await _db.transaction(() async {
      final accountToDelete = await getAccountById(id);
      if (accountToDelete == null) return;
      if (accountToDelete.isDeleted) return; // already soft-deleted

      final remainingAccounts = await (_db.select(_db.accounts)
            ..where(
              (a) =>
                  a.userId.equals(accountToDelete.userId) &
                  a.id.isNotValue(id) &
                  a.isDeleted.equals(false),
            ))
          .get();

      if (remainingAccounts.isEmpty) {
        throw const ValidationException(
          message: 'Cannot delete the last existing account',
          code: 'LAST_ACCOUNT',
        );
      }

      if (accountToDelete.isDefault) {
        final newDefault = remainingAccounts.first;
        await (_db.update(_db.accounts)
              ..where((a) => a.id.equals(newDefault.id)))
            .write(const db.AccountsCompanion(isDefault: Value(true)));
      }

      final now = DateTime.now();

      // Cascade: soft-delete all non-deleted transactions for this account.
      await (_db.update(_db.transactions)
            ..where(
              (t) => t.accountId.equals(id) & t.isDeleted.equals(false),
            ))
          .write(
        db.TransactionsCompanion(
          isDeleted: const Value(true),
          modifiedAt: Value(now),
        ),
      );

      // Soft-delete the account itself.
      await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
        db.AccountsCompanion(
          isDeleted: const Value(true),
          modifiedAt: Value(now),
        ),
      );
    });
  }

  /// Permanently hard-deletes the account row and **all** its transaction rows.
  ///
  /// This is called during the permanent purge flow (30-day trash expiry or
  /// explicit "Delete Forever" action on an account).
  @override
  Future<void> hardDeleteAccount(String id) async {
    await _db.transaction(() async {
      // First remove all transactions belonging to this account.
      await (_db.delete(_db.transactions)..where((t) => t.accountId.equals(id)))
          .go();

      // Then remove the account itself.
      await (_db.delete(_db.accounts)..where((a) => a.id.equals(id))).go();
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
