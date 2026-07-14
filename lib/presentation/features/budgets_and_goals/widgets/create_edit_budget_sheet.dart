import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/budget.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/usecases/create_budget_usecase.dart';
import 'package:stalvi/domain/usecases/update_budget_usecase.dart';
import '../../../providers/budgets_goals_providers.dart';
import '../../../providers/repository_providers.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:stalvi/core/utils/icon_helper.dart';
import 'package:stalvi/domain/entities/category_type.dart';

class CreateEditBudgetSheet extends ConsumerStatefulWidget {
  final Budget? existingBudget;

  const CreateEditBudgetSheet({super.key, this.existingBudget});

  static void show(BuildContext context, {Budget? budget}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
  String? _selectedAccountId;
  String _selectedCurrency = 'EUR';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String? _validationError;

  @override
  void initState() {
    super.initState();
    if (widget.existingBudget != null) {
      final b = widget.existingBudget!;
      _amountController.text = (b.targetAmount / 100).toStringAsFixed(2);
      _selectedCategoryId = b.categoryId;
      _selectedAccountId = b.accountId;
      _startDate = b.startDate;
      _endDate = b.endDate;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final profileAsync = ref.read(defaultProfileProvider);
        if (profileAsync.hasValue) {
          setState(() {
            _selectedCurrency = profileAsync.value!.defaultCurrency;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Color _parseHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final amountDouble = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final targetAmountCents = (amountDouble * 100).round();

    if (widget.existingBudget == null && _selectedAccountId == null) {
      setState(() => _validationError = l10n.errorAccountRequired);
      return;
    }
    if (widget.existingBudget == null && targetAmountCents <= 0) {
      setState(() => _validationError = l10n.errorInvalidAmount);
      return;
    }
    if (_selectedCategoryId == null) {
      setState(() => _validationError = l10n.errorCategoryRequired);
      return;
    }
    if (!_endDate.isAfter(_startDate)) {
      setState(() => _validationError = l10n.errorEndDateBeforeStart);
      return;
    }

    setState(() => _validationError = null);

    if (widget.existingBudget == null) {
      final params = CreateBudgetParams(
        id: const Uuid().v4(),
        accountId: _selectedAccountId!,
        categoryId: _selectedCategoryId!,
        targetAmount: targetAmountCents,
        startDate: _startDate,
        endDate: _endDate,
      );
      await ref.read(budgetsNotifierProvider.notifier).createBudget(params);
    } else {
      final params = UpdateBudgetParams(
        id: widget.existingBudget!.id,
        categoryId: _selectedCategoryId!,
        startDate: _startDate,
        endDate: _endDate,
      );
      await ref.read(budgetsNotifierProvider.notifier).updateBudget(params);
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
    final accountsAsync = ref.watch(accountsListProvider);
    final isEditing = widget.existingBudget != null;
    final state = ref.watch(budgetsNotifierProvider);
    final isLoading = state is AsyncLoading;

    final locale = Localizations.localeOf(context).toString();
    final df = DateFormat.yMMMd(locale);

    final accounts = accountsAsync.valueOrNull ?? [];
    final existingAccount = isEditing
        ? accounts.firstWhere(
            (a) => a.id == widget.existingBudget!.accountId,
            orElse: () => accounts.isNotEmpty
                ? accounts.first
                : Account(
                    id: '',
                    name: '',
                    userId: '',
                    type: AccountType.cash,
                    initialBalance: 0,
                    currency: 'EUR',
                    color: '',
                    icon: '',
                    isDefault: false,
                    isDeleted: false,
                    createdAt: DateTime.now(),
                    modifiedAt: DateTime.now(),
                  ),
          )
        : null;
    final currencyToShow =
        isEditing ? (existingAccount?.currency ?? 'EUR') : _selectedCurrency;

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
                    isEditing ? l10n.budgetDetails : l10n.addBudget,
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
                enabled: !isEditing,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.targetAmount,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBorder: isEditing
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        )
                      : null,
                  suffixIcon: isEditing
                      ? Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: currencyToShow,
                decoration: InputDecoration(
                  labelText: l10n.labelCurrency,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBorder: isEditing
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        )
                      : null,
                  suffixIcon: isEditing
                      ? Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        )
                      : null,
                ),
                items: isEditing
                    ? [
                        DropdownMenuItem(
                          value: currencyToShow,
                          child: Text(currencyToShow),
                        ),
                      ]
                    : [
                        DropdownMenuItem(
                          value: 'EUR',
                          child: Text(l10n.currencyEUR),
                        ),
                        DropdownMenuItem(
                          value: 'USD',
                          child: Text(l10n.currencyUSD),
                        ),
                        DropdownMenuItem(
                          value: 'GBP',
                          child: Text(l10n.currencyGBP),
                        ),
                        DropdownMenuItem(
                          value: 'JPY',
                          child: Text(l10n.currencyJPY),
                        ),
                        DropdownMenuItem(
                          value: 'CHF',
                          child: Text(l10n.currencyCHF),
                        ),
                        DropdownMenuItem(
                          value: 'CAD',
                          child: Text(l10n.currencyCAD),
                        ),
                        DropdownMenuItem(
                          value: 'AUD',
                          child: Text(l10n.currencyAUD),
                        ),
                        DropdownMenuItem(
                          value: 'CNY',
                          child: Text(l10n.currencyCNY),
                        ),
                      ],
                onChanged: isEditing
                    ? null
                    : (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCurrency = val;
                            _selectedAccountId = null;
                          });
                        }
                      },
              ),
              const SizedBox(height: 16),
              accountsAsync.when(
                data: (accountsList) {
                  final filteredAccounts = accountsList
                      .where((a) => a.currency == currencyToShow)
                      .toList();

                  if (!isEditing &&
                      _selectedAccountId == null &&
                      filteredAccounts.isNotEmpty) {
                    final defaultAcc = filteredAccounts.firstWhere(
                      (a) => a.isDefault,
                      orElse: () => filteredAccounts.first,
                    );
                    _selectedAccountId = defaultAcc.id;
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: isEditing
                        ? widget.existingBudget!.accountId
                        : _selectedAccountId,
                    decoration: InputDecoration(
                      labelText: l10n.labelAccount,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBorder: isEditing
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color:
                                    colorScheme.outline.withValues(alpha: 0.3),
                              ),
                            )
                          : null,
                      suffixIcon: isEditing
                          ? Icon(
                              Icons.lock_outline_rounded,
                              size: 18,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            )
                          : null,
                    ),
                    items: isEditing
                        ? (existingAccount != null
                            ? [
                                DropdownMenuItem(
                                  value: existingAccount.id,
                                  child: Row(
                                    children: [
                                      Icon(
                                        getIconData(existingAccount.icon),
                                        color: _parseHexColor(
                                          existingAccount.color,
                                        ),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(existingAccount.name),
                                    ],
                                  ),
                                ),
                              ]
                            : [])
                        : filteredAccounts.map((a) {
                            return DropdownMenuItem(
                              value: a.id,
                              child: Row(
                                children: [
                                  Icon(
                                    getIconData(a.icon),
                                    color: _parseHexColor(a.color),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(a.name),
                                ],
                              ),
                            );
                          }).toList(),
                    onChanged: isEditing
                        ? null
                        : (val) {
                            setState(() => _selectedAccountId = val);
                          },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text(l10n.unexpectedError),
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                data: (categoriesList) {
                  final filteredCategories = categoriesList.where((c) {
                    if (isEditing) {
                      return c.id == widget.existingBudget!.categoryId;
                    }
                    return c.associatedType == CategoryType.expense ||
                        c.associatedType == null;
                  }).toList();

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: l10n.labelCategory,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBorder: isEditing
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color:
                                    colorScheme.outline.withValues(alpha: 0.3),
                              ),
                            )
                          : null,
                      suffixIcon: isEditing
                          ? Icon(
                              Icons.lock_outline_rounded,
                              size: 18,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            )
                          : null,
                    ),
                    items: filteredCategories.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Row(
                          children: [
                            Icon(
                              getIconData(c.icon),
                              color: _parseHexColor(c.color),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(c.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: isEditing
                        ? null
                        : (val) {
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
                      onTap: isEditing ? null : () => _pickDate(true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.startDate,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(df.format(_startDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: isEditing ? null : () => _pickDate(false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.endDate,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(df.format(_endDate)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              if (_validationError != null) ...[
                Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    final colorScheme = theme.colorScheme;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            colorScheme.errorContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.error.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: colorScheme.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _validationError!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isEditing ? l10n.btnCancel : l10n.btnCancel,
                      ), // Wait, close/cancel is fine
                    ),
                  ),
                  if (!isEditing) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: isLoading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          minimumSize: const Size(0, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                l10n.btnSave,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
