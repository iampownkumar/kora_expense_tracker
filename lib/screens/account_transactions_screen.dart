import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/models/transaction.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/models/category.dart';
import 'package:kora_expense_tracker/widgets/transaction_list_item.dart';
import 'package:kora_expense_tracker/widgets/transaction_detail_sheet.dart';
import 'package:kora_expense_tracker/utils/formatters.dart';

/// Account-specific transactions screen with filtering and swipe gestures
class AccountTransactionsScreen extends StatefulWidget {
  final Account account;

  const AccountTransactionsScreen({
    super.key,
    required this.account,
  });

  @override
  State<AccountTransactionsScreen> createState() => _AccountTransactionsScreenState();
}

class _AccountTransactionsScreenState extends State<AccountTransactionsScreen> {
  String _selectedFilter = 'All';
  String _sortBy = 'Date';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final accountTransactions = _getAccountTransactions(appProvider.transactions);
        final filteredTransactions = _getFilteredTransactions(accountTransactions);
        final groupedTransactions = _groupTransactionsByDate(filteredTransactions);

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            // Swipe left/right anywhere in the app to change filter
            if (details.primaryVelocity! > 0) {
              // Swipe right
              _cycleFilter(-1);
            } else if (details.primaryVelocity! < 0) {
              // Swipe left
              _cycleFilter(1);
            }
          },
          child: Scaffold(
            appBar: _buildAppBar(context, appProvider),
            body: Column(
              children: [
                _buildAccountInfo(context),
                _buildFilterChips(),
                _buildSortOptions(),
                Expanded(
                  child: appProvider.isLoading
                      ? _buildLoadingState()
                      : filteredTransactions.isEmpty
                          ? _buildEmptyState()
                          : _buildTransactionList(groupedTransactions, appProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build the app bar
  PreferredSizeWidget _buildAppBar(BuildContext context, AppProvider appProvider) {
    return AppBar(
      title: Text('${widget.account.name} Transactions'),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          onSelected: (value) {
            setState(() {
              if (value == 'Date' || value == 'Amount' || value == 'Category') {
                if (_sortBy == value) {
                  _sortAscending = !_sortAscending;
                } else {
                  _sortBy = value;
                  _sortAscending = false;
                }
              }
            });
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'Date',
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: _sortBy == 'Date' ? Theme.of(context).colorScheme.primary : null,
                  ),
                  const SizedBox(width: 8),
                  Text('Sort by Date'),
                  if (_sortBy == 'Date')
                    Icon(
                      _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'Amount',
              child: Row(
                children: [
                  Icon(
                    Icons.payments,
                    size: 20,
                    color: _sortBy == 'Amount' ? Theme.of(context).colorScheme.primary : null,
                  ),
                  const SizedBox(width: 8),
                  Text('Sort by Amount'),
                  if (_sortBy == 'Amount')
                    Icon(
                      _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'Category',
              child: Row(
                children: [
                  Icon(
                    Icons.category,
                    size: 20,
                    color: _sortBy == 'Category' ? Theme.of(context).colorScheme.primary : null,
                  ),
                  const SizedBox(width: 8),
                  Text('Sort by Category'),
                  if (_sortBy == 'Category')
                    Icon(
                      _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build account information card
  Widget _buildAccountInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.account.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.account.icon,
                  color: widget.account.type.color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.account.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.account.type.displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Current Balance',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.account.getFormattedBalance(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: widget.account.balanceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build filter chips for transaction types
  Widget _buildFilterChips() {
    final filters = ['All', 'Income', 'Expense', 'Transfer'];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          );
        },
      ),
    );
  }

  /// Build sort options display
  Widget _buildSortOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.sort,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Sorted by $_sortBy ${_sortAscending ? '↑' : '↓'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the transaction list with date grouping
  Widget _buildTransactionList(Map<String, List<Transaction>> groupedTransactions, AppProvider appProvider) {
    return RefreshIndicator(
      onRefresh: () async {
        await appProvider.refresh();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: groupedTransactions.length,
        itemBuilder: (context, index) {
          final dateKey = groupedTransactions.keys.elementAt(index);
          final transactions = groupedTransactions[dateKey]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(dateKey, transactions.length),
              ...transactions.map((transaction) {
                Account? account;
                try {
                  account = appProvider.accounts.firstWhere((acc) => acc.id == transaction.accountId);
                } catch (e) {
                  account = appProvider.accounts.isNotEmpty ? appProvider.accounts.first : null;
                }
                
                Category? category;
                try {
                  category = appProvider.categories.firstWhere((cat) => cat.id == transaction.categoryId);
                } catch (e) {
                  category = appProvider.categories.isNotEmpty ? appProvider.categories.first : null;
                }
                
                Account? toAccount;
                if (transaction.toAccountId != null) {
                  try {
                    toAccount = appProvider.accounts.firstWhere((acc) => acc.id == transaction.toAccountId);
                  } catch (e) {
                    toAccount = appProvider.accounts.isNotEmpty ? appProvider.accounts.first : null;
                  }
                }
                
                return TransactionListItem(
                  transaction: transaction,
                  account: account,
                  category: category,
                  toAccount: toAccount,
                  onTap: () => _showTransactionDetails(context, transaction),
                  onEdit: () => _editTransaction(context, transaction, appProvider),
                  onDelete: () => appProvider.deleteTransaction(transaction.id),
                );
              }),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  /// Build date header for grouped transactions
  Widget _buildDateHeader(String dateKey, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            dateKey,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading transactions...'),
        ],
      ),
    );
  }

  /// Build empty state when no transactions
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter != 'All'
                ? 'No $_selectedFilter transactions for this account'
                : 'No transactions for this account yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Cycle through filter options with swipe gestures
  void _cycleFilter(int direction) {
    final filters = ['All', 'Income', 'Expense', 'Transfer'];
    final currentIndex = filters.indexOf(_selectedFilter);
    
    int newIndex;
    if (direction > 0) {
      // Swipe left - go to next filter
      newIndex = (currentIndex + 1) % filters.length;
    } else {
      // Swipe right - go to previous filter
      newIndex = (currentIndex - 1 + filters.length) % filters.length;
    }
    
    setState(() {
      _selectedFilter = filters[newIndex];
    });
  }

  /// Get transactions for this specific account
  List<Transaction> _getAccountTransactions(List<Transaction> transactions) {
    return transactions.where((transaction) {
      return transaction.accountId == widget.account.id || 
             transaction.toAccountId == widget.account.id;
    }).toList();
  }

  /// Get filtered transactions based on filter criteria
  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    var filtered = transactions.where((transaction) {
      // Apply type filter
      if (_selectedFilter != 'All') {
        if (_selectedFilter == 'Income' && transaction.type != AppConstants.transactionTypeIncome) {
          return false;
        }
        if (_selectedFilter == 'Expense' && transaction.type != AppConstants.transactionTypeExpense) {
          return false;
        }
        if (_selectedFilter == 'Transfer' && transaction.type != AppConstants.transactionTypeTransfer) {
          return false;
        }
      }

      return true;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'Date':
          comparison = a.date.compareTo(b.date);
          break;
        case 'Amount':
          comparison = a.amount.compareTo(b.amount);
          break;
        case 'Category':
          comparison = a.categoryId.compareTo(b.categoryId);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  /// Group transactions by date for display
  Map<String, List<Transaction>> _groupTransactionsByDate(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};
    
    for (final transaction in transactions) {
      final dateKey = Formatters.formatDate(transaction.date);
      grouped.putIfAbsent(dateKey, () => []).add(transaction);
    }
    
    return grouped;
  }

  /// Show transaction details in bottom sheet
  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailSheet(
        transaction: transaction,
        appProvider: appProvider,
      ),
    );
  }

  /// Edit existing transaction
  void _editTransaction(BuildContext context, Transaction transaction, AppProvider appProvider) {
    // Import AddTransactionDialog if needed
    // showDialog(
    //   context: context,
    //   builder: (context) => AddTransactionDialog(
    //     appProvider: appProvider,
    //     transaction: transaction,
    //   ),
    // );
  }
}
