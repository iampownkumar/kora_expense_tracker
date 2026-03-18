import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../providers/credit_card_provider.dart';
import '../providers/app_provider.dart';
import '../models/credit_card.dart';
import '../models/credit_card_statement.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';
import 'payment_screen.dart';
import 'statement_analytics_screen.dart';
import 'credit_card_analytics_screen.dart';
import 'edit_credit_card_screen.dart';
import '../widgets/transaction_detail_sheet.dart';
import '../widgets/add_transaction_dialog.dart';

/// Credit Card Detail Screen - Comprehensive view of a single credit card
class CreditCardDetailScreen extends StatefulWidget {
  final CreditCard creditCard;

  const CreditCardDetailScreen({
    super.key,
    required this.creditCard,
  });

  @override
  State<CreditCardDetailScreen> createState() => _CreditCardDetailScreenState();
}

class _CreditCardDetailScreenState extends State<CreditCardDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CreditCard _currentCard;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentCard = widget.creditCard;
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
        title: Text(_currentCard.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Card'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Card', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Transactions'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Statements'),
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionsTab(),
          _buildStatementsTab(),
          _buildOverviewTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Visual
          _buildCardVisual(),
          const SizedBox(height: 24),
          
          // Key Metrics
          _buildKeyMetrics(),
          const SizedBox(height: 24),
          
          // Bill & Due Date Status (Enhanced)
          _buildBillDueDateStatus(),
          const SizedBox(height: 24),
          
          // Billing Information
          _buildBillingInformation(),
          const SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 24),
          
          // Recent Activity
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatementsTab() {
    return Consumer<CreditCardProvider>(
      builder: (context, provider, child) {
        final allStatements = provider.getStatementsForCard(_currentCard.id);
        final generatedStatements = allStatements.where((stmt) => stmt.status == StatementStatus.generated).toList();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Statement Overview
              _buildCurrentStatementOverview(),
              const SizedBox(height: 24),
              
              // Statement History (Only Generated Statements)
              if (generatedStatements.isNotEmpty) ...[
                _buildStatementHistoryList(generatedStatements),
                const SizedBox(height: 24),
              ] else ...[
                _buildStatementHistory(),
                const SizedBox(height: 24),
              ],
              
              // Past Statements (Paid)
              _buildPastStatementsSection(),
            ],
          ),
        );
      },
    );
  }


  Widget _buildAnalyticsTab() {
    return Consumer<CreditCardProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Analytics Overview
              _buildQuickAnalyticsOverview(),
              const SizedBox(height: 24),
              
              // View Detailed Analytics Button
              _buildViewDetailedAnalyticsButton(),
              const SizedBox(height: 24),
              
              // Utilization Chart
              _buildUtilizationChart(),
              const SizedBox(height: 24),
              
              // Payment History
              _buildPaymentHistory(),
              const SizedBox(height: 24),
              
              // Spending Summary
              _buildSpendingSummary(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardVisual() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_currentCard.color, _currentCard.color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _currentCard.color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _currentCard.icon,
                  color: Colors.white,
                  size: 32,
                ),
                const Spacer(),
                Text(
                  _currentCard.network,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              _currentCard.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentCard.maskedCardNumber,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Expires ${_currentCard.formattedExpiryDate}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Credit Limit',
                _currentCard.getFormattedCreditLimit(),
                Icons.account_balance,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                _currentCard.balanceLabel,
                _currentCard.getFormattedUserBalance(),
                Icons.money_off,
                _currentCard.userBalanceColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Available',
                _currentCard.getFormattedAvailableCredit(),
                Icons.account_balance_wallet,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Utilization',
                _currentCard.userFriendlyUtilization,
                Icons.trending_up,
                _currentCard.utilizationColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBillingInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _buildBillingInfoRow(
                'Billing Cycle Day',
                '${_currentCard.billingCycleDay}th of each month',
                Icons.calendar_today,
              ),
              const Divider(),
              _buildBillingInfoRow(
                'Next Billing Date',
                _currentCard.nextBillingDate != null
                    ? Formatters.formatDate(_currentCard.nextBillingDate!)
                    : 'Not set',
                Icons.receipt_long,
              ),
              const Divider(),
              _buildBillingInfoRow(
                'Next Due Date',
                _currentCard.nextDueDate != null
                    ? Formatters.formatDate(_currentCard.nextDueDate!)
                    : 'Not set',
                Icons.payment,
                isUrgent: _currentCard.isDueSoon || _currentCard.isOverdue,
              ),
              const Divider(),
              _buildBillingInfoRow(
                'Grace Period',
                '${_currentCard.gracePeriodDays} days',
                Icons.schedule,
              ),
              const Divider(),
              _buildBillingInfoRow(
                'Interest Rate',
                '${_currentCard.interestRate}% APR',
                Icons.percent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showPaymentDialog(),
                icon: const Icon(Icons.payment),
                label: const Text('Pay Full Due Balance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _generateStatement(),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Generate Statement'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showTransactionHistory(),
                icon: const Icon(Icons.analytics),
                label: const Text('Analytics'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showTransactionHistory(),
                icon: const Icon(Icons.history),
                label: const Text('Transactions'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Get transactions for this credit card
        final creditCardTransactions = appProvider.transactions
            .where((transaction) => transaction.accountId == _currentCard.id)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date, newest first
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (creditCardTransactions.isNotEmpty)
                  TextButton(
                    onPressed: () => _showTransactionHistory(),
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (creditCardTransactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: const Text(
                  'No transactions found for this credit card.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...creditCardTransactions.take(5).map((transaction) => 
                _buildTransactionItem(transaction)
              ),
          ],
        );
      },
    );
  }



  Widget _buildPaymentCard(payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPaymentStatusColor(payment.status),
          child: Icon(
            _getPaymentStatusIcon(payment.status),
            color: Colors.white,
          ),
        ),
        title: Text(payment.paymentTypeDescription),
        subtitle: Text('${payment.formattedPaymentDate} - ${payment.getFormattedAmount()}'),
        trailing: Text(
          payment.status,
          style: TextStyle(
            color: _getPaymentStatusColor(payment.status),
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => _showPaymentDetails(payment),
      ),
    );
  }

  Widget _buildUtilizationChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Credit Utilization',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _currentCard.utilizationPercentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(_currentCard.utilizationColor),
          ),
          const SizedBox(height: 8),
          Text(
            '${_currentCard.userFriendlyUtilization} ${_currentCard.outstandingBalance < 0 ? 'credit available' : 'utilized'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _currentCard.utilizationColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment History',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Payment history analytics will be displayed here.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Spending summary and trends will be displayed here.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAnalyticsOverview() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final transactions = appProvider.transactions
            .where((transaction) => transaction.accountId == _currentCard.id)
            .toList();
        
        final monthlySpending = _calculateMonthlySpending(transactions);
        final totalSpending = monthlySpending.values.fold(0.0, (sum, amount) => sum + amount);
        final avgMonthlySpending = monthlySpending.isNotEmpty ? totalSpending / monthlySpending.length : 0.0;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
                Theme.of(context).primaryColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Analytics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickMetric(
                      'Total Spending',
                      Formatters.formatCurrency(totalSpending),
                      Icons.trending_up,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickMetric(
                      'Avg Monthly',
                      Formatters.formatCurrency(avgMonthlySpending),
                      Icons.calendar_month,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailedAnalyticsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToDetailedAnalytics(),
        icon: const Icon(Icons.analytics),
        label: const Text('View Detailed Analytics'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Map<String, double> _calculateMonthlySpending(List<Transaction> transactions) {
    final Map<String, double> monthlySpending = {};
    
    for (final transaction in transactions) {
      if (transaction.type == 'expense') {
        final monthKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
        monthlySpending[monthKey] = (monthlySpending[monthKey] ?? 0) + transaction.amount.abs();
      }
    }
    
    return monthlySpending;
  }

  void _navigateToDetailedAnalytics() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreditCardAnalyticsScreen(
          creditCard: _currentCard,
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (_tabController.index == 0) {
      // Transactions tab - Add Transaction
      return FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      );
    } else if (_tabController.index == 1) {
      // Statements tab - Generate Statement
      return FloatingActionButton(
        onPressed: _generateStatement,
        tooltip: 'Generate Statement',
        child: const Icon(Icons.add),
      );
    } else if (_tabController.index == 2) {
      // Overview tab - Add Transaction
      return FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBillingInfoRow(String label, String value, IconData icon, {bool isUrgent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isUrgent ? Colors.red : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isUrgent ? Colors.red : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods

  Color _getStatementStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'partial':
        return Colors.orange;
      case 'due soon':
        return Colors.yellow;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatementStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'overdue':
        return Icons.error;
      case 'partial':
        return Icons.pending;
      case 'due soon':
        return Icons.warning;
      default:
        return Icons.receipt_long;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  IconData _getPaymentStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.error;
      case 'refunded':
        return Icons.refresh;
      default:
        return Icons.payment;
    }
  }

  // Action Methods

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editCard();
        break;
      case 'delete':
        _deleteCard();
        break;
    }
  }

  void _editCard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditCreditCardScreen(creditCard: _currentCard),
      ),
    ).then((updatedCard) {
      if (updatedCard != null && updatedCard is CreditCard) {
        setState(() {
          _currentCard = updatedCard;
        });
      }
    });
  }

  void _deleteCard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Credit Card'),
        content: Text('Are you sure you want to delete ${_currentCard.name}? This action cannot be undone.\n\nThis will remove the credit card from both the Credit Cards screen and Accounts screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Delete from CreditCardProvider
              final creditCardProvider = context.read<CreditCardProvider>();
              final creditCardSuccess = await creditCardProvider.deleteCreditCard(_currentCard.id);
              
              // CRITICAL: Also delete from AppProvider (Accounts screen)
              final appProvider = context.read<AppProvider>();
              final accountSuccess = await appProvider.deleteAccount(_currentCard.id);
              
              if (creditCardSuccess && accountSuccess && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Credit card deleted successfully from both screens!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Credit card deletion had issues. Credit Card: $creditCardSuccess, Account: $accountSuccess'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          creditCard: _currentCard,
          suggestedAmount: _currentCard.outstandingBalance, // Always suggest full amount for better financial wellness
        ),
      ),
    );
    
    // If payment was successful, refresh the screen
    if (result == true) {
      // Force UI rebuild to show updated state
      setState(() {
        // This will trigger a rebuild with fresh data
      });
    }
  }

  void _generateStatement() {
    final provider = context.read<CreditCardProvider>();
    final statements = provider.getStatementsForCard(_currentCard.id);
    
    // Check if statement already exists for current period
    final now = DateTime.now();
    final billingDay = _currentCard.billingCycleDay;
    DateTime periodStart;
    
    if (now.day >= billingDay) {
      periodStart = DateTime(now.year, now.month, billingDay);
    } else {
      periodStart = DateTime(now.year, now.month - 1, billingDay);
    }
    
    final existingStatement = statements.any((stmt) => 
        stmt.periodStart.year == periodStart.year && 
        stmt.periodStart.month == periodStart.month &&
        stmt.periodStart.day == periodStart.day);
    
    if (existingStatement) {
      // Show message that statement already exists
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Statement already generated for this billing period!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    // Show generation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Statement'),
        content: const Text(
          'This will generate a statement for the current billing period. '
          'The statement will include all transactions from the last billing cycle.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performStatementGeneration();
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _performStatementGeneration() async {
    final provider = context.read<CreditCardProvider>();
    final statement = await provider.generateStatement(_currentCard.id);
    
    if (statement != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statement ${statement.statementNumber} generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate statement. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCardDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_currentCard.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Network: ${_currentCard.network}'),
            Text('Type: ${_currentCard.type}'),
            Text('Last 4 Digits: ${_currentCard.lastFourDigits}'),
            Text('Expiry: ${_currentCard.formattedExpiryDate}'),
            if (_currentCard.bankName != null) Text('Bank: ${_currentCard.bankName}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final theme = Theme.of(context);
    final isIncome = transaction.isIncome;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Transaction icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isIncome ? Colors.green : Colors.red).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.formatDate(transaction.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          
          // Amount
          Text(
            '${isIncome ? '+' : '-'}${Formatters.formatCurrency(transaction.amount.abs())}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionHistory() {
    // Navigate to the Transactions tab within this credit card detail screen
    _tabController.animateTo(0); // Transactions tab index (now first tab)
  }

  void _handleStatementAction(statement) {
    if (statement.status == StatementStatus.generated) {
      // Navigate to payment screen for generated statements
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            creditCard: _currentCard,
            suggestedAmount: statement.newBalance, // Suggest full amount instead of minimum
          ),
        ),
      );
    } else {
      // Show details for other statuses
      _showStatementDetails(statement);
    }
  }

  /// Show past statement details
  void _showPastStatementDetails(statement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Statement #${statement.statementNumber} Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatementDetailRow('Period', statement.periodDisplay),
              _buildStatementDetailRow('Total Paid', statement.getFormattedTotalDue()),
              _buildStatementDetailRow('Paid Date', Formatters.formatDate(statement.paidDate ?? statement.updatedAt)),
              _buildStatementDetailRow('Status', 'Paid'),
              _buildStatementDetailRow('Generated', Formatters.formatDate(statement.generatedDate)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show statement analytics page
  void _showStatementAnalytics(statement) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatementAnalyticsScreen(
          statement: statement,
          creditCard: _currentCard,
        ),
      ),
    );
  }

  /// Delete past statement (simplified)
  void _deletePastStatement(statement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Statement'),
        content: Text(
          'Are you sure you want to delete Statement #${statement.statementNumber}?\n\nThis will remove the statement record but keep the payment applied to your credit card balance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteStatementOnly(statement);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Delete statement only (keep payment applied)
  void _deleteStatementOnly(statement) async {
    final creditCardProvider = Provider.of<CreditCardProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    final success = await creditCardProvider.deleteStatement(statement.id, appProvider: appProvider);
    
    // Close loading indicator
    if (mounted) Navigator.of(context).pop();
    
    if (success && mounted) {
      // Force UI rebuild to show updated state
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statement #${statement.statementNumber} deleted. Payment remains applied to your balance.'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }


  /// Show past statement transactions
  void _showPastStatementTransactions(statement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Statement #${statement.statementNumber} Transactions'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              // Statement Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Paid:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      statement.getFormattedTotalDue(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Transactions List (Placeholder for now)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Transaction Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Detailed transaction breakdown will be shown here.\nThis includes all purchases, payments, and fees for this statement period.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStatementDetails(statement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Statement #${statement.statementNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatementDetailRow('Period', statement.periodDisplay),
              _buildStatementDetailRow('Total Due', statement.getFormattedTotalDue()),
              _buildStatementDetailRow('Due Date', Formatters.formatDate(statement.paymentDueDate)),
              _buildStatementDetailRow('Status', statement.paymentStatus),
              _buildStatementDetailRow('Generated', Formatters.formatDate(statement.generatedDate)),
              if (statement.paidAmount > 0)
                _buildStatementDetailRow('Paid Amount', Formatters.formatCurrency(statement.paidAmount)),
              if (statement.paidDate != null)
                _buildStatementDetailRow('Paid Date', Formatters.formatDate(statement.paidDate!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatementDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _confirmDeleteStatement(statement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Statement'),
        content: Text(
          'Are you sure you want to delete Statement #${statement.statementNumber}? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteStatement(statement);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStatement(statement) async {
    final creditCardProvider = context.read<CreditCardProvider>();
    final appProvider = context.read<AppProvider>();
    final success = await creditCardProvider.deleteStatement(statement.id, appProvider: appProvider);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Statement and related payments deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(creditCardProvider.error ?? 'Failed to delete statement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPaymentDetails(payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Amount', Formatters.formatCurrency(payment.amount)),
            _buildDetailRow('Date', Formatters.formatDate(payment.paymentDate)),
            _buildDetailRow('Method', payment.paymentMethod),
            if (payment.sourceAccountId != null)
              _buildDetailRow('Source Account', payment.sourceAccountId!),
            if (payment.notes != null && payment.notes!.isNotEmpty)
              _buildDetailRow('Notes', payment.notes!),
            _buildDetailRow('Status', payment.status.toString().split('.').last),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // ENHANCED STATEMENTS & PAYMENTS METHODS
  // ========================================

  /// Build current statement overview
  Widget _buildCurrentStatementOverview() {
    return Consumer<CreditCardProvider>(
      builder: (context, provider, child) {
        final hasCurrentStatement = provider.hasStatementForCurrentMonth(_currentCard.id);
        final currentStatement = provider.getCurrentMonthStatement(_currentCard.id);
        
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Statement',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
                  const Spacer(),
                  // Statement Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hasCurrentStatement ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hasCurrentStatement ? 'Generated' : 'Not Generated',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Statement Period
          _buildStatementInfoRow(
            'Statement Period',
            _getCurrentStatementPeriod(),
            Icons.calendar_today,
          ),
          const SizedBox(height: 12),
              
              // Statement Status
              if (hasCurrentStatement && currentStatement != null) ...[
                _buildStatementInfoRow(
                  'Statement Number',
                  currentStatement.statementNumber,
                  Icons.receipt,
                ),
                const SizedBox(height: 12),
                _buildStatementInfoRow(
                  'Generated Date',
                  Formatters.formatDate(currentStatement.generatedDate),
                  Icons.schedule,
                ),
                const SizedBox(height: 12),
              ],
          
          // Outstanding Balance
          _buildStatementInfoRow(
            'Outstanding Balance',
            _currentCard.getFormattedUserBalance(),
            Icons.account_balance_wallet,
            valueColor: _currentCard.userBalanceColor,
          ),
          const SizedBox(height: 12),
          
              // Removed minimum payment display to encourage full payment
          
          // Due Date
          _buildStatementInfoRow(
            'Due Date',
            _currentCard.nextDueDate != null 
                ? Formatters.formatDate(_currentCard.nextDueDate!)
                : 'Not set',
            Icons.schedule,
            valueColor: _getDueDateColor(_currentCard),
            isUrgent: _currentCard.isDueSoon || _currentCard.isOverdue,
          ),
        ],
      ),
        );
      },
    );
  }

  /// Build statement history section
  Widget _buildStatementHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statement History header with Generate Statement button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Statement History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
            ),
            ElevatedButton.icon(
              onPressed: _generateStatement,
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('Generate Statement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'Statement History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Previous statements will be displayed here once generated.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build past statements section (paid statements)
  Widget _buildPastStatementsSection() {
    return Consumer<CreditCardProvider>(
      builder: (context, provider, child) {
        final pastStatements = provider.getStatementsForCard(_currentCard.id)
            .where((stmt) => stmt.status == StatementStatus.paid)
            .toList();
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              'Past Statements (Paid)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
            if (pastStatements.isEmpty) ...[
              // Show empty state message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No Past Statements',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Paid statements will appear here once you make payments.\nThis helps you track your spending history for each billing cycle.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Show past statements
              ...pastStatements.map((statement) => _buildPastStatementCard(statement)),
            ],
          ],
        );
      },
    );
  }

    /// Build individual past statement card
  Widget _buildPastStatementCard(statement) {
    return GestureDetector(
      onTap: () => _showStatementAnalytics(statement),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statement #${statement.statementNumber}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    statement.periodDisplay,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Paid: ${Formatters.formatDate(statement.paidDate ?? statement.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  statement.getFormattedTotalDue(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  'Paid',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // Small delete button
            GestureDetector(
              onTap: () => _deletePastStatement(statement),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade600,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build statement history list
  Widget _buildStatementHistoryList(List statements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statement History header with Generate Statement button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
              'Statement History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
            ElevatedButton.icon(
                onPressed: _generateStatement,
              icon: const Icon(Icons.receipt_long, size: 18),
                label: const Text('Generate Statement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...statements.map((statement) => _buildStatementCard(statement)),
      ],
    );
  }

  /// Build individual statement card
  Widget _buildStatementCard(statement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statement.paymentStatusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: statement.paymentStatusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
                      'Statement #${statement.statementNumber}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
                    Text(
                      statement.periodDisplay,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
                    'Due: ${Formatters.formatDate(statement.paymentDueDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statement.paymentStatusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    statement.paymentStatus,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statement.paymentStatusColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
          ],
        ),
            ],
          ),
          const SizedBox(height: 12),
          // Full Balance - Prominently displayed (RED for generated statements)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.red.shade300,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.red.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Full Balance: ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
                Text(
                  statement.getFormattedTotalDue(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleStatementAction(statement),
                  icon: Icon(
                    statement.status == StatementStatus.generated ? Icons.payment : Icons.visibility, 
                    size: 16
                  ),
                  label: Text(statement.status == StatementStatus.generated ? 'Pay Full Due Balance' : 'View Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: statement.status == StatementStatus.generated ? Colors.green : null,
                    side: statement.status == StatementStatus.generated 
                        ? const BorderSide(color: Colors.green)
                        : null,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
        Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDeleteStatement(statement),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
        ),
      ],
      ),
    );
  }

  /// Build statement detail item
  Widget _buildStatementDetail(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
            child: Column(
              children: [
          Icon(icon, size: 16, color: Theme.of(context).primaryColor),
          const SizedBox(height: 4),
                Text(
            value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
                  ),
            textAlign: TextAlign.center,
                ),
                Text(
            label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }


  // REMOVED: Payment tab functionality - methods removed to simplify the app

  // Helper methods that are still needed
  Widget _buildStatementInfoRow(String label, String value, IconData icon, {Color? valueColor, bool isUrgent = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
          Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.grey[800],
            ),
          ),
        ],
    );
  }

  String _getCurrentStatementPeriod() {
    final now = DateTime.now();
    final billingDay = _currentCard.billingCycleDay;
    
    DateTime periodStart;
    if (now.day < billingDay) {
      periodStart = DateTime(now.year, now.month - 1, billingDay);
    } else {
      periodStart = DateTime(now.year, now.month, billingDay);
    }
    
    final periodEnd = DateTime(periodStart.year, periodStart.month + 1, billingDay).subtract(const Duration(days: 1));
    
    return '${Formatters.formatDate(periodStart)} - ${Formatters.formatDate(periodEnd)}';
  }

  Color _getDueDateColor(CreditCard card) {
    if (card.isOverdue) return Colors.red;
    if (card.isDueSoon) return Colors.orange;
    return Colors.green;
  }

  /// Build enhanced bill and due date status section
  Widget _buildBillDueDateStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getDueDateColor(_currentCard).withValues(alpha: 0.1),
            _getDueDateColor(_currentCard).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getDueDateColor(_currentCard).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getDueDateIcon(_currentCard),
                color: _getDueDateColor(_currentCard),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Payment Status',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getDueDateColor(_currentCard),
                ),
              ),
              const Spacer(),
              if (_currentCard.isDueSoon || _currentCard.isOverdue)
                ElevatedButton(
                  onPressed: () => _showPaymentDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48BB78),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Pay Now'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Status Overview
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  'Bill Date',
                  _currentCard.nextBillingDate != null 
                      ? Formatters.formatDate(_currentCard.nextBillingDate!)
                      : 'Not set',
                  _getDaysUntilBill(_currentCard),
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  'Due Date',
                  _currentCard.nextDueDate != null 
                      ? Formatters.formatDate(_currentCard.nextDueDate!)
                      : 'Not set',
                  _currentCard.daysUntilDue,
                  Icons.payment,
                  _getDueDateColor(_currentCard),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Payment Status Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getPaymentStatusIcon(_currentCard.isOverdue ? 'overdue' : _currentCard.isDueSoon ? 'due_soon' : 'current'),
                  color: _getDueDateColor(_currentCard),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getPaymentStatusSummary(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getDueDateColor(_currentCard),
                      fontWeight: FontWeight.w500,
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

  /// Build status card for bill/due date info
  Widget _buildStatusCard(String label, String date, int? daysRemaining, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (daysRemaining != null) ...[
            const SizedBox(height: 2),
            Text(
              daysRemaining == 0 ? 'Today' : 
              daysRemaining < 0 ? '${daysRemaining.abs()} days ago' :
              '$daysRemaining days left',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: daysRemaining <= 0 ? Colors.red : 
                       daysRemaining <= 7 ? Colors.orange : Colors.green,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Get days until next bill date
  int? _getDaysUntilBill(CreditCard card) {
    if (card.nextBillingDate == null) return null;
    final days = card.nextBillingDate!.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  /// Get due date icon
  IconData _getDueDateIcon(CreditCard card) {
    if (card.isOverdue) return Icons.error;
    if (card.isDueSoon) return Icons.warning;
    return Icons.check_circle;
  }

  /// Get payment status icon


  /// Get payment status summary
  String _getPaymentStatusSummary() {
    if (_currentCard.isOverdue) {
      return 'Payment is overdue. Please make payment immediately to avoid late fees.';
    } else if (_currentCard.isDueSoon) {
      return 'Payment is due soon. Consider making payment to avoid late fees.';
    } else {
      return 'Payment is on time. No action needed at this time.';
    }
  }

  // ========================================
  // USER-FRIENDLY FUNCTION IMPLEMENTATIONS
  // ========================================

  void _showExportOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Statement'),
        content: const Text(
          'Choose how you would like to export your statement:',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportAsPDF();
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportAsCSV();
            },
            child: const Text('CSV'),
          ),
        ],
      ),
    );
  }

  void _exportAsPDF() {
    // Simulate PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statement exported as PDF successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportAsCSV() {
    // Simulate CSV export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statement exported as CSV successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAutoPaySetup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Auto-Pay'),
        content: const Text(
          'Auto-pay will automatically pay your credit card bill on the due date. '
          'You can choose to pay the minimum amount, full balance, or a custom amount.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _setupAutoPay();
            },
            child: const Text('Setup'),
          ),
        ],
      ),
    );
  }

  void _setupAutoPay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Auto-Pay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Auto-pay will automatically pay your credit card bill 4 days before the due date.',
            ),
            const SizedBox(height: 16),
            // Financial wellness message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '💡 Paying the full balance helps avoid interest charges',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose payment amount:'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmAutoPaySetup(true),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Full Balance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmAutoPaySetup(false),
                    icon: const Icon(Icons.warning_amber, size: 18),
                    label: const Text('Minimum Only'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmAutoPaySetup(bool payFullBalance) async {
    Navigator.of(context).pop(); // Close dialog
    
    final creditCardProvider = context.read<CreditCardProvider>();
    final appProvider = context.read<AppProvider>();
    
    // Get the first available account for payment
    final accounts = appProvider.accounts;
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No accounts available for auto-pay. Please add an account first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final paymentAccount = accounts.first;
    final amount = payFullBalance ? _currentCard.outstandingBalance : _currentCard.minimumPaymentAmount;
    
    final success = await creditCardProvider.setupAutoPay(
      _currentCard.id,
      amount: amount,
      paymentAccountId: paymentAccount.id,
      payFullBalance: payFullBalance,
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Auto-pay setup completed! Will pay ${Formatters.formatCurrency(amount)} 4 days before due date.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(creditCardProvider.error ?? 'Failed to setup auto-pay'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPaymentHistoryExport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Payment History'),
        content: const Text(
          'Export your payment history for record keeping or tax purposes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportPaymentHistory();
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _exportPaymentHistory() {
    // Simulate payment history export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment history exported successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ========================================
  // TRANSACTIONS TAB
  // ========================================

  Widget _buildTransactionsTab() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Get all transactions for this credit card
        final creditCardTransactions = appProvider.transactions
            .where((transaction) => 
                transaction.accountId == _currentCard.id ||
                transaction.description.toLowerCase().contains(_currentCard.name.toLowerCase()))
            .toList();

        // Sort by date (newest first)
        creditCardTransactions.sort((a, b) => b.date.compareTo(a.date));

        return Column(
          children: [
            // Header with transaction count
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Credit Card Transactions',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${creditCardTransactions.length} transactions found',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (creditCardTransactions.isNotEmpty) ...[
                        ElevatedButton.icon(
                          onPressed: _showDetailedAnalytics,
                          icon: const Icon(Icons.analytics, size: 18),
                          label: const Text('Analytics'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _showAnalyticsExportOptions,
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Export'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade50,
                            foregroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Transaction list
            Expanded(
              child: creditCardTransactions.isEmpty
                  ? _buildEmptyTransactionsState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: creditCardTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = creditCardTransactions[index];
                        return _buildTransactionCard(transaction);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyTransactionsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your credit card transactions will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddTransactionDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isExpense = transaction.type == 'expense';
    final amountColor = isExpense ? Colors.red : Colors.green;
    final amountPrefix = isExpense ? '-' : '+';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpense 
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.green.withValues(alpha: 0.1),
          child: Icon(
            isExpense ? Icons.arrow_upward : Icons.arrow_downward,
            color: amountColor,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Formatters.formatDate(transaction.date)),
            Text(
              transaction.type.toUpperCase(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$amountPrefix${Formatters.formatCurrency(transaction.amount)}',
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (transaction.accountId == _currentCard.id)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Credit Card',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    final appProvider = context.read<AppProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailSheet(
        transaction: transaction,
        appProvider: appProvider,
      ),
    );
  }

  void _showAddTransactionDialog() {
    final appProvider = context.read<AppProvider>();
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        appProvider: appProvider,
        defaultAccountId: _currentCard.id, // Pre-select this credit card
      ),
    ).then((result) {
      // Only show success message if transaction was actually added
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction added to ${_currentCard.name} successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _showDetailedAnalytics() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreditCardAnalyticsScreen(creditCard: _currentCard),
      ),
    );
  }

  /// Show analytics export options popup
  void _showAnalyticsExportOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Credit Card Data'),
        content: const Text('Choose the format you want to export your credit card analytics:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _exportToJSON();
            },
            icon: const Icon(Icons.code, size: 18),
            label: const Text('JSON'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _exportToPDF();
            },
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Export credit card data to JSON
  void _exportToJSON() async {
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
              Text('Exporting to JSON...'),
            ],
          ),
        ),
      );

      // Get analytics data
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final transactions = appProvider.transactions
          .where((transaction) => transaction.accountId == _currentCard.id)
          .toList();

      // Create export data
      final exportData = _createExportData(transactions);

      // Export to file
      final success = await _saveAnalyticsToFile(exportData, 'json');

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ JSON exported successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to export JSON'),
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
            content: Text('❌ Export error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Export credit card data to PDF
  void _exportToPDF() async {
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
          .where((transaction) => transaction.accountId == _currentCard.id)
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
            content: Text('✅ PDF exported successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to export PDF'),
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
            content: Text('❌ PDF export error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Create export data structure
  Map<String, dynamic> _createExportData(List<Transaction> transactions) {
    final now = DateTime.now();
    final totalSpent = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    
    final totalTransactions = transactions.length;
    final avgTransaction = totalTransactions > 0 ? totalSpent / totalTransactions : 0.0;

    // Calculate spending by category
    final categorySpending = <String, double>{};
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    for (final transaction in transactions.where((t) => t.isExpense)) {
      final category = appProvider.categories
          .where((c) => c.id == transaction.categoryId)
          .firstOrNull;
      if (category != null) {
        categorySpending[category.name] = (categorySpending[category.name] ?? 0) + transaction.amount.abs();
      }
    }

    return {
      'creditCard': {
        'name': _currentCard.name,
        'creditLimit': _currentCard.creditLimit,
        'outstandingBalance': _currentCard.outstandingBalance,
        'availableCredit': _currentCard.availableCredit,
      },
      'analytics': {
        'exportDate': now.toIso8601String(),
        'totalSpent': totalSpent,
        'totalTransactions': totalTransactions,
        'averageTransaction': avgTransaction,
        'categorySpending': categorySpending,
      },
      'transactions': transactions.map((t) => {
        'date': t.date.toIso8601String(),
        'description': t.description,
        'amount': t.amount,
        'type': t.type,
        'category': appProvider.categories
            .where((c) => c.id == t.categoryId)
            .firstOrNull?.name ?? 'Unknown',
      }).toList(),
    };
  }

  /// Save analytics data to file
  Future<bool> _saveAnalyticsToFile(Map<String, dynamic> data, String format) async {
    try {
      // Create filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${_currentCard.name.replaceAll(' ', '_')}_Analytics_$timestamp.$format';
      
      // Convert data to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      
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
      await file.writeAsString(jsonString);
      
      print('Analytics exported to: ${file.path}');
      return true;
    } catch (e) {
      print('Error saving analytics file: $e');
      return false;
    }
  }

  /// Generate PDF document with analytics data
  Future<pw.Document> _generateAnalyticsPDF(List<Transaction> transactions) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    
    // Calculate analytics data
    final totalSpent = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    
    final totalTransactions = transactions.length;
    final avgTransaction = totalTransactions > 0 ? totalSpent / totalTransactions : 0.0;

    // Calculate spending by category
    final categorySpending = <String, double>{};
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    for (final transaction in transactions.where((t) => t.isExpense)) {
      final category = appProvider.categories
          .where((c) => c.id == transaction.categoryId)
          .firstOrNull;
      if (category != null) {
        categorySpending[category.name] = (categorySpending[category.name] ?? 0) + transaction.amount.abs();
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
                        '${_currentCard.name} Analytics Report',
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
                          pw.Text('Credit Limit:', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('₹${_currentCard.creditLimit.toStringAsFixed(2)}', 
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Outstanding Balance:', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('₹${_currentCard.outstandingBalance.toStringAsFixed(2)}', 
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.red600)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Available Credit:', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('₹${_currentCard.availableCredit.toStringAsFixed(2)}', 
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green600)),
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
                          pw.Text('Total Spent:', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('₹${totalSpent.toStringAsFixed(2)}', 
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Total Transactions:', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('$totalTransactions', 
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Average Transaction:', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('₹${avgTransaction.toStringAsFixed(2)}', 
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
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
      final filename = '${_currentCard.name.replaceAll(' ', '_')}_Analytics_$timestamp.pdf';
      
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
