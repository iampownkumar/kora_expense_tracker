import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/screens/dashboard_screen.dart';
import 'package:kora_expense_tracker/screens/transactions_screen.dart';
import 'package:kora_expense_tracker/screens/accounts_screen.dart';
import 'package:kora_expense_tracker/screens/credit_cards_screen.dart';
import 'package:kora_expense_tracker/screens/more_screen.dart';
import 'package:kora_expense_tracker/widgets/add_transaction_dialog.dart';
import 'package:kora_expense_tracker/utils/storage_service.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
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
        await StorageService.prefs.setString('last_version_seen', AppConstants.appVersion);
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
              Text('• Unlimited custom categories with icons and colors.'),
              SizedBox(height: 8),
              Text('• Attach receipt images to your transactions and view them full screen.'),
              SizedBox(height: 8),
              Text('• Enhanced Home screen with vertical swipe transaction creation.'),
              SizedBox(height: 8),
              Text('• Beautiful new app icon and splash screen design.'),
              SizedBox(height: 8),
              Text('• Sticky filter chips for easy navigation on the Accounts page.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold)),
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
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
                // Swipe from bottom to up detected
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card),
            label: 'Credit Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
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
