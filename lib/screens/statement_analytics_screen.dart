import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/credit_card.dart';
import '../models/credit_card_statement.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';

/// Statement Analytics Screen - Detailed analysis for a specific statement period
class StatementAnalyticsScreen extends StatefulWidget {
  final CreditCardStatement statement;
  final CreditCard creditCard;

  const StatementAnalyticsScreen({
    super.key,
    required this.statement,
    required this.creditCard,
  });

  @override
  State<StatementAnalyticsScreen> createState() => _StatementAnalyticsScreenState();
}

class _StatementAnalyticsScreenState extends State<StatementAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _selectedPeriod = 'Statement Period';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.creditCard.name} Analytics'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.trending_up), text: 'Spending'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Categories'),
            Tab(icon: Icon(Icons.lightbulb), text: 'Insights'),
          ],
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          // Get transactions for this statement period
          final periodTransactions = appProvider.transactions.where((transaction) {
            return transaction.accountId == widget.creditCard.id &&
                   transaction.date.isAfter(widget.statement.periodStart) &&
                   transaction.date.isBefore(widget.statement.periodEnd.add(const Duration(days: 1)));
          }).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(periodTransactions, appProvider),
              _buildSpendingTab(periodTransactions),
              _buildCategoriesTab(periodTransactions, appProvider),
              _buildInsightsTab(periodTransactions),
            ],
          );
        },
      ),
    );
  }

  // ========================================
  // TAB CONTENT METHODS
  // ========================================

  Widget _buildOverviewTab(List transactions, AppProvider appProvider) {
    final totalSpent = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    
    final totalTransactions = transactions.length;
    final avgTransaction = totalTransactions > 0 ? totalSpent / totalTransactions : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statement Period Filter
          _buildPeriodFilter(),
          const SizedBox(height: 24),
          
          // Key Metrics
          _buildKeyMetricsCards(totalSpent, totalTransactions, avgTransaction),
          const SizedBox(height: 24),
          
          // Spending Trend
          _buildSpendingTrend(transactions),
          const SizedBox(height: 24),
          
          // Spending by Category
          _buildSpendingByCategory(transactions, appProvider),
          const SizedBox(height: 24),
          
          // Smart Insights
          _buildSmartInsights(transactions),
        ],
      ),
    );
  }

  Widget _buildSpendingTab(List transactions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodFilter(),
          const SizedBox(height: 24),
          _buildDetailedSpendingAnalysis(transactions),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(List transactions, AppProvider appProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodFilter(),
          const SizedBox(height: 24),
          _buildCategoryBreakdown(transactions, appProvider),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(List transactions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodFilter(),
          const SizedBox(height: 24),
          _buildDetailedInsights(transactions),
        ],
      ),
    );
  }

  // ========================================
  // COMPONENT METHODS
  // ========================================

  Widget _buildPeriodFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            widget.statement.periodDisplay,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsCards(double totalSpent, int totalTransactions, double avgTransaction) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Spending',
            Formatters.formatCurrency(totalSpent),
            Icons.trending_up,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Avg Transaction',
            Formatters.formatCurrency(avgTransaction),
            Icons.calendar_today,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Transactions',
            totalTransactions.toString(),
            Icons.receipt,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrend(List transactions) {
    // Group transactions by day
    final dailySpending = <DateTime, double>{};
    for (final transaction in transactions.where((t) => t.isExpense)) {
      final day = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      dailySpending[day] = (dailySpending[day] ?? 0) + transaction.amount.abs();
    }

    final sortedDays = dailySpending.keys.toList()..sort();
    final maxSpending = dailySpending.values.isEmpty ? 1.0 : dailySpending.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Spending Trend',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (dailySpending.isEmpty)
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Spending Data',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No transactions found for this statement period',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: Column(
                children: [
                  // Chart area
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: sortedDays.map((day) {
                        final spending = dailySpending[day] ?? 0.0;
                        final height = (spending / maxSpending) * 120; // Max height of 120
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 20,
                              height: height,
                              decoration: BoxDecoration(
                                color: _getBarColor(spending, maxSpending),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${day.day}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem('Low', Colors.green),
                      _buildLegendItem('Medium', Colors.orange),
                      _buildLegendItem('High', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getBarColor(double spending, double maxSpending) {
    final ratio = spending / maxSpending;
    if (ratio < 0.3) return Colors.green;
    if (ratio < 0.7) return Colors.orange;
    return Colors.red;
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingByCategory(List transactions, AppProvider appProvider) {
    final categorySpending = <String, double>{};
    
    for (final transaction in transactions.where((t) => t.isExpense)) {
      final category = appProvider.categories
          .where((c) => c.id == transaction.categoryId)
          .firstOrNull;
      if (category != null) {
        categorySpending[category.name] = (categorySpending[category.name] ?? 0) + transaction.amount.abs();
      }
    }

    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (sortedCategories.isEmpty)
            Center(
              child: Text(
                'No spending data available for this period',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            )
          else
            ...sortedCategories.take(5).map((entry) => _buildCategoryItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, double amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            Formatters.formatCurrency(amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsights(List transactions) {
    final totalSpent = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Smart Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow.shade200),
            ),
            child: Text(
              'You spent ${Formatters.formatCurrency(totalSpent)} during this statement period. This represents your total credit card usage for ${widget.statement.periodDisplay}.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // TAB-SPECIFIC METHODS
  // ========================================

  Widget _buildDetailedSpendingAnalysis(List transactions) {
    // Group transactions by day
    final dailySpending = <DateTime, List<dynamic>>{};
    for (final transaction in transactions.where((t) => t.isExpense)) {
      final day = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      if (dailySpending[day] == null) {
        dailySpending[day] = [];
      }
      dailySpending[day]!.add(transaction);
    }

    final sortedDays = dailySpending.keys.toList()..sort((a, b) => b.compareTo(a)); // Most recent first

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daily Spending Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Spending Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (dailySpending.isEmpty)
                Center(
                  child: Text(
                    'No spending data available for this period',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              else
                ...sortedDays.map((day) {
                  final dayTransactions = dailySpending[day]!;
                  final dayTotal = dayTransactions.fold(0.0, (sum, t) => sum + t.amount.abs());
                  return _buildDaySummary(day, dayTotal, dayTransactions.length);
                }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // All Transactions List
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Transactions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (transactions.isEmpty)
                Center(
                  child: Text(
                    'No transactions found for this period',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              else
                ...transactions.where((t) => t.isExpense).map((transaction) => _buildTransactionItem(transaction)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaySummary(DateTime day, double total, int transactionCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today,
              color: Colors.blue.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatters.formatDate(day),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$transactionCount transaction${transactionCount != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            Formatters.formatCurrency(total),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_upward,
              color: Colors.red.shade600,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  Formatters.formatDate(transaction.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-${Formatters.formatCurrency(transaction.amount.abs())}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(List transactions, AppProvider appProvider) {
    final categorySpending = <String, double>{};
    
    for (final transaction in transactions.where((t) => t.isExpense)) {
      final category = appProvider.categories
          .where((c) => c.id == transaction.categoryId)
          .firstOrNull;
      if (category != null) {
        categorySpending[category.name] = (categorySpending[category.name] ?? 0) + transaction.amount.abs();
      }
    }

    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalSpent = categorySpending.values.fold(0.0, (sum, amount) => sum + amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spending by Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (sortedCategories.isEmpty)
                Center(
                  child: Text(
                    'No spending data available for this period',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              else
                ...sortedCategories.map((entry) {
                  final percentage = totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0.0;
                  return _buildCategoryItemWithPercentage(entry.key, entry.value, percentage);
                }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Category Insights
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (sortedCategories.isNotEmpty)
                _buildCategoryInsights(sortedCategories, totalSpent)
              else
                Center(
                  child: Text(
                    'No insights available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItemWithPercentage(String category, double amount, double percentage) {
    final colors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
    ];
    
    final colorIndex = category.hashCode % colors.length;
    final color = colors[colorIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}% of total spending',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            Formatters.formatCurrency(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryInsights(List<MapEntry<String, double>> categories, double totalSpent) {
    final topCategory = categories.first;
    final topCategoryPercentage = totalSpent > 0 ? (topCategory.value / totalSpent) * 100 : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Top Spending Category',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${topCategory.key} is your highest spending category at ${topCategoryPercentage.toStringAsFixed(1)}% of your total spending (${Formatters.formatCurrency(topCategory.value)}).',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInsights(List transactions) {
    final totalSpent = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    
    final transactionCount = transactions.length;
    final avgTransaction = transactionCount > 0 ? totalSpent / transactionCount : 0.0;
    
    // Calculate spending patterns
    final dailySpending = <DateTime, double>{};
    for (final transaction in transactions.where((t) => t.isExpense)) {
      final day = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      dailySpending[day] = (dailySpending[day] ?? 0) + transaction.amount.abs();
    }
    
    final maxDailySpending = dailySpending.values.isEmpty ? 0.0 : dailySpending.values.reduce((a, b) => a > b ? a : b);
    final maxSpendingDay = dailySpending.entries.isEmpty ? null : dailySpending.entries.reduce((a, b) => a.value > b.value ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Key Insights
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Key Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (transactions.isEmpty)
                Center(
                  child: Text(
                    'No insights available for this period',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    _buildInsightCard(
                      'Total Spending',
                      'You spent ${Formatters.formatCurrency(totalSpent)} during this statement period',
                      Icons.account_balance_wallet,
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildInsightCard(
                      'Average Transaction',
                      'Your average transaction was ${Formatters.formatCurrency(avgTransaction)}',
                      Icons.trending_up,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    if (maxSpendingDay != null)
                      _buildInsightCard(
                        'Highest Spending Day',
                        'You spent the most on ${Formatters.formatDate(maxSpendingDay.key)} - ${Formatters.formatCurrency(maxSpendingDay.value)}',
                        Icons.calendar_today,
                        Colors.orange,
                      ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Recommendations
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommendations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildRecommendationCard(
                'Spending Pattern',
                'Consider tracking your daily spending to identify patterns and reduce unnecessary expenses.',
                Icons.lightbulb,
                Colors.yellow,
              ),
              const SizedBox(height: 12),
              _buildRecommendationCard(
                'Budget Planning',
                'Set a monthly budget for your credit card spending to maintain better financial control.',
                Icons.savings,
                Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
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
