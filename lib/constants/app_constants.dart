import 'package:flutter/material.dart';
import '../models/account_type.dart';

/// App-wide constants for the Kora Expense Tracker
class AppConstants {
  // App Information
  static const String appName = 'Kora Expense Tracker';
  static const String appVersion = '1.0.0';
  
  // Default Currency (INR - Indian Rupee)
  static const String defaultCurrency = 'INR';
  static const String defaultCurrencySymbol = '₹';
  
  // Default Locale
  static const String defaultLocale = 'en';
  
  // Storage Keys
  static const String transactionsKey = 'transactions';
  static const String accountsKey = 'accounts';
  static const String categoriesKey = 'categories';
  static const String settingsKey = 'settings';
  static const String creditCardsKey = 'credit_cards';
  static const String creditCardStatementsKey = 'credit_card_statements';
  static const String paymentRecordsKey = 'payment_records';
  static const String paymentsKey = 'payments';
  static const String bankAccountsKey = 'bank_accounts';
  
  // Transaction Types
  static const String transactionTypeIncome = 'income';
  static const String transactionTypeExpense = 'expense';
  static const String transactionTypeTransfer = 'transfer';
  
  // Category Types
  static const String categoryTypeIncome = 'income';
  static const String categoryTypeExpense = 'expense';
  static const String categoryTypeBoth = 'both';
  
  // Account Types (deprecated - use AccountType enum instead)
  static const String accountTypeCash = 'cash';
  static const String accountTypeBank = 'bank';
  static const String accountTypeCredit = 'credit';
  static const String accountTypeInvestment = 'investment';
  
  // Default Categories
  static const List<Map<String, dynamic>> defaultCategories = [
    // Income Categories
    {
      'name': 'Salary',
      'icon': Icons.work,
      'color': Colors.green,
      'type': 'income',
    },
    {
      'name': 'Freelance',
      'icon': Icons.computer,
      'color': Colors.blue,
      'type': 'income',
    },
    {
      'name': 'Investment',
      'icon': Icons.trending_up,
      'color': Colors.orange,
      'type': 'income',
    },
    {
      'name': 'Gift',
      'icon': Icons.card_giftcard,
      'color': Colors.purple,
      'type': 'income',
    },
    
    // Expense Categories
    {
      'name': 'Food & Dining',
      'icon': Icons.restaurant,
      'color': Colors.red,
      'type': 'expense',
    },
    {
      'name': 'Transportation',
      'icon': Icons.directions_car,
      'color': Colors.indigo,
      'type': 'expense',
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': Colors.pink,
      'type': 'expense',
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie,
      'color': Colors.amber,
      'type': 'expense',
    },
    {
      'name': 'Healthcare',
      'icon': Icons.medical_services,
      'color': Colors.teal,
      'type': 'expense',
    },
    {
      'name': 'Bills & Utilities',
      'icon': Icons.receipt,
      'color': Colors.grey,
      'type': 'expense',
    },
    {
      'name': 'Education',
      'icon': Icons.school,
      'color': Colors.cyan,
      'type': 'expense',
    },
    {
      'name': 'Travel',
      'icon': Icons.flight,
      'color': Colors.deepOrange,
      'type': 'expense',
    },
    {
      'name': 'Credit Card Payment',
      'icon': Icons.payment,
      'color': Colors.blue,
      'type': 'expense',
    },
  ];
  
  // Default Accounts - Empty for production (users will create their own)
  static const List<Map<String, dynamic>> defaultAccounts = [];

  // Popular Wallet Types for Quick Selection
  static List<Map<String, dynamic>> get popularWallets => AccountType.getPopularWallets();

  // Popular Bank Types for Quick Selection
  static List<Map<String, dynamic>> get popularBanks => AccountType.getPopularBanks();
  
  // Theme Colors - Kora Finance Brand Colors
  static const Color primaryColor = Color(0xFF1E40AF); // Deep Professional Blue
  static const Color secondaryColor = Color(0xFF3B82F6); // Bright Accent Blue
  static const Color successColor = Color(0xFF059669); // Professional Green
  static const Color errorColor = Color(0xFFDC2626); // Professional Red
  static const Color warningColor = Color(0xFFD97706); // Professional Orange
  static const Color infoColor = Color(0xFF0EA5E9); // Professional Cyan
  
  // Credit Card Specific Colors
  static const Color creditLimitColor = Color(0xFF2B6CB0); // Strong Blue
  static const Color outstandingColor = Color(0xFFC53030); // Strong Red
  static const Color availableColor = Color(0xFF2F855A); // Strong Green
  static const Color utilizationGoodColor = Color(0xFF2F855A); // Good Green
  static const Color utilizationModerateColor = Color(0xFFD97706); // Moderate Orange
  static const Color utilizationHighColor = Color(0xFFDC2626); // High Red
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';
  
  // Validation Constants
  static const int maxTransactionAmount = 999999999;
  static const int maxDescriptionLength = 200;
  static const int maxAccountNameLength = 50;
  static const int maxCategoryNameLength = 30;
}
