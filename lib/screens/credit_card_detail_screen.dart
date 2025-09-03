import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/credit_card_provider.dart';
import '../providers/app_provider.dart';
import '../models/credit_card.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

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
        
        if (statements.isEmpty) {
          return _buildEmptyState(
            icon: Icons.receipt_long,
            title: 'No Statements',
            subtitle: 'No billing statements found for this card',
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: statements.length,
          itemBuilder: (context, index) {
            final statement = statements[index];
            return _buildStatementCard(statement);
          },
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    return Consumer<CreditCardProvider>(
      builder: (context, provider, child) {
        final payments = provider.getPaymentsForCard(_currentCard.id);
        
        if (payments.isEmpty) {
          return _buildEmptyState(
            icon: Icons.payment,
            title: 'No Payments',
            subtitle: 'No payment history found for this card',
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            return _buildPaymentCard(payment);
          },
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

  Widget _buildStatementCard(statement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatementStatusColor(statement.status),
          child: Icon(
            _getStatementStatusIcon(statement.status),
            color: Colors.white,
          ),
        ),
        title: Text('Statement #${statement.statementNumber}'),
        subtitle: Text('${statement.periodDisplay} - ${statement.getFormattedTotalDue()}'),
        trailing: Text(
          statement.paymentStatus,
          style: TextStyle(
            color: _getStatementStatusColor(statement.status),
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => _showStatementDetails(statement),
      ),
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
    // TODO: Implement edit card functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit card functionality coming soon!')),
    );
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
    // TODO: Implement payment dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment functionality coming soon!')),
    );
  }

  void _generateStatement() {
    // TODO: Implement statement generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Statement generation coming soon!')),
    );
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
    // TODO: Implement transaction history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction history coming soon!')),
    );
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
}
