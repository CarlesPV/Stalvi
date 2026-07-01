import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/presentation/providers/automatic_transactions_providers.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'create_automatic_transaction_sheet.dart';

class AutomaticTransactionsScreen extends ConsumerWidget {
  const AutomaticTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(automaticTransactionsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsAutomaticTransactions),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
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
              return Card(
                child: ListTile(
                  title: Text(txn.notes ?? l10n.settingsAutomaticTransactions),
                  subtitle: Text(
                      '${l10n.recurrenceDaysLabel}: ${txn.recurrenceDays}\n${l10n.nextExecution}: ${txn.nextExecutionDate.toLocal().toString().split(' ')[0]}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          CreateAutomaticTransactionSheet.show(context,
                              transactionToEdit: txn);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await ref
                              .read(deleteAutomaticTransactionUseCaseProvider)
                              .execute(txn.id);
                          ref.invalidate(automaticTransactionsListProvider);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          CreateAutomaticTransactionSheet.show(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
