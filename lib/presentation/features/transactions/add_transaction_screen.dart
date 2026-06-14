import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/core/theme/app_theme.dart';
import 'package:konta/domain/entities/account.dart';
import 'package:konta/domain/entities/category.dart';
import 'package:konta/domain/entities/category_type.dart';
import 'package:konta/domain/entities/transaction_type.dart';
import 'package:konta/presentation/providers/add_transaction_notifier.dart';
import 'package:konta/presentation/providers/repository_providers.dart';

/// Screen containing the transaction creation form.
///
/// Fully stylized according to the Konta core brand aesthetics, leveraging the
/// custom semantic colors from [FinancialColors] for positive/negative states.
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Synchronize initial values from controllers to notifier
    _amountController.addListener(() {
      ref
          .read(addTransactionNotifierProvider.notifier)
          .updateAmount(_amountController.text);
    });
    _notesController.addListener(() {
      ref
          .read(addTransactionNotifierProvider.notifier)
          .updateNotes(_notesController.text);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Maps seeded icon name strings to standard [IconData] constants.
  IconData _getIconData(String name) {
    switch (name) {
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'directions_car':
        return Icons.directions_car_rounded;
      case 'attach_money':
        return Icons.attach_money_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _parseHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final financialColors = context.financialColors;

    final state = ref.watch(addTransactionNotifierProvider);
    final isExpense = state.type == TransactionType.expense;
    final activeColor =
        isExpense ? financialColors.negative : financialColors.positive;

    // Listen to form submission status to show SnackBars and pop screen
    ref.listen<AsyncValue<void>>(
      addTransactionNotifierProvider.select((s) => s.submissionStatus),
      (prev, next) {
        next.when(
          data: (_) {
            if (prev is AsyncLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction created successfully!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop();
            }
          },
          error: (err, _) {
            final message = err is AppException ? err.message : err.toString();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          loading: () {},
        );
      },
    );

    // Watch data lists
    final accountsAsync = ref.watch(accountsListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);

    final accounts = accountsAsync.valueOrNull ?? [];
    final selectedAccount = accounts.isEmpty
        ? null
        : accounts.firstWhere(
            (a) => a.id == state.accountId,
            orElse: () => accounts.first,
          );

    final categories = categoriesAsync.valueOrNull ?? [];
    final selectedCategory = state.categoryId == null
        ? null
        : categories.firstWhere(
            (c) => c.id == state.categoryId,
            orElse: () => categories.first,
          );

    final isLoading = state.submissionStatus.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Transaction',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Income/Expense Custom Segmented Control ───────────────────
              Container(
                height: 54,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(addTransactionNotifierProvider.notifier)
                              .updateType(TransactionType.expense);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isExpense
                                ? financialColors.negative
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Expense',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isExpense
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(addTransactionNotifierProvider.notifier)
                              .updateType(TransactionType.income);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !isExpense
                                ? financialColors.positive
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Income',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: !isExpense
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Large Amount Field ────────────────────────────────────────
              Text(
                'AMOUNT',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '€',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: activeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IntrinsicWidth(
                    child: TextField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: activeColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                      ),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      autofocus: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Selectors Card ────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  children: [
                    // Account Selector
                    _FormSelectorTile(
                      label: 'Account',
                      value: selectedAccount?.name ?? 'Select Account',
                      icon: selectedAccount != null
                          ? _getIconData(selectedAccount.icon)
                          : Icons.account_balance_wallet_rounded,
                      iconColor: selectedAccount != null
                          ? _parseHexColor(selectedAccount.color)
                          : colorScheme.onSurfaceVariant,
                      onTap: () => _showAccountSelector(
                        context,
                        accountsAsync.valueOrNull ?? [],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: colorScheme.outline.withValues(alpha: 0.08),
                    ),
                    // Category Selector
                    _FormSelectorTile(
                      label: 'Category',
                      value: selectedCategory?.name ?? 'Uncategorized',
                      icon: selectedCategory != null
                          ? _getIconData(selectedCategory.icon)
                          : Icons.category_rounded,
                      iconColor: selectedCategory != null
                          ? _parseHexColor(selectedCategory.color)
                          : colorScheme.onSurfaceVariant,
                      onTap: () => _showCategorySelector(
                        context,
                        categoriesAsync.valueOrNull ?? [],
                        state.type,
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: colorScheme.outline.withValues(alpha: 0.08),
                    ),
                    // Date Selector
                    _FormSelectorTile(
                      label: 'Date',
                      value: DateFormat('EEEE, MMM d, y').format(state.date),
                      icon: Icons.calendar_today_rounded,
                      iconColor: colorScheme.primary,
                      onTap: () => _selectDate(context, state.date),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Notes Text Field ──────────────────────────────────────────
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  alignLabelWithHint: true,
                  hintText: 'Add details about this transaction...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.2),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.08),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: activeColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // ── Submit Button ─────────────────────────────────────────────
              FilledButton(
                onPressed: isLoading
                    ? null
                    : () {
                        ref
                            .read(addTransactionNotifierProvider.notifier)
                            .submit();
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: activeColor,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: activeColor.withValues(alpha: 0.3),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Transaction',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Sheet Picker Helpers ──────────────────────────────────────────────

  void _showAccountSelector(BuildContext context, List<Account> accounts) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.read(addTransactionNotifierProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Account',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    final isSelected = state.accountId == account.id;
                    final accColor = _parseHexColor(account.color);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accColor.withValues(alpha: 0.08)
                            : colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? accColor.withValues(alpha: 0.4)
                              : Colors.transparent,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: accColor.withValues(alpha: 0.12),
                          child: Icon(
                            _getIconData(account.icon),
                            color: accColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          account.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          account.currency,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded, color: accColor)
                            : null,
                        onTap: () {
                          ref
                              .read(addTransactionNotifierProvider.notifier)
                              .updateAccount(account.id);
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategorySelector(
    BuildContext context,
    List<Category> categories,
    TransactionType type,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.read(addTransactionNotifierProvider);

    // Filter categories: match transaction type (income vs expense)
    final filteredCategories = categories.where((c) {
      if (c.associatedType == null) return true; // neutral category
      if (type == TransactionType.income &&
          c.associatedType == CategoryType.income) {
        return true;
      }
      if (type == TransactionType.expense &&
          c.associatedType == CategoryType.expense) {
        return true;
      }
      return false;
    }).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      filteredCategories.length + 1, // +1 for "Uncategorized"
                  itemBuilder: (context, index) {
                    final isUncategorized = index == 0;
                    final isSelected = isUncategorized
                        ? state.categoryId == null
                        : state.categoryId == filteredCategories[index - 1].id;

                    final category =
                        isUncategorized ? null : filteredCategories[index - 1];
                    final catColor = isUncategorized
                        ? colorScheme.onSurfaceVariant
                        : _parseHexColor(category!.color);
                    final catIcon = isUncategorized
                        ? Icons.category_rounded
                        : _getIconData(category!.icon);
                    final catName =
                        isUncategorized ? 'Uncategorized' : category!.name;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? catColor.withValues(alpha: 0.08)
                            : colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? catColor.withValues(alpha: 0.4)
                              : Colors.transparent,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: catColor.withValues(alpha: 0.12),
                          child: Icon(catIcon, color: catColor, size: 20),
                        ),
                        title: Text(
                          catName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded, color: catColor)
                            : null,
                        onTap: () {
                          ref
                              .read(addTransactionNotifierProvider.notifier)
                              .updateCategory(category?.id);
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime currentDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(currentDate.year - 5),
      lastDate: DateTime.now(), // Protect future date validations
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: context
                      .financialColors.negative, // Match core branding accent
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != currentDate) {
      ref.read(addTransactionNotifierProvider.notifier).updateDate(pickedDate);
    }
  }
}

/// A custom list tile row used as form inputs for selectors.
class _FormSelectorTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _FormSelectorTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: iconColor.withValues(alpha: 0.1),
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
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
