import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../features/accounts/account_controller.dart';
import '../features/transactions/transaction_controller.dart';
import '../features/credit_cards/credit_card_controller.dart';
import '../features/reports/reports_controller.dart';
import '../features/settings/settings_controller.dart';

// Screens
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/accounts/accounts_screen.dart';
import '../screens/credit_cards/credit_cards_screen.dart';
import '../screens/more_screen.dart';
import '../widgets/add_transaction_dialog.dart';
import '../core/utils/storage_service.dart';
import '../core/constants/app_constants.dart';

/// Global coordinator and navigation shell.
///
/// Responsibilities:
///   1. Wires all feature controllers together (cross-module callbacks).
///   2. Owns tab navigation state.
///   3. Hosts the bottom nav bar with the swipe-up gesture (B2 fix).
///
/// Views must NOT import this file — they use their own controller directly.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedTabIndex = 0;
  bool _initialized = false;
  DateTime? _lastBackPress;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    ReportsScreen(),
    AccountsScreen(),
    CreditCardsScreen(),
    MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAllControllers();
      _checkFirstRunAfterUpdate();
    });
  }

  /// Initialize all controllers in dependency order:
  ///   AccountController first (no deps),
  ///   then TransactionController (needs Account for balance updates),
  ///   then CreditCardController (needs Transaction for payment deletion),
  ///   then ReportsController (needs both above),
  ///   then SettingsController (no deps).
  Future<void> _initializeAllControllers() async {
    if (_initialized) return;

    final acc  = context.read<AccountController>();
    final txn  = context.read<TransactionController>();
    final cc   = context.read<CreditCardController>();
    final rep  = context.read<ReportsController>();
    final sett = context.read<SettingsController>();

    await acc.initialize();
    await txn.initialize();
    await cc.initialize();
    await sett.initialize();
    rep.refresh(); // aggregator, no async load needed

    _initialized = true;
  }

  // ── What's New dialog (kept from original home_screen.dart) ──────────────

  Future<void> _checkFirstRunAfterUpdate() async {
    try {
      final lastVersion = StorageService.prefs.getString('last_version_seen');
      if (lastVersion != AppConstants.appVersion) {
        await _showWhatsNewDialog();
        await StorageService.prefs.setString(
          'last_version_seen',
          AppConstants.appVersion,
        );
      }
    } catch (e) {
      debugPrint('AppShell: version check failed: $e');
    }
  }

  Future<void> _showWhatsNewDialog() {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.new_releases, color: AppConstants.primaryColor),
          const SizedBox(width: 8),
          Text("What's New in v${AppConstants.appVersion}"),
        ]),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• MVC refactor: each module is now fully independent.'),
              SizedBox(height: 6),
              Text('• Sub-categories now appear in Quick Stats breakdown.'),
              SizedBox(height: 6),
              Text('• Fixed: deleted account ghost ID bug (B3).'),
              SizedBox(height: 6),
              Text('• Fixed: app drawer no longer opens on nav bar swipe (B2).'),
              SizedBox(height: 6),
              Text('• Fixed: duplicate import check now includes time (B4).'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _onTabSelected(int index) => setState(() => _selectedTabIndex = index);

  void _openAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      builder: (_) => const AddTransactionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Always intercept back press
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 1. If not on Home tab, single press routes to Home.
        if (_selectedTabIndex != 0) {
          setState(() => _selectedTabIndex = 0);
          return;
        }

        // 2. If on Home tab, require double press to exit.
        final now = DateTime.now();
        if (_lastBackPress == null ||
            now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
          _lastBackPress = now;
          
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Press back again to exit'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16), // above nav bar
            ),
          );
          return;
        }

        // Double press confirmed within 2 seconds. Exit app.
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedTabIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildNavBar(context),
      ),
    );
  }

  /// Bottom nav bar with swipe-up to add transaction.
  ///
  /// **Bug B2 fix:** wraps only the nav bar in a GestureDetector using
  /// [HitTestBehavior.deferToChild], so the swipe gesture is only captured
  /// when the finger starts ON the nav bar — the system app drawer swipe
  /// (which starts from the very edge) is no longer intercepted.
  Widget _buildNavBar(BuildContext context) {
    return GestureDetector(
      // B2 fix: deferToChild means the gesture only fires if a child hit-tests first.
      // The NavigationBar is the child — swiping from outside it (system gesture area)
      // won't trigger this detector.
      behavior: HitTestBehavior.deferToChild,
      onVerticalDragEnd: (details) {
        // Only swipe-UP (negative velocity = upward) opens the add dialog
        if ((details.primaryVelocity ?? 0) < -300) {
          _openAddTransaction(context);
        }
      },
      child: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: _onTabSelected,
        height: 58,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Txns',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
