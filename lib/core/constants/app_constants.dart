import 'package:flutter/material.dart';
import '../models/accounts/account_type.dart';

/// App-wide constants for the Kora Expense Tracker
class AppConstants {
  // App Information
  static const String appName = 'Kora Expense Tracker';
  static const String appVersion = '1.0.2';


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

  // Default Categories — comprehensive, modern, India-relevant
  static const List<Map<String, dynamic>> defaultCategories = [

    // ── Income ─────────────────────────────────────────────────────────────
    {
      'name': 'Salary',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFF16A34A), // green-600
      'type': 'income',
    },
    {
      'name': 'Freelance',
      'icon': Icons.laptop_mac,
      'color': Color(0xFF0284C7), // sky-600
      'type': 'income',
    },
    {
      'name': 'Business',
      'icon': Icons.store,
      'color': Color(0xFF7C3AED), // violet-600
      'type': 'income',
    },
    {
      'name': 'Investment Returns',
      'icon': Icons.trending_up,
      'color': Color(0xFF059669), // emerald-600
      'type': 'income',
    },
    {
      'name': 'Gift / Bonus',
      'icon': Icons.card_giftcard,
      'color': Color(0xFFDB2777), // pink-600
      'type': 'income',
    },
    {
      'name': 'Other Income',
      'icon': Icons.add_circle_outline,
      'color': Color(0xFF65A30D), // lime-600
      'type': 'income',
    },

    // ── Expense ─────────────────────────────────────────────────────────────
    {
      'name': 'Food & Dining',
      'icon': Icons.lunch_dining,
      'color': Color(0xFFEA580C), // orange-600
      'type': 'expense',
    },
    {
      'name': 'Groceries',
      'icon': Icons.local_grocery_store,
      'color': Color(0xFF16A34A), // green-600
      'type': 'expense',
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_bus,
      'color': Color(0xFF2563EB), // blue-600
      'type': 'expense',
    },
    {
      'name': 'Fuel',
      'icon': Icons.local_gas_station,
      'color': Color(0xFFCA8A04), // yellow-600
      'type': 'expense',
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': Color(0xFFEC4899), // pink-500
      'type': 'expense',
    },
    {
      'name': 'Bills & Utilities',
      'icon': Icons.electric_bolt,
      'color': Color(0xFFD97706), // amber-600
      'type': 'expense',
    },
    {
      'name': 'Rent & Housing',
      'icon': Icons.home,
      'color': Color(0xFF7C3AED), // violet-600
      'type': 'expense',
    },
    {
      'name': 'Healthcare',
      'icon': Icons.local_hospital,
      'color': Color(0xFFDC2626), // red-600
      'type': 'expense',
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie_filter,
      'color': Color(0xFF9333EA), // purple-600
      'type': 'expense',
    },
    {
      'name': 'Subscriptions',
      'icon': Icons.subscriptions,
      'color': Color(0xFF0891B2), // cyan-600
      'type': 'expense',
    },
    {
      'name': 'Education',
      'icon': Icons.menu_book,
      'color': Color(0xFF0284C7), // sky-600
      'type': 'expense',
    },
    {
      'name': 'Travel',
      'icon': Icons.flight_takeoff,
      'color': Color(0xFF0369A1), // sky-700
      'type': 'expense',
    },
    {
      'name': 'Personal Care',
      'icon': Icons.spa,
      'color': Color(0xFFBE185D), // pink-700
      'type': 'expense',
    },
    {
      'name': 'EMI / Loan',
      'icon': Icons.account_balance,
      'color': Color(0xFF374151), // gray-700
      'type': 'expense',
    },
    {
      'name': 'Credit Card Bill',
      'icon': Icons.credit_card,
      'color': Color(0xFF1D4ED8), // blue-700
      'type': 'expense',
    },
    {
      'name': 'Savings & Investment',
      'icon': Icons.savings,
      'color': Color(0xFF15803D), // green-700
      'type': 'expense',
    },
    {
      'name': 'Other',
      'icon': Icons.more_horiz,
      'color': Color(0xFF6B7280), // gray-500
      'type': 'expense',
    },
  ];

  // Default Accounts - Empty for production (users will create their own)
  static const List<Map<String, dynamic>> defaultAccounts = [];

  // Popular Wallet Types for Quick Selection
  static List<Map<String, dynamic>> get popularWallets =>
      AccountType.getPopularWallets();

  // Popular Bank Types for Quick Selection
  static List<Map<String, dynamic>> get popularBanks =>
      AccountType.getPopularBanks();

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
  static const Color utilizationModerateColor = Color(
    0xFFD97706,
  ); // Moderate Orange
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

  // Compact UI Constants (for denser layouts)
  static const double compactPadding = 10.0;
  static const double compactSmallPadding = 5.0;
  static const double compactLargePadding = 16.0;

  // Responsive helpers — returns a value scaled to screen height
  // Screens < 700dp get ~75% of base, >= 700dp get 100%
  static double responsivePadding(double screenHeight, double base) {
    if (screenHeight < 600) return base * 0.65;
    if (screenHeight < 700) return base * 0.80;
    return base;
  }

  static double responsiveIconSize(double screenHeight, double base) {
    if (screenHeight < 600) return base * 0.70;
    if (screenHeight < 700) return base * 0.85;
    return base;
  }

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
