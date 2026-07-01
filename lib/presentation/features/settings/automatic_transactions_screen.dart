import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/theme/app_theme.dart';
import 'package:stalvi/core/utils/currency_formatter.dart';
import 'package:stalvi/core/utils/icon_helper.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/presentation/providers/automatic_transactions_providers.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'create_edit_automatic_transaction_screen.dart';

class AutomaticTransactionsScreen extends ConsumerWidget {
  const AutomaticTransactionsScreen({super.key});

  Color _parseHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String _formatRecurrence(BuildContext context, int days) {
    final l10n = AppLocalizations.of(context)!;
    if (days == 7) return l10n.autoTxFormatWeekly;
    if (days == 30) return l10n.autoTxFormatMonthly;
    if (days == 365) return l10n.autoTxFormatYearly;
    return l10n.autoTxFormatEveryDays(days);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final financialColors = context.financialColors;

    final transactionsAsync = ref.watch(automaticTransactionsListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final categories = categoriesAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsAutomaticTransactions),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${l10n.unexpectedError}: $e')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Text(l10n.noDataAvailable),
            );
          }
          return ListView.builder(
            itemCount: transactions.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final txn = transactions[index];
              final category =
                  categories.where((c) => c.id == txn.categoryId).firstOrNull;

              final isExpense = txn.type == TransactionType.expense;
              final amountColor = isExpense
                  ? financialColors.negative
                  : financialColors.positive;
              final amountPrefix = isExpense ? '-' : '+';
              final amountText =
                  '$amountPrefix${CurrencyFormatter(currencyCode: txn.currency).format(txn.amount / 100)}';

              final catColor = category != null
                  ? _parseHexColor(category.color)
                  : colorScheme.onSurfaceVariant;
              final catIcon = category != null
                  ? getIconData(category.icon)
                  : Icons.category_rounded;

              return Card(
                elevation: 0,
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateEditAutomaticTransactionScreen(
                          transactionToEdit: txn,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: catColor.withValues(alpha: 0.12),
                          child: Icon(catIcon, color: catColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                txn.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.repeat_rounded,
                                    size: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatRecurrence(
                                      context,
                                      txn.recurrenceDays,
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              amountText,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: amountColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: colorScheme.error,
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(l10n.deleteTransactionTitle),
                                    content: Text(
                                      l10n.deleteTransactionConfirmation,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: Text(l10n.btnCancel),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: Text(
                                          l10n.btnDelete,
                                          style: TextStyle(
                                            color: colorScheme.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm != true) return;

                                await ref
                                    .read(
                                      deleteAutomaticTransactionUseCaseProvider,
                                    )
                                    .execute(txn.id);
                                // No manual invalidate needed — the
                                // StreamProvider reacts automatically.
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateEditAutomaticTransactionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.autoTxNewTemplate),
      ),
    );
  }
}
