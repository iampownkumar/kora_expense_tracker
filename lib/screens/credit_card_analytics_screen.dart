import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/credit_card.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

/// Credit Card Analytics Screen
///
/// Displays comprehensive analytics for a specific credit card including:
/// - Spending trends over time
/// - Category-wise spending breakdown
/// - Credit utilization trends
/// - Smart insights and recommendations
/// - Payment history tracking
class CreditCardAnalyticsScreen extends StatefulWidget {
  final CreditCard creditCard;

  const CreditCardAnalyticsScreen({super.key, required this.creditCard});

  @override
  State<CreditCardAnalyticsScreen> createState() =>
      _CreditCardAnalyticsScreenState();
}

class _CreditCardAnalyticsScreenState extends State<CreditCardAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = '3M'; // 3 Months, 6 Months, 1 Year

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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('${widget.creditCard.name} Analytics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
            tooltip: 'Export PDF',
            onPressed: _exportAnalyticsPDF,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Spending', icon: Icon(Icons.trending_up)),
            Tab(text: 'Categories', icon: Icon(Icons.pie_chart)),
            Tab(text: 'Insights', icon: Icon(Icons.lightbulb)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSpendingTab(),
          _buildCategoriesTab(),
          _buildInsightsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final transactions = _getCreditCardTransactions(appProvider);
        final monthlySpending = _calculateMonthlySpending(transactions);
        final categorySpending = _calculateCategorySpending(
          transactions,
          appProvider,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Range Selector
              _buildTimeRangeSelector(),
              const SizedBox(height: 24),

              // Key Metrics Cards
              _buildKeyMetricsCards(monthlySpending),
              const SizedBox(height: 24),

              // Spending Trend Chart
              _buildSpendingTrendChart(monthlySpending),
              const SizedBox(height: 24),

              // Category Breakdown
              _buildCategoryBreakdown(categorySpending),
              const SizedBox(height: 24),

              // Quick Insights
              _buildQuickInsights(transactions, monthlySpending),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpendingTab() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final transactions = _getCreditCardTransactions(appProvider);
        final monthlySpending = _calculateMonthlySpending(transactions);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeRangeSelector(),
              const SizedBox(height: 24),
              _buildSpendingTrendChart(monthlySpending),
              const SizedBox(height: 24),
              _buildSpendingDetails(transactions, appProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final transactions = _getCreditCardTransactions(appProvider);
        final categorySpending = _calculateCategorySpending(
          transactions,
          appProvider,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeRangeSelector(),
              const SizedBox(height: 24),
              _buildCategoryBreakdown(categorySpending),
              const SizedBox(height: 24),
              _buildCategoryDetails(categorySpending),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightsTab() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final transactions = _getCreditCardTransactions(appProvider);
        final monthlySpending = _calculateMonthlySpending(transactions);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickInsights(transactions, monthlySpending),
              const SizedBox(height: 24),
              _buildDetailedInsights(transactions, monthlySpending),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['1M', '3M', '6M', '1Y'].map((range) {
          final isSelected = _selectedTimeRange == range;
          return GestureDetector(
            onTap: () => setState(() => _selectedTimeRange = range),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                range,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyMetricsCards(Map<String, double> monthlySpending) {
    final totalSpending = monthlySpending.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );
    final avgMonthlySpending = monthlySpending.isNotEmpty
        ? totalSpending / monthlySpending.length
        : 0.0;
    final utilization = widget.creditCard.creditLimit > 0
        ? (widget.creditCard.outstandingBalance /
                  widget.creditCard.creditLimit) *
              100
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Spending',
            Formatters.formatCurrency(totalSpending),
            Icons.trending_up,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Avg Monthly',
            Formatters.formatCurrency(avgMonthlySpending),
            Icons.calendar_month,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Utilization',
            '${utilization.toStringAsFixed(1)}%',
            Icons.pie_chart,
            utilization > 30 ? Colors.orange : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrendChart(Map<String, double> monthlySpending) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: _buildSimpleChart(monthlySpending)),
        ],
      ),
    );
  }

  Widget _buildSimpleChart(Map<String, double> data) {
    if (data.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'No spending data available',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    final maxValue = data.values.fold(
      0.0,
      (max, value) => value > max ? value : max,
    );
    final entries = data.entries.toList();

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          // Y-axis labels
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildYAxisLabels(maxValue),
              ),
            ),
          ),
          // Chart
          Positioned(
            left: 50,
            right: 0,
            top: 0,
            bottom: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: SimpleChartPainter(entries, maxValue),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildYAxisLabels(double maxValue) {
    final labels = <Widget>[];
    final steps = 5; // Number of Y-axis labels

    for (int i = 0; i <= steps; i++) {
      final value = (maxValue / steps) * (steps - i);
      final formattedValue = _formatYAxisValue(value);

      labels.add(
        SizedBox(
          height: 20,
          child: Center(
            child: Text(
              formattedValue,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return labels;
  }

  String _formatYAxisValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value >= 100) {
      return value.toStringAsFixed(0);
    } else {
      return value.toStringAsFixed(0);
    }
  }

  Widget _buildCategoryBreakdown(Map<String, double> categorySpending) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          if (categorySpending.isEmpty)
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No category data available',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            ...categorySpending.entries.map((entry) {
              final percentage =
                  categorySpending.values.fold(
                        0.0,
                        (sum, amount) => sum + amount,
                      ) >
                      0
                  ? (entry.value /
                            categorySpending.values.fold(
                              0.0,
                              (sum, amount) => sum + amount,
                            )) *
                        100
                  : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(entry.value),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildQuickInsights(
    List<Transaction> transactions,
    Map<String, double> monthlySpending,
  ) {
    final insights = _generateInsights(transactions, monthlySpending);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                'Smart Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map(
            (insight) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: insight.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: insight.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(insight.icon, color: insight.color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingDetails(
    List<Transaction> transactions,
    AppProvider appProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ...transactions.take(5).map((transaction) {
              final category = appProvider.categories
                  .where((cat) => cat.id == transaction.categoryId)
                  .firstOrNull;

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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.shopping_cart,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.description,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${category?.name ?? 'Unknown'} • ${Formatters.formatDate(transaction.date)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(transaction.amount.abs()),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCategoryDetails(Map<String, double> categorySpending) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          if (categorySpending.isEmpty)
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'No category data available',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ...categorySpending.entries.map((entry) {
              final percentage =
                  categorySpending.values.fold(
                        0.0,
                        (sum, amount) => sum + amount,
                      ) >
                      0
                  ? (entry.value /
                            categorySpending.values.fold(
                              0.0,
                              (sum, amount) => sum + amount,
                            )) *
                        100
                  : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          entry.key,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(entry.key),
                        color: _getCategoryColor(entry.key),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}% of total spending',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(entry.value),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDetailedInsights(
    List<Transaction> transactions,
    Map<String, double> monthlySpending,
  ) {
    final insights = _generateDetailedInsights(transactions, monthlySpending);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          ...insights.map(
            (insight) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: insight.color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: insight.color.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(insight.icon, color: insight.color, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          insight.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: insight.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    insight.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  if (insight.recommendation != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              insight.recommendation!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<Transaction> _getCreditCardTransactions(AppProvider appProvider) {
    final now = DateTime.now();
    final monthsToShow = _getMonthsToShow();
    final cutoffDate = DateTime(now.year, now.month - monthsToShow + 1, 1);

    return appProvider.transactions
        .where(
          (transaction) =>
              (transaction.accountId == widget.creditCard.id ||
                  transaction.toAccountId == widget.creditCard.id) &&
              transaction.date.isAfter(cutoffDate),
        )
        .toList();
  }

  Map<String, double> _calculateMonthlySpending(
    List<Transaction> transactions,
  ) {
    final Map<String, double> monthlySpending = {};
    final now = DateTime.now();
    final monthsToShow = _getMonthsToShow();

    // Initialize with zero values for the time range
    for (int i = 0; i < monthsToShow; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlySpending[monthKey] = 0.0;
    }

    // Add actual spending data
    for (final transaction in transactions) {
      if (transaction.type == 'expense') {
        final monthKey =
            '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
        if (monthlySpending.containsKey(monthKey)) {
          monthlySpending[monthKey] =
              (monthlySpending[monthKey] ?? 0) + transaction.amount.abs();
        }
      }
    }

    // Sort by date (oldest first)
    final sortedEntries = monthlySpending.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(sortedEntries);
  }

  int _getMonthsToShow() {
    switch (_selectedTimeRange) {
      case '1M':
        return 1;
      case '3M':
        return 3;
      case '6M':
        return 6;
      case '1Y':
        return 12;
      default:
        return 3;
    }
  }

  Map<String, double> _calculateCategorySpending(
    List<Transaction> transactions,
    AppProvider appProvider,
  ) {
    final Map<String, double> categorySpending = {};
    final now = DateTime.now();
    final monthsToShow = _getMonthsToShow();
    final cutoffDate = DateTime(now.year, now.month - monthsToShow + 1, 1);

    for (final transaction in transactions) {
      if (transaction.type == 'expense' &&
          transaction.date.isAfter(cutoffDate)) {
        final category = appProvider.categories
            .where((cat) => cat.id == transaction.categoryId)
            .firstOrNull;
        if (category != null) {
          categorySpending[category.name] =
              (categorySpending[category.name] ?? 0) + transaction.amount.abs();
        }
      }
    }

    // Sort by amount (highest first)
    final sortedEntries = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  List<Insight> _generateInsights(
    List<Transaction> transactions,
    Map<String, double> monthlySpending,
  ) {
    final insights = <Insight>[];

    if (transactions.isEmpty) {
      insights.add(
        Insight(
          message:
              'No spending data available yet. Start using your credit card to see insights!',
          icon: Icons.info_outline,
          color: Colors.blue,
        ),
      );
      return insights;
    }

    final utilization = widget.creditCard.creditLimit > 0
        ? (widget.creditCard.outstandingBalance /
                  widget.creditCard.creditLimit) *
              100
        : 0.0;

    // Utilization insight
    if (utilization > 30) {
      insights.add(
        Insight(
          message:
              'Your credit utilization is ${utilization.toStringAsFixed(1)}%, which is above the recommended 30%.',
          icon: Icons.warning,
          color: Colors.orange,
        ),
      );
    } else if (utilization > 0) {
      insights.add(
        Insight(
          message:
              'Great! Your credit utilization is ${utilization.toStringAsFixed(1)}%, which is within the recommended range.',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
      );
    }

    // Spending trend insight
    if (monthlySpending.length >= 2) {
      final recentMonths = monthlySpending.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key));

      if (recentMonths.length >= 2) {
        final currentMonth = recentMonths[0].value;
        final previousMonth = recentMonths[1].value;
        final change = ((currentMonth - previousMonth) / previousMonth) * 100;

        if (change > 20) {
          insights.add(
            Insight(
              message:
                  'Your spending increased by ${change.toStringAsFixed(1)}% compared to last month.',
              icon: Icons.trending_up,
              color: Colors.orange,
            ),
          );
        } else if (change < -20) {
          insights.add(
            Insight(
              message:
                  'Your spending decreased by ${change.abs().toStringAsFixed(1)}% compared to last month.',
              icon: Icons.trending_down,
              color: Colors.green,
            ),
          );
        }
      }
    }

    // Payment insight
    if (widget.creditCard.outstandingBalance > 0) {
      insights.add(
        Insight(
          message:
              'You have an outstanding balance of ${Formatters.formatCurrency(widget.creditCard.outstandingBalance)}.',
          icon: Icons.payment,
          color: Colors.blue,
        ),
      );
    }

    return insights;
  }

  List<DetailedInsight> _generateDetailedInsights(
    List<Transaction> transactions,
    Map<String, double> monthlySpending,
  ) {
    final insights = <DetailedInsight>[];

    if (transactions.isEmpty) {
      return insights;
    }

    final totalSpending = monthlySpending.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );
    final avgMonthlySpending = monthlySpending.isNotEmpty
        ? totalSpending / monthlySpending.length
        : 0.0;
    final utilization = widget.creditCard.creditLimit > 0
        ? (widget.creditCard.outstandingBalance /
                  widget.creditCard.creditLimit) *
              100
        : 0.0;

    // Credit Health Analysis
    insights.add(
      DetailedInsight(
        title: 'Credit Health Analysis',
        message:
            'Your current credit utilization is ${utilization.toStringAsFixed(1)}%. This affects your credit score and borrowing capacity.',
        icon: Icons.health_and_safety,
        color: utilization > 30 ? Colors.orange : Colors.green,
        recommendation: utilization > 30
            ? 'Consider paying down your balance to improve your credit utilization ratio.'
            : 'Keep up the good work! Your utilization is within the healthy range.',
      ),
    );

    // Spending Pattern Analysis
    if (monthlySpending.isNotEmpty) {
      insights.add(
        DetailedInsight(
          title: 'Spending Pattern Analysis',
          message:
              'Your average monthly spending is ${Formatters.formatCurrency(avgMonthlySpending)}. This helps you understand your spending habits and plan better.',
          icon: Icons.analytics,
          color: Colors.blue,
          recommendation:
              'Set a monthly budget based on your average spending to better control your expenses.',
        ),
      );
    }

    // Payment Behavior
    if (widget.creditCard.outstandingBalance > 0) {
      insights.add(
        DetailedInsight(
          title: 'Payment Behavior',
          message:
              'You currently have an outstanding balance. Making timely payments helps maintain a good credit score.',
          icon: Icons.payment,
          color: Colors.blue,
          recommendation:
              'Set up automatic payments to ensure you never miss a due date.',
        ),
      );
    }

    return insights;
  }

  Color _getCategoryColor(String categoryName) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    final index = categoryName.hashCode % colors.length;
    return colors[index.abs()];
  }

  IconData _getCategoryIcon(String categoryName) {
    final iconMap = {
      'Food': Icons.restaurant,
      'Transportation': Icons.directions_car,
      'Shopping': Icons.shopping_bag,
      'Entertainment': Icons.movie,
      'Bills': Icons.receipt,
      'Healthcare': Icons.medical_services,
      'Travel': Icons.flight,
      'Education': Icons.school,
    };

    return iconMap[categoryName] ?? Icons.category;
  }

  /// Export analytics data as PDF
  void _exportAnalyticsPDF() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generating PDF...'),
            ],
          ),
        ),
      );

      // Get analytics data
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final transactions = appProvider.transactions
          .where((transaction) => transaction.accountId == widget.creditCard.id)
          .toList();

      // Generate PDF
      final pdf = await _generateAnalyticsPDF(transactions);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Save PDF to file
      final success = await _savePDFToFile(pdf);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to export PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF export error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Generate PDF document with analytics data
  Future<pw.Document> _generateAnalyticsPDF(
    List<Transaction> transactions,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    // Calculate analytics data
    final totalSpent = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());

    final totalTransactions = transactions.length;
    final avgTransaction = totalTransactions > 0
        ? totalSpent / totalTransactions
        : 0.0;

    // Calculate spending by category
    final categorySpending = <String, double>{};
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    for (final transaction in transactions.where((t) => t.isExpense)) {
      final category = appProvider.categories
          .where((c) => c.id == transaction.categoryId)
          .firstOrNull;
      if (category != null) {
        categorySpending[category.name] =
            (categorySpending[category.name] ?? 0) + transaction.amount.abs();
      }
    }

    // Sort categories by spending amount
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${widget.creditCard.name} Analytics Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Generated on ${DateFormat('MMMM dd, yyyy').format(now)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue100,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      'Kora Expense Tracker',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 32),

            // Credit Card Information
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Credit Card Information',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Credit Limit:',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            '₹${widget.creditCard.creditLimit.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Outstanding Balance:',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            '₹${widget.creditCard.outstandingBalance.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red600,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Available Credit:',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            '₹${widget.creditCard.availableCredit.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Analytics Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Analytics Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Total Spent:',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            '₹${totalSpent.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Total Transactions:',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            '$totalTransactions',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Average Transaction:',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            '₹${avgTransaction.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  /// Save PDF to file
  Future<bool> _savePDFToFile(pw.Document pdf) async {
    try {
      // Create filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename =
          '${widget.creditCard.name.replaceAll(' ', '_')}_Analytics_$timestamp.pdf';

      // Get external storage directory (Downloads folder for easy access)
      Directory? directory;
      if (Platform.isAndroid) {
        // Use Downloads directory for easy access
        directory = Directory('/storage/emulated/0/Download');
        // Fallback to external storage directory if Downloads doesn't work
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Create KoraExpenseTracker subdirectory
      final koraDirectory = Directory('${directory.path}/KoraExpenseTracker');
      if (!await koraDirectory.exists()) {
        await koraDirectory.create(recursive: true);
      }

      // Create Analytics subdirectory
      final analyticsDirectory = Directory('${koraDirectory.path}/Analytics');
      if (!await analyticsDirectory.exists()) {
        await analyticsDirectory.create(recursive: true);
      }

      // Create the file
      final file = File('${analyticsDirectory.path}/$filename');
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);

      print('PDF exported to: ${file.path}');
      return true;
    } catch (e) {
      print('Error saving PDF file: $e');
      return false;
    }
  }
}

// Data classes for insights
class Insight {
  final String message;
  final IconData icon;
  final Color color;

  Insight({required this.message, required this.icon, required this.color});
}

class DetailedInsight {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final String? recommendation;

  DetailedInsight({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.recommendation,
  });
}

// Simple chart painter for spending trends
class SimpleChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> data;
  final double maxValue;

  SimpleChartPainter(this.data, this.maxValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxValue <= 0) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // Add some padding for better visual appearance
    final padding = 20.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    // Handle single data point
    if (data.length == 1) {
      final x = padding + chartWidth / 2;
      final y =
          padding + chartHeight - (data[0].value / maxValue) * chartHeight;

      path.moveTo(x, y);
      fillPath.moveTo(x, padding + chartHeight);
      fillPath.lineTo(x, y);
      fillPath.lineTo(padding + chartWidth, y);
      fillPath.lineTo(padding + chartWidth, padding + chartHeight);
      fillPath.close();

      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, paint);

      // Draw single point
      final pointPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 6, pointPaint);
      return;
    }

    final stepX = chartWidth / (data.length - 1);
    final stepY = chartHeight / maxValue;

    for (int i = 0; i < data.length; i++) {
      final x = padding + i * stepX;
      final y = padding + chartHeight - (data[i].value * stepY);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, padding + chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(padding + chartWidth, padding + chartHeight);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = padding + i * stepX;
      final y = padding + chartHeight - (data[i].value * stepY);
      canvas.drawCircle(Offset(x, y), 6, pointPaint);
    }

    // Draw month labels
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    for (int i = 0; i < data.length; i++) {
      final x = padding + i * stepX;
      final monthLabel = _formatMonthLabel(data[i].key);

      textPainter.text = TextSpan(
        text: monthLabel,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, padding + chartHeight + 5),
      );
    }
  }

  String _formatMonthLabel(String monthKey) {
    try {
      final parts = monthKey.split('-');
      if (parts.length == 2) {
        final month = int.parse(parts[1]);
        final monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return monthNames[month - 1];
      }
    } catch (e) {
      // Fallback to original key
    }
    return monthKey;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
