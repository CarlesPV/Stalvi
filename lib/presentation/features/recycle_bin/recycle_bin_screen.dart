import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import '../../../domain/entities/trash_item.dart';
import 'recycle_bin_provider.dart';

class RecycleBinScreen extends ConsumerWidget {
  const RecycleBinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recycleBinProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recycleBinTitle),
      ),
      body: state.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(l10n.recycleBinEmpty),
            );
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
      }
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: Icon(getIconForType(), color: Colors.grey.shade700),
      ),
      title: Text(item.name),
      subtitle: Text(
        l10n.recycleBinDaysRemaining(item.daysRemaining),
        style: TextStyle(
          color: item.daysRemaining <= 3 ? Colors.red : Colors.grey,
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
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.btnCancel),
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
                      child: Text(l10n.btnDelete),
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
