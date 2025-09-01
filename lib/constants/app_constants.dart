import 'package:flutter/material.dart';

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
  
  // Transaction Types
  static const String transactionTypeIncome = 'income';
  static const String transactionTypeExpense = 'expense';
  static const String transactionTypeTransfer = 'transfer';
  
  // Category Types
  static const String categoryTypeIncome = 'income';
  static const String categoryTypeExpense = 'expense';
  static const String categoryTypeBoth = 'both';
  
  // Account Types
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
  ];
  
  // Default Accounts
  static const List<Map<String, dynamic>> defaultAccounts = [
    {
      'name': 'Cash',
      'icon': Icons.money,
      'color': Colors.green,
      'balance': 0.0,
    },
    {
      'name': 'Bank Account',
      'icon': Icons.account_balance,
      'color': Colors.blue,
      'balance': 0.0,
    },
  ];
  
  // Theme Colors
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.blueAccent;
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color infoColor = Colors.blue;
  
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
