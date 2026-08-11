import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/account_table.dart';
import '../tables/category_table.dart';
import '../tables/tag_table.dart';
import '../tables/transaction_table.dart';

part 'transaction_dao.g.dart';

/// Encapsulates all advanced transaction queries, in particular the
/// **dynamic multi-dimensional filter** that the presentation layer uses
/// for list/search screens.
///
/// Simple CRUD operations (insert, update, soft-delete) live in
/// [TransactionRepository] so as not to duplicate the balance-adjustment
/// logic that runs inside Drift transactions there.
@DriftAccessor(tables: [Transactions, Accounts, Categories, Tags])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  // ── Reactive filtered query ──────────────────────────────────────────────────

  /// Returns a [Stream] that re-emits whenever the underlying data changes.
  ///
  /// Every non-null parameter is ANDed as an additional WHERE predicate.
  /// `isDeleted = false` is always enforced regardless of other filters.
  ///
  /// Amount parameters use **integer cents** (minor units), consistent with
  /// how [Transactions.amount] is stored in the database.
  ///
  /// [tagId] is resolved to the tag's `name` and matched as a
  /// case-insensitive substring against the transaction's `notes` column.
  /// This relies on the convention that tags are stored as hashtags inside
  /// notes (e.g. `#groceries`), or more loosely as any text match.
  Stream<List<Transaction>> watchFiltered({
    String? accountId,
    TransactionType? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    int? minAmountCents,
    int? maxAmountCents,
    String? tagId,
    String? currency,
  }) {
    final t = transactions;
    final query = select(t);

    // Always exclude soft-deleted rows.
    Expression<bool> conditions = t.isDeleted.equals(false);

    // ── Account ────────────────────────────────────────────────────────────────
    if (accountId != null) {
      conditions = conditions & t.accountId.equals(accountId);
    }

    // ── Type ──────────────────────────────────────────────────────────────────
    if (type != null) {
      conditions = conditions & t.type.equalsValue(type);
    }

    // ── Category ──────────────────────────────────────────────────────────────
    if (categoryId != null) {
      conditions = conditions & t.categoryId.equals(categoryId);
    }

    // ── Date range ────────────────────────────────────────────────────────────
    if (startDate != null && endDate != null) {
      conditions = conditions & t.date.isBetweenValues(startDate, endDate);
    } else if (startDate != null) {
      conditions = conditions & t.date.isBiggerOrEqualValue(startDate);
    } else if (endDate != null) {
      conditions = conditions & t.date.isSmallerOrEqualValue(endDate);
    }

    // ── Amount range ──────────────────────────────────────────────────────────
    if (minAmountCents != null) {
      conditions = conditions & t.amount.isBiggerOrEqualValue(minAmountCents);
    }
    if (maxAmountCents != null) {
      conditions = conditions & t.amount.isSmallerOrEqualValue(maxAmountCents);
    }

    // ── Currency ──────────────────────────────────────────────────────────────
    if (currency != null) {
      conditions = conditions & t.originalCurrency.equals(currency);
    }

    // ── Tag ────────────────────────────────────────────────────────────────────
    if (tagId != null) {
      conditions = conditions & t.tagId.equals(tagId);
    }

    query
      ..where((_) => conditions)
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);

    return query.watch().map((rows) => rows.cast<Transaction>().toList());
  }

  // ── Savings Goal Cascade ──────────────────────────────────────────────────

  Future<List<Transaction>> getTransfersForGoal(String savingsGoalId) {
    return (select(transactions)
          ..where(
            (t) =>
                t.savingsGoalId.equals(savingsGoalId) &
                t.type.equalsValue(TransactionType.transfer),
          ))
        .get();
  }

  Future<void> setDeletedStatusForGoalTransfers(
    String savingsGoalId,
    bool isDeleted,
  ) async {
    final now = DateTime.now();
    await (update(transactions)
          ..where(
            (t) =>
                t.savingsGoalId.equals(savingsGoalId) &
                t.type.equalsValue(TransactionType.transfer),
          ))
        .write(
      TransactionsCompanion(
        isDeleted: Value(isDeleted),
        modifiedAt: Value(now),
      ),
    );
  }
}
