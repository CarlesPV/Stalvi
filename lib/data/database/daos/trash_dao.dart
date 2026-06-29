import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/account_table.dart';
import '../tables/budget_table.dart';
import '../tables/category_table.dart';
import '../tables/savings_goal_table.dart';
import '../tables/transaction_table.dart';
import 'package:stalvi/domain/entities/trash_item.dart';

part 'trash_dao.g.dart';

@DriftAccessor(
  tables: [
    Transactions,
    Categories,
    Accounts,
    Budgets,
    SavingsGoals,
  ],
)
class TrashDao extends DatabaseAccessor<AppDatabase> with _$TrashDaoMixin {
  TrashDao(super.db);

  /// Retrieves all soft-deleted items across major tables, mapped into [TrashItem].
  Future<List<TrashItem>> getTrashItems() async {
    final now = DateTime.now();
    final items = <TrashItem>[];

    // Transactions
    final transactionRows = await (select(transactions)
          ..where((t) => t.isDeleted.equals(true)))
        .get();
    final seenTransfers = <String>{};
    for (final t in transactionRows) {
      if (t.transferId != null) {
        if (seenTransfers.contains(t.transferId)) continue;
        seenTransfers.add(t.transferId!);
      }

      final displayName = t.notes ?? '';

      items.add(
        TrashItem(
          id: t.id,
          name: displayName,
          type: TrashItemType.transaction,
          daysRemaining: 30 - now.difference(t.modifiedAt).inDays,
          metadata: {
            'amount': t.amount,
            'txType': t.type.index,
            'currency': t.originalCurrency,
          },
        ),
      );
    }

    // Categories
    final categoryRows = await (select(categories)
          ..where((c) => c.isDeleted.equals(true)))
        .get();
    for (final c in categoryRows) {
      items.add(
        TrashItem(
          id: c.id,
          name: c.name,
          type: TrashItemType.category,
          daysRemaining: 30 - now.difference(c.modifiedAt).inDays,
        ),
      );
    }

    // Accounts
    final accountRows =
        await (select(accounts)..where((a) => a.isDeleted.equals(true))).get();
    for (final a in accountRows) {
      items.add(
        TrashItem(
          id: a.id,
          name: a.name,
          type: TrashItemType.account,
          daysRemaining: 30 - now.difference(a.modifiedAt).inDays,
        ),
      );
    }

    // Budgets
    final budgetRows =
        await (select(budgets)..where((b) => b.isDeleted.equals(true))).get();
    for (final b in budgetRows) {
      items.add(
        TrashItem(
          id: b.id,
          name: 'Budget',
          type: TrashItemType.budget,
          daysRemaining: 30 - now.difference(b.modifiedAt).inDays,
        ),
      );
    }

    // Savings Goals
    final goalRows = await (select(savingsGoals)
          ..where((s) => s.isDeleted.equals(true)))
        .get();
    for (final s in goalRows) {
      items.add(
        TrashItem(
          id: s.id,
          name: s.name,
          type: TrashItemType.savingsGoal,
          daysRemaining: 30 - now.difference(s.modifiedAt).inDays,
        ),
      );
    }

    // Sort items by days remaining (those expiring sooner first)
    items.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));

    return items;
  }

  /// Restores a soft-deleted item by setting its isDeleted to false and updating modifiedAt.
  Future<void> restoreItem(String id, TrashItemType type) async {
    final now = DateTime.now();

    switch (type) {
      case TrashItemType.transaction:
        await transaction(() async {
          final txn = await (select(transactions)
                ..where((t) => t.id.equals(id)))
              .getSingleOrNull();
          if (txn != null && txn.isDeleted) {
            final accountRow = await (select(accounts)
                  ..where((a) => a.id.equals(txn.accountId)))
                .getSingleOrNull();
            if (accountRow != null) {
              final double delta = txn.amount / 100.0;
              final double newBalance;
              if (txn.type == TransactionType.income) {
                newBalance = accountRow.initialBalance + delta;
              } else {
                newBalance = accountRow.initialBalance - delta;
              }
              await (update(accounts)..where((a) => a.id.equals(txn.accountId)))
                  .write(
                AccountsCompanion(
                  initialBalance: Value(newBalance),
                  modifiedAt: Value(now),
                ),
              );
            }
            await (update(transactions)..where((t) => t.id.equals(id))).write(
              TransactionsCompanion(
                isDeleted: const Value(false),
                modifiedAt: Value(now),
              ),
            );
          }
        });
        break;
      case TrashItemType.category:
        await (update(categories)..where((c) => c.id.equals(id))).write(
          CategoriesCompanion(
            isDeleted: const Value(false),
            modifiedAt: Value(now),
          ),
        );
        break;
      case TrashItemType.account:
        await (update(accounts)..where((a) => a.id.equals(id))).write(
          AccountsCompanion(
            isDeleted: const Value(false),
            modifiedAt: Value(now),
          ),
        );
        break;
      case TrashItemType.budget:
        await (update(budgets)..where((b) => b.id.equals(id))).write(
          BudgetsCompanion(
            isDeleted: const Value(false),
            modifiedAt: Value(now),
          ),
        );
        break;
      case TrashItemType.savingsGoal:
        await (update(savingsGoals)..where((s) => s.id.equals(id))).write(
          SavingsGoalsCompanion(
            isDeleted: const Value(false),
            modifiedAt: Value(now),
          ),
        );
        break;
    }
  }

  /// Permanently deletes an item from the database.
  Future<void> deleteItemPermanently(String id, TrashItemType type) async {
    switch (type) {
      case TrashItemType.transaction:
        await (delete(transactions)..where((t) => t.id.equals(id))).go();
        break;
      case TrashItemType.category:
        await (delete(categories)..where((c) => c.id.equals(id))).go();
        break;
      case TrashItemType.account:
        await (delete(accounts)..where((a) => a.id.equals(id))).go();
        break;
      case TrashItemType.budget:
        await (delete(budgets)..where((b) => b.id.equals(id))).go();
        break;
      case TrashItemType.savingsGoal:
        await (delete(savingsGoals)..where((s) => s.id.equals(id))).go();
        break;
    }
  }

  /// Hard deletes all items that are soft-deleted and were modified before [threshold].
  Future<void> purgeOldItems(DateTime threshold) async {
    await transaction(() async {
      await (delete(transactions)
            ..where(
              (t) =>
                  t.isDeleted.equals(true) &
                  t.modifiedAt.isSmallerThanValue(threshold),
            ))
          .go();

      await (delete(categories)
            ..where(
              (c) =>
                  c.isDeleted.equals(true) &
                  c.modifiedAt.isSmallerThanValue(threshold),
            ))
          .go();

      await (delete(accounts)
            ..where(
              (a) =>
                  a.isDeleted.equals(true) &
                  a.modifiedAt.isSmallerThanValue(threshold),
            ))
          .go();

      await (delete(budgets)
            ..where(
              (b) =>
                  b.isDeleted.equals(true) &
                  b.modifiedAt.isSmallerThanValue(threshold),
            ))
          .go();

      await (delete(savingsGoals)
            ..where(
              (s) =>
                  s.isDeleted.equals(true) &
                  s.modifiedAt.isSmallerThanValue(threshold),
            ))
          .go();
    });
  }
}
