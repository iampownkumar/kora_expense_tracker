import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/models/transaction.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/models/category.dart';
import 'package:kora_expense_tracker/models/settings.dart';
import 'package:kora_expense_tracker/utils/storage_service.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';

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
    return _accounts.fold(0.0, (sum, account) => sum + account.balance);
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
  
  // Load all data from storage
  Future<void> _loadAllData() async {
    final futures = await Future.wait([
      StorageService.loadTransactions(),
      StorageService.loadAccounts(),
      StorageService.loadCategories(),
      StorageService.loadSettings(),
    ]);
    
    _transactions = futures[0] as List<Transaction>;
    _accounts = futures[1] as List<Account>;
    _categories = futures[2] as List<Category>;
    _settings = futures[3] as Settings;
    
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
    for (final accountData in AppConstants.defaultAccounts) {
      final account = Account.create(
        name: accountData['name'],
        icon: accountData['icon'],
        color: accountData['color'],
        balance: accountData['balance'],
      );
      _accounts.add(account);
    }
    await StorageService.saveAccounts(_accounts);
  }
  
  // Tab navigation
  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }
  
  // Transaction management with instant feedback
  Future<bool> addTransaction(Transaction transaction) async {
    try {
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
  
  Future<bool> updateTransaction(Transaction transaction) async {
    try {
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        await StorageService.saveTransactions(_transactions);
        
        // Update account balances
        await _updateAccountBalances(transaction);
        
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
      _accounts.add(account);
      try {
        await StorageService.saveAccounts(_accounts);
      } catch (e) {
        // Handle storage errors gracefully
        print('Storage error: $e');
      }
      notifyListeners();
      return true;
    } catch (e) {
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
      // Handle transfers
      final fromAccount = _accounts.firstWhere((a) => a.id == transaction.accountId);
      final toAccount = _accounts.firstWhere((a) => a.id == transaction.toAccountId!);
      
      final updatedFromAccount = fromAccount.subtractFromBalance(transaction.amount.abs() * multiplier);
      final updatedToAccount = toAccount.addToBalance(transaction.amount.abs() * multiplier);
      
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
    } else {
      // Handle income/expense
      final accountIndex = _accounts.indexWhere((a) => a.id == transaction.accountId);
      if (accountIndex == -1) return; // Account not found
      
      final account = _accounts[accountIndex];
      Account updatedAccount;
      
      if (transaction.isIncome) {
        updatedAccount = account.addToBalance(transaction.amount.abs() * multiplier);
      } else {
        updatedAccount = account.subtractFromBalance(transaction.amount.abs() * multiplier);
      }
      
      try {
        await StorageService.updateAccount(updatedAccount);
      } catch (e) {
        // Handle storage errors gracefully
        print('Storage error: $e');
      }
      
      // Update local state
      _accounts[accountIndex] = updatedAccount;
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
