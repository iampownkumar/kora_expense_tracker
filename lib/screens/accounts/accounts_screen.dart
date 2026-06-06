import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/features/accounts/account_controller.dart';
import 'package:kora_expense_tracker/features/transactions/transaction_controller.dart';
import 'package:kora_expense_tracker/core/models/accounts/account.dart';
import 'package:kora_expense_tracker/core/models/accounts/account_type.dart';
import 'package:kora_expense_tracker/widgets/account_card.dart';
import 'package:kora_expense_tracker/widgets/financial_summary_card.dart';
import 'package:kora_expense_tracker/widgets/add_account_dialog.dart';
import 'account_transactions_screen.dart';
import 'package:kora_expense_tracker/core/constants/app_constants.dart';
import 'package:kora_expense_tracker/core/models/transactions/transaction.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen>
    with TickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Listen to scroll events for scroll-to-top button
    _scrollController.addListener(() {
      if (_scrollController.offset >= 200 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset < 200 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Check if we're on dashboard (index 0)
        // Navigation handled by AppShell

        // If already on dashboard, check for double back press
        final now = DateTime.now();
        if (_lastBackPress == null ||
            now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
          _lastBackPress = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Press back again to exit'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          return false; // Don't exit app
        }

        // Double back press - exit app
        return true;
      },
      child: Scaffold(
        body: Consumer<AccountController>(
          builder: (context, accCtrl, child) {
            final accCtrl = context.read<AccountController>();
            final accounts = _getFilteredAccounts(accCtrl.accounts);
            final accountCounts = _getAccountCounts(accCtrl.accounts);

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildSliverAppBar(context, accCtrl),

                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: FinancialSummaryCard(
                        totalAssets: accCtrl.totalAssets,
                        totalLiabilities: accCtrl.totalLiabilities,
                        netWorth: accCtrl.netWorth,
                        accountCounts: accountCounts,
                        onTap: () => _showFinancialDetails(context, accCtrl),
                      ),
                    ),
                  ),
                ),

                if (accounts.isEmpty)
                  _buildEmptyState(context, accCtrl)
                else
                  _buildAccountsList(accounts, accCtrl),
              ],
            );
          },
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            heroTag: "accounts_fab",
            onPressed: () => _showAddAccountDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Account'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        // Add scroll to top button
        bottomNavigationBar: _showScrollToTop
            ? Container(
                height: 60,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(Icons.keyboard_arrow_up),
                        label: const Text('Scroll to Top'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AccountController provider) {
    final theme = Theme.of(context);

    return SliverAppBar(
      floating: false,
      pinned: true,
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.brightness == Brightness.dark
                  ? [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.secondaryContainer,
                    ]
                  : [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
            ),
          ),
          child: SafeArea(
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Accounts',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => _showAddAccountDialog(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildEmptyState(BuildContext context, AccountController provider) {
    final theme = Theme.of(context);

    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No accounts yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first account to get started',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showAddAccountDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Account'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountsList(List<Account> accounts, AccountController provider) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final account = accounts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AccountCard(
              account: account,
              onTap: () => _navigateToAccountTransactions(context, account),
              onEdit: () => _showEditAccountDialog(context, account),
              onDelete: () =>
                  _showDeleteConfirmation(context, account, provider),
            ),
          );
        }, childCount: accounts.length),
      ),
    );
  }



  List<Account> _getFilteredAccounts(List<Account> accounts) {
    var filtered = List<Account>.from(accounts);
    // Sort by balance (highest first)
    filtered.sort((a, b) => b.balance.compareTo(a.balance));
    return filtered;
  }

  Map<AccountType, int> _getAccountCounts(List<Account> accounts) {
    final Map<AccountType, int> counts = {};
    for (final account in accounts) {
      counts[account.type] = (counts[account.type] ?? 0) + 1;
    }
    return counts;
  }

  void _showAddAccountDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => AddAccountDialog(
        onSave: (account) {
          context.read<AccountController>().addAccount(account);
        },
      ),
    );
  }

  void _showEditAccountDialog(BuildContext context, Account account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => AddAccountDialog(
        existingAccount: account,
        onSave: (updatedAccount) {
          final provider = context.read<AccountController>();

          if (account.balance != updatedAccount.balance) {
            final accountWithOldBalance = updatedAccount.copyWith(
              balance: account.balance,
            );
            provider.updateAccount(accountWithOldBalance);

            final difference = updatedAccount.balance - account.balance;
            final isIncome = difference > 0;

            final categoryId = isIncome
                ? (context.read<TransactionController>().incomeCategories.isNotEmpty
                      ? context.read<TransactionController>().incomeCategories.first.id
                      : 'income')
                : (context.read<TransactionController>().expenseCategories.isNotEmpty
                      ? context.read<TransactionController>().expenseCategories.first.id
                      : 'expense');

            final transaction = Transaction.create(
              type: isIncome
                  ? AppConstants.transactionTypeIncome
                  : AppConstants.transactionTypeExpense,
              amount: difference.abs(),
              description: 'Balance Adjustment',
              categoryId: categoryId,
              accountId: account.id,
              notes: 'Manual balance adjustment',
              date: DateTime.now(),
            );

            context.read<TransactionController>().addTransaction(transaction);
          } else {
            provider.updateAccount(updatedAccount);
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Account account,
    AccountController provider,
  ) {
    final isCreditCard = account.type == AccountType.creditCard;

    // Count transactions for this account
    final transactionCount = context.read<TransactionController>().transactions
        .where((t) => t.accountId == account.id || t.toAccountId == account.id)
        .length;

    // Capture the screen-level context BEFORE showing the dialog.
    // The dialog builder gets its own local context which becomes stale
    // after Navigator.pop(), causing subsequent showDialog calls to silently fail.
    final screenContext = context;

    showDialog(
      context: screenContext,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Delete ${account.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transactionCount > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This account has $transactionCount transaction${transactionCount == 1 ? '' : 's'}.',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Choose deletion option:',
              style: Theme.of(
                dialogCtx,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          if (transactionCount > 0) ...[
            TextButton(
              onPressed: () => _deleteAccountWithTransactions(
                screenContext,
                account,
                provider,
                isCreditCard,
              ),
              child: Text(
                'Delete Account Only',
                style: TextStyle(color: Colors.blue.shade600),
              ),
            ),
            TextButton(
              onPressed: () => _deleteAccountAndTransactions(
                screenContext,
                account,
                provider,
                isCreditCard,
                transactionCount,
              ),
              child: Text(
                'Delete Account + $transactionCount Transaction${transactionCount == 1 ? '' : 's'}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ] else ...[
            TextButton(
              onPressed: () => _deleteAccountWithTransactions(
                screenContext,
                account,
                provider,
                isCreditCard,
              ),
              child: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Delete account only (keep transactions but mark account as deleted)
  void _deleteAccountWithTransactions(
    BuildContext context,
    Account account,
    AccountController provider,
    bool isCreditCard,
  ) async {
    // Close the first (choice) dialog using its navigator before showing the next one.
    Navigator.of(context).pop();

    if (!context.mounted) return;

    // Show confirmation for account-only deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Account Only'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will delete the account but keep all transactions.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Transactions will remain in your history but will show "Unknown Account".',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _performAccountDeletion(
        context,
        account,
        provider,
        isCreditCard,
        false,
      );
    }
  }

  // Delete account and all its transactions
  void _deleteAccountAndTransactions(
    BuildContext context,
    Account account,
    AccountController provider,
    bool isCreditCard,
    int transactionCount,
  ) async {
    // Close the first (choice) dialog using its navigator before showing the next one.
    Navigator.of(context).pop();

    if (!context.mounted) return;

    // Show confirmation for account + transactions deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Account + Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete the account and all $transactionCount transaction${transactionCount == 1 ? '' : 's'}.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. All transaction history will be lost.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text(
              'Delete Everything',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _performAccountDeletion(
        context,
        account,
        provider,
        isCreditCard,
        true,
      );
    }
  }

  // Perform the actual deletion
  Future<void> _performAccountDeletion(
    BuildContext context,
    Account account,
    AccountController provider,
    bool isCreditCard,
    bool deleteTransactions,
  ) async {
    try {
      bool success = false;

      final txns = context.read<TransactionController>().transactions;
      if (deleteTransactions) {
        // Delete account with all transactions (handles credit card sync automatically)
        success = await provider.deleteAccountWithTransactions(account.id, txns);
      } else {
        // Delete account only (handles credit card sync automatically)
        success = await provider.deleteAccount(account.id, txns);
      }

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              deleteTransactions
                  ? '${account.name} and all transactions deleted successfully!'
                  : (isCreditCard
                        ? '${account.name} deleted successfully from both screens!'
                        : '${account.name} deleted successfully'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete ${account.name}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToAccountTransactions(BuildContext context, Account account) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccountTransactionsScreen(account: account),
      ),
    );
  }

  void _showFinancialDetails(BuildContext context, AccountController provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.analytics,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Financial Overview',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Detailed financial health analysis',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Financial details
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Financial Health Score
                      _buildHealthScoreCard(context, provider),
                      const SizedBox(height: 16),

                      // Main Financial Metrics
                      _buildFinancialDetailCard(
                        context,
                        'Total Assets',
                        provider.totalAssets,
                        Colors.green,
                        Icons.trending_up,
                        'Your total asset value',
                      ),
                      const SizedBox(height: 12),
                      _buildFinancialDetailCard(
                        context,
                        'Total Liabilities',
                        provider.totalLiabilities,
                        Colors.red,
                        Icons.trending_down,
                        'Your total debt and obligations',
                      ),
                      const SizedBox(height: 12),
                      _buildFinancialDetailCard(
                        context,
                        'Net Worth',
                        provider.netWorth,
                        provider.netWorth >= 0 ? Colors.green : Colors.red,
                        provider.netWorth >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        'Assets minus liabilities',
                      ),
                      const SizedBox(height: 16),

                      // Financial Insights
                      _buildInsightsCard(context, provider),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialDetailCard(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
    String description,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${amount.toStringAsFixed(0)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
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

  Widget _buildHealthScoreCard(BuildContext context, AccountController provider) {
    final theme = Theme.of(context);
    final healthScore = _calculateHealthScore(provider);
    final healthColor = _getHealthScoreColor(healthScore);
    final healthStatus = _getHealthScoreStatus(healthScore);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              healthColor.withValues(alpha: 0.1),
              healthColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: healthColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.health_and_safety,
                    color: healthColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial Health Score',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Based on your financial metrics',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      '$healthScore',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: healthColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Score',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                Column(
                  children: [
                    Text(
                      healthStatus,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: healthColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Status',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(BuildContext context, AccountController provider) {
    final theme = Theme.of(context);
    final insights = _generateInsights(provider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lightbulb,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Financial Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(insight['icon'], color: insight['color'], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight['text'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: insight['color'],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateHealthScore(AccountController provider) {
    // Simple health score calculation based on net worth and asset-to-liability ratio
    final netWorth = provider.netWorth;
    final assets = provider.totalAssets;
    final liabilities = provider.totalLiabilities;

    int score = 50; // Base score

    // Net worth factor
    if (netWorth > 100000) {
      score += 30;
    } else if (netWorth > 50000)
      score += 20;
    else if (netWorth > 0)
      score += 10;
    else if (netWorth > -50000)
      score -= 10;
    else
      score -= 20;

    // Asset-to-liability ratio
    if (liabilities > 0) {
      final ratio = assets / liabilities;
      if (ratio > 3) {
        score += 20;
      } else if (ratio > 2)
        score += 10;
      else if (ratio > 1)
        score += 5;
      else
        score -= 10;
    } else if (assets > 0) {
      score += 20; // No liabilities is great
    }

    return score.clamp(0, 100);
  }

  Color _getHealthScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.amber;
    return Colors.red;
  }

  String _getHealthScoreStatus(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  List<Map<String, dynamic>> _generateInsights(AccountController provider) {
    final insights = <Map<String, dynamic>>[];
    final netWorth = provider.netWorth;
    final assets = provider.totalAssets;
    final liabilities = provider.totalLiabilities;

    if (netWorth > 0) {
      insights.add({
        'icon': Icons.check_circle,
        'color': Colors.green,
        'text': 'Great! You have a positive net worth.',
      });
    } else {
      insights.add({
        'icon': Icons.warning,
        'color': Colors.orange,
        'text': 'Consider reducing liabilities to improve net worth.',
      });
    }

    if (liabilities > 0 && assets > 0) {
      final ratio = assets / liabilities;
      if (ratio > 2) {
        insights.add({
          'icon': Icons.trending_up,
          'color': Colors.green,
          'text':
              'Strong asset-to-liability ratio of ${ratio.toStringAsFixed(1)}:1.',
        });
      } else if (ratio < 1) {
        insights.add({
          'icon': Icons.trending_down,
          'color': Colors.red,
          'text': 'Liabilities exceed assets. Focus on debt reduction.',
        });
      }
    }

    if (provider.accounts.length > 3) {
      insights.add({
        'icon': Icons.account_balance,
        'color': Colors.blue,
        'text':
            'Good diversification with ${provider.accounts.length} accounts.',
      });
    }

    if (insights.isEmpty) {
      insights.add({
        'icon': Icons.info,
        'color': Colors.blue,
        'text': 'Add more accounts to get detailed insights.',
      });
    }

    return insights;
  }
}
