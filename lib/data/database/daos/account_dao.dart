import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/account_table.dart';

part 'account_dao.g.dart';

/// Data-Access Object for [Accounts].
///
/// Provides account-specific database operations that go beyond the simple
/// CRUD already handled inside [AccountRepository], most notably the
/// **exclusive-default** business rule: at most one account may be marked as
/// default at any point in time.
@DriftAccessor(tables: [Accounts])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  AccountDao(super.db);

  // ── Queries ─────────────────────────────────────────────────────────────────

  /// Returns all non-deleted accounts for a given [userId].
  Future<List<Account>> getAccountsByUserId(String userId) {
    return (select(accounts)
          ..where((a) => a.userId.equals(userId) & a.isDeleted.equals(false))
          ..orderBy([(a) => OrderingTerm(expression: a.name)]))
        .get();
  }

  /// Streams all non-deleted accounts for a given [userId].
  Stream<List<Account>> watchAccountsByUserId(String userId) {
    return (select(accounts)
          ..where((a) => a.userId.equals(userId) & a.isDeleted.equals(false))
          ..orderBy([(a) => OrderingTerm(expression: a.name)]))
        .watch();
  }

  /// Returns the single account currently flagged as default for [userId],
  /// or `null` if none exists.
  Future<Account?> getDefaultAccount(String userId) {
    return (select(accounts)
          ..where(
            (a) =>
                a.userId.equals(userId) &
                a.isDefault.equals(true) &
                a.isDeleted.equals(false),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  // ── Mutations ────────────────────────────────────────────────────────────────

  /// Marks [accountId] as the single default account for its owner.
  ///
  /// Business rule (exclusive default):
  ///   1. Clear `is_default` on **every** account belonging to the same user.
  ///   2. Set `is_default = true` on the target account.
  ///
  /// Both writes happen inside a single Drift transaction so the invariant
  /// is never violated mid-operation.
  Future<void> setDefaultAccount(String accountId) async {
    await transaction(() async {
      // 1. Resolve the owner of the target account.
      final target = await (select(accounts)
            ..where((a) => a.id.equals(accountId))
            ..limit(1))
          .getSingleOrNull();

      if (target == null) {
        throw ArgumentError(
          'setDefaultAccount: no account found with id "$accountId".',
        );
      }

      final now = DateTime.now();

      // 2. Clear is_default for all accounts belonging to the same user.
      await (update(accounts)
            ..where(
              (a) => a.userId.equals(target.userId) & a.isDefault.equals(true),
            ))
          .write(
        AccountsCompanion(
          isDefault: const Value(false),
          modifiedAt: Value(now),
        ),
      );

      // 3. Set is_default = true on the target account.
      await (update(accounts)..where((a) => a.id.equals(accountId))).write(
        AccountsCompanion(isDefault: const Value(true), modifiedAt: Value(now)),
      );
    });
  }

  /// Adjusts the initial balance of an account. Can be positive or negative.
  Future<void> adjustBalance(String accountId, double amountDelta) async {
    final account = await (select(
      accounts,
    )..where((a) => a.id.equals(accountId)))
        .getSingleOrNull();

    if (account == null) {
      throw Exception('adjustBalance: no account found with id "$accountId".');
    }

    final now = DateTime.now();
    await (update(accounts)..where((a) => a.id.equals(accountId))).write(
      AccountsCompanion(
        initialBalance: Value(account.initialBalance + amountDelta),
        modifiedAt: Value(now),
      ),
    );
  }
}
