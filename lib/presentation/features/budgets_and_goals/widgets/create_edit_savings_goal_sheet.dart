import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/savings_goal.dart';
import 'package:stalvi/domain/usecases/create_savings_goal_usecase.dart';
import 'package:stalvi/domain/usecases/update_savings_goal_usecase.dart';
import '../../../providers/budgets_goals_providers.dart';
import '../../../providers/repository_providers.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CreateEditSavingsGoalSheet extends ConsumerStatefulWidget {
  final SavingsGoal? existingGoal;

  const CreateEditSavingsGoalSheet({super.key, this.existingGoal});

  static void show(BuildContext context, {SavingsGoal? goal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateEditSavingsGoalSheet(existingGoal: goal),
    );
  }

  @override
  ConsumerState<CreateEditSavingsGoalSheet> createState() =>
      _CreateEditSavingsGoalSheetState();
}

class _CreateEditSavingsGoalSheetState
    extends ConsumerState<CreateEditSavingsGoalSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _targetDate;
  String _selectedColor = '#4CAF50';
  String _selectedIcon = 'savings';
  String _selectedCurrency = 'EUR';
  String? _validationError;

  final List<String> _colors = [
    '#2196F3',
    '#4CAF50',
    '#FFC107',
    '#E91E63',
    '#9C27B0',
    '#FF5722',
  ];
  final List<Map<String, dynamic>> _icons = [
    {'name': 'savings', 'icon': Icons.savings_rounded},
    {'name': 'directions_car', 'icon': Icons.directions_car_rounded},
    {'name': 'home', 'icon': Icons.home_rounded},
    {'name': 'flight', 'icon': Icons.flight_rounded},
    {'name': 'school', 'icon': Icons.school_rounded},
    {'name': 'medical_services', 'icon': Icons.medical_services_rounded},
    {'name': 'laptop', 'icon': Icons.laptop_rounded},
    {'name': 'beach_access', 'icon': Icons.beach_access_rounded},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingGoal != null) {
      final g = widget.existingGoal!;
      _nameController.text = g.name;
      _amountController.text = (g.targetAmount / 100).toStringAsFixed(2);
      _targetDate = g.targetDate;
      _selectedColor = g.color;
      _selectedIcon = g.icon;
      _selectedCurrency = g.currency;
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
    _nameController.dispose();
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
    final name = _nameController.text.trim();
    final amountDouble = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final targetAmountCents = (amountDouble * 100).round();

    if (name.isEmpty) {
      setState(() => _validationError = l10n.errorNameRequired);
      return;
    }
    if (widget.existingGoal == null && targetAmountCents <= 0) {
      setState(() => _validationError = l10n.errorInvalidAmount);
      return;
    }

    setState(() => _validationError = null);

    if (widget.existingGoal == null) {
      final params = CreateSavingsGoalParams(
        id: const Uuid().v4(),
        name: name,
        targetAmount: targetAmountCents,
        targetDate: _targetDate,
        color: _selectedColor,
        icon: _selectedIcon,
        currency: _selectedCurrency,
      );
      await ref
          .read(savingsGoalsNotifierProvider.notifier)
          .createSavingsGoal(params);
    } else {
      final params = UpdateSavingsGoalParams(
        id: widget.existingGoal!.id,
        name: name,
        targetDate: _targetDate,
        color: _selectedColor,
        icon: _selectedIcon,
      );
      await ref
          .read(savingsGoalsNotifierProvider.notifier)
          .updateSavingsGoal(params);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    if (widget.existingGoal == null) return;
    await ref
        .read(savingsGoalsNotifierProvider.notifier)
        .deleteSavingsGoal(widget.existingGoal!.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _targetDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.existingGoal != null;
    final state = ref.watch(savingsGoalsNotifierProvider);
    final isLoading = state is AsyncLoading;
    final locale = Localizations.localeOf(context).toString();
    final df = DateFormat.yMMMd(locale);

    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          24 + mediaQuery.viewInsets.bottom,
        ),
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
                    isEditing ? l10n.savingsGoalDetails : l10n.addSavingsGoal,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (isEditing)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                      onPressed: isLoading ? null : _delete,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                enabled: !isEditing,
                maxLength: 31,
                decoration: InputDecoration(
                  labelText: l10n.goalName,
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
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                enabled: !isEditing,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d{0,13}([.,]\d{0,2})?'),
                  ),
                ],
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
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCurrency,
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
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        )
                      : null,
                ),
                items: isEditing
                    ? [
                        DropdownMenuItem(
                          value: _selectedCurrency,
                          child: Text(_selectedCurrency),
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
                          setState(() => _selectedCurrency = val);
                        }
                      },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: isEditing ? null : _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.targetDate,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _targetDate != null
                        ? df.format(_targetDate!)
                        : l10n.optionalPlaceholder,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 8,
                runSpacing: 8,
                children: _colors.map((colorHex) {
                  final color = _parseHexColor(colorHex);
                  final isSelected = _selectedColor == colorHex;

                  return GestureDetector(
                    onTap: isEditing
                        ? null
                        : () => setState(() => _selectedColor = colorHex),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.outline
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 8,
                runSpacing: 8,
                children: _icons.map((item) {
                  final name = item['name'] as String;
                  final icon = item['icon'] as IconData;
                  final isSelected = _selectedIcon == name;
                  final activeColor = _parseHexColor(_selectedColor);

                  return GestureDetector(
                    onTap: isEditing
                        ? null
                        : () => setState(() => _selectedIcon = name),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? activeColor.withValues(alpha: 0.12)
                            : colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.3,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? activeColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? activeColor
                            : colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                    ),
                  );
                }).toList(),
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
                        color: colorScheme.errorContainer.withValues(
                          alpha: 0.2,
                        ),
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
                              maxLines: null,
                              overflow: TextOverflow.visible,
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
                mainAxisAlignment: MainAxisAlignment.center,
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
                      child: Text(l10n.btnCancel),
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
