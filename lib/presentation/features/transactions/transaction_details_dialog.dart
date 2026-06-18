import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/theme/app_theme.dart';
import 'package:stalvi/core/utils/currency_formatter.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:stalvi/presentation/providers/statistics_providers.dart';

import 'package:stalvi/core/utils/icon_helper.dart';

class TransactionDetailsDialog extends ConsumerWidget {
  final Transaction transaction;

  const TransactionDetailsDialog({
    super.key,
    required this.transaction,
  });

  static void show(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailsDialog(transaction: transaction),
    );
  }

  Color _parseHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  IconData _getIconData(String name) {
    return getIconData(name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final financialColors = context.financialColors;
    final l10n = AppLocalizations.of(context)!;

    final isIncome = transaction.type == TransactionType.income;
    final amountDouble = transaction.amount / 100.0;

    final formatter = ref.watch(currencyFormatterProvider);
    final amountStr = formatter.format(
      amountDouble,
      currencyCode: transaction.originalCurrency,
      showSign: true,
    );

    final isTransfer = transaction.type == TransactionType.transfer;

    final color = isTransfer
        ? Colors.blue
        : (isIncome ? financialColors.positive : financialColors.negative);

    final typeIcon = isTransfer
        ? Icons.swap_horiz_rounded
        : (isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded);

    final dateStr =
        DateFormat.yMMMMd(Localizations.localeOf(context).toString())
            .add_jm()
            .format(transaction.date);

    final accounts = ref.watch(accountsListProvider).valueOrNull ?? [];
    Account? account;
    Account? destinationAccount;
    for (final a in accounts) {
      if (a.id == transaction.accountId) {
        account = a;
      }
    }

    if (isTransfer) {
      final allTransactions =
          ref.watch(transactionsStreamProvider).valueOrNull ?? [];
      for (final tx in allTransactions) {
        if (tx.id != transaction.id &&
            tx.type == TransactionType.income &&
            tx.amount == transaction.amount &&
            tx.date == transaction.date) {
          for (final a in accounts) {
            if (a.id == tx.accountId) {
              destinationAccount = a;
              break;
            }
          }
          break;
        }
      }
    }

    final categories = ref.watch(categoriesListProvider).valueOrNull ?? [];
    Category? category;
    if (transaction.categoryId != null) {
      for (final c in categories) {
        if (c.id == transaction.categoryId) {
          category = c;
          break;
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle bar
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header title
          Text(
            isTransfer
                ? l10n.filterTransfer
                : (isIncome ? l10n.filterIncome : l10n.filterExpense),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Large stylized amount
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(typeIcon, color: color, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    amountStr,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Details grid/list
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              children: [
                if (isTransfer) ...[
                  _DetailRow(
                    label: l10n.labelOriginAccount,
                    valueWidget: Text(
                      account?.name ?? l10n.unknownAccount,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    icon: account != null
                        ? _getIconData(account.icon)
                        : Icons.account_balance_wallet_rounded,
                    iconColor: account != null
                        ? _parseHexColor(account.color)
                        : colorScheme.onSurfaceVariant,
                  ),
                  Divider(
                    height: 1,
                    color: colorScheme.outline.withValues(alpha: 0.08),
                  ),
                  _DetailRow(
                    label: l10n.labelDestinationAccount,
                    valueWidget: Text(
                      destinationAccount?.name ?? l10n.unknownAccount,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    icon: destinationAccount != null
                        ? _getIconData(destinationAccount.icon)
                        : Icons.account_balance_wallet_rounded,
                    iconColor: destinationAccount != null
                        ? _parseHexColor(destinationAccount.color)
                        : colorScheme.onSurfaceVariant,
                  ),
                ] else ...[
                  _DetailRow(
                    label: l10n.labelAccount,
                    valueWidget: Text(
                      account?.name ?? l10n.unknownAccount,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    icon: account != null
                        ? _getIconData(account.icon)
                        : Icons.account_balance_wallet_rounded,
                    iconColor: account != null
                        ? _parseHexColor(account.color)
                        : colorScheme.onSurfaceVariant,
                  ),
                  Divider(
                    height: 1,
                    color: colorScheme.outline.withValues(alpha: 0.08),
                  ),
                  _DetailRow(
                    label: l10n.labelCategory,
                    valueWidget: Text(
                      category?.name ?? l10n.uncategorized,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    icon: category != null
                        ? _getIconData(category.icon)
                        : Icons.category_rounded,
                    iconColor: category != null
                        ? _parseHexColor(category.color)
                        : colorScheme.onSurfaceVariant,
                  ),
                ],
                Divider(
                  height: 1,
                  color: colorScheme.outline.withValues(alpha: 0.08),
                ),
                _DetailRow(
                  label: l10n.labelDate,
                  valueWidget: Text(
                    dateStr,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  icon: Icons.calendar_today_rounded,
                  iconColor: colorScheme.primary,
                ),
                if (transaction.notes?.isNotEmpty == true) ...[
                  Divider(
                    height: 1,
                    color: colorScheme.outline.withValues(alpha: 0.08),
                  ),
                  _DetailRow(
                    label: l10n.labelNotes,
                    valueWidget: Text(
                      transaction.notes!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    icon: Icons.notes_rounded,
                    iconColor: colorScheme.secondary,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Action buttons: Delete in full destructiveness
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    l10n.btnClose,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey('deleteTransactionButton'),
                  onPressed: () => _confirmDelete(context, ref),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: Text(
                    l10n.btnDelete,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.deleteTransactionTitle)),
            ],
          ),
          content: Text(
            l10n.deleteTransactionConfirmation,
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                l10n.btnCancel,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FilledButton(
              key: const ValueKey('confirmDeleteButton'),
              onPressed: () async {
                // Pop confirm dialog
                Navigator.of(dialogContext).pop();
                // Pop details sheet
                Navigator.of(context).pop();

                try {
                  // Perform soft delete
                  await ref
                      .read(transactionRepositoryProvider)
                      .deleteTransaction(transaction.id);

                  ref.invalidate(accountsListProvider);
                  ref.invalidate(transactionsStreamProvider);
                  ref.invalidate(periodSummaryProvider);
                  ref.invalidate(topExpenseCategoriesProvider);
                  ref.invalidate(topIncomeCategoriesProvider);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.transactionMovedToRecycleBin),
                        backgroundColor: colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${l10n.errorDeleteTransaction}: $e'),
                        backgroundColor: colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: Text(l10n.btnDelete),
            ),
          ],
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final Widget valueWidget;
  final IconData icon;
  final Color iconColor;

  const _DetailRow({
    required this.label,
    required this.valueWidget,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                valueWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
