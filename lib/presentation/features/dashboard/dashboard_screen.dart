import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:konta/core/l10n/app_localizations.dart';
import 'package:konta/core/theme/app_theme.dart';
import 'package:konta/core/utils/currency_formatter.dart';
import 'package:konta/domain/entities/transaction.dart';
import 'package:konta/domain/entities/transaction_type.dart';
import 'package:konta/presentation/features/transactions/add_transaction_screen.dart';
import 'package:konta/presentation/features/budgets_and_goals/budgets_and_goals_screen.dart';
import 'package:konta/presentation/features/statistics/statistics_screen.dart';
import 'package:konta/presentation/providers/repository_providers.dart';
import 'package:konta/presentation/widgets/empty_state_widget.dart';

/// The main application scaffold — shown after successful authentication.
///
/// Currently a **skeleton** that demonstrates the navigation structure and
/// overall visual hierarchy. Each tab body uses animated shimmer placeholders
/// that will be replaced with real data widgets in subsequent phases.
///
/// Tab layout:
/// 1. Overview    — balance card + income/expense stats + recent transactions
/// 2. Transactions — full transaction list
/// 3. Accounts    — account cards
/// 4. Settings    — settings rows
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  // Shared shimmer animation for all skeleton elements.
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _shimmer = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
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
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 18,
                color: colorScheme.onPrimary,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _SkeletonAvatar(shimmer: _shimmer, colorScheme: colorScheme),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _OverviewTab(shimmer: _shimmer, financialColors: financialColors),
          _TransactionsTab(shimmer: _shimmer),
          _GenericSkeletonTab(shimmer: _shimmer, itemCount: 4),
          _SettingsSkeletonTab(shimmer: _shimmer),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: destinations,
      ),
      floatingActionButton: _selectedIndex == 3
          ? null
          : FloatingActionButton(
              onPressed: () => _navigateToAddTransaction(context),
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
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
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

  const _OverviewTab({
    required this.shimmer,
    required this.financialColors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final transactionsAsync = ref.watch(transactionsStreamProvider);

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
                  label: AppLocalizations.of(context)!.income,
                  icon: Icons.trending_up_rounded,
                  accentColor: financialColors.positive,
                  shimmer: shimmer,
                  colorScheme: colorScheme,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: AppLocalizations.of(context)!.expenses,
                  icon: Icons.trending_down_rounded,
                  accentColor: financialColors.negative,
                  shimmer: shimmer,
                  colorScheme: colorScheme,
                  theme: theme,
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
                    subtitle:
                        AppLocalizations.of(context)!.noTransactionsSubtitle,
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
                    child: _TransactionItem(transaction: txn),
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

class _TransactionsTab extends ConsumerWidget {
  final Animation<double> shimmer;

  const _TransactionsTab({required this.shimmer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return transactionsAsync.when(
      loading: () => _GenericSkeletonTab(shimmer: shimmer, itemCount: 8),
      error: (err, _) => Center(
        child: Text(
          AppLocalizations.of(context)!.failedLoadTransactions,
          style: TextStyle(color: colorScheme.error),
        ),
      ),
      data: (transactions) {
        if (transactions.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: AppLocalizations.of(context)!.noTransactionsTitle,
            subtitle: AppLocalizations.of(context)!.noTransactionsSubtitle,
            actionLabel: AppLocalizations.of(context)!.addTransaction,
            onActionPressed: () {
              final state =
                  context.findAncestorStateOfType<_DashboardScreenState>();
              if (state != null) {
                state._navigateToAddTransaction(context);
              }
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          itemCount: transactions.length,
          itemBuilder: (context, i) {
            final txn = transactions[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TransactionItem(transaction: txn),
            );
          },
        );
      },
    );
  }
}

// ─── Real Transaction Item Widget ─────────────────────────────────────────────

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final financialColors = context.financialColors;

    final isIncome = transaction.type == TransactionType.income;
    final amountDouble = transaction.amount / 100.0;
    final amountStr = CurrencyFormatter.format(
      amountDouble,
      currencyCode: transaction.originalCurrency,
      showSign: true,
    );
    final color =
        isIncome ? financialColors.positive : financialColors.negative;

    final icon = isIncome
        ? Icons.trending_up_rounded
        : (transaction.type == TransactionType.transfer
            ? Icons.swap_horiz_rounded
            : Icons.trending_down_rounded);

    final dateStr = DateFormat('MMM d, yyyy').format(transaction.date);

    return Container(
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
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.notes?.isNotEmpty == true
                      ? transaction.notes!
                      : (isIncome ? 'Income' : 'Expense'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          Text(
            amountStr,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Generic skeleton tab ─────────────────────────────────────────────────────

class _GenericSkeletonTab extends StatelessWidget {
  final Animation<double> shimmer;
  final int itemCount;

  const _GenericSkeletonTab({
    required this.shimmer,
    required this.itemCount,
  });

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

class _SettingsSkeletonTab extends StatelessWidget {
  final Animation<double> shimmer;

  const _SettingsSkeletonTab({required this.shimmer});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      itemCount: 7,
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
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
                    builder: (context) => const StatisticsScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      color: colorScheme.secondary,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.settingsStatistics,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
class _BalanceCard extends StatelessWidget {
  final Animation<double> shimmer;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _BalanceCard({
    required this.shimmer,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            AppLocalizations.of(context)!.balanceTotal,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 14),
          // Skeleton amount placeholder
          AnimatedBuilder(
            animation: shimmer,
            builder: (_, __) => Container(
              width: 170,
              height: 34,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary
                    .withValues(alpha: 0.18 + 0.12 * shimmer.value),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: shimmer,
            builder: (_, __) => Container(
              width: 110,
              height: 15,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary
                    .withValues(alpha: 0.12 + 0.08 * shimmer.value),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Mini month label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              DateFormat.yMMMM(Localizations.localeOf(context).toString())
                  .format(DateTime(2026, 6)),
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
class _StatCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final Animation<double> shimmer;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _StatCard({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.shimmer,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
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
              _SkeletonBlock(
                shimmer: shimmer,
                width: 36,
                height: 14,
                borderRadius: 4,
              ),
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
          _SkeletonBlock(
            shimmer: shimmer,
            width: double.infinity,
            height: 20,
            borderRadius: 5,
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

/// A pulsing circular avatar placeholder for the AppBar.
class _SkeletonAvatar extends StatelessWidget {
  final Animation<double> shimmer;
  final ColorScheme colorScheme;

  const _SkeletonAvatar({
    required this.shimmer,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (_, __) => CircleAvatar(
        radius: 18,
        backgroundColor: Color.lerp(
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurface.withValues(alpha: 0.12),
          shimmer.value,
        ),
        child: Icon(
          Icons.person_rounded,
          size: 20,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
