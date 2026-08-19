import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/theme/app_theme.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/category_type.dart';
import 'package:stalvi/domain/entities/tag.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/recurrence_type.dart';
import '../../providers/create_edit_automatic_transaction_notifier.dart';
import '../../providers/repository_providers.dart';
import 'package:stalvi/core/utils/currency_formatter.dart';
import 'package:stalvi/core/utils/icon_helper.dart';
import 'categories_tags_management_screen.dart';

class CreateEditAutomaticTransactionScreen extends ConsumerStatefulWidget {
  final AutomaticTransaction? transactionToEdit;

  const CreateEditAutomaticTransactionScreen({
    super.key,
    this.transactionToEdit,
  });

  @override
  ConsumerState<CreateEditAutomaticTransactionScreen> createState() =>
      _CreateEditAutomaticTransactionScreenState();
}

class _CreateEditAutomaticTransactionScreenState
    extends ConsumerState<CreateEditAutomaticTransactionScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late final TextEditingController _customRecurrenceController;

  @override
  void initState() {
    super.initState();
    final initialTxn = widget.transactionToEdit;

    _nameController = TextEditingController(text: initialTxn?.name ?? '');
    _amountController = TextEditingController(
      text: initialTxn != null ? (initialTxn.amount / 100).toString() : '',
    );
    _notesController = TextEditingController(text: initialTxn?.notes ?? '');
    _customRecurrenceController = TextEditingController();

    _nameController.addListener(() {
      ref
          .read(createEditAutomaticTransactionProvider(initialTxn).notifier)
          .updateName(_nameController.text);
    });
    _amountController.addListener(() {
      ref
          .read(createEditAutomaticTransactionProvider(initialTxn).notifier)
          .updateAmount(_amountController.text);
    });
    _notesController.addListener(() {
      ref
          .read(createEditAutomaticTransactionProvider(initialTxn).notifier)
          .updateNotes(_notesController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _customRecurrenceController.dispose();
    super.dispose();
  }

  IconData _getIconData(String name) {
    return getIconData(name);
  }

  Color _parseHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String _getLocalizedError(BuildContext context, dynamic error) {
    if (error is ValidationException) {
      final l10n = AppLocalizations.of(context)!;
      switch (error.code) {
        case 'NAME_REQUIRED':
          return l10n.autoTxNameRequired;
        case 'INVALID_AMOUNT':
          return l10n.errorInvalidAmount;
        case 'ACCOUNT_REQUIRED':
          return l10n.errorAccountRequired;
        case 'CATEGORY_REQUIRED':
          return l10n.errorCategoryRequired;
        case 'CURRENCY_REQUIRED':
          return l10n.errorCurrencyRequired;
        default:
          return error.message;
      }
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final financialColors = context.financialColors;
    final l10n = AppLocalizations.of(context)!;
    final initialTxn = widget.transactionToEdit;

    final state = ref.watch(createEditAutomaticTransactionProvider(initialTxn));
    final isExpense = state.type == TransactionType.expense;
    final activeColor =
        isExpense ? financialColors.negative : financialColors.positive;

    ref.listen<AsyncValue<void>>(
      createEditAutomaticTransactionProvider(
        initialTxn,
      ).select((s) => s.submissionStatus),
      (prev, next) {
        next.when(
          data: (_) {
            if (prev is AsyncLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.autoTxSavedMessage),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop();
            }
          },
          error: (err, _) {},
          loading: () {},
        );
      },
    );

    final accountsAsync = ref.watch(accountsListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final tagsAsync = ref.watch(tagsListProvider);

    final accounts = accountsAsync.value ?? [];
    final selectedAccount = accounts.isEmpty
        ? null
        : accounts.firstWhere(
            (a) => a.id == state.accountId,
            orElse: () => accounts.first,
          );

    final categories = categoriesAsync.value ?? [];
    final selectedCategory = state.categoryId == null
        ? null
        : categories.firstWhere(
            (c) => c.id == state.categoryId,
            orElse: () => categories.first,
          );

    final tags = tagsAsync.value ?? [];
    final selectedTag = state.labelId == null
        ? null
        : tags.firstWhere(
            (t) => t.id == state.labelId,
            orElse: () => tags.first,
          );

    final isLoading = state.submissionStatus.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          initialTxn == null ? l10n.autoTxNewTitle : l10n.autoTxEditTitle,
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
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: isLoading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 54,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref
                                .read(
                                  createEditAutomaticTransactionProvider(
                                    initialTxn,
                                  ).notifier,
                                )
                                .updateType(TransactionType.expense);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: state.type == TransactionType.expense
                                  ? financialColors.negative
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                l10n.expense(1),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: state.type == TransactionType.expense
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref
                                .read(
                                  createEditAutomaticTransactionProvider(
                                    initialTxn,
                                  ).notifier,
                                )
                                .updateType(TransactionType.income);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: state.type == TransactionType.income
                                  ? financialColors.positive
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                l10n.income(1),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: state.type == TransactionType.income
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.labelAmount,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              CurrencyFormatter.getCurrencySymbol(
                                state.currency ?? 'EUR',
                              ),
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
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d{0,13}([.,]\d{0,2})?'),
                                  ),
                                ],
                                style: theme.textTheme.displayLarge?.copyWith(
                                  color: activeColor,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.0,
                                ),
                                textAlign: TextAlign.left,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!
                                      .hintAmountZero,
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                autofocus: initialTxn == null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (state.errors.containsKey('amount'))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _getLocalizedError(
                        context,
                        ValidationException(
                          message: '',
                          code: state.errors['amount']!,
                        ),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 32),
                TextField(
                  controller: _nameController,
                  maxLength: 31,
                  decoration: InputDecoration(
                    labelText: l10n.autoTxTemplateNameLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                if (state.errors.containsKey('name'))
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    child: Text(
                      l10n.autoTxNameRequired,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FormSelectorTile(
                        label: l10n.labelAccount,
                        value: selectedAccount?.name ?? l10n.labelSelectAccount,
                        icon: selectedAccount != null
                            ? _getIconData(selectedAccount.icon)
                            : Icons.account_balance_wallet_rounded,
                        iconColor: selectedAccount != null
                            ? _parseHexColor(selectedAccount.color)
                            : colorScheme.onSurfaceVariant,
                        onTap: () => _showAccountSelector(
                          context,
                          accountsAsync.value ?? [],
                          initialTxn,
                        ),
                      ),
                      if (state.errors.containsKey('accountId'))
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 64,
                            right: 16,
                            bottom: 8,
                          ),
                          child: Text(
                            _getLocalizedError(
                              context,
                              ValidationException(
                                message: '',
                                code: state.errors['accountId']!,
                              ),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      Divider(
                        height: 1,
                        color: colorScheme.outline.withValues(alpha: 0.08),
                      ),
                      _FormSelectorTile(
                        label: l10n.labelCategory,
                        value:
                            selectedCategory?.name ?? l10n.labelSelectCategory,
                        icon: selectedCategory != null
                            ? _getIconData(selectedCategory.icon)
                            : Icons.category_rounded,
                        iconColor: selectedCategory != null
                            ? _parseHexColor(selectedCategory.color)
                            : colorScheme.onSurfaceVariant,
                        onTap: () => _showCategorySelector(
                          context,
                          categoriesAsync.value ?? [],
                          state.type,
                          initialTxn,
                        ),
                      ),
                      if (state.errors.containsKey('categoryId'))
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 64,
                            right: 16,
                            bottom: 8,
                          ),
                          child: Text(
                            _getLocalizedError(
                              context,
                              ValidationException(
                                message: '',
                                code: state.errors['categoryId']!,
                              ),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      Divider(
                        height: 1,
                        color: colorScheme.outline.withValues(alpha: 0.08),
                      ),
                      _FormSelectorTile(
                        label: "${l10n.labelTag} ${l10n.optionalPlaceholder}",
                        value: selectedTag != null
                            ? selectedTag.name
                            : "${l10n.labelSelectTag} ${l10n.optionalPlaceholder}",
                        icon: Icons.local_offer_rounded,
                        iconColor: colorScheme.tertiary,
                        onTap: () =>
                            _showTagSelector(context, tags, initialTxn),
                      ),
                      Divider(
                        height: 1,
                        color: colorScheme.outline.withValues(alpha: 0.08),
                      ),
                      _FormSelectorTile(
                        label: l10n.labelCurrency,
                        value: state.currency ?? l10n.labelSelectCurrency,
                        icon: Icons.monetization_on_rounded,
                        iconColor: colorScheme.secondary,
                        onTap: () => _showCurrencySelector(context, initialTxn),
                      ),
                      Divider(
                        height: 1,
                        color: colorScheme.outline.withValues(alpha: 0.08),
                      ),
                      _FormSelectorTile(
                        label: l10n.autoTxLabelRecurrence,
                        value: _formatRecurrence(
                          context,
                          state.recurrenceType,
                          state.recurrenceDays,
                        ),
                        icon: Icons.repeat_rounded,
                        iconColor: colorScheme.tertiary,
                        onTap: () =>
                            _showRecurrenceSelector(context, initialTxn),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  maxLength: 63,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: "${l10n.labelNotes} ${l10n.optionalPlaceholder}",
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    alignLabelWithHint: true,
                    hintText:
                        "${l10n.labelNotesHint} ${l10n.optionalPlaceholder}",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.2,
                    ),
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
                const SizedBox(height: 24),
                (() {
                  final error = state.submissionStatus.error;
                  if (error == null) return const SizedBox.shrink();

                  final isValidationError = error is ValidationException;

                  if (isValidationError) return const SizedBox.shrink();

                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
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
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _getLocalizedError(context, error),
                                maxLines: null,
                                overflow: TextOverflow.visible,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                })(),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          ref
                              .read(
                                createEditAutomaticTransactionProvider(
                                  initialTxn,
                                ).notifier,
                              )
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            l10n.btnSaveTransaction,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatRecurrence(
    BuildContext context,
    RecurrenceType type,
    int days,
  ) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case RecurrenceType.specificDayOfMonth:
        return l10n.autoTxFormatSpecificDay(days.toString());
      case RecurrenceType.weekly:
        return l10n.autoTxFormatWeekly;
      case RecurrenceType.monthly:
        return l10n.autoTxFormatMonthly;
      case RecurrenceType.yearly:
        return l10n.autoTxFormatYearly;
      case RecurrenceType.intervalDays:
        return l10n.autoTxFormatEveryDays(days);
    }
  }

  void _showAccountSelector(
    BuildContext context,
    List<Account> accounts,
    AutomaticTransaction? initialTxn,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.read(createEditAutomaticTransactionProvider(initialTxn));
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
                l10n.labelSelectAccount,
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
                            : colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.2,
                              ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? accColor.withValues(alpha: 0.4)
                              : Colors.transparent,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
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
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: accColor,
                                )
                              : null,
                          onTap: () {
                            ref
                                .read(
                                  createEditAutomaticTransactionProvider(
                                    initialTxn,
                                  ).notifier,
                                )
                                .updateAccount(account.id);
                            Navigator.of(context).pop();
                          },
                        ),
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
    AutomaticTransaction? initialTxn,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.read(createEditAutomaticTransactionProvider(initialTxn));
    final l10n = AppLocalizations.of(context)!;

    final filteredCategories = categories.where((c) {
      if (c.associatedType == null) return true;

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
      isScrollControlled: true,
      useSafeArea: true,
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
                l10n.labelSelectCategory,
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
                      filteredCategories.length + 1, // +1 for "Create New"
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              AppLocalizations.of(context)!.createNewCategory,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                            onTap: () async {
                              Navigator.of(context).pop();
                              final newId = await CategoryDialog.show(
                                context,
                                ref,
                              );
                              if (newId != null) {
                                ref
                                    .read(
                                      createEditAutomaticTransactionProvider(
                                        initialTxn,
                                      ).notifier,
                                    )
                                    .updateCategory(newId);
                              }
                            },
                          ),
                        ),
                      );
                    }

                    final category = filteredCategories[index - 1];
                    final isSelected = state.categoryId == category.id;
                    final catColor = _parseHexColor(category.color);
                    final catIcon = _getIconData(category.icon);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? catColor.withValues(alpha: 0.08)
                            : colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.2,
                              ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? catColor.withValues(alpha: 0.4)
                              : Colors.transparent,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: catColor.withValues(alpha: 0.12),
                            child: Icon(catIcon, color: catColor, size: 20),
                          ),
                          title: Text(
                            category.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: catColor,
                                )
                              : null,
                          onTap: () {
                            ref
                                .read(
                                  createEditAutomaticTransactionProvider(
                                    initialTxn,
                                  ).notifier,
                                )
                                .updateCategory(category.id);
                            Navigator.of(context).pop();
                          },
                        ),
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

  void _showTagSelector(
    BuildContext context,
    List<Tag> tags,
    AutomaticTransaction? initialTxn,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.read(createEditAutomaticTransactionProvider(initialTxn));
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
                l10n.labelSelectTag,
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
                      tags.length + 2, // +1 for "Create New", +1 for "None"
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorScheme.tertiary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.tertiary.withValues(
                                alpha: 0.12,
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                color: colorScheme.tertiary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              AppLocalizations.of(context)!.createNewLabel,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.tertiary,
                              ),
                            ),
                            onTap: () async {
                              Navigator.of(context).pop();
                              final newId = await TagDialog.show(context, ref);
                              if (newId != null) {
                                ref
                                    .read(
                                      createEditAutomaticTransactionProvider(
                                        initialTxn,
                                      ).notifier,
                                    )
                                    .updateLabel(newId);
                              }
                            },
                          ),
                        ),
                      );
                    }

                    final isNone = index == 1;
                    final isSelected = isNone
                        ? state.labelId == null
                        : state.labelId == tags[index - 2].id;

                    final tag = isNone ? null : tags[index - 2];
                    final tagName = isNone ? l10n.noTag : tag!.name;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.tertiary.withValues(alpha: 0.08)
                            : colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.2,
                              ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.tertiary.withValues(alpha: 0.4)
                              : Colors.transparent,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.tertiary.withValues(
                              alpha: 0.12,
                            ),
                            child: Icon(
                              isNone
                                  ? Icons.block_rounded
                                  : Icons.local_offer_rounded,
                              color: colorScheme.tertiary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            tagName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: colorScheme.tertiary,
                                )
                              : null,
                          onTap: () {
                            ref
                                .read(
                                  createEditAutomaticTransactionProvider(
                                    initialTxn,
                                  ).notifier,
                                )
                                .updateLabel(tag?.id);
                            Navigator.of(context).pop();
                          },
                        ),
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

  void _showCurrencySelector(
    BuildContext context,
    AutomaticTransaction? initialTxn,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.read(createEditAutomaticTransactionProvider(initialTxn));
    final l10n = AppLocalizations.of(context)!;
    final currencies = {
      'EUR': l10n.currencyEUR,
      'USD': l10n.currencyUSD,
      'GBP': l10n.currencyGBP,
      'JPY': l10n.currencyJPY,
      'CHF': l10n.currencyCHF,
      'CAD': l10n.currencyCAD,
      'AUD': l10n.currencyAUD,
      'CNY': l10n.currencyCNY,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
                l10n.labelSelectCurrency,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currencies.length,
                  itemBuilder: (context, index) {
                    final code = currencies.keys.elementAt(index);
                    final name = currencies[code]!;
                    final isSelected = state.currency == code;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary.withValues(alpha: 0.08)
                            : colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.2,
                              ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: 0.4)
                              : Colors.transparent,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            child: Text(
                              CurrencyFormatter.getCurrencySymbol(code),
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(name),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            ref
                                .read(
                                  createEditAutomaticTransactionProvider(
                                    initialTxn,
                                  ).notifier,
                                )
                                .updateCurrency(code);
                            Navigator.of(context).pop();
                          },
                        ),
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

  void _showRecurrenceSelector(
    BuildContext context,
    AutomaticTransaction? initialTxn,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Provide a stateful builder so the bottom sheet can update when segmented control or radio changes.
    // However, riverpod state will automatically rebuild the caller, but the bottom sheet needs its own state
    // for the custom type selection before applying.

    final initialState = ref.read(
      createEditAutomaticTransactionProvider(initialTxn),
    );

    RecurrenceType localCustomType = initialState.recurrenceType;
    bool isCustomActive = false;
    String? localError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(
              createEditAutomaticTransactionProvider(initialTxn),
            );
            final l10n = AppLocalizations.of(context)!;
            return StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 24,
                        left: 20,
                        right: 20,
                        bottom: 24,
                      ),
                      child: Form(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.autoTxSelectRecurrence,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.recurrenceUtcWarning,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            _RecurrenceOptionTile(
                              title: l10n.autoTxRecurrenceWeekly,
                              isSelected: !isCustomActive &&
                                  state.recurrenceType == RecurrenceType.weekly,
                              onTap: () {
                                ref
                                    .read(
                                      createEditAutomaticTransactionProvider(
                                        initialTxn,
                                      ).notifier,
                                    )
                                    .updateRecurrence(RecurrenceType.weekly, 7);
                                Navigator.of(context).pop();
                              },
                            ),
                            _RecurrenceOptionTile(
                              title: l10n.autoTxRecurrenceMonthly,
                              isSelected: !isCustomActive &&
                                  state.recurrenceType ==
                                      RecurrenceType.monthly,
                              onTap: () {
                                ref
                                    .read(
                                      createEditAutomaticTransactionProvider(
                                        initialTxn,
                                      ).notifier,
                                    )
                                    .updateRecurrence(
                                      RecurrenceType.monthly,
                                      30,
                                    );
                                Navigator.of(context).pop();
                              },
                            ),
                            _RecurrenceOptionTile(
                              title: l10n.autoTxRecurrenceYearly,
                              isSelected: !isCustomActive &&
                                  state.recurrenceType == RecurrenceType.yearly,
                              onTap: () {
                                ref
                                    .read(
                                      createEditAutomaticTransactionProvider(
                                        initialTxn,
                                      ).notifier,
                                    )
                                    .updateRecurrence(
                                      RecurrenceType.yearly,
                                      365,
                                    );
                                Navigator.of(context).pop();
                              },
                            ),
                            const Divider(height: 32),
                            Text(
                              l10n.autoTxRecurrenceCustomInterval,
                              style: theme.textTheme.labelMedium,
                            ),
                            const SizedBox(height: 8),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<RecurrenceType>(
                                        title: Text(
                                          l10n.autoTxRecurrenceEveryXDays,
                                        ),
                                        value: RecurrenceType.intervalDays,
                                        // ignore: deprecated_member_use
                                        groupValue: localCustomType,
                                        contentPadding: EdgeInsets.zero,
                                        // ignore: deprecated_member_use
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              localCustomType = val;
                                              isCustomActive = true;
                                              localError = null;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<RecurrenceType>(
                                        title: Text(
                                          l10n.autoTxRecurrenceDayOfMonth,
                                        ),
                                        value:
                                            RecurrenceType.specificDayOfMonth,
                                        // ignore: deprecated_member_use
                                        groupValue: localCustomType,
                                        contentPadding: EdgeInsets.zero,
                                        // ignore: deprecated_member_use
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              localCustomType = val;
                                              isCustomActive = true;
                                              localError = null;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _customRecurrenceController,
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => setState(() {
                                          isCustomActive = true;
                                          localError = null;
                                        }),
                                        decoration: InputDecoration(
                                          hintText:
                                              l10n.autoTxRecurrenceCustomHint,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          errorText: localError ??
                                              (state.errors.containsKey(
                                                'recurrenceDays',
                                              )
                                                  ? (localCustomType ==
                                                          RecurrenceType
                                                              .specificDayOfMonth
                                                      ? l10n
                                                          .autoTxErrorInvalidDayOfMonth
                                                      : l10n
                                                          .autoTxErrorInvalidRecurrenceInterval)
                                                  : null),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: FilledButton(
                                        onPressed: () {
                                          final parsed = int.tryParse(
                                            _customRecurrenceController.text,
                                          );
                                          final maxVal = localCustomType ==
                                                  RecurrenceType
                                                      .specificDayOfMonth
                                              ? 31
                                              : 365;
                                          if (parsed != null &&
                                              parsed > 0 &&
                                              parsed <= maxVal) {
                                            ref
                                                .read(
                                                  createEditAutomaticTransactionProvider(
                                                    initialTxn,
                                                  ).notifier,
                                                )
                                                .updateRecurrence(
                                                  localCustomType,
                                                  parsed,
                                                );
                                            Navigator.of(context).pop();
                                          } else {
                                            setState(() {
                                              localError = localCustomType ==
                                                      RecurrenceType
                                                          .specificDayOfMonth
                                                  ? l10n
                                                      .autoTxErrorInvalidDayOfMonth
                                                  : l10n
                                                      .autoTxErrorInvalidRecurrenceInterval;
                                            });
                                          }
                                        },
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            l10n.autoTxRecurrenceApply,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // We removed the StatefulBuilder around the custom section since it is now wrapping the entire sheet.
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
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
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecurrenceOptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecurrenceOptionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          title: Text(title),
          trailing: isSelected
              ? Icon(Icons.check_circle_rounded, color: colorScheme.primary)
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
