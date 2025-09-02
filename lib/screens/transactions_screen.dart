import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/models/transaction.dart';
import 'package:kora_expense_tracker/widgets/add_transaction_dialog.dart';
import 'package:kora_expense_tracker/widgets/transaction_list_item.dart';
import 'package:kora_expense_tracker/widgets/transaction_detail_sheet.dart';
import 'package:kora_expense_tracker/utils/formatters.dart';

/// Comprehensive Transaction Screen with filtering, search, and sorting
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'Date';
  bool _sortAscending = false;
  bool _isSearchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final filteredTransactions = _getFilteredTransactions(appProvider.transactions);
        final groupedTransactions = _groupTransactionsByDate(filteredTransactions);

        return Scaffold(
          appBar: _buildAppBar(context, appProvider),
          body: Column(
            children: [
              if (_isSearchVisible) _buildSearchBar(),
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
          floatingActionButton: _buildFAB(context, appProvider),
        );
      },
    );
  }

  /// Build the app bar with search and filter actions
  PreferredSizeWidget _buildAppBar(BuildContext context, AppProvider appProvider) {
    return AppBar(
      title: Text('Transactions (${appProvider.transactions.length})'),
      actions: [
        IconButton(
          icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearchVisible = !_isSearchVisible;
              if (!_isSearchVisible) {
                _searchController.clear();
                _searchQuery = '';
                _searchFocus.unfocus();
              } else {
                _searchFocus.requestFocus();
              }
            });
          },
        ),
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
                    Icons.attach_money,
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

  /// Build the search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
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
              ...transactions.map((transaction) => TransactionListItem(
                transaction: transaction,
                onTap: () => _showTransactionDetails(context, transaction),
                onEdit: () => _editTransaction(context, transaction, appProvider),
              )),
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
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? 'Try adjusting your search or filters'
                : 'Tap + to add your first transaction',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build the floating action button
  Widget _buildFAB(BuildContext context, AppProvider appProvider) {
    return Container(
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
        onPressed: () => _addTransaction(context, appProvider),
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
    );
  }

  /// Get filtered transactions based on search and filter criteria
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

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return transaction.description.toLowerCase().contains(query) ||
               transaction.amount.toString().contains(query) ||
               (transaction.notes?.toLowerCase().contains(query) ?? false);
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

  /// Add new transaction
  void _addTransaction(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(appProvider: appProvider),
    );
  }

  /// Show transaction details in bottom sheet
  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailSheet(transaction: transaction),
    );
  }

  /// Edit existing transaction
  void _editTransaction(BuildContext context, Transaction transaction, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        appProvider: appProvider,
        transaction: transaction,
      ),
    );
  }
}
