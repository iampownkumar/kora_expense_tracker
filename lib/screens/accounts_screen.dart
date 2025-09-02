import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/models/account_type.dart';
import 'package:kora_expense_tracker/widgets/account_card.dart';
import 'package:kora_expense_tracker/widgets/financial_summary_card.dart';
import 'package:kora_expense_tracker/widgets/add_account_dialog.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> with TickerProviderStateMixin {
  AccountType? _selectedFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
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
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Check if we're on dashboard (index 0)
        final provider = context.read<AppProvider>();
        if (provider.selectedTabIndex != 0) {
          // Go to dashboard first
          provider.setSelectedTab(0);
          return false; // Don't exit app
        }
        
        // If already on dashboard, check for double back press
        final now = DateTime.now();
        if (_lastBackPress == null || now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
          _lastBackPress = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Press back again to exit'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              margin: const EdgeInsets.all(16),
            ),
          );
          return false; // Don't exit app
        }
        
        // Double back press - exit app
        return true;
      },
      child: Scaffold(
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final accounts = _getFilteredAccounts(provider.accounts);
          final accountCounts = _getAccountCounts(provider.accounts);
          
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              // Swipe left/right to cycle through account types
              if (details.primaryVelocity! > 0) {
                // Swipe right - go to previous filter
                _cycleFilter(-1);
              } else if (details.primaryVelocity! < 0) {
                // Swipe left - go to next filter
                _cycleFilter(1);
              }
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
              // App Bar with search
              _buildSliverAppBar(context, provider),
              
              // Financial Summary
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: FinancialSummaryCard(
                      totalAssets: provider.totalAssets,
                      totalLiabilities: provider.totalLiabilities,
                      netWorth: provider.netWorth,
                      accountCounts: accountCounts,
                      onTap: () => _showFinancialDetails(context, provider),
                    ),
                  ),
                ),
              ),
              
              // Filter chips
              if (provider.accounts.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildFilterChips(context),
                ),
              
              // Accounts list or empty state
              if (accounts.isEmpty)
                _buildEmptyState(context, provider)
              else
                _buildAccountsList(accounts, provider),
              ],
            ),
          );
        },
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
          child: FloatingActionButton.extended(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildSliverAppBar(BuildContext context, AppProvider provider) {
    final theme = Theme.of(context);
    
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: theme.brightness == Brightness.dark 
          ? theme.colorScheme.primaryContainer 
          : theme.colorScheme.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(bottom: 8),
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
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Title area
                Container(
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
                        icon: const Icon(Icons.filter_list, color: Colors.white),
                        onPressed: () => _showFilterOptions(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () => _showAddAccountDialog(context),
                      ),
                    ],
                  ),
                ),
                // Search bar area
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (value) {
                      setState(() => _searchQuery = value.toLowerCase());
                    },
                    onTap: () {
                      // Only focus when user explicitly taps
                      _searchFocusNode.requestFocus();
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search accounts...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final theme = Theme.of(context);
    final ScrollController filterScrollController = ScrollController();
    
    // Auto-scroll to selected filter when it changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (filterScrollController.hasClients) {
        final selectedIndex = _selectedFilter == null ? 0 : AccountType.values.indexOf(_selectedFilter!) + 1;
        final chipWidth = 120.0; // Approximate width of each chip
        final screenWidth = MediaQuery.of(context).size.width;
        final scrollPosition = (selectedIndex * chipWidth) - (screenWidth / 2) + (chipWidth / 2);
        // Ensure we don't scroll beyond bounds
        final maxScroll = filterScrollController.position.maxScrollExtent;
        final finalPosition = scrollPosition.clamp(0.0, maxScroll);
        filterScrollController.animateTo(
          finalPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: ListView(
        controller: filterScrollController,
        scrollDirection: Axis.horizontal,
        children: [
          // All accounts chip
          _buildFilterChip(
            context,
            'All',
            _selectedFilter == null,
            () => setState(() => _selectedFilter = null),
          ),
          
          // Account type chips
          ...AccountType.values.map((type) => _buildFilterChip(
            context,
            type.displayName,
            _selectedFilter == type,
            () => setState(() => _selectedFilter = type),
            type.color,
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap, [
    Color? color,
  ]) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: color?.withOpacity(0.1) ?? theme.colorScheme.surface,
        selectedColor: color?.withOpacity(0.2) ?? theme.colorScheme.primary.withOpacity(0.2),
        checkmarkColor: color ?? theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? (color ?? theme.colorScheme.primary) : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppProvider provider) {
    final theme = Theme.of(context);
    final isSearching = _searchQuery.isNotEmpty;
    final hasFilter = _selectedFilter != null;
    
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSearching || hasFilter ? Icons.search_off : Icons.account_balance_wallet,
                size: 80,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                isSearching || hasFilter ? 'No accounts found' : 'No accounts yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSearching || hasFilter
                    ? 'Try adjusting your search or filter'
                    : 'Add your first account to get started',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (!isSearching && !hasFilter)
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

  Widget _buildAccountsList(List<Account> accounts, AppProvider provider) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final account = accounts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AccountCard(
                account: account,
                onTap: () => _showAccountDetails(context, account),
                onEdit: () => _showEditAccountDialog(context, account),
                onDelete: () => _showDeleteConfirmation(context, account, provider),
              ),
            );
          },
          childCount: accounts.length,
        ),
      ),
    );
  }

  // Add manual scroll helper
  void _scrollToTop() {
    // This will be called when user wants to scroll to top
    // You can add a scroll controller if needed for more control
  }

  // Clear search focus and keyboard
  void _clearSearchFocus() {
    // Clear search text
    _searchController.clear();
    setState(() => _searchQuery = '');
    
    // Remove focus from search field specifically
    _searchFocusNode.unfocus();
    
    // Also remove any other focus
    FocusScope.of(context).unfocus();
  }

  // Cycle through account type filters with swipe
  void _cycleFilter(int direction) {
    // Include all account types for complete swipe loop
    final List<AccountType?> filters = [
      null, // All
      AccountType.savings,
      AccountType.wallet,
      AccountType.creditCard,
      AccountType.cash,
      AccountType.investment,
      AccountType.loan,
    ];
    final currentIndex = filters.indexOf(_selectedFilter);
    
    int newIndex;
    if (direction > 0) {
      // Swipe left - next filter
      newIndex = (currentIndex + 1) % filters.length;
    } else {
      // Swipe right - previous filter
      newIndex = (currentIndex - 1 + filters.length) % filters.length;
    }
    
    setState(() {
      _selectedFilter = filters[newIndex];
    });
    
    // Comment out popup message for production
    // final filterName = _selectedFilter == null ? 'All' : _selectedFilter!.displayName;
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     duration: const Duration(milliseconds: 1200),
    //     behavior: SnackBarBehavior.floating,
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //     margin: const EdgeInsets.all(16),
    //     elevation: 4,
    //     backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
    //     content: Text(
    //       'Showing: $filterName',
    //       style: TextStyle(
    //         color: Theme.of(context).colorScheme.onSurfaceVariant,
    //         fontWeight: FontWeight.w500,
    //       ),
    //     ),
    //   ),
    // );
  }

  List<Account> _getFilteredAccounts(List<Account> accounts) {
    var filtered = accounts.where((account) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = account.name.toLowerCase().contains(_searchQuery) ||
            account.type.displayName.toLowerCase().contains(_searchQuery) ||
            (account.description?.toLowerCase().contains(_searchQuery) ?? false);
        if (!matchesSearch) return false;
      }
      
      // Type filter
      if (_selectedFilter != null) {
        return account.type == _selectedFilter;
      }
      
      return true;
    }).toList();
    
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
    showDialog(
      context: context,
      builder: (dialogContext) => AddAccountDialog(
        onSave: (account) {
          // Use the original context that has access to the provider
          context.read<AppProvider>().addAccount(account);
        },
      ),
    ).then((_) {
      // Clear search focus when dialog is dismissed
      _clearSearchFocus();
    });
  }

  void _showEditAccountDialog(BuildContext context, Account account) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddAccountDialog(
        existingAccount: account,
        onSave: (updatedAccount) {
          // Use the original context that has access to the provider
          context.read<AppProvider>().updateAccount(updatedAccount);
        },
      ),
    ).then((_) {
      // Clear search focus when dialog is dismissed
      _clearSearchFocus();
    });
  }

  void _showDeleteConfirmation(BuildContext context, Account account, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete "${account.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteAccount(account.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${account.name} deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAccountDetails(BuildContext context, Account account) {
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
                    Text(
                      'Account Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Clear search focus when returning
                        _clearSearchFocus();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Account card
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: AccountCard(
                    account: account,
                    isExpanded: true,
                    showActions: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      // Clear search focus when modal is dismissed
      _clearSearchFocus();
    });
  }

  void _showFinancialDetails(BuildContext context, AppProvider provider) {
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
                    Text(
                      'Financial Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Clear search focus when returning
                        _clearSearchFocus();
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
                      _buildFinancialDetailCard(
                        context,
                        'Total Assets',
                        provider.totalAssets,
                        Colors.green,
                        Icons.trending_up,
                      ),
                      const SizedBox(height: 12),
                      _buildFinancialDetailCard(
                        context,
                        'Total Liabilities',
                        provider.totalLiabilities,
                        Colors.red,
                        Icons.trending_down,
                      ),
                      const SizedBox(height: 12),
                      _buildFinancialDetailCard(
                        context,
                        'Net Worth',
                        provider.netWorth,
                        provider.netWorth >= 0 ? Colors.green : Colors.red,
                        provider.netWorth >= 0 ? Icons.trending_up : Icons.trending_down,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      // Clear search focus when modal is dismissed
      _clearSearchFocus();
    });
  }

  Widget _buildFinancialDetailCard(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
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

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Accounts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Add filter options here
            const Text('Filter options will be implemented here'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
