import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/core/constants/app_constants.dart';
import 'package:kora_expense_tracker/features/transactions/transaction_controller.dart';
import 'package:kora_expense_tracker/features/accounts/account_controller.dart';
import 'package:kora_expense_tracker/features/settings/settings_controller.dart';
import 'package:kora_expense_tracker/widgets/add_transaction_dialog.dart';
import 'package:kora_expense_tracker/widgets/transaction_list_item.dart';
import 'package:kora_expense_tracker/widgets/animated_balance_text.dart';
import 'package:kora_expense_tracker/core/models/categories/category.dart';
import 'package:kora_expense_tracker/core/models/accounts/account.dart';
import 'package:kora_expense_tracker/screens/categories/categories_screen.dart';
import 'package:kora_expense_tracker/screens/transactions/transactions_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _heroCtrl;
  late final AnimationController _listCtrl;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _listFade;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _listCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _listFade = CurvedAnimation(parent: _listCtrl, curve: Curves.easeOut);

    // Staggered entry
    _heroCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _listCtrl.forward();
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Consumer2<TransactionController, AccountController>(
      builder: (context, txnCtrl, accCtrl, _) {
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: _buildAppBar(context, cs, isDark),
          body: RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              await txnCtrl.refresh();
              await accCtrl.refresh();
            },
            displacement: 60,
            color: cs.primary,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Hero balance card ──────────────────────────────
                      SlideTransition(
                        position: _heroSlide,
                        child: FadeTransition(
                          opacity: _heroFade,
                          child: _HeroCard(
                            accCtrl: accCtrl,
                            txnCtrl: txnCtrl,
                            isDark: isDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Quick stats row ────────────────────────────────
                      FadeTransition(
                        opacity: _listFade,
                        child: _QuickStatsRow(
                            accCtrl: accCtrl, txnCtrl: txnCtrl),
                      ),
                      const SizedBox(height: 24),

                      // ── Recent transactions ────────────────────────────
                      FadeTransition(
                        opacity: _listFade,
                        child: _RecentTransactionsSection(
                          txnCtrl: txnCtrl,
                          accCtrl: accCtrl,
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _buildFAB(context, cs),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ColorScheme cs, bool isDark) {
    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 56,
      title: Row(
        children: [
          // App icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: cs.primary.withValues(alpha: 0.12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 32,
                height: 32,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.wallet, size: 18, color: cs.primary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Kora Expense Tracker',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
      actions: [
        // Theme toggle pill
        _ThemeToggle(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFAB(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FloatingActionButton.extended(
        heroTag: 'dashboard_fab',
        onPressed: () {
          HapticFeedback.lightImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddTransactionDialog(),
          );
        },
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Add',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}

// ── Theme toggle ─────────────────────────────────────────────────────────────
class _ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          context.read<SettingsController>().toggleThemeMode();
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Row(
                key: ValueKey<bool>(isDark),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isDark ? 'Dark' : 'Light',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hero balance card ─────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final AccountController accCtrl;
  final TransactionController txnCtrl;
  final bool isDark;

  const _HeroCard({
    required this.accCtrl,
    required this.txnCtrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final income = txnCtrl.totalIncome;
    final expense = txnCtrl.totalExpenses;
    final total = income + expense;
    final savingsRate =
        income > 0 ? ((income - expense) / income * 100).clamp(0.0, 100.0) : 0.0;
    final spendRatio = total > 0 ? (expense / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E1B4B),
                  const Color(0xFF312E81),
                  const Color(0xFF4F46E5),
                ]
              : [
                  const Color(0xFF4F46E5),
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: isDark ? 0.3 : 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting + Today's Date ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _todayLabel(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Total Balance',
              style: TextStyle(
                  color: Colors.white60, fontSize: 11, letterSpacing: 0.5),
            ),
            const SizedBox(height: 4),

            // ── Balance number ────────────────────────────────────────────
            AnimatedBalanceText(
              value: accCtrl.totalBalance,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 14),

            // ── Income vs Expense split bar ───────────────────────────────
            _SpendBar(spendRatio: spendRatio),
            const SizedBox(height: 10),

            // ── Income / Expense / Savings ────────────────────────────────
            Row(
              children: [
                _MiniStat(
                  label: 'Income',
                  numericValue: income,
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFF4ADE80), // green-400
                ),
                const SizedBox(width: 10),
                _MiniStat(
                  label: 'Expenses',
                  numericValue: expense,
                  icon: Icons.arrow_downward_rounded,
                  color: const Color(0xFFFCA5A5), // red-300
                ),
                const SizedBox(width: 10),
                _MiniStat(
                  label: 'Saved',
                  textValue: '${savingsRate.toStringAsFixed(0)}%',
                  icon: Icons.savings_outlined,
                  color: const Color(0xFF93C5FD), // blue-300
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning ☀️';
    if (h < 17) return 'Good Afternoon 👋';
    return 'Good Evening 🌙';
  }

  String _todayLabel() {
    const weekdays = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    final weekdayStr = weekdays[now.weekday];
    return '$weekdayStr, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

// ── Spend ratio bar ───────────────────────────────────────────────────────────
class _SpendBar extends StatelessWidget {
  final double spendRatio;
  const _SpendBar({required this.spendRatio});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Spent',
                style: TextStyle(color: Colors.white60, fontSize: 11)),
            const Text('Saved',
                style: TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: Stack(
              children: [
                // Background (savings)
                Container(color: const Color(0xFF4ADE80).withValues(alpha: 0.3)),
                // Spend portion
                FractionallySizedBox(
                  widthFactor: spendRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFCA5A5),
                          const Color(0xFFF87171),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mini stat widget ──────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final double? numericValue;
  final String? textValue;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    this.numericValue,
    this.textValue,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 3),
                Text(label,
                    style: TextStyle(
                        color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 4),
            if (numericValue != null)
              AnimatedBalanceText(
                value: numericValue!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              Text(
                textValue ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Quick stats row ───────────────────────────────────────────────────────────
class _QuickStatsRow extends StatelessWidget {
  final AccountController accCtrl;
  final TransactionController txnCtrl;

  const _QuickStatsRow({required this.accCtrl, required this.txnCtrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        _StatChip(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Accounts',
          value: '${accCtrl.accounts.length}',
          color: cs.primary,
          onTap: null,
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.category_outlined,
          label: 'Categories',
          value: '${txnCtrl.topLevelCategories.length}',
          color: const Color(0xFF0891B2),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoriesScreen()),
          ),
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.receipt_long_outlined,
          label: 'Transactions',
          value: '${txnCtrl.transactions.length}',
          color: const Color(0xFF9333EA),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionsScreen()),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (onTap != null) {
            HapticFeedback.selectionClick();
            onTap!();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recent transactions section ───────────────────────────────────────────────
class _RecentTransactionsSection extends StatelessWidget {
  final TransactionController txnCtrl;
  final AccountController accCtrl;

  const _RecentTransactionsSection({
    required this.txnCtrl,
    required this.accCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (txnCtrl.recentTransactions.isEmpty) {
      return _EmptyTransactions();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ─────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransactionsScreen()),
              ),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: cs.primary.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('View All',
                  style:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Scrollable transaction list ─────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              // Show max 4 rows, each ~68px — scrolls independently
              height: (txnCtrl.recentTransactions.length > 4
                      ? 4
                      : txnCtrl.recentTransactions.length) *
                  68.0,
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                physics: const ClampingScrollPhysics(),
                itemCount: txnCtrl.recentTransactions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 64,
                  endIndent: 16,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                ),
                itemBuilder: (context, index) {
                  final txn = txnCtrl.recentTransactions[index];
                  final cat = txnCtrl.categories.firstWhere(
                    (c) => c.id == txn.categoryId,
                    orElse: () => Category.create(
                      name: 'Unknown',
                      icon: Icons.category,
                      color: AppConstants.primaryColor,
                      type: AppConstants.categoryTypeExpense,
                    ),
                  );
                  final acct = accCtrl.findById(txn.accountId);
                  Account? toAcct;
                  if (txn.toAccountId != null) {
                    toAcct = accCtrl.findById(txn.toAccountId!);
                  }
                  return TransactionListItem(
                    transaction: txn,
                    category: cat,
                    account: acct,
                    toAccount: toAcct,
                    compact: true,
                    enableSwipeToDelete: true,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AddTransactionDialog(transaction: txn),
                    ),
                    onEdit: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AddTransactionDialog(transaction: txn),
                    ),
                    onDelete: () async {
                      HapticFeedback.mediumImpact();
                      await txnCtrl.deleteTransaction(txn.id);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.receipt_long_outlined,
                size: 30, color: cs.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Add your first transaction to start tracking',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const AddTransactionDialog(),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }
}
