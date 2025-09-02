import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/utils/formatters.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/widgets/add_transaction_dialog.dart';
import 'package:kora_expense_tracker/widgets/transaction_list_item.dart';
import 'package:kora_expense_tracker/models/category.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/models/account_type.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  int _lastSelectedTabIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _resetScrollPosition() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Check if user returned to dashboard from another tab
        if (appProvider.selectedTabIndex == 0 && _lastSelectedTabIndex != 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _resetScrollPosition();
          });
        }
        _lastSelectedTabIndex = appProvider.selectedTabIndex;
        
        return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
                  onRefresh: () async {
          await appProvider.refresh();
        },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Summary Card with Greeting
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () {
                      // Navigate to accounts tab in bottom navigation
                      appProvider.setSelectedTab(2); // Accounts tab is at index 2
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total Balance',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    size: 32,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.6),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          Text(
                            Formatters.formatCurrency(appProvider.totalBalance),
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: AppConstants.smallPadding),
                          // Net Worth Row
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 16,
                                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Net Worth: ',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                Formatters.formatCurrency(appProvider.netWorth),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          Row(
                            children: [
                              Expanded(
                                child: _buildBalanceItem(
                                  context,
                                  'Income',
                                  Formatters.formatCurrency(appProvider.totalIncome),
                                  AppConstants.successColor,
                                  Icons.arrow_upward,
                                ),
                              ),
                              const SizedBox(width: AppConstants.defaultPadding),
                              Expanded(
                                child: _buildBalanceItem(
                                  context,
                                  'Expenses',
                                  Formatters.formatCurrency(appProvider.totalExpenses),
                                  AppConstants.errorColor,
                                  Icons.arrow_downward,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.largePadding),
                
                // Recent Transactions Section
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                
                // Recent Transactions or Empty State
                if (appProvider.recentTransactions.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                color: AppConstants.primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: AppConstants.smallPadding),
                              Text(
                                'Recent Transactions',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          SizedBox(
                            height: 300,
                            child: ListView.builder(
                              itemCount: appProvider.recentTransactions.length,
                              itemBuilder: (context, index) {
                                final transaction = appProvider.recentTransactions[index];
                                final category = appProvider.categories.firstWhere(
                                  (c) => c.id == transaction.categoryId,
                                  orElse: () => Category.create(
                                    name: 'Unknown',
                                    icon: Icons.category,
                                    color: AppConstants.primaryColor,
                                    type: AppConstants.categoryTypeExpense,
                                  ),
                                );
                                final account = appProvider.accounts.firstWhere(
                                  (a) => a.id == transaction.accountId,
                                  orElse: () => Account.create(
                                    name: 'Unknown Account',
                                    icon: Icons.account_balance,
                                    color: AppConstants.primaryColor,
                                    type: AccountType.savings,
                                  ),
                                );
                                final toAccount = transaction.toAccountId != null
                                    ? appProvider.accounts.firstWhere(
                                        (a) => a.id == transaction.toAccountId,
                                        orElse: () => Account.create(
                                          name: 'Unknown Account',
                                          icon: Icons.account_balance,
                                          color: AppConstants.primaryColor,
                                          type: AccountType.savings,
                                        ),
                                      )
                                    : null;

                                return TransactionListItem(
                                  transaction: transaction,
                                  category: category,
                                  account: account,
                                  toAccount: toAccount,
                                  enableSwipeToDelete: true, // Enable swipe-to-delete for dashboard
                                  onTap: () {
                                    // Show transaction details or edit dialog
                                    showDialog(
                                      context: context,
                                      builder: (context) => AddTransactionDialog(
                                        appProvider: appProvider,
                                        transaction: transaction,
                                      ),
                                    );
                                  },
                                  onEdit: () {
                                    // Show edit transaction dialog
                                    showDialog(
                                      context: context,
                                      builder: (context) => AddTransactionDialog(
                                        appProvider: appProvider,
                                        transaction: transaction,
                                      ),
                                    );
                                  },
                                  onDelete: () async {
                                    await appProvider.deleteTransaction(transaction.id);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.largePadding),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          Text(
                            'No transactions yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppConstants.smallPadding),
                          Text(
                            'Add your first transaction to get started',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddTransactionDialog(appProvider: appProvider),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Transaction'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: AppConstants.largePadding),
                
                // Quick Stats Section
                Text(
                  'Quick Stats',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.defaultPadding),
                          child: Column(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: AppConstants.successColor,
                                size: 32,
                              ),
                              const SizedBox(height: AppConstants.smallPadding),
                              Text(
                                '${appProvider.accounts.length}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Accounts',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.defaultPadding),
                          child: Column(
                            children: [
                              Icon(
                                Icons.category,
                                color: AppConstants.infoColor,
                                size: 32,
                              ),
                              const SizedBox(height: AppConstants.smallPadding),
                              Text(
                                '${appProvider.categories.length}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Categories',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: "dashboard_fab",
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddTransactionDialog(appProvider: appProvider),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 32,
              weight: 100,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildBalanceItem(
    BuildContext context,
    String label,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning, Pown';
    } else if (hour < 17) {
      return 'Good Afternoon, Pown';
    } else {
      return 'Good Evening, Pown';
    }
  }
}
