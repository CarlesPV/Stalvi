import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/utils/currency_formatter.dart';
import 'package:stalvi/domain/entities/trash_item.dart';
import 'package:stalvi/presentation/widgets/category_icon_picker.dart';
import 'recycle_bin_provider.dart';

class RecycleBinScreen extends ConsumerWidget {
  const RecycleBinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recycleBinProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recycleBinTitle)),
      body: state.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.recycleBinEmpty));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _TrashItemTile(item: item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) =>
            Center(child: Text('${l10n.unexpectedError}: $err')),
      ),
    );
  }
}

class _TrashItemTile extends ConsumerWidget {
  final TrashItem item;

  const _TrashItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(recycleBinProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final formatter = ref.watch(currencyFormatterProvider);

    IconData getIconForType() {
      switch (item.type) {
        case TrashItemType.transaction:
          return Icons.receipt_long;
        case TrashItemType.category:
          return Icons.category;
        case TrashItemType.account:
          return Icons.account_balance_wallet;
        case TrashItemType.budget:
          return Icons.pie_chart;
        case TrashItemType.savingsGoal:
          return Icons.savings;
        case TrashItemType.automaticTransaction:
          return Icons.autorenew;
        case TrashItemType.tag:
          return Icons.tag;
      }
    }

    String getTypeLabel() {
      switch (item.type) {
        case TrashItemType.transaction:
          return l10n.transactions;
        case TrashItemType.category:
          return l10n.filterSheetCategory;
        case TrashItemType.account:
          return l10n.labelAccount;
        case TrashItemType.budget:
          return l10n.budgets;
        case TrashItemType.savingsGoal:
          return l10n.savingsGoal;
        case TrashItemType.automaticTransaction:
          return l10n.settingsAutomaticTransactions;
        case TrashItemType.tag:
          return l10n.labelTag;
      }
    }

    String getFormattedTitle() {
      if (item.type == TrashItemType.budget) {
        return l10n.labelBudget;
      }
      if (item.type != TrashItemType.transaction || item.metadata == null) {
        return item.name;
      }

      final txTypeIdx = item.metadata!['txType'] as int;
      final txTypeStr = txTypeIdx == 0
          ? l10n.filterIncome
          : (txTypeIdx == 1
              ? l10n.filterExpense
              : l10n.filterSheetTransferType);

      final nameStr = item.name.isNotEmpty ? item.name : txTypeStr;

      final amount = item.metadata!['amount'] as int;
      final currency = item.metadata!['currency'] as String;

      final formattedAmt = formatter.format(
        amount / 100.0,
        currencyCode: currency,
        showSign: false,
      );

      return '$nameStr - $formattedAmt';
    }

    final remainingDays = 30 - DateTime.now().difference(item.deletedAt).inDays;

    Color getAvatarColor() {
      if (item.metadata != null && item.metadata!['color'] != null) {
        final colorStr = item.metadata!['color'] as String;
        if (colorStr.isNotEmpty) {
          return _parseTrashColor(colorStr);
        }
      }
      return Colors.grey.shade300;
    }

    IconData getDisplayIcon() {
      if (item.metadata != null && item.metadata!['icon'] != null) {
        final iconStr = item.metadata!['icon'] as String;
        if (iconStr.isNotEmpty) {
          return CategoryIconPicker.iconDataForKey(iconStr);
        }
      }
      return getIconForType();
    }

    Color getIconColor() {
      if (item.metadata != null && item.metadata!['color'] != null) {
        final colorStr = item.metadata!['color'] as String;
        if (colorStr.isNotEmpty) {
          return Colors.white;
        }
      }
      return Colors.grey.shade700;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: getAvatarColor(),
        child: Icon(getDisplayIcon(), color: getIconColor()),
      ),
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          getFormattedTitle(),
        ),
      ),
      subtitle: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          '${l10n.recycleBinDaysRemaining(remainingDays)} • ${getTypeLabel()}',
          style: TextStyle(
            color: remainingDays <= 3 ? Colors.red : Colors.grey,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.restore, color: Colors.green),
            tooltip: l10n.recycleBinRestoreTooltip,
            onPressed: () {
              notifier.restoreItem(item.id, item.type);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.recycleBinRestoredMessage)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            tooltip: l10n.recycleBinDeleteTooltip,
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.recycleBinDeleteConfirmTitle),
                  content: Text(l10n.recycleBinDeleteConfirmMessage),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(l10n.btnCancel),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        notifier.deleteItemPermanently(item.id, item.type);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.recycleBinDeletedMessage),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(l10n.btnDelete),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Color _parseTrashColor(String hexString) {
  if (hexString.isEmpty) return Colors.grey;
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  try {
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (_) {
    return Colors.grey;
  }
}
