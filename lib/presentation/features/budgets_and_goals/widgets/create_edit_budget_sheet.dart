import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/budget.dart';
import 'package:stalvi/domain/usecases/create_budget_usecase.dart';
import 'package:stalvi/presentation/providers/budgets_goals_providers.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CreateEditBudgetSheet extends ConsumerStatefulWidget {
  final Budget? existingBudget;

  const CreateEditBudgetSheet({super.key, this.existingBudget});

  static void show(BuildContext context, {Budget? budget}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateEditBudgetSheet(existingBudget: budget),
    );
  }

  @override
  ConsumerState<CreateEditBudgetSheet> createState() =>
      _CreateEditBudgetSheetState();
}

class _CreateEditBudgetSheetState extends ConsumerState<CreateEditBudgetSheet> {
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    if (widget.existingBudget != null) {
      final b = widget.existingBudget!;
      _amountController.text = (b.targetAmount / 100).toStringAsFixed(2);
      _selectedCategoryId = b.categoryId;
      _startDate = b.startDate;
      _endDate = b.endDate;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final amountDouble = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final targetAmountCents = (amountDouble * 100).round();

    if (targetAmountCents <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.errorInvalidAmount)));
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.errorCategoryRequired)));
      return;
    }
    if (!_endDate.isAfter(_startDate)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.errorEndDateBeforeStart)));
      return;
    }

    if (widget.existingBudget == null) {
      final params = CreateBudgetParams(
        id: const Uuid().v4(),
        categoryId: _selectedCategoryId!,
        targetAmount: targetAmountCents,
        startDate: _startDate,
        endDate: _endDate,
      );
      await ref.read(budgetsNotifierProvider.notifier).createBudget(params);
    } else {
      final updatedBudget = widget.existingBudget!.copyWith(
        categoryId: _selectedCategoryId,
        targetAmount: targetAmountCents,
        startDate: _startDate,
        endDate: _endDate,
        modifiedAt: DateTime.now(),
      );
      await ref
          .read(budgetsNotifierProvider.notifier)
          .updateBudget(updatedBudget);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    if (widget.existingBudget == null) return;
    await ref
        .read(budgetsNotifierProvider.notifier)
        .deleteBudget(widget.existingBudget!.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate(bool isStart) async {
    final current = isStart ? _startDate : _endDate;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesListProvider);
    final isEditing = widget.existingBudget != null;
    final state = ref.watch(budgetsNotifierProvider);
    final isLoading = state is AsyncLoading;

    final locale = Localizations.localeOf(context).toString();
    final df = DateFormat.yMMMd(locale);

    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        padding:
            EdgeInsets.fromLTRB(24, 12, 24, 24 + mediaQuery.viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? l10n.editBudget : l10n.addBudget,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (isEditing)
                    IconButton(
                      icon:
                          Icon(Icons.delete_outline, color: colorScheme.error),
                      onPressed: isLoading ? null : _delete,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.targetAmount,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                data: (categories) {
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: l10n.labelCategory,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    items: categories.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCategoryId = val);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text(l10n.unexpectedError),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.startDate,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(df.format(_startDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.endDate,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(df.format(_endDate)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 54),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(l10n.btnCancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        minimumSize: const Size(0, 54),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(l10n.btnSave,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
