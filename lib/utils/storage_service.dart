import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/settings.dart';
import '../models/credit_card.dart';
import '../models/credit_card_statement.dart';
import '../models/payment_record.dart';
import '../models/payment.dart';
import '../models/bank_account.dart';

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
  
  // Credit Card Storage Methods
  
  /// Save credit cards to local storage
  static Future<bool> saveCreditCards(List<CreditCard> creditCards) async {
    try {
      final jsonList = creditCards.map((cc) => cc.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await prefs.setString(AppConstants.creditCardsKey, jsonString);
    } catch (e) {
      print('Error saving credit cards: $e');
      return false;
    }
  }

  /// Load credit cards from local storage
  static Future<List<CreditCard>> loadCreditCards() async {
    try {
      final jsonString = prefs.getString(AppConstants.creditCardsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => CreditCard.fromJson(json)).toList();
    } catch (e) {
      print('Error loading credit cards: $e');
      return [];
    }
  }

  /// Add a single credit card
  static Future<bool> addCreditCard(CreditCard creditCard) async {
    try {
      final creditCards = await loadCreditCards();
      creditCards.add(creditCard);
      return await saveCreditCards(creditCards);
    } catch (e) {
      print('Error adding credit card: $e');
      return false;
    }
  }

  /// Update a credit card
  static Future<bool> updateCreditCard(CreditCard creditCard) async {
    try {
      final creditCards = await loadCreditCards();
      final index = creditCards.indexWhere((cc) => cc.id == creditCard.id);
      if (index != -1) {
        creditCards[index] = creditCard;
        return await saveCreditCards(creditCards);
      }
      return false;
    } catch (e) {
      print('Error updating credit card: $e');
      return false;
    }
  }

  /// Delete a credit card
  static Future<bool> deleteCreditCard(String creditCardId) async {
    try {
      final creditCards = await loadCreditCards();
      creditCards.removeWhere((cc) => cc.id == creditCardId);
      return await saveCreditCards(creditCards);
    } catch (e) {
      print('Error deleting credit card: $e');
      return false;
    }
  }

  // Credit Card Statement Storage Methods
  
  /// Save credit card statements to local storage
  static Future<bool> saveCreditCardStatements(List<CreditCardStatement> statements) async {
    try {
      final jsonList = statements.map((stmt) => stmt.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await prefs.setString(AppConstants.creditCardStatementsKey, jsonString);
    } catch (e) {
      print('Error saving credit card statements: $e');
      return false;
    }
  }

  /// Load credit card statements from local storage
  static Future<List<CreditCardStatement>> loadCreditCardStatements() async {
    try {
      final jsonString = prefs.getString(AppConstants.creditCardStatementsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => CreditCardStatement.fromJson(json)).toList();
    } catch (e) {
      print('Error loading credit card statements: $e');
      return [];
    }
  }

  /// Add a single credit card statement
  static Future<bool> addCreditCardStatement(CreditCardStatement statement) async {
    try {
      final statements = await loadCreditCardStatements();
      statements.add(statement);
      return await saveCreditCardStatements(statements);
    } catch (e) {
      print('Error adding credit card statement: $e');
      return false;
    }
  }

  /// Update a credit card statement
  static Future<bool> updateCreditCardStatement(CreditCardStatement statement) async {
    try {
      final statements = await loadCreditCardStatements();
      final index = statements.indexWhere((stmt) => stmt.id == statement.id);
      if (index != -1) {
        statements[index] = statement;
        return await saveCreditCardStatements(statements);
      }
      return false;
    } catch (e) {
      print('Error updating credit card statement: $e');
      return false;
    }
  }

  /// Delete a credit card statement
  static Future<bool> deleteCreditCardStatement(String statementId) async {
    try {
      final statements = await loadCreditCardStatements();
      statements.removeWhere((stmt) => stmt.id == statementId);
      return await saveCreditCardStatements(statements);
    } catch (e) {
      print('Error deleting credit card statement: $e');
      return false;
    }
  }

  // Payment Record Storage Methods
  
  /// Save payment records to local storage
  static Future<bool> savePaymentRecords(List<PaymentRecord> payments) async {
    try {
      final jsonList = payments.map((payment) => payment.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await prefs.setString(AppConstants.paymentRecordsKey, jsonString);
    } catch (e) {
      print('Error saving payment records: $e');
      return false;
    }
  }

  /// Load payment records from local storage
  static Future<List<PaymentRecord>> loadPaymentRecords() async {
    try {
      final jsonString = prefs.getString(AppConstants.paymentRecordsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => PaymentRecord.fromJson(json)).toList();
    } catch (e) {
      print('Error loading payment records: $e');
      return [];
    }
  }

  /// Add a single payment record
  static Future<bool> addPaymentRecord(PaymentRecord payment) async {
    try {
      final payments = await loadPaymentRecords();
      payments.add(payment);
      return await savePaymentRecords(payments);
    } catch (e) {
      print('Error adding payment record: $e');
      return false;
    }
  }

  /// Update a payment record
  static Future<bool> updatePaymentRecord(PaymentRecord payment) async {
    try {
      final payments = await loadPaymentRecords();
      final index = payments.indexWhere((p) => p.id == payment.id);
      if (index != -1) {
        payments[index] = payment;
        return await savePaymentRecords(payments);
      }
      return false;
    } catch (e) {
      print('Error updating payment record: $e');
      return false;
    }
  }

  /// Delete a payment record
  static Future<bool> deletePaymentRecord(String paymentId) async {
    try {
      final payments = await loadPaymentRecords();
      payments.removeWhere((p) => p.id == paymentId);
      return await savePaymentRecords(payments);
    } catch (e) {
      print('Error deleting payment record: $e');
      return false;
    }
  }

  /// Clear all data
  static Future<bool> clearAllData() async {
    try {
      await prefs.remove(AppConstants.transactionsKey);
      await prefs.remove(AppConstants.accountsKey);
      await prefs.remove(AppConstants.categoriesKey);
      await prefs.remove(AppConstants.settingsKey);
      await prefs.remove(AppConstants.creditCardsKey);
      await prefs.remove(AppConstants.creditCardStatementsKey);
      await prefs.remove(AppConstants.paymentRecordsKey);
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

  // Payment Storage Methods

  /// Save payments to local storage
  static Future<bool> savePayments(List<Payment> payments) async {
    try {
      final jsonList = payments.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await prefs.setString(AppConstants.paymentsKey, jsonString);
    } catch (e) {
      print('Error saving payments: $e');
      return false;
    }
  }

  /// Load payments from local storage
  static Future<List<Payment>> loadPayments() async {
    try {
      final jsonString = prefs.getString(AppConstants.paymentsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      print('Error loading payments: $e');
      return [];
    }
  }

  /// Add a single payment
  static Future<bool> addPayment(Payment payment) async {
    try {
      final payments = await loadPayments();
      payments.add(payment);
      return await savePayments(payments);
    } catch (e) {
      print('Error adding payment: $e');
      return false;
    }
  }

  /// Update a payment
  static Future<bool> updatePayment(Payment payment) async {
    try {
      final payments = await loadPayments();
      final index = payments.indexWhere((p) => p.id == payment.id);
      if (index != -1) {
        payments[index] = payment;
        return await savePayments(payments);
      }
      return false;
    } catch (e) {
      print('Error updating payment: $e');
      return false;
    }
  }

  /// Delete a payment
  static Future<bool> deletePayment(String paymentId) async {
    try {
      final payments = await loadPayments();
      payments.removeWhere((p) => p.id == paymentId);
      return await savePayments(payments);
    } catch (e) {
      print('Error deleting payment: $e');
      return false;
    }
  }

  // Bank Account Storage Methods

  /// Save bank accounts to local storage
  static Future<bool> saveBankAccounts(List<BankAccount> bankAccounts) async {
    try {
      final jsonList = bankAccounts.map((ba) => ba.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await prefs.setString(AppConstants.bankAccountsKey, jsonString);
    } catch (e) {
      print('Error saving bank accounts: $e');
      return false;
    }
  }

  /// Load bank accounts from local storage
  static Future<List<BankAccount>> loadBankAccounts() async {
    try {
      final jsonString = prefs.getString(AppConstants.bankAccountsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => BankAccount.fromJson(json)).toList();
    } catch (e) {
      print('Error loading bank accounts: $e');
      return [];
    }
  }

  /// Add a single bank account
  static Future<bool> addBankAccount(BankAccount bankAccount) async {
    try {
      final bankAccounts = await loadBankAccounts();
      bankAccounts.add(bankAccount);
      return await saveBankAccounts(bankAccounts);
    } catch (e) {
      print('Error adding bank account: $e');
      return false;
    }
  }

  /// Update a bank account
  static Future<bool> updateBankAccount(BankAccount bankAccount) async {
    try {
      final bankAccounts = await loadBankAccounts();
      final index = bankAccounts.indexWhere((ba) => ba.id == bankAccount.id);
      if (index != -1) {
        bankAccounts[index] = bankAccount;
        return await saveBankAccounts(bankAccounts);
      }
      return false;
    } catch (e) {
      print('Error updating bank account: $e');
      return false;
    }
  }

  /// Delete a bank account
  static Future<bool> deleteBankAccount(String bankAccountId) async {
    try {
      final bankAccounts = await loadBankAccounts();
      bankAccounts.removeWhere((ba) => ba.id == bankAccountId);
      return await saveBankAccounts(bankAccounts);
    } catch (e) {
      print('Error deleting bank account: $e');
      return false;
    }
  }

  /// Get storage statistics
  static Future<Map<String, int>> getStorageStats() async {
    try {
      final transactions = await loadTransactions();
      final accounts = await loadAccounts();
      final categories = await loadCategories();
      final creditCards = await loadCreditCards();
      final payments = await loadPayments();
      final bankAccounts = await loadBankAccounts();

      return {
        'transactions': transactions.length,
        'accounts': accounts.length,
        'categories': categories.length,
        'credit_cards': creditCards.length,
        'payments': payments.length,
        'bank_accounts': bankAccounts.length,
      };
    } catch (e) {
      print('Error getting storage stats: $e');
      return {};
    }
  }
}
