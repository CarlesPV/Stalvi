import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/presentation/providers/automatic_transactions_providers.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';

class CreateAutomaticTransactionSheet extends ConsumerStatefulWidget {
  final AutomaticTransaction? transactionToEdit;

  const CreateAutomaticTransactionSheet({super.key, this.transactionToEdit});

  static void show(BuildContext context,
      {AutomaticTransaction? transactionToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          CreateAutomaticTransactionSheet(transactionToEdit: transactionToEdit),
    );
  }

  @override
  ConsumerState<CreateAutomaticTransactionSheet> createState() =>
      _CreateAutomaticTransactionSheetState();
}

class _CreateAutomaticTransactionSheetState
    extends ConsumerState<CreateAutomaticTransactionSheet> {
  late TextEditingController _notesController;
  late TextEditingController _amountController;
  late TextEditingController _recurrenceController;
  String? _selectedAccountId;
  TransactionType _selectedType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    _notesController =
        TextEditingController(text: widget.transactionToEdit?.notes ?? '');
    _amountController = TextEditingController(
        text: widget.transactionToEdit != null
            ? (widget.transactionToEdit!.amount / 100).toString()
            : '');
    _recurrenceController = TextEditingController(
        text: widget.transactionToEdit?.recurrenceDays.toString() ?? '30');
    _selectedAccountId = widget.transactionToEdit?.accountId;
    if (widget.transactionToEdit != null) {
      _selectedType = widget.transactionToEdit!.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accountsAsync = ref.watch(accountsListProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
                widget.transactionToEdit == null
                    ? l10n.createAutomaticTransaction
                    : l10n.btnSave,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SegmentedButton<TransactionType>(
              segments: [
                ButtonSegment(
                    value: TransactionType.expense, label: Text(l10n.expense)),
                ButtonSegment(
                    value: TransactionType.income, label: Text(l10n.income)),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<TransactionType> selection) {
                setState(() {
                  _selectedType = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  labelText: l10n.labelAmount,
                  border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            accountsAsync.when(
              data: (accounts) => DropdownButtonFormField<String>(
                value: _selectedAccountId ??
                    (accounts.isNotEmpty ? accounts.first.id : null),
                items: accounts
                    .map((a) =>
                        DropdownMenuItem(value: a.id, child: Text(a.name)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedAccountId = val),
                decoration: InputDecoration(
                    labelText: l10n.labelAccount,
                    border: const OutlineInputBorder()),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text(e.toString()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                  labelText: l10n.labelNotes,
                  border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _recurrenceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: l10n.recurrenceDaysLabel,
                  border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: Text(l10n.btnSave),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _save() async {
    final amtDouble = double.tryParse(_amountController.text);
    if (amtDouble == null || _selectedAccountId == null) return;

    int recDays = int.tryParse(_recurrenceController.text) ?? 30;

    final txn = AutomaticTransaction(
      id: widget.transactionToEdit?.id ?? const Uuid().v4(),
      amount: (amtDouble * 100).toInt(),
      type: _selectedType,
      accountId: _selectedAccountId!,
      notes: _notesController.text,
      recurrenceDays: recDays,
      nextExecutionDate: widget.transactionToEdit?.nextExecutionDate ??
          DateTime.now().add(Duration(days: recDays)),
      createdAt: widget.transactionToEdit?.createdAt ?? DateTime.now(),
    );

    if (widget.transactionToEdit == null) {
      await ref.read(createAutomaticTransactionUseCaseProvider).execute(txn);
    } else {
      await ref.read(updateAutomaticTransactionUseCaseProvider).execute(txn);
    }

    ref.invalidate(automaticTransactionsListProvider);
    if (mounted) Navigator.of(context).pop();
  }
}
