import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:stalvi/presentation/providers/transaction_filter_provider.dart';

/// Advanced filter bottom sheet for the Transactions section.
///
/// Provides UI controls for every filter dimension in [TransactionFilter]:
/// - Account selector
/// - Type (income / expense / transfer) chips
/// - Category dropdown
/// - Date range picker
/// - Min / Max amount text fields
/// - Tag selector
/// - Currency dropdown
///
/// Changes are applied **live** to [transactionFilterProvider] so the
/// transaction list updates reactively while the sheet is open.
class TransactionFilterSheet extends ConsumerStatefulWidget {
  const TransactionFilterSheet({super.key});

  /// Opens the sheet as a scrollable modal bottom sheet.
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const TransactionFilterSheet(),
    );
  }

  @override
  ConsumerState<TransactionFilterSheet> createState() =>
      _TransactionFilterSheetState();
}

class _TransactionFilterSheetState
    extends ConsumerState<TransactionFilterSheet> {
  // Local draft of the filter so changes are staged before Apply is pressed.
  late TransactionFilter _draft;

  late final TextEditingController _minAmountController;
  late final TextEditingController _maxAmountController;

  // Supported currencies shown in the dropdown.
  static const _currencies = [
    'EUR',
    'USD',
    'GBP',
    'JPY',
    'CHF',
    'CAD',
    'AUD',
    'CNY',
  ];

  @override
  void initState() {
    super.initState();
    // Snapshot the current filter as the initial draft.
    _draft = ref.read(transactionFilterProvider);
    _minAmountController = TextEditingController(
      text: _draft.minAmountCents != null
          ? (_draft.minAmountCents! / 100.0).toStringAsFixed(2)
          : '',
    );
    _maxAmountController = TextEditingController(
      text: _draft.maxAmountCents != null
          ? (_draft.maxAmountCents! / 100.0).toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  int get _activeFilterCount {
    int count = 0;
    if (_draft.accountId != null) count++;
    if (_draft.type != null) count++;
    if (_draft.categoryId != null) count++;
    if (_draft.dateRange != null) count++;
    if (_draft.minAmountCents != null) count++;
    if (_draft.maxAmountCents != null) count++;
    if (_draft.tagId != null) count++;
    if (_draft.currency != null) count++;
    return count;
  }

  void _applyFilters() {
    // Parse amount text fields before applying.
    final minText = _minAmountController.text.trim();
    final maxText = _maxAmountController.text.trim();
    final minCents = minText.isNotEmpty
        ? ((double.tryParse(minText) ?? 0) * 100).toInt()
        : null;
    final maxCents = maxText.isNotEmpty
        ? ((double.tryParse(maxText) ?? 0) * 100).toInt()
        : null;

    _draft = _draft.copyWith(
      minAmountCentsFn: () => minCents,
      maxAmountCentsFn: () => maxCents,
    );

    ref.read(transactionFilterProvider.notifier).setFilter(_draft);
    Navigator.of(context).pop();
  }

  void _clearAll() {
    setState(() {
      _draft = const TransactionFilter();
      _minAmountController.clear();
      _maxAmountController.clear();
    });
    ref.read(transactionFilterProvider.notifier).clearAll();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: _draft.dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _draft = _draft.copyWith(dateRangeFn: () => picked);
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);

    final accountsAsync = ref.watch(accountsListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final tagsAsync = ref.watch(tagsListProvider);

    final activeCount = _activeFilterCount;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
            // ── Drag handle ────────────────────────────────────────────────
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
            const SizedBox(height: 20),

            // ── Header ─────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.filterSheetTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (activeCount > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.filterSheetActiveFilters(activeCount),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: activeCount > 0 ? _clearAll : null,
                  icon: const Icon(Icons.cleaning_services, size: 18),
                  label: Text(l10n.filterSheetClearAll),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Account ────────────────────────────────────────────────────
            _SectionLabel(
              label: l10n.labelAccount,
              icon: Icons.account_balance_outlined,
              colorScheme: colorScheme,
              theme: theme,
            ),
            const SizedBox(height: 8),
            accountsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (accounts) {
                return DropdownButtonFormField<String?>(
                  key: const ValueKey('filterAccountDropdown'),
                  initialValue: _draft.accountId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        l10n.filterSheetAllTypes,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    ...accounts.map(
                      (acc) => DropdownMenuItem<String?>(
                        value: acc.id,
                        child: Text(acc.name),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _draft = _draft.copyWith(accountIdFn: () => val);
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Type ──────────────────────────────────────────────────────
            _SectionLabel(
              label: l10n.filterSheetType,
              icon: Icons.swap_vert_rounded,
              colorScheme: colorScheme,
              theme: theme,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _TypeChip(
                  key: const ValueKey('filterTypeAll'),
                  label: l10n.filterAll,
                  selected: _draft.type == null,
                  onTap: () => setState(() {
                    _draft = _draft.copyWith(typeFn: () => null);
                  }),
                  colorScheme: colorScheme,
                  theme: theme,
                ),
                _TypeChip(
                  key: const ValueKey('filterTypeIncome'),
                  label: l10n.filterIncome,
                  selected: _draft.type == TransactionType.income,
                  onTap: () => setState(() {
                    _draft =
                        _draft.copyWith(typeFn: () => TransactionType.income);
                  }),
                  colorScheme: colorScheme,
                  theme: theme,
                  accentColor: Colors.green,
                ),
                _TypeChip(
                  key: const ValueKey('filterTypeExpense'),
                  label: l10n.filterExpense,
                  selected: _draft.type == TransactionType.expense,
                  onTap: () => setState(() {
                    _draft =
                        _draft.copyWith(typeFn: () => TransactionType.expense);
                  }),
                  colorScheme: colorScheme,
                  theme: theme,
                  accentColor: Colors.red,
                ),
                _TypeChip(
                  key: const ValueKey('filterTypeTransfer'),
                  label: l10n.filterSheetTransferType,
                  selected: _draft.type == TransactionType.transfer,
                  onTap: () => setState(() {
                    _draft =
                        _draft.copyWith(typeFn: () => TransactionType.transfer);
                  }),
                  colorScheme: colorScheme,
                  theme: theme,
                  accentColor: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Category ──────────────────────────────────────────────────
            _SectionLabel(
              label: l10n.filterSheetCategory,
              icon: Icons.category_outlined,
              colorScheme: colorScheme,
              theme: theme,
            ),
            const SizedBox(height: 8),
            categoriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (categories) {
                return DropdownButtonFormField<String?>(
                  key: const ValueKey('filterCategoryDropdown'),
                  initialValue: _draft.categoryId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        l10n.filterSheetAllCategories,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    ...categories.where((c) => !c.isDeleted).map(
                          (cat) => DropdownMenuItem<String?>(
                            value: cat.id,
                            child: Text(cat.name),
                          ),
                        ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _draft = _draft.copyWith(categoryIdFn: () => val);
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Date Range ────────────────────────────────────────────────
            _SectionLabel(
              label: l10n.filterSheetDateRange,
              icon: Icons.date_range_outlined,
              colorScheme: colorScheme,
              theme: theme,
            ),
            const SizedBox(height: 8),
            InkWell(
              key: const ValueKey('filterDateRangePicker'),
              onTap: _pickDateRange,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _draft.dateRange != null
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.5),
                    width: _draft.dateRange != null ? 1.5 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  color: _draft.dateRange != null
                      ? colorScheme.primary.withValues(alpha: 0.06)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 18,
                      color: _draft.dateRange != null
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _draft.dateRange != null
                            ? '${_formatDate(_draft.dateRange!.start)} → ${_formatDate(_draft.dateRange!.end)}'
                            : l10n.filterSheetSelectDateRange,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _draft.dateRange != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (_draft.dateRange != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _draft = _draft.copyWith(dateRangeFn: () => null);
                          });
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Amount Range ──────────────────────────────────────────────
            _SectionLabel(
              label: l10n.filterSheetAmountRange,
              icon: Icons.attach_money_rounded,
              colorScheme: colorScheme,
              theme: theme,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const ValueKey('filterMinAmount'),
                    controller: _minAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.filterSheetMinAmount,
                      prefixIcon:
                          const Icon(Icons.arrow_downward_rounded, size: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    key: const ValueKey('filterMaxAmount'),
                    controller: _maxAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.filterSheetMaxAmount,
                      prefixIcon:
                          const Icon(Icons.arrow_upward_rounded, size: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Tag ───────────────────────────────────────────────────────
            _SectionLabel(
              label: l10n.filterSheetTag,
              icon: Icons.label_outline_rounded,
              colorScheme: colorScheme,
              theme: theme,
            ),
            const SizedBox(height: 8),
            tagsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (tags) {
                final activeTags = tags.where((t) => !t.isDeleted).toList();
                return DropdownButtonFormField<String?>(
                  key: const ValueKey('filterTagDropdown'),
                  initialValue: _draft.tagId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        l10n.filterSheetAllTags,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    ...activeTags.map(
                      (tag) => DropdownMenuItem<String?>(
                        value: tag.id,
                        child: Row(
                          children: [
                            Icon(
                              Icons.label_rounded,
                              size: 14,
                              color: colorScheme.primary.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(tag.name),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _draft = _draft.copyWith(tagIdFn: () => val);
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Currency ──────────────────────────────────────────────────
            _SectionLabel(
              label: l10n.filterSheetCurrency,
              icon: Icons.currency_exchange_rounded,
              colorScheme: colorScheme,
              theme: theme,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              key: const ValueKey('filterCurrencyDropdown'),
              initialValue: _draft.currency,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                isDense: true,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    l10n.filterSheetAllCurrencies,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                ..._currencies.map(
                  (code) => DropdownMenuItem<String?>(
                    value: code,
                    child: Text(code),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  _draft = _draft.copyWith(currencyFn: () => val);
                });
              },
            ),
            const SizedBox(height: 32),

            // ── Actions ────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.btnCancel,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    key: const ValueKey('filterApplyButton'),
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(l10n.filterSheetApply),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}

// ─── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _SectionLabel({
    required this.label,
    required this.icon,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ─── Type Chip ────────────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final Color? accentColor;

  const _TypeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
    required this.theme,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final effective = selected ? (accentColor ?? colorScheme.primary) : null;
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor:
          (accentColor ?? colorScheme.primary).withValues(alpha: 0.15),
      side: BorderSide(
        color: selected
            ? (accentColor ?? colorScheme.primary)
            : colorScheme.outline.withValues(alpha: 0.25),
        width: selected ? 1.5 : 1.0,
      ),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: selected
            ? (effective ?? colorScheme.primary)
            : colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      onSelected: (_) => onTap(),
    );
  }
}
