import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
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
import 'database_helper.dart';

/// Service for handling local data storage seamlessly switching to SQLite
class StorageService {
  static SharedPreferences? _prefs;

  /// Initialize the storage service and seamlessly migrate legacy data
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await DatabaseHelper.instance.init();
    await _migrateLegacyDataIfNeeded();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized.');
    }
    return _prefs!;
  }

  /// ONE-TIME MIGRATION SCRIPT: Moves old SharedPreferences JSON to SQLite
  static Future<void> _migrateLegacyDataIfNeeded() async {
    if (_prefs!.getBool('is_sqlite_migrated') == true) return;
    debugPrint("Running one-time Database Migration to SQLite...");

    Future<void> migrateCollection(
      String key,
      Function(Map<String, dynamic>) fromJson,
      String Function(dynamic) getId,
    ) async {
      try {
        final jsonString = _prefs!.getString(key);
        if (jsonString != null && jsonString.isNotEmpty) {
          final jsonList = jsonDecode(jsonString) as List;
          for (var item in jsonList) {
            final obj = fromJson(item as Map<String, dynamic>);
            await DatabaseHelper.instance.insertDocument(key, getId(obj), item);
          }
          await _prefs!.remove(key); // Free up space!
        }
      } catch (e) {
        debugPrint("Migration failed for $key: $e");
      }
    }

    await migrateCollection(
      AppConstants.transactionsKey,
      (j) => Transaction.fromJson(j),
      (o) => (o as Transaction).id,
    );
    await migrateCollection(
      AppConstants.accountsKey,
      (j) => Account.fromJson(j),
      (o) => (o as Account).id,
    );
    await migrateCollection(
      AppConstants.categoriesKey,
      (j) => Category.fromJson(j),
      (o) => (o as Category).id,
    );
    await migrateCollection(
      AppConstants.creditCardsKey,
      (j) => CreditCard.fromJson(j),
      (o) => (o as CreditCard).id,
    );
    await migrateCollection(
      AppConstants.creditCardStatementsKey,
      (j) => CreditCardStatement.fromJson(j),
      (o) => (o as CreditCardStatement).id,
    );
    await migrateCollection(
      AppConstants.paymentRecordsKey,
      (j) => PaymentRecord.fromJson(j),
      (o) => (o as PaymentRecord).id,
    );
    await migrateCollection(
      AppConstants.paymentsKey,
      (j) => Payment.fromJson(j),
      (o) => (o as Payment).id,
    );
    await migrateCollection(
      AppConstants.bankAccountsKey,
      (j) => BankAccount.fromJson(j),
      (o) => (o as BankAccount).id,
    );

    await _prefs!.setBool('is_sqlite_migrated', true);
    debugPrint("Database Migration Complete!");
  }

  // ================= Transactions ==================
  static Future<bool> saveTransactions(List<Transaction> items) async {
    await DatabaseHelper.instance.clearCollection(AppConstants.transactionsKey);
    for (var t in items) {
      await addTransaction(t);
    }
    return true;
  }

  static Future<List<Transaction>> loadTransactions() async {
    final docs = await DatabaseHelper.instance.getDocuments(
      AppConstants.transactionsKey,
    );
    return docs.map((json) => Transaction.fromJson(json)).toList();
  }

  static Future<bool> addTransaction(Transaction item) async =>
      await DatabaseHelper.instance.insertDocument(
        AppConstants.transactionsKey,
        item.id,
        item.toJson(),
      );
  static Future<bool> updateTransaction(Transaction item) async =>
      await DatabaseHelper.instance.updateDocument(AppConstants.transactionsKey, item.id, item.toJson());
  static Future<bool> deleteTransaction(String id) async =>
      await DatabaseHelper.instance.deleteDocument(AppConstants.transactionsKey, id);

  // ================= Accounts ==================
  static Future<bool> saveAccounts(List<Account> items) async {
    await DatabaseHelper.instance.clearCollection(AppConstants.accountsKey);
    for (var i in items) {
      await addAccount(i);
    }
    return true;
  }

  static Future<List<Account>> loadAccounts() async {
    final docs = await DatabaseHelper.instance.getDocuments(
      AppConstants.accountsKey,
    );
    return docs.map((json) => Account.fromJson(json)).toList();
  }

  static Future<bool> addAccount(Account item) async => await DatabaseHelper
      .instance
      .insertDocument(AppConstants.accountsKey, item.id, item.toJson());
  static Future<bool> updateAccount(Account item) async =>
      await DatabaseHelper.instance.updateDocument(AppConstants.accountsKey, item.id, item.toJson());
  static Future<bool> deleteAccount(String id) async =>
      await DatabaseHelper.instance.deleteDocument(AppConstants.accountsKey, id);

  // ================= Categories ==================
  static Future<bool> saveCategories(List<Category> items) async {
    await DatabaseHelper.instance.clearCollection(AppConstants.categoriesKey);
    for (var i in items) {
      await addCategory(i);
    }
    return true;
  }

  static Future<List<Category>> loadCategories() async {
    final docs = await DatabaseHelper.instance.getDocuments(
      AppConstants.categoriesKey,
    );
    return docs.map((json) => Category.fromJson(json)).toList();
  }

  static Future<bool> addCategory(Category item) async => await DatabaseHelper
      .instance
      .insertDocument(AppConstants.categoriesKey, item.id, item.toJson());
  static Future<bool> updateCategory(Category item) async =>
      await DatabaseHelper.instance.updateDocument(AppConstants.categoriesKey, item.id, item.toJson());
  static Future<bool> deleteCategory(String id) async =>
      await DatabaseHelper.instance.deleteDocument(AppConstants.categoriesKey, id);

  // ================= Credit Cards ==================
  static Future<bool> saveCreditCards(List<CreditCard> items) async {
    await DatabaseHelper.instance.clearCollection(AppConstants.creditCardsKey);
    for (var i in items) {
      await addCreditCard(i);
    }
    return true;
  }

  static Future<List<CreditCard>> loadCreditCards() async {
    final docs = await DatabaseHelper.instance.getDocuments(
      AppConstants.creditCardsKey,
    );
    return docs.map((json) => CreditCard.fromJson(json)).toList();
  }

  static Future<bool> addCreditCard(CreditCard item) async =>
      await DatabaseHelper.instance.insertDocument(
        AppConstants.creditCardsKey,
        item.id,
        item.toJson(),
      );
  static Future<bool> updateCreditCard(CreditCard item) async =>
      await DatabaseHelper.instance.updateDocument(AppConstants.creditCardsKey, item.id, item.toJson());
  static Future<bool> deleteCreditCard(String id) async =>
      await DatabaseHelper.instance.deleteDocument(AppConstants.creditCardsKey, id);

  // ================= Statements ==================
  static Future<bool> saveCreditCardStatements(
    List<CreditCardStatement> items,
  ) async {
    await DatabaseHelper.instance.clearCollection(
      AppConstants.creditCardStatementsKey,
    );
    for (var i in items) {
      await addCreditCardStatement(i);
    }
    return true;
  }

  static Future<List<CreditCardStatement>> loadCreditCardStatements() async {
    final docs = await DatabaseHelper.instance.getDocuments(
      AppConstants.creditCardStatementsKey,
    );
    return docs.map((json) => CreditCardStatement.fromJson(json)).toList();
  }

  static Future<bool> addCreditCardStatement(CreditCardStatement item) async =>
      await DatabaseHelper.instance.insertDocument(
        AppConstants.creditCardStatementsKey,
        item.id,
        item.toJson(),
      );
  static Future<bool> updateCreditCardStatement(
    CreditCardStatement item,
  ) async =>
      await DatabaseHelper.instance.updateDocument(AppConstants.creditCardStatementsKey, item.id, item.toJson());
  static Future<bool> deleteCreditCardStatement(String id) async =>
      await DatabaseHelper.instance.deleteDocument(AppConstants.creditCardStatementsKey, id);

  // ================= Payment Records ==================
  static Future<bool> savePaymentRecords(List<PaymentRecord> items) async {
    await DatabaseHelper.instance.clearCollection(
      AppConstants.paymentRecordsKey,
    );
    for (var i in items) {
      await addPaymentRecord(i);
    }
    return true;
  }

  static Future<List<PaymentRecord>> loadPaymentRecords() async {
    final docs = await DatabaseHelper.instance.getDocuments(
      AppConstants.paymentRecordsKey,
    );
    return docs.map((json) => PaymentRecord.fromJson(json)).toList();
  }

  static Future<bool> addPaymentRecord(PaymentRecord item) async =>
      await DatabaseHelper.instance.insertDocument(
        AppConstants.paymentRecordsKey,
        item.id,
        item.toJson(),
      );
  static Future<bool> updatePaymentRecord(PaymentRecord item) async =>
      await DatabaseHelper.instance.updateDocument(AppConstants.paymentRecordsKey, item.id, item.toJson());
  static Future<bool> deletePaymentRecord(String id) async =>
      await DatabaseHelper.instance.deleteDocument(AppConstants.paymentRecordsKey, id);

  // ================= Payments ==================
  static Future<bool> savePayments(List<Payment> items) async {
    await DatabaseHelper.instance.clearCollection(AppConstants.paymentsKey);
    for (var i in items) {
      await addPayment(i);
    }
    return true;
  }

  static Future<List<Payment>> loadPayments() async {
    final docs = await DatabaseHelper.instance.getDocuments(
      AppConstants.paymentsKey,
    );
    return docs.map((json) => Payment.fromJson(json)).toList();
  }

  static Future<bool> addPayment(Payment item) async => await DatabaseHelper
      .instance
      .insertDocument(AppConstants.paymentsKey, item.id, item.toJson());
  static Future<bool> updatePayment(Payment item) async =>
      await DatabaseHelper.instance.updateDocument(AppConstants.paymentsKey, item.id, item.toJson());
  static Future<bool> deletePayment(String id) async =>
      await DatabaseHelper.instance.deleteDocument(AppConstants.paymentsKey, id);

  // ================= Bank Accounts ==================
  static Future<bool> saveBankAccounts(List<BankAccount> items) async {
    await DatabaseHelper.instance.clearCollection(AppConstants.bankAccountsKey);
    for (var i in items) {
      await addBankAccount(i);
    }
    return true;
  }

  static Future<List<BankAccount>> loadBankAccounts() async {
    final docs = await DatabaseHelper.instance.getDocuments(
      AppConstants.bankAccountsKey,
    );
    return docs.map((json) => BankAccount.fromJson(json)).toList();
  }

  static Future<bool> addBankAccount(BankAccount item) async =>
      await DatabaseHelper.instance.insertDocument(
        AppConstants.bankAccountsKey,
        item.id,
        item.toJson(),
      );
  static Future<bool> updateBankAccount(BankAccount item) async =>
      await DatabaseHelper.instance.updateDocument(AppConstants.bankAccountsKey, item.id, item.toJson());
  static Future<bool> deleteBankAccount(String id) async =>
      await DatabaseHelper.instance.deleteDocument(AppConstants.bankAccountsKey, id);

  // ================= Settings (Remains strictly in SharedPreferences) ==================
  static Future<bool> saveSettings(Settings settings) async {
    try {
      final jsonString = jsonEncode(settings.toJson());
      return await prefs.setString(AppConstants.settingsKey, jsonString);
    } catch (e) {
      debugPrint('Error saving settings: $e');
      return false;
    }
  }

  static Future<Settings> loadSettings() async {
    try {
      final jsonString = prefs.getString(AppConstants.settingsKey);
      if (jsonString == null || jsonString.isEmpty) return Settings.defaults();
      return Settings.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return Settings.defaults();
    }
  }

  static Future<bool> updateSettings(Settings settings) async =>
      await saveSettings(settings);

  // ================= Global Utilities ==================
  static Future<bool> clearAllData() async {
    try {
      await DatabaseHelper.instance.clearCollection(
        AppConstants.transactionsKey,
      );
      await DatabaseHelper.instance.clearCollection(AppConstants.accountsKey);
      await DatabaseHelper.instance.clearCollection(AppConstants.categoriesKey);
      await DatabaseHelper.instance.clearCollection(
        AppConstants.creditCardsKey,
      );
      await DatabaseHelper.instance.clearCollection(
        AppConstants.creditCardStatementsKey,
      );
      await DatabaseHelper.instance.clearCollection(
        AppConstants.paymentRecordsKey,
      );
      await DatabaseHelper.instance.clearCollection(AppConstants.paymentsKey);
      await DatabaseHelper.instance.clearCollection(
        AppConstants.bankAccountsKey,
      );
      await prefs.remove(AppConstants.settingsKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool hasData() {
    // Check SharedPreferences flag or actual sqlite data. Actually, checking if sqlite has transactions is easy.
    // However, since this is a synchronous method in the old architecture (which is bad),
    // wait, `hasData()` was historically synchronous `return prefs.containsKey(AppConstants.transactionsKey);`.
    // We can rely on `is_sqlite_migrated` or if there's any setting saved to indicate that data exists.
    return prefs.getBool('is_sqlite_migrated') == true ||
        prefs.containsKey(AppConstants.transactionsKey);
  }

  static Future<Map<String, int>> getStorageStats() async {
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
  }

  static Future<Map<String, dynamic>> exportData() async {
    return {
      'transactions': (await loadTransactions())
          .map((t) => t.toJson())
          .toList(),
      'accounts': (await loadAccounts()).map((a) => a.toJson()).toList(),
      'categories': (await loadCategories()).map((c) => c.toJson()).toList(),
      'settings': (await loadSettings()).toJson(),
      'creditCards': (await loadCreditCards()).map((c) => c.toJson()).toList(),
      'statements': (await loadCreditCardStatements())
          .map((s) => s.toJson())
          .toList(),
      'payments': (await loadPayments()).map((p) => p.toJson()).toList(),
      'paymentRecords': (await loadPaymentRecords())
          .map((p) => p.toJson())
          .toList(),
      'bankAccounts': (await loadBankAccounts())
          .map((b) => b.toJson())
          .toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'version': AppConstants.appVersion,
    };
  }

  static Future<bool> importData(Map<String, dynamic> data) async {
    try {
      if (data['transactions'] != null) {
        await saveTransactions(
          (data['transactions'] as List)
              .map((j) => Transaction.fromJson(j))
              .toList(),
        );
      }
      if (data['accounts'] != null) {
        await saveAccounts(
          (data['accounts'] as List).map((j) => Account.fromJson(j)).toList(),
        );
      }
      if (data['categories'] != null) {
        await saveCategories(
          (data['categories'] as List)
              .map((j) => Category.fromJson(j))
              .toList(),
        );
      }
      if (data['creditCards'] != null) {
        await saveCreditCards(
          (data['creditCards'] as List)
              .map((j) => CreditCard.fromJson(j))
              .toList(),
        );
      }
      if (data['statements'] != null) {
        await saveCreditCardStatements(
          (data['statements'] as List)
              .map((j) => CreditCardStatement.fromJson(j))
              .toList(),
        );
      }
      if (data['payments'] != null) {
        await savePayments(
          (data['payments'] as List).map((j) => Payment.fromJson(j)).toList(),
        );
      }
      if (data['paymentRecords'] != null) {
        await savePaymentRecords(
          (data['paymentRecords'] as List)
              .map((j) => PaymentRecord.fromJson(j))
              .toList(),
        );
      }
      if (data['bankAccounts'] != null) {
        await saveBankAccounts(
          (data['bankAccounts'] as List)
              .map((j) => BankAccount.fromJson(j))
              .toList(),
        );
      }
      if (data['settings'] != null) {
        // Assume settings is a map, otherwise parse it
        try {
          await saveSettings(
            Settings.fromJson(data['settings'] as Map<String, dynamic>),
          );
        } catch (e) {
          // fallback
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }
}
