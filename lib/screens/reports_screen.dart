import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/utils/formatters.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/models/transaction.dart';
import 'package:kora_expense_tracker/models/category.dart';

/// Period filter options for the Reports screen.
enum ReportPeriod { week, month, year }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.month;

  // ─── Helpers ────────────────────────────────────────────────────────────────

  DateTimeRange _range(ReportPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case ReportPeriod.week:
        // Start of current week (Monday)
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return DateTimeRange(
          start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          end: now,
        );
      case ReportPeriod.month:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
      case ReportPeriod.year:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        );
    }
  }

  List<Transaction> _filtered(List<Transaction> all, DateTimeRange range) {
    return all.where((t) {
      return !t.date.isBefore(range.start) && !t.date.isAfter(range.end);
    }).toList();
  }

  String _periodLabel(ReportPeriod p) {
    switch (p) {
      case ReportPeriod.week:
        return 'This Week';
      case ReportPeriod.month:
        return 'This Month';
      case ReportPeriod.year:
        return 'This Year';
    }
  }

  int _periodDays(ReportPeriod p) {
    switch (p) {
      case ReportPeriod.week:
        return 7;
      case ReportPeriod.month:
        return DateTime.now().day;
      case ReportPeriod.year:
        return DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays + 1;
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final range = _range(_period);
        final filtered = _filtered(provider.transactions, range);

        final income = filtered
            .where((t) => t.isIncome)
            .fold(0.0, (s, t) => s + t.amount.abs());
        final expenses = filtered
            .where((t) => t.isExpense)
            .fold(0.0, (s, t) => s + t.amount.abs());
        final savings = income - expenses;
        final days = _periodDays(_period);
        final dailyAvg = days > 0 ? expenses / days : 0.0;

        // Top categories by spend
        final Map<String, double> catSpend = {};
        for (final t in filtered.where((t) => t.isExpense)) {
          catSpend[t.categoryId] =
              (catSpend[t.categoryId] ?? 0) + t.amount.abs();
        }
        final sortedCats = catSpend.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final topCats = sortedCats.take(5).toList();
        final maxCatSpend =
            topCats.isNotEmpty ? topCats.first.value : 1.0;

        final savingsRate = income > 0 ? (savings / income).clamp(0.0, 1.0) : 0.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reports'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => provider.refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Period filter chips ─────────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ReportPeriod.values.map((p) {
                          final selected = _period == p;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: selected,
                              label: Text(_periodLabel(p)),
                              onSelected: (_) =>
                                  setState(() => _period = p),
                              selectedColor:
                                  Theme.of(context).colorScheme.primaryContainer,
                              checkmarkColor:
                                  Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: AppConstants.defaultPadding),

                    // ── Summary header card ─────────────────────────────────
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(AppConstants.defaultPadding),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer,
                              Theme.of(context).colorScheme.secondaryContainer,
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _periodLabel(_period),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Net Savings',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withValues(alpha: 0.75),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.formatCurrency(savings),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: savings >= 0
                                        ? AppConstants.successColor
                                        : AppConstants.errorColor,
                                  ),
                            ),
                            const SizedBox(height: AppConstants.defaultPadding),
                            Row(
                              children: [
                                Expanded(
                                  child: _summaryItem(
                                    context,
                                    'Income',
                                    Formatters.formatCurrency(income),
                                    AppConstants.successColor,
                                    Icons.arrow_upward_rounded,
                                  ),
                                ),
                                const SizedBox(
                                    width: AppConstants.defaultPadding),
                                Expanded(
                                  child: _summaryItem(
                                    context,
                                    'Expenses',
                                    Formatters.formatCurrency(expenses),
                                    AppConstants.errorColor,
                                    Icons.arrow_downward_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.defaultPadding),

                    // ── Key metrics row ─────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _metricCard(
                            context,
                            icon: Icons.calendar_today_rounded,
                            label: 'Daily Avg',
                            value: Formatters.formatCurrency(dailyAvg),
                            color: AppConstants.infoColor,
                          ),
                        ),
                        const SizedBox(width: AppConstants.defaultPadding),
                        Expanded(
                          child: _metricCard(
                            context,
                            icon: Icons.savings_rounded,
                            label: 'Savings Rate',
                            value:
                                '${(savingsRate * 100).toStringAsFixed(1)}%',
                            color: savingsRate >= 0.2
                                ? AppConstants.successColor
                                : AppConstants.warningColor,
                          ),
                        ),
                        const SizedBox(width: AppConstants.defaultPadding),
                        Expanded(
                          child: _metricCard(
                            context,
                            icon: Icons.receipt_long_rounded,
                            label: 'Transactions',
                            value: '${filtered.length}',
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.largePadding),

                    // ── Income vs Expense bar ───────────────────────────────
                    if (income > 0 || expenses > 0) ...[
                      Text(
                        'Income vs Expenses',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(
                              AppConstants.defaultPadding),
                          child: _incomeExpenseBar(
                              context, income, expenses),
                        ),
                      ),
                      const SizedBox(height: AppConstants.largePadding),
                    ],

                    // ── Top spending categories ─────────────────────────────
                    if (topCats.isNotEmpty) ...[
                      Text(
                        'Top Spending Categories',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(
                              AppConstants.defaultPadding),
                          child: Column(
                            children: topCats.map((entry) {
                              final cat = _findCategory(
                                  provider.categories, entry.key);
                              final ratio =
                                  maxCatSpend > 0
                                      ? entry.value / maxCatSpend
                                      : 0.0;
                              return _categoryBar(
                                context,
                                cat: cat,
                                amount: entry.value,
                                ratio: ratio,
                                totalExpenses: expenses,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.largePadding),
                    ],

                    // ── Empty state ─────────────────────────────────────────
                    if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Column(
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                size: 72,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No data for ${_periodLabel(_period).toLowerCase()}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add transactions to see your report.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Sub-widgets ─────────────────────────────────────────────────────────────

  Widget _summaryItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withValues(alpha: 0.75),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _metricCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _incomeExpenseBar(
      BuildContext context, double income, double expenses) {
    final total = income + expenses;
    final incomeFrac = total > 0 ? (income / total) : 0.5;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Flexible(
                flex: (incomeFrac * 100).round(),
                child: Container(
                  height: 18,
                  color: AppConstants.successColor,
                ),
              ),
              Flexible(
                flex: ((1 - incomeFrac) * 100).round(),
                child: Container(
                  height: 18,
                  color: AppConstants.errorColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _legendDot(context, AppConstants.successColor,
                'Income ${(incomeFrac * 100).toStringAsFixed(1)}%'),
            _legendDot(context, AppConstants.errorColor,
                'Expenses ${((1 - incomeFrac) * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ],
    );
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _categoryBar(
    BuildContext context, {
    required Category? cat,
    required double amount,
    required double ratio,
    required double totalExpenses,
  }) {
    final pct =
        totalExpenses > 0 ? (amount / totalExpenses * 100) : 0.0;
    final color = cat != null ? cat.color : AppConstants.primaryColor;
    final icon = cat?.icon ?? Icons.category;
    final name = cat?.name ?? 'Unknown';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          Formatters.formatCurrency(amount),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.errorColor,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pct.toStringAsFixed(1)}% of expenses',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Category? _findCategory(List<Category> cats, String id) {
    try {
      return cats.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
