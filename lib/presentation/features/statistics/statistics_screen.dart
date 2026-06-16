import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:konta/core/l10n/app_localizations.dart';
import 'package:konta/core/theme/app_theme.dart';
import 'package:konta/core/utils/currency_formatter.dart';
import 'package:konta/domain/entities/category_statistic.dart';
import 'package:konta/domain/entities/period_summary.dart';
import 'package:konta/presentation/providers/statistics_providers.dart';
import 'package:konta/presentation/widgets/empty_state_widget.dart';

// ─── Main Screen ──────────────────────────────────────────────────────────────

/// Statistics screen displaying income vs. expense summary and top spending
/// categories using fl_chart visualisations.
///
/// Reactive: Every chart and summary card re-renders automatically whenever
/// [StatisticsFilterNotifier] emits a new [StatisticsFilter].
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
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
    final filter = ref.watch(statisticsFilterProvider);
    final summaryAsync = ref.watch(periodSummaryProvider);

    final isEmpty = summaryAsync.when(
      data: (s) => s.totalIncome == 0 && s.totalExpense == 0,
      loading: () => false,
      error: (_, __) => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settingsStatistics,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.date_range_rounded),
              tooltip:
                  AppLocalizations.of(context)!.statisticsTooltipCustomRange,
              onPressed: () => _pickCustomRange(context),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(periodSummaryProvider);
          ref.invalidate(topExpenseCategoriesProvider);
          ref.invalidate(topIncomeCategoriesProvider);
        },
        color: colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            // ── Filter chips ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _FilterChipsRow(currentFilter: filter),
            ),

            // ── Period header ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _PeriodHeader(dateRange: filter.dateRange),
            ),

            if (isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: EmptyStateWidget(
                      icon: Icons.bar_chart_rounded,
                      title: AppLocalizations.of(context)!.noDataAvailable,
                      subtitle: AppLocalizations.of(context)!
                          .statisticsNoDataSubtitle,
                    ),
                  ),
                ),
              )
            else ...[
              // ── Income vs. Expense summary ────────────────────────────────
              SliverToBoxAdapter(
                child: _SummarySection(shimmer: _shimmer),
              ),

              // ── Top Expense Categories ─────────────────────────────────────
              SliverToBoxAdapter(
                child: _CategoryChartSection(
                  key: const ValueKey('expense_chart'),
                  shimmer: _shimmer,
                  categoriesAsync: ref.watch(topExpenseCategoriesProvider),
                  title: AppLocalizations.of(context)!.statisticsTopSpending,
                  subtitle:
                      AppLocalizations.of(context)!.statisticsWhereMoneyGoes,
                  emptyLabel:
                      AppLocalizations.of(context)!.statisticsNoExpenses,
                  accentColor: context.financialColors.negative,
                ),
              ),

              // ── Top Income Categories ──────────────────────────────────────
              SliverToBoxAdapter(
                child: _CategoryChartSection(
                  key: const ValueKey('income_chart'),
                  shimmer: _shimmer,
                  categoriesAsync: ref.watch(topIncomeCategoriesProvider),
                  title: AppLocalizations.of(context)!.statisticsTopIncome,
                  subtitle:
                      AppLocalizations.of(context)!.statisticsWhatYouEarned,
                  emptyLabel: AppLocalizations.of(context)!.statisticsNoIncome,
                  accentColor: context.financialColors.positive,
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final filter = ref.read(statisticsFilterProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: filter.dateRange.start,
        end: filter.dateRange.end,
      ),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref
          .read(statisticsFilterProvider.notifier)
          .setCustomDateTimeRange(picked);
    }
  }
}

// ─── Filter chips row ─────────────────────────────────────────────────────────

class _FilterChipsRow extends ConsumerWidget {
  final StatisticsFilter currentFilter;

  const _FilterChipsRow({required this.currentFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: StatisticsDatePreset.values.map((preset) {
          final isSelected = currentFilter.preset == preset;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: FilterChip(
                key: ValueKey(preset.name),
                label: Text(preset.getLocalizedLabel(context)),
                selected: isSelected,
                showCheckmark: false,
                backgroundColor: colorScheme.surfaceContainerHighest,
                selectedColor: colorScheme.primary,
                labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : colorScheme.outline.withValues(alpha: 0.2),
                ),
                onSelected: (_) {
                  if (preset != StatisticsDatePreset.custom) {
                    ref
                        .read(statisticsFilterProvider.notifier)
                        .setPreset(preset);
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Period header ────────────────────────────────────────────────────────────

class _PeriodHeader extends StatelessWidget {
  final DateTimeRange dateRange;

  const _PeriodHeader({required this.dateRange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formatted =
        '${DateFormat('MMM d').format(dateRange.start)} – ${DateFormat('MMM d, y').format(dateRange.end)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            formatted,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary section ──────────────────────────────────────────────────────────

class _SummarySection extends ConsumerWidget {
  final Animation<double> shimmer;

  const _SummarySection({required this.shimmer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(periodSummaryProvider);
    final financialColors = context.financialColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: summaryAsync.when(
        loading: () => Row(
          children: [
            Expanded(
              child: _SummaryCardSkeleton(
                shimmer: shimmer,
                label: AppLocalizations.of(context)!.income,
                accentColor: financialColors.positive,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCardSkeleton(
                shimmer: shimmer,
                label: AppLocalizations.of(context)!.expenses,
                accentColor: financialColors.negative,
              ),
            ),
          ],
        ),
        error: (err, _) => _InlineError(message: err.toString()),
        data: (summary) => Column(
          children: [
            // Net balance card
            _NetBalanceCard(summary: summary),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: AppLocalizations.of(context)!.income,
                    amount: summary.totalIncome / 100.0,
                    icon: Icons.trending_up_rounded,
                    accentColor: financialColors.positive,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: AppLocalizations.of(context)!.expenses,
                    amount: summary.totalExpense / 100.0,
                    icon: Icons.trending_down_rounded,
                    accentColor: financialColors.negative,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NetBalanceCard extends StatelessWidget {
  final PeriodSummary summary;

  const _NetBalanceCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final financialColors = context.financialColors;

    final net = (summary.totalIncome - summary.totalExpense) / 100.0;
    final isPositive = net >= 0;
    final accentColor =
        isPositive ? financialColors.positive : financialColors.negative;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.18),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isPositive
                  ? Icons.account_balance_wallet_rounded
                  : Icons.warning_amber_rounded,
              color: accentColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.statisticsNetBalance,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(net.abs(), showSign: false),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              isPositive
                  ? '▲ ${AppLocalizations.of(context)!.statisticsSurplus}'
                  : '▼ ${AppLocalizations.of(context)!.statisticsDeficit}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color accentColor;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.format(amount),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCardSkeleton extends StatelessWidget {
  final Animation<double> shimmer;
  final String label;
  final Color accentColor;

  const _SummaryCardSkeleton({
    required this.shimmer,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: shimmer,
            builder: (_, __) => Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    accentColor.withValues(alpha: 0.07 + 0.07 * shimmer.value),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: shimmer,
                  builder: (_, __) => Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        colorScheme.onSurface.withValues(alpha: 0.07),
                        colorScheme.onSurface.withValues(alpha: 0.14),
                        shimmer.value,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category chart section ───────────────────────────────────────────────────

class _CategoryChartSection extends StatefulWidget {
  final Animation<double> shimmer;
  final AsyncValue<List<CategoryStatistic>> categoriesAsync;
  final String title;
  final String subtitle;
  final String emptyLabel;
  final Color accentColor;

  const _CategoryChartSection({
    super.key,
    required this.shimmer,
    required this.categoriesAsync,
    required this.title,
    required this.subtitle,
    required this.emptyLabel,
    required this.accentColor,
  });

  @override
  State<_CategoryChartSection> createState() => _CategoryChartSectionState();
}

class _CategoryChartSectionState extends State<_CategoryChartSection> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart body
          widget.categoriesAsync.when(
            loading: () => _ChartSkeleton(shimmer: widget.shimmer),
            error: (err, _) => _InlineError(message: err.toString()),
            data: (categories) {
              if (categories.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.pie_chart_outline_rounded,
                  title: widget.emptyLabel,
                  subtitle:
                      AppLocalizations.of(context)!.statisticsNoDataSubtitle,
                );
              }
              return _PieChartWithLegend(
                categories: categories,
                touchedIndex: _touchedIndex,
                onTouch: (index) => setState(() => _touchedIndex = index),
                accentColor: widget.accentColor,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Pie chart ────────────────────────────────────────────────────────────────

class _PieChartWithLegend extends StatelessWidget {
  final List<CategoryStatistic> categories;
  final int touchedIndex;
  final ValueChanged<int> onTouch;
  final Color accentColor;

  const _PieChartWithLegend({
    required this.categories,
    required this.touchedIndex,
    required this.onTouch,
    required this.accentColor,
  });

  Color _parseHexColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final total = categories.fold<int>(0, (s, c) => s + c.totalAmount);

    // Show at most 6 slices; group the rest into "Other".
    final displayCategories = categories.take(6).toList();
    final otherTotal =
        categories.skip(6).fold<int>(0, (s, c) => s + c.totalAmount);

    final sections = <PieChartSectionData>[];
    for (var i = 0; i < displayCategories.length; i++) {
      final cat = displayCategories[i];
      final isTouched = i == touchedIndex;
      final ratio = total > 0 ? cat.totalAmount / total : 0.0;
      final catColor = _parseHexColor(cat.categoryColor);

      sections.add(
        PieChartSectionData(
          value: cat.totalAmount.toDouble(),
          color: catColor,
          radius: isTouched ? 72 : 60,
          title: isTouched ? '${(ratio * 100).toStringAsFixed(0)}%' : '',
          titleStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
          ),
          badgeWidget: isTouched ? null : null,
        ),
      );
    }

    if (otherTotal > 0) {
      sections.add(
        PieChartSectionData(
          value: otherTotal.toDouble(),
          color: colorScheme.onSurface.withValues(alpha: 0.18),
          radius: 60,
          title: '',
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          // Pie chart
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 50,
                sectionsSpace: 3,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (event.isInterestedForInteractions &&
                        response?.touchedSection != null) {
                      onTouch(response!.touchedSection!.touchedSectionIndex);
                    } else {
                      onTouch(-1);
                    }
                  },
                ),
              ),
            ),
          ),

          // Centre tap hint
          if (touchedIndex >= 0 && touchedIndex < displayCategories.length)
            _TouchedCategoryInfo(
              category: displayCategories[touchedIndex],
              total: total,
              parseColor: _parseHexColor,
            )
          else
            const SizedBox(height: 4),

          const SizedBox(height: 16),

          // Legend list
          ...List.generate(
            math.min(displayCategories.length, 6),
            (i) {
              final cat = displayCategories[i];
              final ratio = total > 0 ? cat.totalAmount / total : 0.0;
              final catColor = _parseHexColor(cat.categoryColor);
              final isTouched = i == touchedIndex;

              return GestureDetector(
                onTap: () => onTouch(isTouched ? -1 : i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isTouched
                        ? catColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: catColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cat.categoryName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight:
                                isTouched ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${(ratio * 100).toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        CurrencyFormatter.format(cat.totalAmount / 100.0),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: catColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (otherTotal > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Other (${categories.length - 6} categories)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  CurrencyFormatter.format(otherTotal / 100.0),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TouchedCategoryInfo extends StatelessWidget {
  final CategoryStatistic category;
  final int total;
  final Color Function(String) parseColor;

  const _TouchedCategoryInfo({
    required this.category,
    required this.total,
    required this.parseColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catColor = parseColor(category.categoryColor);
    final percentage = total > 0
        ? (category.totalAmount / total * 100).toStringAsFixed(1)
        : '0.0';

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: catColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: catColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.categoryName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: catColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '·',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: catColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percentage%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: catColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '·',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: catColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              CurrencyFormatter.format(category.totalAmount / 100.0),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: catColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skeleton & empty/error states ───────────────────────────────────────────

class _ChartSkeleton extends StatelessWidget {
  final Animation<double> shimmer;

  const _ChartSkeleton({required this.shimmer});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Circle shimmer
          AnimatedBuilder(
            animation: shimmer,
            builder: (_, __) => Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(
                  colorScheme.onSurface.withValues(alpha: 0.05),
                  colorScheme.onSurface.withValues(alpha: 0.1),
                  shimmer.value,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend skeletons
          ...List.generate(2, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AnimatedBuilder(
                animation: shimmer,
                builder: (_, __) => Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      colorScheme.onSurface.withValues(alpha: 0.05),
                      colorScheme.onSurface.withValues(alpha: 0.10),
                      shimmer.value,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
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
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on StatisticsDatePreset {
  String getLocalizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case StatisticsDatePreset.thisMonth:
        return l10n.presetThisMonth;
      case StatisticsDatePreset.last3Months:
        return l10n.presetLast3Months;
      case StatisticsDatePreset.last6Months:
        return l10n.presetLast6Months;
      case StatisticsDatePreset.thisYear:
        return l10n.presetThisYear;
      case StatisticsDatePreset.custom:
        return l10n.presetCustom;
    }
  }
}
