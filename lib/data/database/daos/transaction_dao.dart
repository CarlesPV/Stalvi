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

    query
      ..where((_) => conditions)
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);

    // ── Tag (resolved via subquery + LIKE on notes) ────────────────────────────
    // If tagId is provided we return a stream that first resolves the tag name,
    // then layers a LIKE filter on the notes column. Because Drift streams are
    // reactive but subqueries must run asynchronously, we use asyncExpand to
    // flatten the two futures into a single stream.
    if (tagId != null) {
      return _watchFilteredWithTag(query, tagId);
    }

    return query.watch().map((rows) => rows.cast<Transaction>().toList());
  }

  /// Fetches the [Tag] with [tagId], extracts its name, applies a LIKE filter
  /// on the notes column, and returns a reactive stream.
  ///
  /// If the tag does not exist the stream emits an empty list and completes.
  Stream<List<Transaction>> _watchFilteredWithTag(
    SimpleSelectStatement<$TransactionsTable, Transaction> baseQuery,
    String tagId,
  ) async* {
    final tag = await (select(tags)..where((tg) => tg.id.equals(tagId)))
        .getSingleOrNull();

    if (tag == null) {
      yield [];
      return;
    }

    // Apply LIKE filter: '%tagName%' matches the tag name inside notes.
    // SQLite LIKE is case-insensitive for ASCII characters by default.
    baseQuery.where((t) => t.notes.like('%${tag.name}%'));

    yield* baseQuery.watch().map((rows) => rows.cast<Transaction>().toList());
  }
}
