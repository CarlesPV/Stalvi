import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/theme/app_theme.dart';
import 'package:stalvi/core/utils/currency_formatter.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/category.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transaction_filter_sheet.dart';
import '../budgets_and_goals/budgets_and_goals_screen.dart';
import '../statistics/statistics_screen.dart';
import '../../providers/repository_providers.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/locale_provider.dart';
import '../settings/profile_settings_screen.dart';
import '../settings/categories_tags_management_screen.dart';
import '../settings/data_management_screen.dart';
import '../recycle_bin/recycle_bin_screen.dart';
import '../settings/automatic_transactions_screen.dart' as stalvi_auto;
import '../../widgets/empty_state_widget.dart';
import '../../providers/discreet_mode_provider.dart';
import '../../widgets/obfuscated_text.dart';
import '../../providers/statistics_providers.dart';
import '../../widgets/create_account_dialog.dart';
import '../../widgets/edit_account_dialog.dart';
import '../transactions/transaction_details_dialog.dart';
import 'package:stalvi/core/utils/icon_helper.dart';
import '../../providers/transaction_filter_provider.dart';
import '../../providers/automatic_transactions_providers.dart';

/// The main application scaffold — shown after successful authentication.
///
/// Contains the tabs:
/// 1. Overview    — balance card + income/expense stats + recent transactions (using real data).
/// 2. Transactions — full transaction list with filters and details.
/// 3. Accounts    — account cards, balance tracking, and default indicator.
/// 4. Settings    — settings list (Budgets/Goals, Statistics, Profile & Security, and Recycle Bin).
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 0;

  // Shared shimmer animation for all skeleton elements.
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _shimmer = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(discreetModeProvider.notifier).setDiscreet(true);
      _checkBiometricOptIn();
      _executeFallbackTransactions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(discreetModeProvider.notifier).setDiscreet(true);
    }
  }

  Future<void> _checkBiometricOptIn() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    final secureStorage = ref.read(secureStorageProvider);

    final isAvailable = await notifier.isBiometricAvailable();
    if (!isAvailable) return;

    final hasChoice = await secureStorage.hasBiometricsChoice();
    if (hasChoice) return;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Icon(
                Icons.fingerprint_rounded,
                color: colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.authBiometricOptInTitle)),
            ],
          ),
          content: Text(l10n.authBiometricOptInSubtitle),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await notifier.skipBiometricOptIn();
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.authBiometricOptInSkip,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await notifier.enableBiometricsOptIn();
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(l10n.authBiometricOptInEnable),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _executeFallbackTransactions() async {
    try {
      final useCase = ref.read(executeRecurringTransactionsUseCaseProvider);
      await useCase.execute();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final financialColors = context.financialColors;

    final l10n = AppLocalizations.of(context)!;
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard_rounded),
        label: l10n.overview,
      ),
      NavigationDestination(
        icon: const Icon(Icons.receipt_long_outlined),
        selectedIcon: const Icon(Icons.receipt_long_rounded),
        label: l10n.transactions,
      ),
      NavigationDestination(
        icon: const Icon(Icons.account_balance_outlined),
        selectedIcon: const Icon(Icons.account_balance_rounded),
        label: l10n.accounts,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings_rounded),
        label: l10n.settings,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Mini logo for context
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 34,
                height: 34,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Image.asset(
                      'assets/icon/app_icon.png',
                      fit: BoxFit.contain,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.appTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: const [],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _OverviewTab(shimmer: _shimmer, financialColors: financialColors),
          _TransactionsTab(shimmer: _shimmer),
          _AccountsTab(shimmer: _shimmer),
          _SettingsSkeletonTab(shimmer: _shimmer),
        ],
      ),
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.0,
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          destinations: destinations,
        ),
      ),
      floatingActionButton: _selectedIndex == 3
          ? null
          : FloatingActionButton(
              onPressed: () {
                if (_selectedIndex == 2) {
                  CreateAccountDialog.show(context);
                } else {
                  _navigateToAddTransaction(context);
                }
              },
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_rounded, size: 28),
            ),
    );
  }

  void _navigateToAddTransaction(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddTransactionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.1);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends ConsumerWidget {
  final Animation<double> shimmer;
  final FinancialColors financialColors;

  const _OverviewTab({required this.shimmer, required this.financialColors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final transactions = transactionsAsync.value ?? [];
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final last30DaysTxns = transactions.where(
      (tx) =>
          tx.date.isAfter(thirtyDaysAgo) ||
          tx.date.isAtSameMomentAs(thirtyDaysAgo),
    );
    final incomeCount =
        last30DaysTxns.where((tx) => tx.type == TransactionType.income).length;
    final expenseCount =
        last30DaysTxns.where((tx) => tx.type == TransactionType.expense).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Balance card ──────────────────────────────────────────────
          _BalanceCard(
            shimmer: shimmer,
            colorScheme: colorScheme,
            theme: theme,
          ),

          const SizedBox(height: 16),

          // ── Income / Expense stat cards ───────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: AppLocalizations.of(context)!.income(incomeCount),
                  icon: Icons.trending_up_rounded,
                  accentColor: financialColors.positive,
                  shimmer: shimmer,
                  colorScheme: colorScheme,
                  theme: theme,
                  isIncome: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: AppLocalizations.of(context)!.expense(expenseCount),
                  icon: Icons.trending_down_rounded,
                  accentColor: financialColors.negative,
                  shimmer: shimmer,
                  colorScheme: colorScheme,
                  theme: theme,
                  isIncome: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Section header ────────────────────────────────────────────
          Text(
            AppLocalizations.of(context)!.recentTransactions,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 14),

          // ── Transactions / Skeletons / Empty State ────────────────────
          transactionsAsync.when(
            loading: () => Column(
              children: List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TransactionSkeleton(shimmer: shimmer),
                ),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.failedLoadTransactions,
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ),
            data: (transactions) {
              if (transactions.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: EmptyStateWidget(
                    icon: Icons.receipt_long_outlined,
                    title: AppLocalizations.of(context)!.noTransactionsTitle,
                    subtitle: AppLocalizations.of(
                      context,
                    )!
                        .noTransactionsSubtitle,
                    actionLabel: AppLocalizations.of(context)!.addTransaction,
                    onActionPressed: () {
                      final state = context
                          .findAncestorStateOfType<_DashboardScreenState>();
                      if (state != null) {
                        state._navigateToAddTransaction(context);
                      }
                    },
                  ),
                );
              }

              final recent = transactions.take(5).toList();
              return Column(
                children: recent.map((txn) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TransactionItem(
                      key: ValueKey('recent_transaction_${txn.id}'),
                      transaction: txn,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Transactions Tab ─────────────────────────────────────────────────────────

class _TransactionsTab extends ConsumerStatefulWidget {
  final Animation<double> shimmer;

  const _TransactionsTab({required this.shimmer});

  @override
  ConsumerState<_TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends ConsumerState<_TransactionsTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredAsync = ref.watch(filteredTransactionsProvider);
    final activeFilter = ref.watch(transactionFilterProvider);
    final l10n = AppLocalizations.of(context)!;

    return filteredAsync.when(
      loading: () => _GenericSkeletonTab(shimmer: widget.shimmer, itemCount: 8),
      error: (err, _) => Center(
        child: Text(
          l10n.failedLoadTransactions,
          style: TextStyle(color: colorScheme.error),
        ),
      ),
      data: (transactions) {
        return Column(
          children: [
            // ── Filter bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  // Quick type filter chips
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildTypeChip(
                            l10n.filterAll,
                            null,
                            colorScheme,
                            activeFilter,
                          ),
                          const SizedBox(width: 8),
                          _buildTypeChip(
                            l10n.filterIncome,
                            TransactionType.income,
                            colorScheme,
                            activeFilter,
                          ),
                          const SizedBox(width: 8),
                          _buildTypeChip(
                            l10n.filterExpense,
                            TransactionType.expense,
                            colorScheme,
                            activeFilter,
                          ),
                          const SizedBox(width: 8),
                          _buildTypeChip(
                            l10n.filterTransfer,
                            TransactionType.transfer,
                            colorScheme,
                            activeFilter,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Advanced filter button
                  const SizedBox(width: 8),
                  Badge(
                    isLabelVisible: activeFilter.isNotEmpty,
                    backgroundColor: colorScheme.primary,
                    child: IconButton.filledTonal(
                      key: const ValueKey('advancedFilterButton'),
                      icon: const Icon(Icons.tune_rounded),
                      tooltip: l10n.filterSheetTitle,
                      onPressed: () {
                        TransactionFilterSheet.show(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // ── Transaction list ────────────────────────────────────────
            Expanded(
              child: transactions.isEmpty
                  ? (activeFilter.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.receipt_long_outlined,
                          title: l10n.noTransactionsTitle,
                          subtitle: l10n.noTransactionsSubtitle,
                          actionLabel: l10n.addTransaction,
                          onActionPressed: () {
                            final state = context.findAncestorStateOfType<
                                _DashboardScreenState>();
                            if (state != null) {
                              state._navigateToAddTransaction(context);
                            }
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.noDataAvailable,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () => ref
                                    .read(transactionFilterProvider.notifier)
                                    .clearAll(),
                                icon: const Icon(
                                  Icons.cleaning_services,
                                  size: 16,
                                ),
                                label: Text(l10n.filterSheetClearAll),
                              ),
                            ],
                          ),
                        ))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                      itemCount: transactions.length,
                      itemBuilder: (context, i) {
                        final txn = transactions[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TransactionItem(
                            key: ValueKey('all_transaction_${txn.id}'),
                            transaction: txn,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTypeChip(
    String label,
    TransactionType? type,
    ColorScheme colorScheme,
    TransactionFilter activeFilter,
  ) {
    final isSelected = activeFilter.type == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.primary,
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
      side: BorderSide(
        color: isSelected
            ? Colors.transparent
            : colorScheme.outline.withValues(alpha: 0.2),
      ),
      onSelected: (_) {
        ref.read(transactionFilterProvider.notifier).setType(type);
      },
    );
  }
}

// ─── Accounts Tab ─────────────────────────────────────────────────────────────

class _AccountsTab extends ConsumerWidget {
  final Animation<double> shimmer;

  const _AccountsTab({required this.shimmer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accountsAsync = ref.watch(accountsListProvider);

    return accountsAsync.when(
      loading: () => _GenericSkeletonTab(shimmer: shimmer, itemCount: 4),
      error: (err, _) => Center(
        child: Text(
          AppLocalizations.of(context)!.failedLoadAccounts,
          style: TextStyle(color: colorScheme.error),
        ),
      ),
      data: (accounts) {
        if (accounts.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.account_balance_outlined,
            title: AppLocalizations.of(context)!.noAccountsTitle,
            subtitle: AppLocalizations.of(context)!.noAccountsSubtitle,
            actionLabel: AppLocalizations.of(context)!.getStarted,
            onActionPressed: () {
              CreateAccountDialog.show(context);
            },
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            // ─── Statistics Header ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        color: colorScheme.secondary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.settingsStatistics,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const StatisticsScreen(),
                      ),
                    );
                  },
                  label: Text(
                    AppLocalizations.of(context)!.btnViewDetails,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 20),

            // ─── Accounts Header ───
            Row(
              children: [
                Icon(
                  Icons.account_balance_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.accounts,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Accounts List ───
            ...accounts.map((account) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AccountItem(account: account),
              );
            }),
          ],
        );
      },
    );
  }
}

class _AccountItem extends ConsumerWidget {
  final Account account;

  const _AccountItem({required this.account});

  Color _parseHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  IconData _getIconData(String name) {
    return getIconData(name);
  }

  String _getLocalizedAccountType(BuildContext context, AccountType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case AccountType.cash:
        return l10n.accountTypeCash;
      case AccountType.bank:
        return l10n.accountTypeBank;
      case AccountType.savings:
        return l10n.accountTypeSavings;
      case AccountType.card:
        return l10n.accountTypeCard;
      case AccountType.other:
        return l10n.accountTypeOther;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accColor = _parseHexColor(account.color);
    final accIcon = _getIconData(account.icon);

    final formatter = ref.watch(currencyFormatterProvider);
    final balanceAsync = ref.watch(accountBalanceProvider(account.id));
    final balanceStr = balanceAsync.when(
      data: (balance) =>
          formatter.format(balance, currencyCode: account.currency),
      loading: () => '...',
      error: (_, __) => 'Error',
    );

    return GestureDetector(
      onTap: () => EditAccountDialog.show(context, account),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: account.isDefault
              ? Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.4),
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(accIcon, color: accColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      account.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getLocalizedAccountType(
                      context,
                      account.type,
                    ).toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      balanceStr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (account.isDefault) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          AppLocalizations.of(context)!.defaultAccountLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends ConsumerWidget {
  final Transaction transaction;

  const _TransactionItem({super.key, required this.transaction});

  Color _parseHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final financialColors = context.financialColors;

    final isTransfer = transaction.type == TransactionType.transfer;
    final isOrigin = isTransfer && !transaction.id.endsWith('_dst');
    final isIncome =
        transaction.type == TransactionType.income || (isTransfer && !isOrigin);
    final amountDouble = isTransfer
        ? transaction.amount.abs() / 100.0
        : (isIncome ? transaction.amount : -transaction.amount) / 100.0;

    final formatter = ref.watch(currencyFormatterProvider);
    final amountStr = formatter.format(
      amountDouble,
      currencyCode: transaction.originalCurrency,
      showSign: !isTransfer,
    );
    final color = isTransfer
        ? colorScheme.onSurface
        : (isIncome ? financialColors.positive : financialColors.negative);

    final categories = ref.watch(categoriesListProvider).value ?? [];
    Category? category;
    if (transaction.categoryId != null) {
      for (final c in categories) {
        if (c.id == transaction.categoryId) {
          category = c;
          break;
        }
      }
    }

    final Color iconColor;
    final IconData icon;

    if (isTransfer) {
      icon = Icons.swap_horiz_rounded;
      iconColor = Colors.blue;
    } else if (category != null) {
      icon = getIconData(category.icon);
      iconColor = _parseHexColor(category.color);
    } else {
      icon = isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded;
      iconColor =
          isIncome ? financialColors.positive : financialColors.negative;
    }

    final dateStr = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(transaction.date);

    return InkWell(
      onTap: () {
        TransactionDetailsDialog.show(context, transaction);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      transaction.notes?.isNotEmpty == true
                          ? transaction.notes!
                          : (transaction.type == TransactionType.transfer
                              ? AppLocalizations.of(
                                  context,
                                )!
                                  .filterSheetTransferType
                              : (isIncome
                                  ? AppLocalizations.of(
                                      context,
                                    )!
                                      .fallbackIncome
                                  : AppLocalizations.of(
                                      context,
                                    )!
                                      .fallbackExpense)),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  amountStr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Generic skeleton tab ─────────────────────────────────────────────────────

class _GenericSkeletonTab extends StatelessWidget {
  final Animation<double> shimmer;
  final int itemCount;

  const _GenericSkeletonTab({required this.shimmer, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _TransactionSkeleton(shimmer: shimmer),
    );
  }
}

// ─── Settings skeleton tab ────────────────────────────────────────────────────

class _SettingsSkeletonTab extends ConsumerWidget {
  final Animation<double> shimmer;

  const _SettingsSkeletonTab({required this.shimmer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Container(
            height: 60,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BudgetsAndGoalsScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.pie_chart_rounded,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.settingsBudgetsGoals,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (i == 1) {
          return Container(
            height: 60,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const CategoriesTagsManagementScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.category_rounded,
                      color: colorScheme.tertiary,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.categoriesAndTags,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (i == 2) {
          return Container(
            height: 60,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const stalvi_auto.AutomaticTransactionsScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.autorenew_rounded,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!
                            .settingsAutomaticTransactions,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (i == 3) {
          return Container(
            height: 60,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileSettingsScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.manage_accounts_rounded,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.profileSettingsTitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (i == 4) {
          return Container(
            height: 60,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DataManagementScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.storage_rounded,
                      color: colorScheme.secondary,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.settingsDataManagement,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (i == 5) {
          return Container(
            height: 60,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RecycleBinScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: colorScheme.error,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.recycleBinTitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _SkeletonBlock(
                shimmer: shimmer,
                width: 28,
                height: 28,
                borderRadius: 8,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SkeletonBlock(
                  shimmer: shimmer,
                  width: double.infinity,
                  height: 14,
                  borderRadius: 4,
                ),
              ),
              const SizedBox(width: 32),
              _SkeletonBlock(
                shimmer: shimmer,
                width: 20,
                height: 14,
                borderRadius: 4,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Card widgets ─────────────────────────────────────────────────────────────

/// Hero balance card with gradient fill and shimmer placeholders.
class _BalanceCard extends ConsumerWidget {
  final Animation<double> shimmer;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _BalanceCard({
    required this.shimmer,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDiscreet = ref.watch(discreetModeProvider);
    final accountsAsync = ref.watch(accountsListProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.32),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.balanceTotal,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  key: const ValueKey('discreetModeIconButton'),
                  iconSize: 32.0,
                  padding: const EdgeInsets.all(8.0),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isDiscreet ? Icons.visibility_off : Icons.visibility,
                    color: colorScheme.onPrimary.withValues(alpha: 0.85),
                    size: 32.0,
                  ),
                  onPressed: () {
                    ref.read(discreetModeProvider.notifier).toggle();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          accountsAsync.when(
            loading: () => AnimatedBuilder(
              animation: shimmer,
              builder: (_, __) => Container(
                width: 170,
                height: 34,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(
                    alpha: 0.18 + 0.12 * shimmer.value,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            error: (_, __) => Text(
              '--',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            data: (accounts) {
              final globalBalanceAsync = ref.watch(globalBalanceProvider);
              return globalBalanceAsync.when(
                loading: () => AnimatedBuilder(
                  animation: shimmer,
                  builder: (_, __) => Container(
                    width: 170,
                    height: 34,
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withValues(
                        alpha: 0.18 + 0.12 * shimmer.value,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                error: (_, __) => Text(
                  '--',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                data: (totalBalance) {
                  final profile = ref.watch(defaultProfileProvider).value;
                  final currency = profile?.defaultCurrency ?? 'EUR';
                  final formatter = ref.watch(currencyFormatterProvider);
                  final balanceStr = formatter.format(
                    totalBalance,
                    currencyCode: currency,
                  );
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: ObfuscatedText(
                      balanceStr,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 10),
          accountsAsync.when(
            loading: () => AnimatedBuilder(
              animation: shimmer,
              builder: (_, __) => Container(
                width: 110,
                height: 15,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(
                    alpha: 0.12 + 0.08 * shimmer.value,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            error: (_, __) => const SizedBox(height: 15),
            data: (accounts) {
              return Text(
                AppLocalizations.of(
                  context,
                )!
                    .acrossAccountsCount(accounts.length),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              AppLocalizations.of(context)!.presetLast30Days,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Income / Expense stat card with accent colour from [FinancialColors].
class _StatCard extends ConsumerWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final Animation<double> shimmer;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final bool isIncome;

  const _StatCard({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.shimmer,
    required this.colorScheme,
    required this.theme,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardPeriodSummaryProvider);
    final profile = ref.watch(defaultProfileProvider).value;
    final currency = profile?.defaultCurrency ?? 'EUR';
    final formatter = ref.watch(currencyFormatterProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const Spacer(),
              // Trend placeholder
              const SizedBox(width: 36, height: 14),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          summaryAsync.when(
            loading: () => _SkeletonBlock(
              shimmer: shimmer,
              width: double.infinity,
              height: 20,
              borderRadius: 5,
            ),
            error: (_, __) => Text(
              '--',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
            data: (summary) {
              final amount =
                  (isIncome ? summary.totalIncome : summary.totalExpense) /
                      100.0;
              final amountStr = formatter.format(
                amount,
                currencyCode: currency,
              );
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: ObfuscatedText(
                  amountStr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton primitives ──────────────────────────────────────────────────────

/// A shimmering transaction row placeholder.
class _TransactionSkeleton extends StatelessWidget {
  final Animation<double> shimmer;

  const _TransactionSkeleton({required this.shimmer});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Category icon placeholder
          _SkeletonBlock(
            shimmer: shimmer,
            width: 40,
            height: 40,
            borderRadius: 12,
          ),
          const SizedBox(width: 12),
          // Description + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBlock(
                  shimmer: shimmer,
                  width: double.infinity,
                  height: 14,
                  borderRadius: 4,
                ),
                const SizedBox(height: 6),
                _SkeletonBlock(
                  shimmer: shimmer,
                  width: 80,
                  height: 11,
                  borderRadius: 3,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Amount placeholder
          _SkeletonBlock(
            shimmer: shimmer,
            width: 60,
            height: 16,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}

/// A rectangular block that pulses opacity to simulate loading shimmer.
class _SkeletonBlock extends StatelessWidget {
  final Animation<double> shimmer;
  final double width;
  final double height;
  final double borderRadius;

  const _SkeletonBlock({
    required this.shimmer,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: shimmer,
      builder: (_, __) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Color.lerp(
              colorScheme.onSurface.withValues(alpha: 0.07),
              colorScheme.onSurface.withValues(alpha: 0.14),
              shimmer.value,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }
}
