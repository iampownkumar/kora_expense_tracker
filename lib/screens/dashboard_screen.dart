import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/core/constants/app_constants.dart';
import 'package:kora_expense_tracker/core/utils/formatters.dart';
import 'package:kora_expense_tracker/features/transactions/transaction_controller.dart';
import 'package:kora_expense_tracker/features/accounts/account_controller.dart';
import 'package:kora_expense_tracker/widgets/add_transaction_dialog.dart';
import 'package:kora_expense_tracker/widgets/transaction_list_item.dart';
import 'package:kora_expense_tracker/core/models/category.dart';
import 'package:kora_expense_tracker/core/models/account.dart';
import 'package:kora_expense_tracker/screens/categories_screen.dart';

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
    return Consumer2<TransactionController, AccountController>(
      builder: (context, txnCtrl, accCtrl, child) {
        // Tab index no longer tracked via legacy provider

        final sh = MediaQuery.of(context).size.height;
        // Aggressive compact scaling: small=0.65, medium=0.80, large=1.0
        final p = AppConstants.responsivePadding(sh, 12.0);
        final sp = AppConstants.responsivePadding(sh, 6.0);
        final lp = AppConstants.responsivePadding(sh, 14.0);
        final walletIconSize = AppConstants.responsiveIconSize(sh, 24.0);

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 46,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.wallet, size: 24),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Kora'),
              ],
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await txnCtrl.refresh();
                await accCtrl.refresh();
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.all(p),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Balance Summary Card ──────────────────────────────
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {},  // Tab navigation handled by AppShell
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.all(p),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getGreeting(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      Text(
                                        'Total Balance',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer
                                                  .withValues(alpha: 0.8),
                                            ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet,
                                        size: walletIconSize,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                            .withValues(alpha: 0.8),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                            .withValues(alpha: 0.6),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: sp),
                              Text(
                                Formatters.formatCurrency(
                                    accCtrl.totalBalance),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                              ),
                              SizedBox(height: sp / 2),
                              // Net Worth row
                              Row(
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    size: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Net Worth: ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                              .withValues(alpha: 0.8),
                                        ),
                                  ),
                                  Text(
                                    Formatters.formatCurrency(
                                        accCtrl.netWorth),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: sp),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildBalanceItem(
                                      context,
                                      'Income',
                                      Formatters.formatCurrency(
                                          txnCtrl.totalIncome),
                                      AppConstants.successColor,
                                      Icons.arrow_upward,
                                    ),
                                  ),
                                  SizedBox(width: sp),
                                  Expanded(
                                    child: _buildBalanceItem(
                                      context,
                                      'Expenses',
                                      Formatters.formatCurrency(
                                          txnCtrl.totalExpenses),
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

                    SizedBox(height: lp),

                    // ── Recent Transactions ───────────────────────────────
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: sp),

                    if (txnCtrl.recentTransactions.isNotEmpty) ...[
                      Card(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: p,
                            vertical: sp,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: txnCtrl.recentTransactions.length
                                .clamp(0, 4),
                            itemBuilder: (context, index) {
                              final transaction =
                                  txnCtrl.recentTransactions[index];
                              final category = txnCtrl.categories
                                  .firstWhere(
                                    (c) => c.id == transaction.categoryId,
                                    orElse: () => Category.create(
                                      name: 'Unknown',
                                      icon: Icons.category,
                                      color: AppConstants.primaryColor,
                                      type: AppConstants.categoryTypeExpense,
                                    ),
                                  );
                              final account = accCtrl.findById(transaction.accountId);
                              Account? toAccount;
                              if (transaction.toAccountId != null) {
                                toAccount = accCtrl.findById(transaction.toAccountId!);
                              }
                              return TransactionListItem(
                                transaction: transaction,
                                category: category,
                                account: account,
                                toAccount: toAccount,
                                compact: true,
                                enableSwipeToDelete: true,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AddTransactionDialog(
                                      transaction: transaction,
                                    ),
                                  );
                                },
                                onEdit: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AddTransactionDialog(
                                      transaction: transaction,
                                    ),
                                  );
                                },
                                onDelete: () async {
                                  await txnCtrl
                                      .deleteTransaction(transaction.id);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ] else ...[
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(lp),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 36,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              SizedBox(height: sp),
                              Text(
                                'No transactions yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              SizedBox(height: sp / 2),
                              Text(
                                'Add your first transaction to get started',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: sp),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const AddTransactionDialog(),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 14),
                                label: const Text('Add Transaction'),
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 12),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: lp),

                    // ── Quick Stats ───────────────────────────────────────
                    Text(
                      'Quick Stats',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: sp),

                    Row(
                      children: [
                        // Accounts stat
                        Expanded(
                          child: _buildQuickStatCard(
                            context,
                            Icons.trending_up,
                            AppConstants.successColor,
                            '${accCtrl.accounts.length}',
                            'Accounts',
                            null,
                          ),
                        ),
                        SizedBox(width: sp),
                        // Categories stat — tap to open categories with subcategories
                        Expanded(
                          child: _buildQuickStatCard(
                            context,
                            Icons.category,
                            AppConstants.infoColor,
                            '${txnCtrl.topLevelCategories.length}',
                            'Categories',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CategoriesScreen(),
                              ),
                            ),
                            subLabel: txnCtrl.subCategoryCount > 0
                                ? '${txnCtrl.subCategoryCount} sub'
                                : null,
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
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              heroTag: 'dashboard_fab',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      AddTransactionDialog(),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.add_rounded, size: 28),
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
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 3),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
    BuildContext context,
    IconData icon,
    Color iconColor,
    String value,
    String label,
    VoidCallback? onTap, {
    String? subLabel,
  }) {
    final sh = MediaQuery.of(context).size.height;
    final iconSz = AppConstants.responsiveIconSize(sh, 20.0);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: iconSz),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              if (subLabel != null) ...[
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: iconColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
