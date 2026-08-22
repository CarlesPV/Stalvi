import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import '../providers/repository_providers.dart';
import 'package:stalvi/domain/usecases/update_account_usecase.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';

class EditAccountDialog extends ConsumerStatefulWidget {
  final Account account;

  const EditAccountDialog({super.key, required this.account});

  static void show(BuildContext context, Account account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditAccountDialog(account: account),
    );
  }

  @override
  ConsumerState<EditAccountDialog> createState() => _EditAccountDialogState();
}

class _EditAccountDialogState extends ConsumerState<EditAccountDialog> {
  late final TextEditingController _nameController;
  final _nameFocusNode = FocusNode();

  late AccountType _selectedType;
  late String _selectedColor;
  late String _selectedIcon;
  bool _isLoading = false;
  late bool _isDefault;
  String? _errorMessage;
  String? _nameError;
  String? _defaultAccountError;

  final List<String> _colors = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FFC107', // Amber
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#FF5722', // Deep Orange
  ];

  final List<Map<String, dynamic>> _icons = [
    {'name': 'wallet', 'icon': Icons.account_balance_wallet_rounded},
    {'name': 'business', 'icon': Icons.business_center_rounded},
    {'name': 'savings', 'icon': Icons.savings_rounded},
    {'name': 'credit_card', 'icon': Icons.credit_card_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
    _selectedType = widget.account.type;
    _selectedColor = widget.account.color;
    _selectedIcon = widget.account.icon;
    _isDefault = widget.account.isDefault;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Color _parseHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();

    setState(() {
      _errorMessage = null;
      _nameError = null;
      _defaultAccountError = null;
    });

    final l10n = AppLocalizations.of(context)!;
    if (name.isEmpty) {
      setState(() {
        _nameError = l10n.createAccountErrorName;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final params = UpdateAccountParams(
        id: widget.account.id,
        name: name,
        type: _selectedType,
        color: _selectedColor,
        icon: _selectedIcon,
        isDefault: _isDefault,
      );

      await ref.read(updateAccountUseCaseProvider).execute(params);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on ValidationException catch (e) {
      if (mounted) {
        setState(() {
          if (e.code == 'INVALID_NAME') {
            _errorMessage = l10n.createAccountErrorName;
          } else if (e.code == 'DEFAULT_ACCOUNT_REQUIRED') {
            _defaultAccountError = l10n.errorDefaultAccountRequired;
          } else {
            _errorMessage = e.message;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '${l10n.createAccountErrorFailed}: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    setState(() => _isLoading = true);
    bool hasTransactions = false;
    try {
      hasTransactions = await ref
          .read(transactionRepositoryProvider)
          .hasAnyTransactions(widget.account.id);
    } catch (e) {
      // Ignore: default to standard warning
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    if (!mounted) return;

    String? dialogError;
    bool isDeleting = false;

    // Show delete confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: colorScheme.error,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.btnDelete)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hasTransactions) ...[
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withValues(
                            alpha: 0.4,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: colorScheme.error,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                  Text(
                    hasTransactions
                        ? l10n.deleteAccountWithTransactionsWarning
                        : l10n.deleteAllDataWarning,
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      dialogError!,
                      style: TextStyle(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.btnCancel,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() {
                            isDeleting = true;
                            dialogError = null;
                          });
                          try {
                            await ref
                                .read(deleteAccountUseCaseProvider)
                                .execute(widget.account.id);
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop(true);
                            }
                          } on AccountInUseByAutomaticTransactionException {
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop(false);
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: colorScheme.error,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(l10n.warning),
                                    ],
                                  ),
                                  content: Text(
                                    l10n.accountInUseByAutoTxMessage,
                                  ),
                                  actionsAlignment: MainAxisAlignment.center,
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(l10n.btnClose),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } on ValidationException catch (e) {
                            if (dialogContext.mounted) {
                              setDialogState(() {
                                isDeleting = false;
                                if (e.code == 'LAST_ACCOUNT') {
                                  dialogError =
                                      l10n.errorCannotDeleteLastAccount;
                                } else if (e.code ==
                                    'DEFAULT_ACCOUNT_DELETION') {
                                  dialogError =
                                      l10n.errorCannotDeleteDefaultAccount;
                                } else if (e.code == 'NO_DEFAULT_ACCOUNT') {
                                  dialogError =
                                      l10n.errorNoDefaultAccountForReassignment;
                                } else {
                                  dialogError = e.message;
                                }
                              });
                            }
                          } catch (e) {
                            if (dialogContext.mounted) {
                              setDialogState(() {
                                isDeleting = false;
                                dialogError = e.toString().replaceAll(
                                      'Exception: ',
                                      '',
                                    );
                              });
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(l10n.btnDelete),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      if (mounted) {
        Navigator.of(context).pop(); // Close bottom sheet
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final l10n = AppLocalizations.of(context)!;

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
              // Drag handle
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
                    widget.account.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : _delete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: colorScheme.error,
                    ),
                    tooltip: l10n.btnDelete,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Account Name field
              TextField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                textInputAction: TextInputAction.done,
                maxLength: 31,
                decoration: InputDecoration(
                  labelText: l10n.createAccountNameLabel,
                  hintText: l10n.createAccountNameHint,
                  errorText: _nameError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Initial Balance field (read-only)
              TextField(
                controller: TextEditingController(
                  text: widget.account.initialBalance.toStringAsFixed(2),
                ),
                readOnly: true,
                enabled: false,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.createAccountInitialBalanceLabel,
                  hintText: l10n.hintAmountZero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  suffixIcon: Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Account Type header
              Text(
                l10n.createAccountTypeLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Account Type Selector Row with Horizontal Scroll
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: AccountType.values.map((type) {
                    final isSelected = _selectedType == type;
                    String label;
                    IconData icon;
                    switch (type) {
                      case AccountType.cash:
                        label = l10n.accountTypeCash;
                        icon = Icons.money_rounded;
                        break;
                      case AccountType.bank:
                        label = l10n.accountTypeBank;
                        icon = Icons.account_balance_rounded;
                        break;
                      case AccountType.savings:
                        label = l10n.accountTypeSavings;
                        icon = Icons.savings_rounded;
                        break;
                      case AccountType.card:
                        label = l10n.accountTypeCard;
                        icon = Icons.credit_card_rounded;
                        break;
                      case AccountType.other:
                        label = l10n.accountTypeOther;
                        icon = Icons.monetization_on_rounded;
                        break;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        showCheckmark: false,
                        avatar: Icon(
                          icon,
                          size: 16,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                        label: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: colorScheme.primary,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedType = type);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Currency Selector (read-only — immutable after creation)
              DropdownButtonFormField<String>(
                initialValue: widget.account.currency,
                decoration: InputDecoration(
                  labelText: l10n.labelCurrency,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  suffixIcon: Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'EUR', child: Text(l10n.currencyEUR)),
                  DropdownMenuItem(value: 'USD', child: Text(l10n.currencyUSD)),
                  DropdownMenuItem(value: 'GBP', child: Text(l10n.currencyGBP)),
                  DropdownMenuItem(value: 'JPY', child: Text(l10n.currencyJPY)),
                  DropdownMenuItem(value: 'CHF', child: Text(l10n.currencyCHF)),
                  DropdownMenuItem(value: 'CAD', child: Text(l10n.currencyCAD)),
                  DropdownMenuItem(value: 'AUD', child: Text(l10n.currencyAUD)),
                  DropdownMenuItem(value: 'CNY', child: Text(l10n.currencyCNY)),
                ],
                // null disables the dropdown — currency is immutable after creation
                onChanged: null,
              ),
              const SizedBox(height: 20),

              // Color selection
              Text(
                l10n.createAccountColorThemeLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _colors.map((colorHex) {
                  final color = _parseHexColor(colorHex);
                  final isSelected = _selectedColor == colorHex;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = colorHex),
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

              // Icon selection
              Text(
                l10n.createAccountIconLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
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
                    onTap: () => setState(() => _selectedIcon = name),
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
              // Set as Default switch
              SwitchListTile(
                title: Text(l10n.setAsDefault),
                value: _isDefault,
                onChanged: (val) async {
                  if (val) {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.warning),
                        content: Text(l10n.replaceDefaultAccountConfirm),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(l10n.btnCancel),
                            ),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(l10n.btnContinue),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      setState(() {
                        _isDefault = true;
                        _defaultAccountError = null;
                      });
                    }
                  } else {
                    setState(() {
                      _isDefault = false;
                      _defaultAccountError = null;
                    });
                  }
                },
              ),
              if (_defaultAccountError != null)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: Text(
                    _defaultAccountError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 28),

              // Save / Cancel button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n.btnCancel,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        minimumSize: const Size(0, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                l10n.btnSave,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
