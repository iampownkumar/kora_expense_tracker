import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/credit_card_provider.dart';
import '../models/credit_card.dart';
import '../utils/formatters.dart';
import '../constants/app_constants.dart';
import 'payment_screen.dart';
import 'credit_card_detail_screen.dart';
import 'add_credit_card_screen.dart';

/// Main Credit Cards Screen - Comprehensive credit card management dashboard
class CreditCardsScreen extends StatefulWidget {
  const CreditCardsScreen({super.key});

  @override
  State<CreditCardsScreen> createState() => _CreditCardsScreenState();
}

class _CreditCardsScreenState extends State<CreditCardsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Active',
    'High Utilization',
    'Due Soon',
    'Overdue',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize credit card provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreditCardProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Cards'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => _filterOptions.map((option) => 
              PopupMenuItem(
                value: option,
                child: Text(option),
              ),
            ).toList(),
          ),
        ],
      ),
      body: Consumer<CreditCardProvider>(
        builder: (context, creditCardProvider, child) {
          if (creditCardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (creditCardProvider.error != null) {
            return _buildErrorState(context, creditCardProvider.error!);
          }

          final filteredCards = _getFilteredCards(creditCardProvider.creditCards);

          return RefreshIndicator(
            onRefresh: () => creditCardProvider.refresh(),
            child: CustomScrollView(
              slivers: [
                // Beta Warning Banner
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                        // const SizedBox(width: 5),
                        const Expanded(
                          child: Text(
                            'Credit cards feature is under development (Beta).',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Credit Overview Card
                _buildCreditOverviewCard(context, creditCardProvider),
                
                // Quick Stats
                _buildQuickStats(context, creditCardProvider),
                
                // Filter Chips
                _buildFilterChips(context),
                
                // Credit Cards List
                if (filteredCards.isEmpty)
                  _buildEmptyState(context)
                else
                  _buildCreditCardsList(context, filteredCards),
                
                // Bottom padding
                if (filteredCards.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 180),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: FloatingActionButton(
          onPressed: () => _navigateToAddCreditCard(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  /// Build credit overview card with key metrics
  Widget _buildCreditOverviewCard(BuildContext context, CreditCardProvider provider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1E3A8A), // Darker blue for better contrast
              const Color(0xFF1E40AF), // Slightly lighter blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E40AF).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.credit_card,
                  size: 28,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  'Credit Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewStat(
                    context,
                    'Total Limit',
                    Formatters.formatCurrency(provider.totalCreditLimit),
                    Icons.account_balance,
                    color: const Color(0xFF60A5FA), // Bright blue for better visibility
                  ),
                ),
                Expanded(
                  child: _buildOverviewStat(
                    context,
                    provider.totalOutstandingBalance < 0 ? 'Available Credit' : 'Outstanding',
                    Formatters.formatCurrency(provider.totalOutstandingBalance.abs()),
                    Icons.account_balance_wallet,
                    color: provider.totalOutstandingBalance <= 0 ? const Color(0xFF34D399) : const Color(0xFFF87171), // Bright green/red
                  ),
                ),
                Expanded(
                  child: _buildOverviewStat(
                    context,
                    'Available',
                    Formatters.formatCurrency(provider.totalAvailableCredit),
                    Icons.account_balance_wallet,
                    color: const Color(0xFF34D399), // Bright green
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getUtilizationColor(provider.overallUtilization).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getUtilizationColor(provider.overallUtilization),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: _getUtilizationColor(provider.overallUtilization),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Utilization',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          '${(provider.overallUtilization.abs() * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: _getUtilizationColor(provider.overallUtilization.abs()),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          provider.overallUtilization < 0 ? 'Credit Available' : provider.overallUtilizationStatus,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick stats row
  Widget _buildQuickStats(BuildContext context, CreditCardProvider provider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildQuickStatCard(
                context,
                'Active Cards',
                '${provider.activeCreditCards.length}',
                Icons.credit_card,
                const Color(0xFF3182CE),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStatCard(
                context,
                'Due Soon',
                '${provider.dueSoonCards.length}',
                Icons.schedule,
                const Color(0xFFDD6B20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStatCard(
                context,
                'Overdue',
                '${provider.overdueCards.length}',
                Icons.warning,
                const Color(0xFFE53E3E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filterOptions.map((option) {
              final isSelected = _selectedFilter == option;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? option : 'All';
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Credit Cards',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first credit card to start tracking',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 1),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddCreditCard(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Credit Card'),
            ),
          ]
        ),
      ),
    );
  }

  /// Build credit cards list
  Widget _buildCreditCardsList(BuildContext context, List<CreditCard> cards) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final card = cards[index];
          return _buildCreditCardItem(context, card);
        },
        childCount: cards.length,
      ),
    );
  }

  /// Build individual credit card item
  Widget _buildCreditCardItem(BuildContext context, CreditCard card) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToCreditCardDetail(context, card),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: card.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        card.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            card.maskedCardNumber,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(context, card.utilizationStatus),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Card Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildCardStat(
                        context,
                        'Credit Limit',
                        card.getFormattedCreditLimit(),
                        Icons.account_balance,
                        color: AppConstants.creditLimitColor,
                      ),
                    ),
                    Expanded(
                      child: _buildCardStat(
                        context,
                        card.balanceLabel,
                        card.getFormattedUserBalance(),
                        Icons.account_balance_wallet,
                        color: card.userBalanceColor,
                      ),
                    ),
                    Expanded(
                      child: _buildCardStat(
                        context,
                        'Available',
                        card.getFormattedAvailableCredit(),
                        Icons.account_balance_wallet,
                        color: AppConstants.availableColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Utilization Bar
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: card.utilizationPercentage.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          card.utilizationColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      card.userFriendlyUtilization,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: card.utilizationColor,
                      ),
                    ),
                  ],
                ),
                
                // Bill & Due Date Info
                const SizedBox(height: 16),
                _buildBillDueDateInfo(context, card),
                
                // Statement Status
                const SizedBox(height: 12),
                _buildStatementStatus(context, card),
                
                // Quick Actions
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToCreditCardDetail(context, card),
                        icon: const Icon(Icons.receipt_long, size: 16),
                        label: const Text('Statements'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showQuickPaymentDialog(context, card),
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text('Pay'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods

  List<CreditCard> _getFilteredCards(List<CreditCard> cards) {
    switch (_selectedFilter) {
      case 'Active':
        return cards.where((card) => card.isActive && card.outstandingBalance > 0).toList();
      case 'High Utilization':
        return cards.where((card) => card.utilizationPercentage >= 0.8).toList();
      case 'Due Soon':
        return cards.where((card) => card.isDueSoon).toList();
      case 'Overdue':
        return cards.where((card) => card.isOverdue).toList();
      default:
        return cards;
    }
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error loading credit cards'),
          const SizedBox(height: 8),
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<CreditCardProvider>().refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(BuildContext context, String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCardStat(BuildContext context, String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color chipColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'critical':
        chipColor = const Color(0xFFE53E3E);
        textColor = Colors.white;
        break;
      case 'warning':
        chipColor = const Color(0xFFDD6B20);
        textColor = Colors.white;
        break;
      case 'high':
        chipColor = const Color(0xFFD69E2E);
        textColor = Colors.white;
        break;
      case 'moderate':
        chipColor = const Color(0xFFF6AD55);
        textColor = const Color(0xFF2D3748);
        break;
      case 'elevated':
        chipColor = const Color(0xFF68D391);
        textColor = const Color(0xFF2D3748);
        break;
      default:
        chipColor = const Color(0xFF48BB78);
        textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getUtilizationColor(double utilization) {
    if (utilization >= 0.9) return const Color(0xFFE53E3E); // Critical Red
    if (utilization >= 0.8) return const Color(0xFFDD6B20); // Warning Orange
    if (utilization >= 0.7) return const Color(0xFFD69E2E); // High Amber
    if (utilization >= 0.5) return const Color(0xFFF6AD55); // Moderate Yellow
    if (utilization >= 0.3) return const Color(0xFF68D391); // Elevated Green
    return const Color(0xFF48BB78); // Good Green
  }

  Color _getDueDateColor(CreditCard card) {
    if (card.isOverdue) return const Color(0xFFE53E3E); // Critical Red
    if (card.isDueSoon) return const Color(0xFFDD6B20); // Warning Orange
    return const Color(0xFF48BB78); // Good Green
  }

  IconData _getDueDateIcon(CreditCard card) {
    if (card.isOverdue) return Icons.error;
    if (card.isDueSoon) return Icons.warning;
    return Icons.check_circle;
  }

  String _getDueDateText(CreditCard card) {
    if (card.isOverdue) return 'Payment overdue';
    if (card.isDueSoon) return 'Due in ${card.daysUntilDue} days';
    return 'Due in ${card.daysUntilDue} days';
  }

  /// Build comprehensive bill and due date information
  Widget _buildBillDueDateInfo(BuildContext context, CreditCard card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getDueDateColor(card).withValues(alpha: 0.1),
            _getDueDateColor(card).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getDueDateColor(card).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Header with status
          Row(
            children: [
              Icon(
                _getDueDateIcon(card),
                size: 20,
                color: _getDueDateColor(card),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getDueDateStatusText(card),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _getDueDateColor(card),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (card.isDueSoon || card.isOverdue)
                ElevatedButton(
                  onPressed: () => _showQuickPaymentDialog(context, card),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48BB78),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Pay Now', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Bill and Due Date Details
          Row(
            children: [
              // Bill Date Info
              Expanded(
                child: _buildDateInfo(
                  context,
                  'Bill Date',
                  card.nextBillingDate != null 
                      ? Formatters.formatDate(card.nextBillingDate!)
                      : 'Not set',
                  _getDaysUntilBill(card),
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              
              // Due Date Info
              Expanded(
                child: _buildDateInfo(
                  context,
                  'Due Date',
                  card.nextDueDate != null 
                      ? Formatters.formatDate(card.nextDueDate!)
                      : 'Not set',
                  card.daysUntilDue,
                  Icons.payment,
                  _getDueDateColor(card),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual date information widget
  Widget _buildDateInfo(BuildContext context, String label, String date, int? daysRemaining, IconData icon, Color color) {
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

  /// Get due date status text
  String _getDueDateStatusText(CreditCard card) {
    if (card.isOverdue) return 'Payment Overdue';
    if (card.isDueSoon) return 'Due Soon';
    return 'Payment Due';
  }

  /// Build statement status indicator
  Widget _buildStatementStatus(BuildContext context, CreditCard card) {
    return Consumer<CreditCardProvider>(
      builder: (context, provider, child) {
        final hasCurrentStatement = provider.hasStatementForCurrentMonth(card.id);
        final currentStatement = provider.getCurrentMonthStatement(card.id);
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasCurrentStatement 
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasCurrentStatement 
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.orange.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasCurrentStatement ? Icons.receipt_long : Icons.receipt_long_outlined,
                color: hasCurrentStatement ? Colors.green : Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statement Status',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      hasCurrentStatement 
                          ? 'Generated for ${_getCurrentMonthName()}'
                          : 'Not generated for ${_getCurrentMonthName()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: hasCurrentStatement ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hasCurrentStatement && currentStatement != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Statement #${currentStatement.statementNumber}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Get current month name
  String _getCurrentMonthName() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[now.month - 1];
  }

  // Navigation Methods

  void _navigateToAddCreditCard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddCreditCardScreen(),
      ),
    );
  }

  void _navigateToCreditCardDetail(BuildContext context, CreditCard card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreditCardDetailScreen(creditCard: card),
      ),
    );
  }

  void _showQuickPaymentDialog(BuildContext context, CreditCard card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          creditCard: card,
          suggestedAmount: card.isDueSoon || card.isOverdue ? card.minimumPaymentAmount : null,
        ),
      ),
    );
  }
}
