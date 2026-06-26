import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/theme/app_theme.dart';
import 'package:stalvi/core/utils/currency_formatter.dart';
import 'package:stalvi/domain/entities/budget.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/savings_goal.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:stalvi/presentation/widgets/progress_bar_widget.dart';
import 'package:stalvi/presentation/widgets/empty_state_widget.dart';
import 'package:stalvi/core/utils/icon_helper.dart';
import 'package:stalvi/presentation/features/budgets_and_goals/widgets/create_edit_budget_sheet.dart';
import 'package:stalvi/presentation/features/budgets_and_goals/widgets/create_edit_savings_goal_sheet.dart';

/// Screen displaying Budgets and Savings Goals in a tabbed interface.
///
/// Shows spent-to-budget limits and savings goal milestones, utilizing
/// the reusable [ProgressBarWidget] and styled with the app's pastel aesthetic.
class BudgetsAndGoalsScreen extends ConsumerWidget {
  const BudgetsAndGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.budgetsAndGoals,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.onSurface,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: theme.textTheme.bodyMedium,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.budgets),
              Tab(text: AppLocalizations.of(context)!.savingsGoals),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BudgetsTabBody(),
            _SavingsGoalsTabBody(),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
                final tabController = DefaultTabController.of(context);
                if (tabController.index == 0) {
                  CreateEditBudgetSheet.show(context);
                } else {
                  CreateEditSavingsGoalSheet.show(context);
                }
              },
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(Icons.add_rounded),
            );
          },
        ),
      ),
    );
  }
}

class _BudgetsTabBody extends ConsumerWidget {
  const _BudgetsTabBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsStreamProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);

    return budgetsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, _) => _ErrorStateWidget(
        message: AppLocalizations.of(context)!.failedLoadBudgets,
        errorDetails: err.toString(),
      ),
      data: (budgets) {
        if (budgets.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.pie_chart_outline_rounded,
            title: AppLocalizations.of(context)!.noBudgetsTitle,
            subtitle: AppLocalizations.of(context)!.noBudgetsSubtitle,
          );
        }

        final categories = categoriesAsync.valueOrNull ?? [];

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: budgets.length,
          itemBuilder: (context, index) {
            final budget = budgets[index];
            final category = categories.firstWhere(
              (c) => c.id == budget.categoryId,
              orElse: () => Category(
                id: budget.categoryId,
                name: AppLocalizations.of(context)!.uncategorized,
                icon: 'category',
                color: '#94A3B8',
                createdAt: DateTime.now(),
                modifiedAt: DateTime.now(),
              ),
            );

            return _BudgetCard(budget: budget, category: category);
          },
        );
      },
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  final Budget budget;
  final Category category;

  const _BudgetCard({
    required this.budget,
    required this.category,
  });

  Color _parseHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  IconData _getIconData(String name) {
    return getIconData(name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final financialColors = context.financialColors;

    final catColor = _parseHexColor(category.color);
    final catIcon = _getIconData(category.icon);

    final double spentDouble = budget.currentAmount / 100.0;
    final double targetDouble = budget.targetAmount / 100.0;
    final double remainingDouble = targetDouble - spentDouble;
    final double progress = budget.targetAmount > 0
        ? budget.currentAmount / budget.targetAmount
        : 0.0;

    final formatter = ref.watch(currencyFormatterProvider);
    final accounts = ref.watch(accountsListProvider).valueOrNull ?? [];
    Account? budgetAccount;
    for (final a in accounts) {
      if (a.id == budget.accountId) {
        budgetAccount = a;
        break;
      }
    }
    final currencyToShow = budgetAccount?.currency ?? formatter.currencyCode;

    final spentStr =
        formatter.format(spentDouble, currencyCode: currencyToShow);
    final targetStr =
        formatter.format(targetDouble, currencyCode: currencyToShow);
    final remainingStr =
        formatter.format(remainingDouble.abs(), currencyCode: currencyToShow);
    final progressStr =
        CurrencyFormatter.formatPercentage(progress, decimalDigits: 0);

    final isOverspent = budget.currentAmount > budget.targetAmount;
    final statusText = isOverspent
        ? AppLocalizations.of(context)!.budgetOverspent(remainingStr)
        : AppLocalizations.of(context)!.budgetRemaining(remainingStr);
    final statusColor =
        isOverspent ? financialColors.negative : colorScheme.onSurfaceVariant;

    final locale = Localizations.localeOf(context).toString();
    final dateRangeStr =
        '${DateFormat.MMMd(locale).format(budget.startDate)} - ${DateFormat.yMMMd(locale).format(budget.endDate)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => CreateEditBudgetSheet.show(context, budget: budget),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: catColor.withValues(alpha: 0.12),
                      child: Icon(catIcon, color: catColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateRangeStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      progressStr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isOverspent
                            ? financialColors.negative
                            : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!
                            .budgetSpentOf(spentStr, targetStr),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        statusText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ProgressBarWidget(
                  currentAmount: budget.currentAmount,
                  targetAmount: budget.targetAmount,
                  activeColor: catColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavingsGoalsTabBody extends ConsumerWidget {
  const _SavingsGoalsTabBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsGoalsAsync = ref.watch(savingsGoalsStreamProvider);

    return savingsGoalsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, _) => _ErrorStateWidget(
        message: AppLocalizations.of(context)!.failedLoadSavingsGoals,
        errorDetails: err.toString(),
      ),
      data: (goals) {
        if (goals.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.savings_outlined,
            title: AppLocalizations.of(context)!.noSavingsGoalsTitle,
            subtitle: AppLocalizations.of(context)!.noSavingsGoalsSubtitle,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            return _SavingsGoalCard(goal: goal);
          },
        );
      },
    );
  }
}

class _SavingsGoalCard extends ConsumerWidget {
  final SavingsGoal goal;

  const _SavingsGoalCard({required this.goal});

  Color _parseHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  IconData _getIconData(String name) {
    return getIconData(name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final financialColors = context.financialColors;

    final goalColor = _parseHexColor(goal.color);
    final goalIcon = _getIconData(goal.icon);

    final double savedDouble = goal.currentAmount / 100.0;
    final double targetDouble = goal.targetAmount / 100.0;
    final double progress =
        goal.targetAmount > 0 ? goal.currentAmount / goal.targetAmount : 0.0;

    final formatter = ref.watch(currencyFormatterProvider);

    final savedStr = formatter.format(savedDouble, currencyCode: goal.currency);
    final targetStr =
        formatter.format(targetDouble, currencyCode: goal.currency);
    final progressStr =
        CurrencyFormatter.formatPercentage(progress, decimalDigits: 0);

    final targetDateStr = goal.targetDate != null
        ? AppLocalizations.of(context)!.savingsTargetDate(
            DateFormat.yMMMd(Localizations.localeOf(context).toString())
                .format(goal.targetDate!),
          )
        : AppLocalizations.of(context)!.savingsNoTargetDate;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => CreateEditSavingsGoalSheet.show(context, goal: goal),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: goalColor.withValues(alpha: 0.12),
                      child: Icon(goalIcon, color: goalColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            targetDateStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      progressStr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: progress >= 1.0
                            ? financialColors.positive
                            : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!
                            .savingsSavedOf(savedStr, targetStr),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (progress >= 1.0) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.savingsGoalAchieved,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: financialColors.positive,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                ProgressBarWidget(
                  currentAmount: goal.currentAmount,
                  targetAmount: goal.targetAmount,
                  activeColor: goalColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorStateWidget extends StatelessWidget {
  final String message;
  final String errorDetails;

  const _ErrorStateWidget({
    required this.message,
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              errorDetails,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
