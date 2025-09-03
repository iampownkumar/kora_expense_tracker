import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/models/transaction.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/models/account_type.dart';
import 'package:kora_expense_tracker/models/category.dart';
import 'package:kora_expense_tracker/models/settings.dart';
import 'package:kora_expense_tracker/utils/storage_service.dart';
import 'package:kora_expense_tracker/utils/formatters.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/providers/credit_card_provider.dart';

// Transfer validation result
class TransferValidationResult {
  final bool isValid;
  final String errorMessage;
  
  const TransferValidationResult({
    required this.isValid,
    required this.errorMessage,
  });
}

/// Main app provider for managing all state with real-time updates
class AppProvider extends ChangeNotifier {
  // Data
  List<Transaction> _transactions = [];
  List<Account> _accounts = [];
  List<Category> _categories = [];
  Settings _settings = Settings.defaults();
  
  // UI State
  bool _isLoading = false;
  String? _error;
  int _selectedTabIndex = 0;
  
  // Credit Card Provider reference for balance sync
  CreditCardProvider? _creditCardProvider;
  
  // Setter for CreditCardProvider reference
  void setCreditCardProvider(CreditCardProvider provider) {
    _creditCardProvider = provider;
  }
  
  // Getters
  List<Transaction> get transactions => _transactions;
  List<Account> get accounts => _accounts;
  List<Category> get categories => _categories;
  Settings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedTabIndex => _selectedTabIndex;
  
  // Computed values for instant feedback
  double get totalBalance {
    // Total balance should only include asset accounts (savings, wallet, cash, investment)
    // Liability accounts (credit cards, loans) should not be included in total balance
    return totalAssets;
  }

  /// Get total assets (positive balances from asset accounts + overpaid credit cards)
  double get totalAssets {
    return _accounts.fold(0.0, (sum, account) {
      if (account.isAsset) {
        // Regular assets: positive balance
        return sum + account.balance;
      } else if (account.isLiability && account.balance < 0) {
        // Overpaid credit cards: negative balance becomes positive asset
        return sum + account.balance.abs();
      }
      return sum;
    });
  }

  /// Get total liabilities (positive balances from liability accounts)
  /// For credit cards: positive balance = debt, negative balance = credit (reduces liabilities)
  double get totalLiabilities {
    return _accounts
        .where((account) => account.isLiability)
        .fold(0.0, (sum, account) {
          // For liabilities: positive balance = debt, negative balance = credit
          // Only positive balances count as liabilities
          return sum + (account.balance > 0 ? account.balance : 0);
        });
  }

  /// Get net worth (assets - liabilities)
  double get netWorth {
    return totalAssets - totalLiabilities;
  }

  /// Get accounts grouped by type
  Map<AccountType, List<Account>> get accountsByType {
    final Map<AccountType, List<Account>> grouped = {};
    for (final account in _accounts) {
      grouped.putIfAbsent(account.type, () => []).add(account);
    }
    return grouped;
  }

  /// Get accounts filtered by type
  List<Account> getAccountsByType(AccountType type) {
    return _accounts.where((account) => account.type == type).toList();
  }
  
  double get totalIncome {
    return _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }
  
  double get totalExpenses {
    return _transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }
  
  List<Transaction> get recentTransactions {
    final sorted = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(10).toList();
  }
  
  List<Category> get incomeCategories {
    return _categories.where((c) => c.isIncome || c.isBoth).toList();
  }
  
  List<Category> get expenseCategories {
    return _categories.where((c) => c.isExpense || c.isBoth).toList();
  }
  
  // Initialize app data
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadAllData();
      _error = null;
    } catch (e) {
      _error = 'Failed to load data: $e';
    } finally {
      _setLoading(false);
    }
  }
  
  // Loading state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Load all data from storage in parallel for better performance
  Future<void> _loadAllData() async {
    // Load all data in parallel for faster initialization
    final results = await Future.wait([
      StorageService.loadTransactions(),
      StorageService.loadAccounts(),
      StorageService.loadCategories(),
      StorageService.loadSettings(),
    ]);
    
    _transactions = results[0] as List<Transaction>;
    _accounts = results[1] as List<Account>;
    _categories = results[2] as List<Category>;
    _settings = results[3] as Settings;
    
    // If no categories exist, create default ones
    if (_categories.isEmpty) {
      await _createDefaultCategories();
    }
    
    // If no accounts exist, create default ones
    if (_accounts.isEmpty) {
      await _createDefaultAccounts();
    }
  }
  
  // Create default categories for instant gratification
  Future<void> _createDefaultCategories() async {
    for (final categoryData in AppConstants.defaultCategories) {
      final category = Category.create(
        name: categoryData['name'],
        icon: categoryData['icon'],
        color: categoryData['color'],
        type: categoryData['type'],
        isDefault: true,
      );
      _categories.add(category);
    }
    await StorageService.saveCategories(_categories);
  }
  
  // Create default accounts
  Future<void> _createDefaultAccounts() async {
    print('Creating default accounts...');
    for (final accountData in AppConstants.defaultAccounts) {
      print('Creating account: ${accountData['name']} with type: ${accountData['type']}');
      final account = Account.create(
        name: accountData['name'],
        icon: accountData['icon'],
        color: accountData['color'],
        balance: accountData['balance'],
        type: accountData['type'] as AccountType,
      );
      print('Account created: ${account.id}');
      _accounts.add(account);
    }
    print('Saving ${_accounts.length} default accounts to storage');
    await StorageService.saveAccounts(_accounts);
    print('Default accounts creation complete');
  }
  
  // Tab navigation
  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }
  
  // Transaction management with instant feedback
  Future<bool> addTransaction(Transaction transaction) async {
    try {
      // Validate transfer before adding
      if (transaction.isTransfer && transaction.toAccountId != null) {
        final validationResult = _validateTransfer(transaction);
        if (!validationResult.isValid) {
          _error = validationResult.errorMessage;
          notifyListeners();
          return false;
        }
      }
      
      // Validate expense balance for asset accounts
      if (transaction.isExpense) {
        final validationResult = _validateExpenseBalance(transaction);
        if (!validationResult.isValid) {
          _error = validationResult.errorMessage;
          notifyListeners();
          return false;
        }
      }
      
      _transactions.add(transaction);
      try {
        await StorageService.saveTransactions(_transactions);
      } catch (e) {
        // Handle storage errors gracefully
        print('Storage error: $e');
      }
      
      // Update account balances instantly
      await _updateAccountBalances(transaction);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add transaction: $e';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateTransaction(String transactionId, Transaction updatedTransaction) async {
    try {
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index != -1) {
        final oldTransaction = _transactions[index];
        
        // First, reverse the old transaction's effect on account balances
        await _updateAccountBalances(oldTransaction, isDelete: true);
        
        // Then, apply the new transaction's effect
        await _updateAccountBalances(updatedTransaction);
        
        // Update the transaction
        _transactions[index] = updatedTransaction;
        await StorageService.saveTransactions(_transactions);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update transaction: $e';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteTransaction(String transactionId) async {
    try {
      final transaction = _transactions.firstWhere((t) => t.id == transactionId);
      _transactions.removeWhere((t) => t.id == transactionId);
      await StorageService.saveTransactions(_transactions);
      
      // Update account balances
      await _updateAccountBalances(transaction, isDelete: true);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete transaction: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Account management
  Future<bool> addAccount(Account account) async {
    try {
      print('Adding account: ${account.name} with type: ${account.type}');
      _accounts.add(account);
      print('Account added to local list. Total accounts: ${_accounts.length}');
      
      try {
        final success = await StorageService.saveAccounts(_accounts);
        print('Storage save result: $success');
        if (!success) {
          print('Warning: Storage save failed, but account added to local state');
        }
      } catch (e) {
        print('Storage error: $e');
        print('Account remains in local state despite storage error');
      }
      
      notifyListeners();
      print('Notified listeners. Account addition complete.');
      return true;
    } catch (e) {
      print('Error adding account: $e');
      _error = 'Failed to add account: $e';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateAccount(Account account) async {
    try {
      final index = _accounts.indexWhere((a) => a.id == account.id);
      if (index != -1) {
        _accounts[index] = account;
        await StorageService.saveAccounts(_accounts);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update account: $e';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteAccount(String accountId) async {
    try {
      // Check if this is a credit card account
      final account = _accounts.firstWhere((a) => a.id == accountId);
      final isCreditCard = account.type == AccountType.creditCard;
      
      // Create a "Deleted Account" placeholder for transactions only
      final deletedAccount = Account.create(
        name: 'Deleted Account',
        icon: Icons.delete_outline,
        color: Colors.grey,
        type: account.type,
        description: 'This account has been deleted',
      );
      
      // Update all transactions that reference this account
      for (int i = 0; i < _transactions.length; i++) {
        final transaction = _transactions[i];
        if (transaction.accountId == accountId) {
          // Update the transaction to reference the deleted account
          _transactions[i] = transaction.copyWith(
            accountId: deletedAccount.id,
          );
        }
        if (transaction.toAccountId == accountId) {
          // Update the transaction to reference the deleted account
          _transactions[i] = transaction.copyWith(
            toAccountId: deletedAccount.id,
          );
        }
      }
      
      // Save updated transactions
      await StorageService.saveTransactions(_transactions);
      
      // If it's a credit card, also delete from CreditCardProvider
      if (isCreditCard && _creditCardProvider != null) {
        await _creditCardProvider!.deleteCreditCard(accountId);
      }
      
      // Remove the account completely from the accounts list
      _accounts.removeWhere((a) => a.id == accountId);
      
      await StorageService.saveAccounts(_accounts);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete account: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Delete account and all its transactions
  Future<bool> deleteAccountWithTransactions(String accountId) async {
    try {
      // Check if this is a credit card account
      final account = _accounts.firstWhere((a) => a.id == accountId);
      final isCreditCard = account.type == AccountType.creditCard;
      
      // First, delete all transactions related to this account
      final transactionsToDelete = _transactions.where((t) => 
        t.accountId == accountId || t.toAccountId == accountId
      ).toList();
      
      // Remove transactions from the list
      _transactions.removeWhere((t) => 
        t.accountId == accountId || t.toAccountId == accountId
      );
      
      // Save updated transactions
      await StorageService.saveTransactions(_transactions);
      
      // If it's a credit card, also delete from CreditCardProvider
      if (isCreditCard && _creditCardProvider != null) {
        await _creditCardProvider!.deleteCreditCard(accountId);
      }
      
      // Then delete the account
      _accounts.removeWhere((a) => a.id == accountId);
      await StorageService.saveAccounts(_accounts);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete account with transactions: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Category management
  Future<bool> addCategory(Category category) async {
    try {
      _categories.add(category);
      try {
        await StorageService.saveCategories(_categories);
      } catch (e) {
        // Handle storage errors gracefully
        print('Storage error: $e');
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add category: $e';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateCategory(Category category) async {
    try {
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        await StorageService.saveCategories(_categories);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update category: $e';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteCategory(String categoryId) async {
    try {
      _categories.removeWhere((c) => c.id == categoryId);
      await StorageService.saveCategories(_categories);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete category: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Settings management
  Future<bool> updateSettings(Settings settings) async {
    try {
      _settings = settings;
      await StorageService.saveSettings(settings);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update settings: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Update account balances when transactions change
  Future<void> _updateAccountBalances(Transaction transaction, {bool isDelete = false}) async {
    final multiplier = isDelete ? -1 : 1;
    
    if (transaction.isTransfer && transaction.toAccountId != null) {
      // Handle transfers with proper credit card logic
      final fromAccount = _accounts.firstWhere((a) => a.id == transaction.accountId);
      final toAccount = _accounts.firstWhere((a) => a.id == transaction.toAccountId!);
      
      final transferAmount = transaction.amount.abs() * multiplier;
      Account updatedFromAccount;
      Account updatedToAccount;
      
      // FROM ACCOUNT: Always subtract (debit)
      updatedFromAccount = fromAccount.subtractFromBalance(transferAmount);
      
      // TO ACCOUNT: Handle based on account type
      if (toAccount.type == AccountType.creditCard) {
        // For credit cards: subtract from balance (reduces debt)
        // This is because credit card balance represents debt, so reducing it is good
        updatedToAccount = toAccount.subtractFromBalance(transferAmount);
      } else {
        // For regular accounts: add to balance (increases assets)
        updatedToAccount = toAccount.addToBalance(transferAmount);
      }
      
      try {
        await StorageService.updateAccount(updatedFromAccount);
        await StorageService.updateAccount(updatedToAccount);
      } catch (e) {
        // Handle storage errors gracefully
        print('Storage error: $e');
      }
      
      // Update local state
      final fromIndex = _accounts.indexWhere((a) => a.id == transaction.accountId);
      final toIndex = _accounts.indexWhere((a) => a.id == transaction.toAccountId!);
      
      if (fromIndex != -1) _accounts[fromIndex] = updatedFromAccount;
      if (toIndex != -1) _accounts[toIndex] = updatedToAccount;
      
      // CRITICAL: If the TO account is a credit card, also update the CreditCard entity
      if (toAccount.type == AccountType.creditCard && _creditCardProvider != null) {
        final newOutstandingBalance = updatedToAccount.balance;
        await _creditCardProvider!.updateCreditCardBalance(toAccount.id, newOutstandingBalance);
      }
    } else {
      // Handle income/expense
      final accountIndex = _accounts.indexWhere((a) => a.id == transaction.accountId);
      if (accountIndex == -1) return; // Account not found
      
      final account = _accounts[accountIndex];
      Account updatedAccount;
      
      if (transaction.isIncome) {
        // For credit cards (liabilities), income reduces debt (subtract from balance)
        if (account.type == AccountType.creditCard) {
          // For credit cards, income should reduce debt (subtract from balance)
          updatedAccount = account.subtractFromBalance(transaction.amount.abs() * multiplier);
        } else {
          // For regular accounts, income increases balance
          updatedAccount = account.addToBalance(transaction.amount.abs() * multiplier);
        }
      } else {
        // For credit cards (liabilities), expenses increase debt (add to balance)
        if (account.type == AccountType.creditCard) {
          // For credit cards, expenses should increase debt (add to balance)
          updatedAccount = account.addToBalance(transaction.amount.abs() * multiplier);
        } else {
          // For regular accounts, expenses decrease balance
          updatedAccount = account.subtractFromBalance(transaction.amount.abs() * multiplier);
        }
      }
      
      try {
        await StorageService.updateAccount(updatedAccount);
      } catch (e) {
        // Handle storage errors gracefully
        print('Storage error: $e');
      }
      
      // Update local state
      _accounts[accountIndex] = updatedAccount;
      
      // If this is a credit card account, also update the credit card outstanding balance
      if (account.type == AccountType.creditCard && _creditCardProvider != null) {
        // For credit cards, the account balance directly represents the outstanding balance
        final newOutstandingBalance = updatedAccount.balance;
        await _creditCardProvider!.updateCreditCardBalance(account.id, newOutstandingBalance);
      }
    }
  }
  
  // Validate transfer logic
  TransferValidationResult _validateTransfer(Transaction transaction) {
    try {
      final fromAccount = _accounts.firstWhere((a) => a.id == transaction.accountId);
      final toAccount = _accounts.firstWhere((a) => a.id == transaction.toAccountId!);
      
      // Rule 1: Only Asset → Liability or Asset → Asset
      if (fromAccount.type.isLiability) {
        return const TransferValidationResult(
          isValid: false,
          errorMessage: 'Cannot transfer from liability accounts (Credit Cards, Loans). Only asset accounts can initiate transfers.',
        );
      }
      
      // Rule 2: Check sufficient balance for asset accounts
      if (fromAccount.type.isAsset && fromAccount.balance < transaction.amount.abs()) {
        return TransferValidationResult(
          isValid: false,
          errorMessage: 'Insufficient balance. Available: ${Formatters.formatCurrency(fromAccount.balance)}, Required: ${Formatters.formatCurrency(transaction.amount.abs())}',
        );
      }
      
      // Rule 3: Prevent transfer to same account
      if (fromAccount.id == toAccount.id) {
        return const TransferValidationResult(
          isValid: false,
          errorMessage: 'Cannot transfer to the same account.',
        );
      }
      
      return const TransferValidationResult(
        isValid: true,
        errorMessage: '',
      );
    } catch (e) {
      return TransferValidationResult(
        isValid: false,
        errorMessage: 'Account not found: $e',
      );
    }
  }
  
  // Validate expense balance for asset accounts
  TransferValidationResult _validateExpenseBalance(Transaction transaction) {
    try {
      final account = _accounts.firstWhere((a) => a.id == transaction.accountId);
      
      // Only check balance for asset accounts (savings, cash, wallet, etc.)
      if (account.type.isAsset && account.balance < transaction.amount.abs()) {
        return TransferValidationResult(
          isValid: false,
          errorMessage: 'Insufficient balance for expense. Available: ${Formatters.formatCurrency(account.balance)}, Required: ${Formatters.formatCurrency(transaction.amount.abs())}',
        );
      }
      
      return const TransferValidationResult(
        isValid: true,
        errorMessage: '',
      );
    } catch (e) {
      return TransferValidationResult(
        isValid: false,
        errorMessage: 'Account not found: $e',
      );
    }
  }
  
  // Get account for transaction display (handles deleted accounts)
  Account? getAccountForTransaction(String accountId) {
    try {
      // First try to find the account in the current accounts list
      return _accounts.firstWhere((a) => a.id == accountId);
    } catch (e) {
      // If account not found, it might be deleted - return null
      // The UI will show "Unknown Account" for null accounts
      return null;
    }
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Refresh data
  Future<void> refresh() async {
    await _loadAllData();
    notifyListeners();
  }
}
