import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/screens/dashboard_screen.dart';
import 'package:kora_expense_tracker/screens/transactions_screen.dart';
import 'package:kora_expense_tracker/screens/accounts_screen.dart';
import 'package:kora_expense_tracker/screens/credit_cards_screen.dart';
import 'package:kora_expense_tracker/screens/categories_screen.dart';
import 'package:kora_expense_tracker/screens/more_screen.dart';
import 'package:kora_expense_tracker/widgets/add_transaction_dialog.dart';

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
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
                // Swipe from left to right detected
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
            child: IndexedStack(
              index: appProvider.selectedTabIndex,
              children: _screens,
            ),
          ),
          bottomNavigationBar: NavigationBar(
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
    );
      },
    );
  }
}
