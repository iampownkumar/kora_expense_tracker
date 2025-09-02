import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/settings.dart';

/// Service for handling local data storage using SharedPreferences
class StorageService {
  static SharedPreferences? _prefs;
  
  /// Initialize the storage service
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // Transaction Storage Methods
  
  /// Save transactions to local storage
  static Future<bool> saveTransactions(List<Transaction> transactions) async {
    try {
      final jsonList = transactions.map((t) => t.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await prefs.setString(AppConstants.transactionsKey, jsonString);
    } catch (e) {
      print('Error saving transactions: $e');
      return false;
    }
  }

  /// Load transactions from local storage
  static Future<List<Transaction>> loadTransactions() async {
    try {
      final jsonString = prefs.getString(AppConstants.transactionsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      print('Error loading transactions: $e');
      return [];
    }
  }

  /// Add a single transaction
  static Future<bool> addTransaction(Transaction transaction) async {
    try {
      final transactions = await loadTransactions();
      transactions.add(transaction);
      return await saveTransactions(transactions);
    } catch (e) {
      print('Error adding transaction: $e');
      return false;
    }
  }

  /// Update a transaction
  static Future<bool> updateTransaction(Transaction transaction) async {
    try {
      final transactions = await loadTransactions();
      final index = transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        transactions[index] = transaction;
        return await saveTransactions(transactions);
      }
      return false;
    } catch (e) {
      print('Error updating transaction: $e');
      return false;
    }
  }

  /// Delete a transaction
  static Future<bool> deleteTransaction(String transactionId) async {
    try {
      final transactions = await loadTransactions();
      transactions.removeWhere((t) => t.id == transactionId);
      return await saveTransactions(transactions);
    } catch (e) {
      print('Error deleting transaction: $e');
      return false;
    }
  }

  // Account Storage Methods
  
  /// Save accounts to local storage
  static Future<bool> saveAccounts(List<Account> accounts) async {
    try {
      print('StorageService: Saving ${accounts.length} accounts');
      final jsonList = accounts.map((a) => a.toJson()).toList();
      print('StorageService: JSON conversion successful');
      final jsonString = jsonEncode(jsonList);
      print('StorageService: JSON encoding successful, length: ${jsonString.length}');
      final result = await prefs.setString(AppConstants.accountsKey, jsonString);
      print('StorageService: SharedPreferences save result: $result');
      return result;
    } catch (e) {
      print('StorageService: Error saving accounts: $e');
      print('StorageService: Error stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Load accounts from local storage
  static Future<List<Account>> loadAccounts() async {
    try {
      final jsonString = prefs.getString(AppConstants.accountsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Account.fromJson(json)).toList();
    } catch (e) {
      print('Error loading accounts: $e');
      return [];
    }
  }

  /// Add a single account
  static Future<bool> addAccount(Account account) async {
    try {
      final accounts = await loadAccounts();
      accounts.add(account);
      return await saveAccounts(accounts);
    } catch (e) {
      print('Error adding account: $e');
      return false;
    }
  }

  /// Update an account
  static Future<bool> updateAccount(Account account) async {
    try {
      final accounts = await loadAccounts();
      final index = accounts.indexWhere((a) => a.id == account.id);
      if (index != -1) {
        accounts[index] = account;
        return await saveAccounts(accounts);
      }
      return false;
    } catch (e) {
      print('Error updating account: $e');
      return false;
    }
  }

  /// Delete an account
  static Future<bool> deleteAccount(String accountId) async {
    try {
      final accounts = await loadAccounts();
      accounts.removeWhere((a) => a.id == accountId);
      return await saveAccounts(accounts);
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  // Category Storage Methods
  
  /// Save categories to local storage
  static Future<bool> saveCategories(List<Category> categories) async {
    try {
      final jsonList = categories.map((c) => c.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await prefs.setString(AppConstants.categoriesKey, jsonString);
    } catch (e) {
      print('Error saving categories: $e');
      return false;
    }
  }

  /// Load categories from local storage
  static Future<List<Category>> loadCategories() async {
    try {
      final jsonString = prefs.getString(AppConstants.categoriesKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      print('Error loading categories: $e');
      return [];
    }
  }

  /// Add a single category
  static Future<bool> addCategory(Category category) async {
    try {
      final categories = await loadCategories();
      categories.add(category);
      return await saveCategories(categories);
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }

  /// Update a category
  static Future<bool> updateCategory(Category category) async {
    try {
      final categories = await loadCategories();
      final index = categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        categories[index] = category;
        return await saveCategories(categories);
      }
      return false;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  /// Delete a category
  static Future<bool> deleteCategory(String categoryId) async {
    try {
      final categories = await loadCategories();
      categories.removeWhere((c) => c.id == categoryId);
      return await saveCategories(categories);
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  // Settings Storage Methods
  
  /// Save settings to local storage
  static Future<bool> saveSettings(Settings settings) async {
    try {
      final jsonString = jsonEncode(settings.toJson());
      return await prefs.setString(AppConstants.settingsKey, jsonString);
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }

  /// Load settings from local storage
  static Future<Settings> loadSettings() async {
    try {
      final jsonString = prefs.getString(AppConstants.settingsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return Settings.defaults();
      }
      
      final json = jsonDecode(jsonString);
      return Settings.fromJson(json);
    } catch (e) {
      print('Error loading settings: $e');
      return Settings.defaults();
    }
  }

  /// Update settings
  static Future<bool> updateSettings(Settings settings) async {
    return await saveSettings(settings);
  }

  // Utility Methods
  
  /// Clear all data
  static Future<bool> clearAllData() async {
    try {
      await prefs.remove(AppConstants.transactionsKey);
      await prefs.remove(AppConstants.accountsKey);
      await prefs.remove(AppConstants.categoriesKey);
      await prefs.remove(AppConstants.settingsKey);
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }

  /// Export all data as JSON
  static Future<Map<String, dynamic>> exportData() async {
    try {
      final transactions = await loadTransactions();
      final accounts = await loadAccounts();
      final categories = await loadCategories();
      final settings = await loadSettings();

      return {
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'accounts': accounts.map((a) => a.toJson()).toList(),
        'categories': categories.map((c) => c.toJson()).toList(),
        'settings': settings.toJson(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': AppConstants.appVersion,
      };
    } catch (e) {
      print('Error exporting data: $e');
      return {};
    }
  }

  /// Import data from JSON
  static Future<bool> importData(Map<String, dynamic> data) async {
    try {
      if (data['transactions'] != null) {
        final transactions = (data['transactions'] as List)
            .map((json) => Transaction.fromJson(json))
            .toList();
        await saveTransactions(transactions);
      }

      if (data['accounts'] != null) {
        final accounts = (data['accounts'] as List)
            .map((json) => Account.fromJson(json))
            .toList();
        await saveAccounts(accounts);
      }

      if (data['categories'] != null) {
        final categories = (data['categories'] as List)
            .map((json) => Category.fromJson(json))
            .toList();
        await saveCategories(categories);
      }

      if (data['settings'] != null) {
        final settings = Settings.fromJson(data['settings']);
        await saveSettings(settings);
      }

      return true;
    } catch (e) {
      print('Error importing data: $e');
      return false;
    }
  }

  /// Check if data exists
  static bool hasData() {
    return prefs.containsKey(AppConstants.transactionsKey) ||
           prefs.containsKey(AppConstants.accountsKey) ||
           prefs.containsKey(AppConstants.categoriesKey);
  }

  /// Get storage statistics
  static Future<Map<String, int>> getStorageStats() async {
    try {
      final transactions = await loadTransactions();
      final accounts = await loadAccounts();
      final categories = await loadCategories();

      return {
        'transactions': transactions.length,
        'accounts': accounts.length,
        'categories': categories.length,
      };
    } catch (e) {
      print('Error getting storage stats: $e');
      return {};
    }
  }
}
