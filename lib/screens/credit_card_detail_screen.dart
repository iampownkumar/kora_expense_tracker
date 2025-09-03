import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/credit_card_provider.dart';
import '../providers/app_provider.dart';
import '../models/credit_card.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';
import 'payment_screen.dart';
import 'credit_card_analytics_screen.dart';
import 'edit_credit_card_screen.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Statements'),
            Tab(icon: Icon(Icons.payment), text: 'Payments'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildStatementsTab(),
          _buildPaymentsTab(),
          _buildAnalyticsTab(),
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
        final statements = provider.getStatementsForCard(_currentCard.id);
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Statement Overview
              _buildCurrentStatementOverview(),
              const SizedBox(height: 24),
              
              // Statement History
              if (statements.isNotEmpty) ...[
                _buildStatementHistoryList(statements),
                const SizedBox(height: 24),
              ] else ...[
                _buildStatementHistory(),
                const SizedBox(height: 24),
              ],
              
              // Generate Statement Section
              _buildGenerateStatementSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Get payment transactions for this credit card
        final paymentTransactions = appProvider.transactions
            .where((transaction) => 
                transaction.type == 'transfer' && 
                transaction.toAccountId == _currentCard.id)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date, newest first
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Overview
              _buildPaymentOverview(),
              const SizedBox(height: 24),
              
              // Quick Payment Actions
              _buildQuickPaymentActions(),
              const SizedBox(height: 24),
              
              // Payment History
              _buildPaymentHistorySection(paymentTransactions),
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
                label: const Text('Make Payment'),
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
                onPressed: () => _showCardDetails(),
                icon: const Icon(Icons.info),
                label: const Text('Card Details'),
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
              ).toList(),
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
    if (_tabController.index == 1) {
      // Statements tab
      return FloatingActionButton(
        onPressed: _generateStatement,
        child: const Icon(Icons.add),
      );
    } else if (_tabController.index == 2) {
      // Payments tab
      return FloatingActionButton(
        onPressed: _showPaymentDialog,
        child: const Icon(Icons.payment),
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

  void _showPaymentDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          creditCard: _currentCard,
          suggestedAmount: _currentCard.isDueSoon || _currentCard.isOverdue 
              ? _currentCard.minimumPaymentAmount 
              : null,
        ),
      ),
    );
  }

  void _generateStatement() {
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
    // Navigate to transactions screen with filter for this credit card
    Navigator.of(context).pushNamed('/transactions', arguments: {
      'filter': 'account',
      'accountId': _currentCard.id,
    });
  }

  void _showStatementDetails(statement) {
    // TODO: Implement statement details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Statement details coming soon!')),
    );
  }

  void _showPaymentDetails(payment) {
    // TODO: Implement payment details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment details coming soon!')),
    );
  }

  // ========================================
  // ENHANCED STATEMENTS & PAYMENTS METHODS
  // ========================================

  /// Build current statement overview
  Widget _buildCurrentStatementOverview() {
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
          
          // Outstanding Balance
          _buildStatementInfoRow(
            'Outstanding Balance',
            _currentCard.getFormattedUserBalance(),
            Icons.account_balance_wallet,
            valueColor: _currentCard.userBalanceColor,
          ),
          const SizedBox(height: 12),
          
          // Minimum Payment
          _buildStatementInfoRow(
            'Minimum Payment',
            Formatters.formatCurrency(_currentCard.minimumPaymentAmount),
            Icons.payment,
            valueColor: Colors.orange,
          ),
          const SizedBox(height: 12),
          
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
  }

  /// Build statement history section
  Widget _buildStatementHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statement History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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

  /// Build statement history list
  Widget _buildStatementHistoryList(List statements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statement History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...statements.map((statement) => _buildStatementCard(statement)).toList(),
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
                    statement.getFormattedTotalDue(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statement.paymentStatusColor,
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
          Row(
            children: [
              Expanded(
                child: _buildStatementDetail(
                  'Minimum Payment',
                  statement.getFormattedMinimumPayment(),
                  Icons.payment,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatementDetail(
                  'Due Date',
                  Formatters.formatDate(statement.paymentDueDate),
                  Icons.schedule,
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

  /// Build generate statement section
  Widget _buildGenerateStatementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statement Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _generateStatement,
                icon: const Icon(Icons.receipt_long),
                label: const Text('Generate Statement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _showExportOptions();
                },
                icon: const Icon(Icons.download),
                label: const Text('Export PDF'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build payment overview
  Widget _buildPaymentOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.1),
            Colors.green.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payment,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Payment Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Outstanding Balance
          _buildPaymentInfoRow(
            'Outstanding Balance',
            _currentCard.getFormattedUserBalance(),
            Icons.account_balance_wallet,
            valueColor: _currentCard.userBalanceColor,
          ),
          const SizedBox(height: 12),
          
          // Minimum Payment
          _buildPaymentInfoRow(
            'Minimum Payment Due',
            Formatters.formatCurrency(_currentCard.minimumPaymentAmount),
            Icons.payment,
            valueColor: Colors.orange,
          ),
          const SizedBox(height: 12),
          
          // Due Date Status
          _buildPaymentInfoRow(
            'Payment Status',
            _getPaymentStatusText(),
            Icons.schedule,
            valueColor: _getDueDateColor(_currentCard),
            isUrgent: _currentCard.isDueSoon || _currentCard.isOverdue,
          ),
        ],
      ),
    );
  }

  /// Build quick payment actions
  Widget _buildQuickPaymentActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Payment Actions',
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
                label: const Text('Make Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showPaymentDialog(),
                icon: const Icon(Icons.schedule),
                label: const Text('Schedule Payment'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _showAutoPaySetup();
                },
                icon: const Icon(Icons.autorenew),
                label: const Text('Setup Auto-Pay'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _showPaymentHistoryExport();
                },
                icon: const Icon(Icons.download),
                label: const Text('Export History'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build payment history section
  Widget _buildPaymentHistorySection(List<Transaction> paymentTransactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (paymentTransactions.isNotEmpty)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Full payment history coming soon!')),
                  );
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (paymentTransactions.isEmpty)
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
                  Icons.payment,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'No Payment History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No payments have been made to this credit card yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...paymentTransactions.take(5).map((transaction) => 
            _buildPaymentTransactionItem(transaction)
          ).toList(),
      ],
    );
  }

  // Helper Methods for Enhanced Sections

  Widget _buildStatementInfoRow(String label, String value, IconData icon, {Color? valueColor, bool isUrgent = false}) {
    return Row(
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
                  color: valueColor ?? (isUrgent ? Colors.red : Theme.of(context).colorScheme.onSurface),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfoRow(String label, String value, IconData icon, {Color? valueColor, bool isUrgent = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isUrgent ? Colors.red : Colors.green,
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
                  color: valueColor ?? (isUrgent ? Colors.red : Theme.of(context).colorScheme.onSurface),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTransactionItem(Transaction transaction) {
    final sourceAccount = context.read<AppProvider>().getAccountForTransaction(transaction.accountId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Payment icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.payment,
              color: Colors.green,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          
          // Payment details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment from ${sourceAccount?.name ?? 'Unknown Account'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.formatDate(transaction.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          
          // Amount
          Text(
            '+${Formatters.formatCurrency(transaction.amount.abs())}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentStatementPeriod() {
    final now = DateTime.now();
    final billingDay = _currentCard.billingCycleDay;
    
    // Calculate current statement period
    DateTime periodStart;
    DateTime periodEnd;
    
    if (now.day < billingDay) {
      // Current period started last month
      periodStart = DateTime(now.year, now.month - 1, billingDay);
      periodEnd = DateTime(now.year, now.month, billingDay - 1);
    } else {
      // Current period started this month
      periodStart = DateTime(now.year, now.month, billingDay);
      periodEnd = DateTime(now.year, now.month + 1, billingDay - 1);
    }
    
    return '${Formatters.formatDate(periodStart)} - ${Formatters.formatDate(periodEnd)}';
  }

  String _getPaymentStatusText() {
    if (_currentCard.isOverdue) return 'Overdue';
    if (_currentCard.isDueSoon) return 'Due Soon';
    return 'On Time';
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
    // Simulate auto-pay setup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Auto-pay setup completed! Your payments will be automatic.'),
        backgroundColor: Colors.green,
      ),
    );
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
}
