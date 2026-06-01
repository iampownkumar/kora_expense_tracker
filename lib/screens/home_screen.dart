import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/screens/dashboard_screen.dart';
import 'package:kora_expense_tracker/screens/transactions_screen.dart';
import 'package:kora_expense_tracker/screens/accounts_screen.dart';
import 'package:kora_expense_tracker/screens/credit_cards_screen.dart';
import 'package:kora_expense_tracker/screens/more_screen.dart';
import 'package:kora_expense_tracker/screens/reports_screen.dart';
import 'package:kora_expense_tracker/widgets/add_transaction_dialog.dart';
import 'package:kora_expense_tracker/core/utils/storage_service.dart';
import 'package:kora_expense_tracker/core/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const ReportsScreen(),
    const AccountsScreen(),
    const CreditCardsScreen(),
    const MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstRunAfterUpdate();
    });
  }

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
      debugPrint('Error checking version: $e');
    }
  }

  Future<void> _showWhatsNewDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.new_releases, color: AppConstants.primaryColor),
            const SizedBox(width: 8),
            Text('What\'s New in v${AppConstants.appVersion}'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• Sub-categories: select a parent category then optionally refine with a sub-category when adding transactions.',
              ),
              SizedBox(height: 8),
              Text(
                '• Swipe up from the nav bar to add a transaction — swipe down anywhere to close, just like an Android launcher.',
              ),
              SizedBox(height: 8),
              Text(
                '• Compact navigation bar and refreshed dashboard layout for more breathing room.',
              ),
              SizedBox(height: 8),
              Text(
                '• Category hierarchy: create and manage parent → child categories from the Categories screen.',
              ),
              SizedBox(height: 8),
              Text(
                '• Bug fixes: double-back press no longer triggers app-exit toast when closing the add transaction screen.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Awesome!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: appProvider.selectedTabIndex,
            children: _screens,
          ),
          bottomNavigationBar: GestureDetector(
            // ── Original swipe-up to add transaction ──────────────────────
            // Opens AddTransactionDialog as a bottom sheet (swipe DOWN to close)
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < -300) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  // enableDrag = true → swipe down dismisses the sheet
                  enableDrag: true,
                  isDismissible: true,
                  builder: (context) => AddTransactionDialog(
                    appProvider: context.read<AppProvider>(),
                  ),
                );
              }
            },
            child: NavigationBar(
              selectedIndex: appProvider.selectedTabIndex,
              onDestinationSelected: (index) {
                appProvider.setSelectedTab(index);
              },
              // Compact height
              height: 58,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
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
          ),
        );
      },
    );
  }
}
