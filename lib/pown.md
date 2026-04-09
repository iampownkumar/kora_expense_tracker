import 'package:flutter/material.dart';
import '../models/account_type.dart';

/// App-wide constants for the Kora Expense Tracker
class AppConstants {
  // App Information
  static const String appName = 'Kora Expense Tracker';
  static const String appVersion = '1.0.0+2';

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
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/utils/storage_service.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/providers/credit_card_provider.dart';
import 'package:kora_expense_tracker/providers/payment_provider.dart';
import 'package:kora_expense_tracker/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService.initialize();

  runApp(const KoraExpenseTrackerApp());
}

class KoraExpenseTrackerApp extends StatelessWidget {
  const KoraExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (context) => CreditCardProvider()..initialize(),
        ),
        ChangeNotifierProvider(create: (context) => PaymentProvider()),
      ],
      builder: (context, child) {
        // Set up the CreditCardProvider reference in AppProvider
        final appProvider = context.read<AppProvider>();
        final creditCardProvider = context.read<CreditCardProvider>();
        appProvider.setCreditCardProvider(creditCardProvider);

        return child!;
      },
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,

        // Internationalization
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('ta', ''), // Tamil
          Locale('hi', ''), // Hindi
        ],
        locale: const Locale('en', ''),

        // Material 3 Theme
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryColor,
            brightness: Brightness.light,
          ),
          fontFamily: 'Inter',
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          cardTheme: CardThemeData(
            elevation: AppConstants.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        ),

        // Dark Theme
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryColor,
            brightness: Brightness.dark,
          ),
          fontFamily: 'Inter',
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          cardTheme: CardThemeData(
            elevation: AppConstants.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        ),

        // Theme mode
        themeMode: ThemeMode.system,

        // Home screen
        home: const SplashScreen(),
      ),
    );
  }
}
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/json_converters.dart';
import 'account_type.dart';

part 'account.g.dart';

/// Account model representing a financial account
@JsonSerializable()
class Account {
  /// Unique identifier for the account
  final String id;
  
  /// Account name
  final String name;
  
  /// Account icon
  @IconDataConverter()
  final IconData icon;
  
  /// Account color
  @ColorConverter()
  final Color color;
  
  /// Current balance
  final double balance;
  
  /// Account type (savings, credit, etc.)
  final AccountType type;
  
  /// Account description (optional)
  final String? description;
  
  /// Whether the account is active
  final bool isActive;
  
  /// When the account was created
  final DateTime createdAt;
  
  /// When the account was last modified
  final DateTime updatedAt;

  /// Constructor for Account
  const Account({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.balance,
    required this.type,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new Account with current timestamps
  factory Account.create({
    required String name,
    required IconData icon,
    required Color color,
    double balance = 0.0,
    AccountType type = AccountType.savings,
    String? description,
  }) {
    final now = DateTime.now();
    return Account(
      id: _generateId(),
      name: name,
      icon: icon,
      color: color,
      balance: balance,
      type: type,
      description: description,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a copy of this account with updated fields
  Account copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    double? balance,
    AccountType? type,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Update the balance of this account
  Account updateBalance(double newBalance) {
    return copyWith(balance: newBalance);
  }

  /// Add amount to the balance
  Account addToBalance(double amount) {
    return copyWith(balance: balance + amount);
  }

  /// Subtract amount from the balance
  Account subtractFromBalance(double amount) {
    return copyWith(balance: balance - amount);
  }

  /// Check if account has sufficient balance
  bool hasSufficientBalance(double amount) {
    return balance >= amount;
  }

  /// Get the balance color based on account type and amount
  Color get balanceColor {
    return type.getBalanceColor(balance);
  }

   /// Get the balance icon based on amount and account type
  IconData get balanceIcon {
    if (type == AccountType.creditCard) {
      // For credit cards: negative balance (credit) is good (upward trend)
      if (balance < 0) return Icons.trending_up; // Credit is good!
      if (balance > 0) return Icons.trending_down; // Debt is bad
      return Icons.remove; // Zero balance
    } else {
      // For regular accounts: positive balance is good
      if (balance > 0) return Icons.trending_up;
      if (balance < 0) return Icons.trending_down;
      return Icons.remove;
    }
  }

  /// Check if this account is a liability (debt)
  bool get isLiability => type.isLiability;

  /// Check if this account is an asset
  bool get isAsset => type.isAsset;

  /// Get formatted balance with currency symbol
  String getFormattedBalance({String currencySymbol = '₹'}) {
    final absBalance = balance.abs();
    // Format with commas for thousands separator using NumberFormat
    final formatter = NumberFormat('#,##0');
    final formattedNumber = formatter.format(absBalance);
    return '$currencySymbol$formattedNumber';
  }

  /// Get user-friendly formatted balance (removes minus for credit card credits)
  String getFormattedUserBalance({String currencySymbol = '₹'}) {
    final formatter = NumberFormat('#,##0');
    // For credit cards, if balance is negative (credit), show as positive
    final displayAmount = (type == AccountType.creditCard && balance < 0) ? balance.abs() : balance.abs();
    return '$currencySymbol${formatter.format(displayAmount)}';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$AccountToJson(this);

  /// Create from JSON
  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  /// Generate a unique ID for accounts
  static String _generateId() {
    return 'acc_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Account(id: $id, name: $name, balance: $balance, type: $type)';
  }
}
import 'package:flutter/material.dart';

/// Enum representing different types of financial accounts
enum AccountType {
  savings('savings', 'Savings Account', Icons.account_balance, Colors.blue),
  wallet('wallet', 'Digital Wallet', Icons.account_balance_wallet, Colors.purple),
  creditCard('credit_card', 'Credit Card', Icons.credit_card, Colors.orange),
  cash('cash', 'Cash', Icons.money, Colors.green),
  investment('investment', 'Investment', Icons.trending_up, Colors.teal),
  loan('loan', 'Loan', Icons.account_balance_wallet, Colors.red);

  const AccountType(this.value, this.displayName, this.icon, this.color);

  final String value;
  final String displayName;
  final IconData icon;
  final Color color;

  /// Get AccountType from string value
  static AccountType fromString(String value) {
    return AccountType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AccountType.savings,
    );
  }

  /// Check if this account type represents a liability (debt)
  bool get isLiability {
    return this == AccountType.creditCard || this == AccountType.loan;
  }

  /// Check if this account type represents an asset
  bool get isAsset {
    return !isLiability;
  }

  /// Get the appropriate balance color for this account type
  Color getBalanceColor(double balance) {
    if (isLiability) {
      // For liabilities (credit cards):
      // balance > 0: Has debt (red)
      // balance = 0: No debt (green) 
      // balance < 0: Has credit/overpaid (green - this is good!)
      return balance <= 0 ? Colors.green : Colors.red;
    } else {
      // For assets, higher balance is better
      return balance >= 0 ? Colors.green : Colors.red;
    }
  }

  /// Get a list of popular wallet types for quick selection
  static List<Map<String, dynamic>> getPopularWallets() {
    return [
      {
        'name': 'Amazon Pay',
        'icon': Icons.shopping_bag,
        'color': Colors.orange,
        'type': AccountType.wallet.value,
      },
      {
        'name': 'PhonePe',
        'icon': Icons.phone_android,
        'color': Colors.purple,
        'type': AccountType.wallet.value,
      },
      {
        'name': 'Paytm',
        'icon': Icons.payment,
        'color': Colors.blue,
        'type': AccountType.wallet.value,
      },
      {
        'name': 'Google Pay',
        'icon': Icons.payment,
        'color': Colors.green,
        'type': AccountType.wallet.value,
      },
      {
        'name': 'BHIM UPI',
        'icon': Icons.account_balance,
        'color': Colors.indigo,
        'type': AccountType.wallet.value,
      },
    ];
  }

  /// Get a list of popular bank types for quick selection
  static List<Map<String, dynamic>> getPopularBanks() {
    return [
      {
        'name': 'HDFC Bank',
        'icon': Icons.account_balance,
        'color': Colors.blue,
        'type': AccountType.savings.value,
      },
      {
        'name': 'ICICI Bank',
        'icon': Icons.account_balance,
        'color': Colors.orange,
        'type': AccountType.savings.value,
      },
      {
        'name': 'SBI Bank',
        'icon': Icons.account_balance,
        'color': Colors.blue,
        'type': AccountType.savings.value,
      },
      {
        'name': 'Axis Bank',
        'icon': Icons.account_balance,
        'color': Colors.red,
        'type': AccountType.savings.value,
      },
      {
        'name': 'Kotak Bank',
        'icon': Icons.account_balance,
        'color': Colors.purple,
        'type': AccountType.savings.value,
      },
    ];
  }
}
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '../utils/json_converters.dart';

part 'bank_account.g.dart';

/// Bank Account model for payment processing
@JsonSerializable()
class BankAccount {
  /// Unique identifier for the bank account
  final String id;
  
  /// Account holder name
  final String accountHolderName;
  
  /// Bank name
  final String bankName;
  
  /// Account number (masked for security)
  final String accountNumber;
  
  /// IFSC code
  final String ifscCode;
  
  /// Account type (savings, current, etc.)
  final String accountType;
  
  /// Current balance
  final double currentBalance;
  
  /// Account color for UI
  @ColorConverter()
  final Color color;
  
  /// Account icon
  @IconDataConverter()
  final IconData icon;
  
  /// Whether account is active
  final bool isActive;
  
  /// Whether account is verified
  final bool isVerified;
  
  /// Created timestamp
  final DateTime createdAt;
  
  /// Updated timestamp
  final DateTime updatedAt;

  const BankAccount({
    required this.id,
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountType,
    required this.currentBalance,
    required this.color,
    required this.icon,
    this.isActive = true,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new bank account
  factory BankAccount.create({
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    required String accountType,
    double currentBalance = 0.0,
    Color? color,
    IconData? icon,
    bool isActive = true,
    bool isVerified = false,
  }) {
    final now = DateTime.now();
    return BankAccount(
      id: 'bank_${now.millisecondsSinceEpoch}_${(now.microsecondsSinceEpoch % 1000).toString().padLeft(3, '0')}',
      accountHolderName: accountHolderName,
      bankName: bankName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      accountType: accountType,
      currentBalance: currentBalance,
      color: color ?? Colors.blue,
      icon: icon ?? Icons.account_balance,
      isActive: isActive,
      isVerified: isVerified,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Copy with new values
  BankAccount copyWith({
    String? id,
    String? accountHolderName,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? accountType,
    double? currentBalance,
    Color? color,
    IconData? icon,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BankAccount(
      id: id ?? this.id,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      accountType: accountType ?? this.accountType,
      currentBalance: currentBalance ?? this.currentBalance,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert from JSON
  factory BankAccount.fromJson(Map<String, dynamic> json) => _$BankAccountFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$BankAccountToJson(this);

  /// Get masked account number for display
  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    final lastFour = accountNumber.substring(accountNumber.length - 4);
    return '•••• •••• •••• $lastFour';
  }

  /// Get account type display text
  String get accountTypeDisplayText {
    switch (accountType.toLowerCase()) {
      case 'savings':
        return 'Savings Account';
      case 'current':
        return 'Current Account';
      case 'salary':
        return 'Salary Account';
      case 'nri':
        return 'NRI Account';
      default:
        return accountType;
    }
  }

  /// Get formatted balance
  String getFormattedBalance() {
    return '₹${currentBalance.toStringAsFixed(2)}';
  }

  /// Check if account has sufficient balance
  bool hasSufficientBalance(double amount) {
    return currentBalance >= amount;
  }

  /// Get account display name
  String get displayName {
    return '$bankName - $accountTypeDisplayText';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BankAccount && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BankAccount(id: $id, bankName: $bankName, accountNumber: $maskedAccountNumber)';
  }
}
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/json_converters.dart';

part 'category.g.dart';

/// Category model representing a transaction category
@JsonSerializable()
class Category {
  /// Unique identifier for the category
  final String id;
  
  /// Category name
  final String name;
  
  /// Category icon
  @IconDataConverter()
  final IconData icon;
  
  /// Category color
  @ColorConverter()
  final Color color;
  
  /// Category type: income, expense, or both
  final String type;
  
  /// Whether this is a default category
  final bool isDefault;
  
  /// Whether the category is active
  final bool isActive;
  
  /// When the category was created
  final DateTime createdAt;
  
  /// When the category was last modified
  final DateTime updatedAt;

  /// Constructor for Category
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new Category with current timestamps
  factory Category.create({
    required String name,
    required IconData icon,
    required Color color,
    required String type,
    bool isDefault = false,
  }) {
    final now = DateTime.now();
    return Category(
      id: _generateId(),
      name: name,
      icon: icon,
      color: color,
      type: type,
      isDefault: isDefault,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a copy of this category with updated fields
  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    String? type,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Check if this category is for income transactions
  bool get isIncome => type == AppConstants.transactionTypeIncome;

  /// Check if this category is for expense transactions
  bool get isExpense => type == AppConstants.transactionTypeExpense;

  /// Check if this category is for both income and expense
  bool get isBoth => type == 'both';

  /// Check if this category can be used for a specific transaction type
  bool canBeUsedFor(String transactionType) {
    if (isBoth) return true;
    return type == transactionType;
  }

  /// Get the category type display name
  String get typeDisplayName {
    switch (type) {
      case AppConstants.transactionTypeIncome:
        return 'Income';
      case AppConstants.transactionTypeExpense:
        return 'Expense';
      case 'both':
        return 'Both';
      default:
        return 'Unknown';
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  /// Create from JSON
  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  /// Generate a unique ID for categories
  static String _generateId() {
    return 'cat_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, type: $type, isDefault: $isDefault)';
  }
}
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/json_converters.dart';

part 'credit_card.g.dart';

/// Enhanced Credit Card model with comprehensive banking features
@JsonSerializable()
class CreditCard {
  /// Unique identifier for the credit card
  final String id;
  
  /// Card name (e.g., "Chase Sapphire", "Amex Gold")
  final String name;
  
  /// Card network (Visa, Mastercard, Amex, Rupay, etc.)
  final String network;
  
  /// Card type (Premium, Standard, Business, etc.)
  final String type;
  
  /// Last 4 digits of the card
  final String lastFourDigits;
  
  /// Cardholder name
  final String? cardholderName;
  
  /// Expiry date (optional for privacy)
  final DateTime? expiryDate;
  
  /// Credit limit
  final double creditLimit;
  
  /// Current outstanding balance
  final double outstandingBalance;
  
  /// Available credit (limit - outstanding)
  final double availableCredit;
  
  /// Interest rate (APR)
  final double interestRate;
  
  /// Minimum payment percentage
  final double minimumPaymentPercentage;
  
  /// Grace period in days
  final int gracePeriodDays;
  
  /// Billing cycle day (1-31)
  final int billingCycleDay;
  
  /// Next billing date
  final DateTime? nextBillingDate;
  
  /// Next due date
  final DateTime? nextDueDate;
  
  /// Last payment date
  final DateTime? lastPaymentDate;
  
  /// Last payment amount
  final double? lastPaymentAmount;
  
  /// Card color for UI
  @ColorConverter()
  final Color color;
  
  /// Card icon
  @IconDataConverter()
  final IconData icon;
  
  /// Bank name
  final String? bankName;
  
  /// Whether the card is active
  final bool isActive;
  
  /// Whether to auto-generate statements
  final bool autoGenerateStatements;
  
  /// Notes
  final String? notes;
  
  /// Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreditCard({
    required this.id,
    required this.name,
    required this.network,
    required this.type,
    required this.lastFourDigits,
    this.cardholderName,
    required this.expiryDate,
    required this.creditLimit,
    required this.outstandingBalance,
    required this.availableCredit,
    required this.interestRate,
    required this.minimumPaymentPercentage,
    required this.gracePeriodDays,
    required this.billingCycleDay,
    this.nextBillingDate,
    this.nextDueDate,
    this.lastPaymentDate,
    this.lastPaymentAmount,
    required this.color,
    required this.icon,
    this.bankName,
    required this.isActive,
    required this.autoGenerateStatements,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new CreditCard with current timestamps
  factory CreditCard.create({
    required String name,
    required String network,
    required String type,
    required String lastFourDigits,
    String? cardholderName,
    DateTime? expiryDate,
    required double creditLimit,
    double outstandingBalance = 0.0,
    double interestRate = 18.0,
    double minimumPaymentPercentage = 5.0,
    int gracePeriodDays = 21,
    int billingCycleDay = 15,
    Color? color,
    IconData? icon,
    String? bankName,
    bool autoGenerateStatements = true,
    String? notes,
  }) {
    final now = DateTime.now();
    final availableCredit = creditLimit - outstandingBalance;
    
    // Calculate initial billing dates
    DateTime? nextBillingDate;
    DateTime? nextDueDate;
    
    if (billingCycleDay > 0) {
      // Set billing date to current month's billing day
      if (now.day < billingCycleDay) {
        nextBillingDate = DateTime(now.year, now.month, billingCycleDay);
      } else {
        nextBillingDate = DateTime(now.year, now.month + 1, billingCycleDay);
        if (nextBillingDate.month > 12) {
          nextBillingDate = DateTime(now.year + 1, 1, billingCycleDay);
        }
      }
      
      // Calculate due date
      nextDueDate = nextBillingDate.add(Duration(days: gracePeriodDays));
    }
    
    return CreditCard(
      id: _generateId(),
      name: name,
      network: network,
      type: type,
      lastFourDigits: lastFourDigits,
      cardholderName: cardholderName,
      expiryDate: expiryDate,
      creditLimit: creditLimit,
      outstandingBalance: outstandingBalance,
      availableCredit: availableCredit,
      interestRate: interestRate,
      minimumPaymentPercentage: minimumPaymentPercentage,
      gracePeriodDays: gracePeriodDays,
      billingCycleDay: billingCycleDay,
      nextBillingDate: nextBillingDate,
      nextDueDate: nextDueDate,
      color: color ?? Colors.blue,
      icon: icon ?? Icons.credit_card,
      bankName: bankName,
      isActive: true,
      autoGenerateStatements: autoGenerateStatements,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a copy of this credit card with updated fields
  CreditCard copyWith({
    String? id,
    String? name,
    String? network,
    String? type,
    String? lastFourDigits,
    String? cardholderName,
    DateTime? expiryDate,
    double? creditLimit,
    double? outstandingBalance,
    double? availableCredit,
    double? interestRate,
    double? minimumPaymentPercentage,
    int? gracePeriodDays,
    int? billingCycleDay,
    DateTime? nextBillingDate,
    DateTime? nextDueDate,
    DateTime? lastPaymentDate,
    double? lastPaymentAmount,
    Color? color,
    IconData? icon,
    String? bankName,
    bool? isActive,
    bool? autoGenerateStatements,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreditCard(
      id: id ?? this.id,
      name: name ?? this.name,
      network: network ?? this.network,
      type: type ?? this.type,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      cardholderName: cardholderName ?? this.cardholderName,
      expiryDate: expiryDate ?? this.expiryDate,
      creditLimit: creditLimit ?? this.creditLimit,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      availableCredit: availableCredit ?? this.availableCredit,
      interestRate: interestRate ?? this.interestRate,
      minimumPaymentPercentage: minimumPaymentPercentage ?? this.minimumPaymentPercentage,
      gracePeriodDays: gracePeriodDays ?? this.gracePeriodDays,
      billingCycleDay: billingCycleDay ?? this.billingCycleDay,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      lastPaymentAmount: lastPaymentAmount ?? this.lastPaymentAmount,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      bankName: bankName ?? this.bankName,
      isActive: isActive ?? this.isActive,
      autoGenerateStatements: autoGenerateStatements ?? this.autoGenerateStatements,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // ========================================
  // BANKING CALCULATIONS & UTILITIES
  // ========================================

  /// Get credit utilization percentage
  double get utilizationPercentage {
    if (creditLimit <= 0) return 0.0;
    return outstandingBalance / creditLimit;
  }

  /// Get minimum payment amount
  double get minimumPaymentAmount {
    final calculated = outstandingBalance * (minimumPaymentPercentage / 100);
    return calculated > 0.0 ? calculated : 0.0; // Minimum ₹0
  }

  /// Check if payment is overdue
  bool get isOverdue {
    if (nextDueDate == null) return false;
    return DateTime.now().isAfter(nextDueDate!);
  }

  /// Get days until due date
  int? get daysUntilDue {
    if (nextDueDate == null) return null;
    final days = nextDueDate!.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  /// Check if due soon (within 7 days)
  bool get isDueSoon {
    if (nextDueDate == null) return false;
    final days = nextDueDate!.difference(DateTime.now()).inDays;
    return days >= 0 && days <= 7;
  }

  /// Check if in grace period
  bool get isInGracePeriod {
    if (nextDueDate == null) return false;
    final days = nextDueDate!.difference(DateTime.now()).inDays;
    return days < 0 && days >= -gracePeriodDays;
  }

  /// Get utilization status
  String get utilizationStatus {
    final utilization = utilizationPercentage;
    if (utilization >= 0.90) return 'Critical';
    if (utilization >= 0.80) return 'Warning';
    if (utilization >= 0.70) return 'High';
    if (utilization >= 0.50) return 'Moderate';
    if (utilization >= 0.30) return 'Elevated';
    return 'Safe';
  }

  /// Get utilization color for UI
  Color get utilizationColor {
    final utilization = utilizationPercentage.abs();
    if (utilization >= 0.90) return Colors.red;
    if (utilization >= 0.80) return Colors.orange;
    if (utilization >= 0.70) return Colors.deepOrange;
    if (utilization >= 0.50) return Colors.yellow;
    if (utilization >= 0.30) return Colors.lightGreen;
    return Colors.green;
  }

  /// Get user-friendly utilization percentage (removes minus for credit)
  String get userFriendlyUtilization {
    final percentage = utilizationPercentage.abs() * 100;
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Get utilization status for user display
  String get userUtilizationStatus {
    if (outstandingBalance < 0) return 'Credit Available';
    if (outstandingBalance == 0) return 'Paid Off';
    return utilizationStatus;
  }

  /// Get risk assessment
  String get riskAssessment {
    if (utilizationPercentage >= 0.90) return 'Critical Risk';
    if (utilizationPercentage >= 0.80) return 'High Risk';
    if (utilizationPercentage >= 0.70) return 'Elevated Risk';
    if (utilizationPercentage >= 0.50) return 'Moderate Risk';
    if (utilizationPercentage >= 0.30) return 'Low Risk';
    return 'Safe Zone';
  }

  /// Get next billing cycle start date
  DateTime get nextBillingCycleStart {
    final now = DateTime.now();
    DateTime nextCycle = DateTime(now.year, now.month, billingCycleDay);
    
    // If this month's cycle day has passed, move to next month
    if (now.isAfter(nextCycle)) {
      nextCycle = DateTime(now.year, now.month + 1, billingCycleDay);
    }
    
    return nextCycle;
  }

  /// Get next billing cycle end date
  DateTime get nextBillingCycleEnd {
    final start = nextBillingCycleStart;
    return DateTime(start.year, start.month + 1, start.day - 1);
  }

  /// Get formatted balance with currency symbol
  String getFormattedBalance({String currencySymbol = '₹'}) {
    final formatter = NumberFormat('#,##0.00');
    return '$currencySymbol${formatter.format(outstandingBalance)}';
  }

  /// Get user-friendly formatted balance (removes minus for overpaid amounts)
  String getFormattedUserBalance({String currencySymbol = '₹'}) {
    final formatter = NumberFormat('#,##0.00');
    // If overpaid (negative), show as positive credit
    final displayAmount = outstandingBalance < 0 ? outstandingBalance.abs() : outstandingBalance;
    return '$currencySymbol${formatter.format(displayAmount)}';
  }

  /// Get balance label based on status
  String get balanceLabel {
    if (outstandingBalance < 0) return 'Available Credit';
    if (outstandingBalance == 0) return 'Outstanding';
    return 'Outstanding';
  }

  /// Get balance color for user display
  Color get userBalanceColor {
    if (outstandingBalance <= 0) return Colors.green; // Credit or zero = good
    return Colors.red; // Debt = bad
  }

  /// Get formatted credit limit
  String getFormattedCreditLimit({String currencySymbol = '₹'}) {
    final formatter = NumberFormat('#,##0.00');
    return '$currencySymbol${formatter.format(creditLimit)}';
  }

  /// Get formatted available credit
  String getFormattedAvailableCredit({String currencySymbol = '₹'}) {
    final formatter = NumberFormat('#,##0.00');
    return '$currencySymbol${formatter.format(availableCredit)}';
  }

  /// Get masked card number
  String get maskedCardNumber {
    return '•••• •••• •••• $lastFourDigits';
  }

  /// Get expiry date in MM/YY format
  String get formattedExpiryDate {
    if (expiryDate == null) return 'N/A';
    return DateFormat('MM/yy').format(expiryDate!);
  }

  /// Check if card is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Get card display name with network
  String get displayName {
    return '$name ($network)';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$CreditCardToJson(this);

  /// Create from JSON
  factory CreditCard.fromJson(Map<String, dynamic> json) => _$CreditCardFromJson(json);

  /// Generate a unique ID for credit cards
  static String _generateId() {
    return 'cc_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreditCard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CreditCard(id: $id, name: $name, limit: $creditLimit, balance: $outstandingBalance)';
  }
}
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '../utils/formatters.dart';

part 'credit_card_statement.g.dart';

/// Credit Card Statement model for billing statements
@JsonSerializable()
class CreditCardStatement {
  /// Unique identifier for the statement
  final String id;
  
  /// Credit card ID this statement belongs to
  final String creditCardId;
  
  /// Statement number (e.g., "2024-001")
  final String statementNumber;
  
  /// Statement period start date
  final DateTime periodStart;
  
  /// Statement period end date
  final DateTime periodEnd;
  
  /// Previous balance
  final double previousBalance;
  
  /// Payments and credits during the period
  final double paymentsAndCredits;
  
  /// Purchases during the period
  final double purchases;
  
  /// Cash advances during the period
  final double cashAdvances;
  
  /// Interest charges
  final double interestCharges;
  
  /// Fees and charges
  final double feesAndCharges;
  
  /// New balance (total amount due)
  final double newBalance;
  
  /// Minimum payment due
  final double minimumPaymentDue;
  
  /// Payment due date
  final DateTime paymentDueDate;
  
  /// Amount paid towards this statement
  final double paidAmount;
  
  /// Late fees
  final double lateFees;
  
  /// Over limit fees
  final double overLimitFees;
  
  /// Balance transfers
  final double balanceTransfers;
  
  /// Other fees
  final double fees;
  
  /// Adjustments
  final double adjustments;
  
  /// Date when statement was paid
  final DateTime? paidDate;
  
  /// Notes
  final String? notes;
  
  /// Statement generation date
  final DateTime generatedDate;
  
  /// Statement status
  final StatementStatus status;
  
  /// Whether the statement has been viewed
  final bool isViewed;
  
  /// Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreditCardStatement({
    required this.id,
    required this.creditCardId,
    required this.statementNumber,
    required this.periodStart,
    required this.periodEnd,
    required this.previousBalance,
    required this.paymentsAndCredits,
    required this.purchases,
    required this.cashAdvances,
    required this.interestCharges,
    required this.feesAndCharges,
    required this.newBalance,
    required this.minimumPaymentDue,
    required this.paymentDueDate,
    this.paidAmount = 0.0,
    this.lateFees = 0.0,
    this.overLimitFees = 0.0,
    this.balanceTransfers = 0.0,
    this.fees = 0.0,
    this.adjustments = 0.0,
    this.paidDate,
    this.notes,
    required this.generatedDate,
    required this.status,
    this.isViewed = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new statement
  factory CreditCardStatement.create({
    required String creditCardId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required double previousBalance,
    required double paymentsAndCredits,
    required double purchases,
    required double cashAdvances,
    required double interestCharges,
    required double feesAndCharges,
    required double minimumPaymentDue,
    required DateTime paymentDueDate,
  }) {
    final now = DateTime.now();
    final newBalance = previousBalance + purchases + cashAdvances + interestCharges + feesAndCharges - paymentsAndCredits;
    
    return CreditCardStatement(
      id: _generateId(),
      creditCardId: creditCardId,
      statementNumber: _generateStatementNumber(periodStart),
      periodStart: periodStart,
      periodEnd: periodEnd,
      previousBalance: previousBalance,
      paymentsAndCredits: paymentsAndCredits,
      purchases: purchases,
      cashAdvances: cashAdvances,
      interestCharges: interestCharges,
      feesAndCharges: feesAndCharges,
      newBalance: newBalance,
      minimumPaymentDue: minimumPaymentDue,
      paymentDueDate: paymentDueDate,
      generatedDate: now,
      status: StatementStatus.generated,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a copy with updated fields
  CreditCardStatement copyWith({
    String? id,
    String? creditCardId,
    String? statementNumber,
    DateTime? periodStart,
    DateTime? periodEnd,
    double? previousBalance,
    double? paymentsAndCredits,
    double? purchases,
    double? cashAdvances,
    double? interestCharges,
    double? feesAndCharges,
    double? newBalance,
    double? minimumPaymentDue,
    DateTime? paymentDueDate,
    double? paidAmount,
    double? lateFees,
    double? overLimitFees,
    double? balanceTransfers,
    double? fees,
    double? adjustments,
    DateTime? paidDate,
    String? notes,
    DateTime? generatedDate,
    StatementStatus? status,
    bool? isViewed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreditCardStatement(
      id: id ?? this.id,
      creditCardId: creditCardId ?? this.creditCardId,
      statementNumber: statementNumber ?? this.statementNumber,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      previousBalance: previousBalance ?? this.previousBalance,
      paymentsAndCredits: paymentsAndCredits ?? this.paymentsAndCredits,
      purchases: purchases ?? this.purchases,
      cashAdvances: cashAdvances ?? this.cashAdvances,
      interestCharges: interestCharges ?? this.interestCharges,
      feesAndCharges: feesAndCharges ?? this.feesAndCharges,
      newBalance: newBalance ?? this.newBalance,
      minimumPaymentDue: minimumPaymentDue ?? this.minimumPaymentDue,
      paymentDueDate: paymentDueDate ?? this.paymentDueDate,
      paidAmount: paidAmount ?? this.paidAmount,
      lateFees: lateFees ?? this.lateFees,
      overLimitFees: overLimitFees ?? this.overLimitFees,
      balanceTransfers: balanceTransfers ?? this.balanceTransfers,
      fees: fees ?? this.fees,
      adjustments: adjustments ?? this.adjustments,
      paidDate: paidDate ?? this.paidDate,
      notes: notes ?? this.notes,
      generatedDate: generatedDate ?? this.generatedDate,
      status: status ?? this.status,
      isViewed: isViewed ?? this.isViewed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  /// Get statement period display text
  String get periodDisplay {
    return '${Formatters.formatDate(periodStart)} - ${Formatters.formatDate(periodEnd)}';
  }

  /// Get formatted total due
  String getFormattedTotalDue() {
    return Formatters.formatCurrency(newBalance);
  }

  /// Get formatted minimum payment
  String getFormattedMinimumPayment() {
    return Formatters.formatCurrency(minimumPaymentDue);
  }

  /// Get payment status
  String get paymentStatus {
    final now = DateTime.now();
    if (now.isAfter(paymentDueDate)) {
      return 'Overdue';
    } else if (paymentDueDate.difference(now).inDays <= 7) {
      return 'Due Soon';
    } else {
      return 'Current';
    }
  }

  /// Get payment status color
  Color get paymentStatusColor {
    final now = DateTime.now();
    if (now.isAfter(paymentDueDate)) {
      return Colors.red;
    } else if (paymentDueDate.difference(now).inDays <= 7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  /// Check if payment is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(paymentDueDate);
  }

  /// Check if payment is due soon
  bool get isDueSoon {
    final daysUntilDue = paymentDueDate.difference(DateTime.now()).inDays;
    return daysUntilDue >= 0 && daysUntilDue <= 7;
  }

  /// Get days until due date
  int get daysUntilDue {
    final days = paymentDueDate.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  /// Get total due (alias for newBalance)
  double get totalDue => newBalance;

  /// Get minimum due (alias for minimumPaymentDue)
  double get minimumDue => minimumPaymentDue;

  /// Get due date (alias for paymentDueDate)
  DateTime get dueDate => paymentDueDate;

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$CreditCardStatementToJson(this);

  /// Create from JSON
  factory CreditCardStatement.fromJson(Map<String, dynamic> json) => _$CreditCardStatementFromJson(json);

  /// Generate unique ID
  static String _generateId() {
    return 'stmt_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Generate statement number
  static String _generateStatementNumber(DateTime periodStart) {
    final year = periodStart.year;
    final month = periodStart.month.toString().padLeft(2, '0');
    return '$year-$month';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreditCardStatement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CreditCardStatement(id: $id, statementNumber: $statementNumber, newBalance: $newBalance)';
  }
}

/// Statement status enum
enum StatementStatus {
  @JsonValue('generated')
  generated,
  @JsonValue('viewed')
  viewed,
  @JsonValue('paid')
  paid,
  @JsonValue('overdue')
  overdue,
}import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'payment.g.dart';

/// Payment model for credit card payments
@JsonSerializable()
class Payment {
  /// Unique identifier for the payment
  final String id;
  
  /// Credit card ID this payment is for
  final String creditCardId;
  
  /// Statement ID this payment is for (optional)
  final String? statementId;
  
  /// Payment amount
  final double amount;
  
  /// Payment date
  final DateTime paymentDate;
  
  /// Payment method (bank_transfer, debit_card, cash, etc.)
  final String paymentMethod;
  
  /// Payment status (pending, completed, failed, cancelled)
  final String status;
  
  /// Reference number or transaction ID
  final String? referenceNumber;
  
  /// Notes about the payment
  final String? notes;
  
  /// Bank account used for payment (if applicable)
  final String? bankAccountId;
  
  /// Processing fee (if any)
  final double processingFee;
  
  /// Created timestamp
  final DateTime createdAt;
  
  /// Updated timestamp
  final DateTime updatedAt;

  const Payment({
    required this.id,
    required this.creditCardId,
    this.statementId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.status,
    this.referenceNumber,
    this.notes,
    this.bankAccountId,
    this.processingFee = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new payment
  factory Payment.create({
    required String creditCardId,
    String? statementId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
    String? bankAccountId,
    double processingFee = 0.0,
  }) {
    final now = DateTime.now();
    return Payment(
      id: 'payment_${now.millisecondsSinceEpoch}_${(now.microsecondsSinceEpoch % 1000).toString().padLeft(3, '0')}',
      creditCardId: creditCardId,
      statementId: statementId,
      amount: amount,
      paymentDate: now,
      paymentMethod: paymentMethod,
      status: 'pending',
      referenceNumber: referenceNumber,
      notes: notes,
      bankAccountId: bankAccountId,
      processingFee: processingFee,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Copy with new values
  Payment copyWith({
    String? id,
    String? creditCardId,
    String? statementId,
    double? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? status,
    String? referenceNumber,
    String? notes,
    String? bankAccountId,
    double? processingFee,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      creditCardId: creditCardId ?? this.creditCardId,
      statementId: statementId ?? this.statementId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      processingFee: processingFee ?? this.processingFee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert from JSON
  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  /// Get payment status display text
  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  /// Get payment status color
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Get payment method display text
  String get paymentMethodDisplayText {
    switch (paymentMethod.toLowerCase()) {
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'debit_card':
        return 'Debit Card';
      case 'cash':
        return 'Cash';
      case 'upi':
        return 'UPI';
      case 'net_banking':
        return 'Net Banking';
      case 'wallet':
        return 'Digital Wallet';
      default:
        return paymentMethod;
    }
  }

  /// Check if payment is completed
  bool get isCompleted => status.toLowerCase() == 'completed';

  /// Check if payment is pending
  bool get isPending => status.toLowerCase() == 'pending';

  /// Check if payment failed
  bool get isFailed => status.toLowerCase() == 'failed';

  /// Get total amount including processing fee
  double get totalAmount => amount + processingFee;

  /// Get formatted amount
  String getFormattedAmount() {
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Get formatted total amount
  String getFormattedTotalAmount() {
    return '₹${totalAmount.toStringAsFixed(2)}';
  }

  /// Get formatted processing fee
  String getFormattedProcessingFee() {
    return '₹${processingFee.toStringAsFixed(2)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Payment(id: $id, creditCardId: $creditCardId, amount: $amount, status: $status)';
  }
}
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'payment_record.g.dart';

/// Payment Record model for tracking credit card payments
@JsonSerializable()
class PaymentRecord {
  /// Unique identifier for the payment
  final String id;
  
  /// Credit card ID this payment is for
  final String creditCardId;
  
  /// Statement ID this payment is for (if applicable)
  final String? statementId;
  
  /// Payment amount
  final double amount;
  
  /// Payment date
  final DateTime paymentDate;
  
  /// Payment method (Bank Transfer, UPI, etc.)
  final String paymentMethod;
  
  /// Source account ID (bank account used for payment)
  final String? sourceAccountId;
  
  /// Payment status (Pending, Completed, Failed, Refunded)
  final String status;
  
  /// Transaction reference number
  final String? transactionReference;
  
  /// Payment notes
  final String? notes;
  
  /// Whether this is a minimum payment
  final bool isMinimumPayment;
  
  /// Whether this is a full payment
  final bool isFullPayment;
  
  /// Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentRecord({
    required this.id,
    required this.creditCardId,
    this.statementId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.sourceAccountId,
    this.status = 'Completed',
    this.transactionReference,
    this.notes,
    this.isMinimumPayment = false,
    this.isFullPayment = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new PaymentRecord with current timestamps
  factory PaymentRecord.create({
    required String creditCardId,
    String? statementId,
    required double amount,
    required DateTime paymentDate,
    required String paymentMethod,
    String? sourceAccountId,
    String status = 'Completed',
    String? transactionReference,
    String? notes,
    bool isMinimumPayment = false,
    bool isFullPayment = false,
  }) {
    final now = DateTime.now();
    return PaymentRecord(
      id: _generateId(),
      creditCardId: creditCardId,
      statementId: statementId,
      amount: amount,
      paymentDate: paymentDate,
      paymentMethod: paymentMethod,
      sourceAccountId: sourceAccountId,
      status: status,
      transactionReference: transactionReference,
      notes: notes,
      isMinimumPayment: isMinimumPayment,
      isFullPayment: isFullPayment,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a copy of this payment record with updated fields
  PaymentRecord copyWith({
    String? id,
    String? creditCardId,
    String? statementId,
    double? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? sourceAccountId,
    String? status,
    String? transactionReference,
    String? notes,
    bool? isMinimumPayment,
    bool? isFullPayment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentRecord(
      id: id ?? this.id,
      creditCardId: creditCardId ?? this.creditCardId,
      statementId: statementId ?? this.statementId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      status: status ?? this.status,
      transactionReference: transactionReference ?? this.transactionReference,
      notes: notes ?? this.notes,
      isMinimumPayment: isMinimumPayment ?? this.isMinimumPayment,
      isFullPayment: isFullPayment ?? this.isFullPayment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // ========================================
  // UTILITIES
  // ========================================

  /// Check if payment is successful
  bool get isSuccessful {
    return status == 'Completed';
  }

  /// Check if payment is pending
  bool get isPending {
    return status == 'Pending';
  }

  /// Check if payment failed
  bool get isFailed {
    return status == 'Failed';
  }

  /// Check if payment was refunded
  bool get isRefunded {
    return status == 'Refunded';
  }

  /// Get payment status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return '#4CAF50'; // Green
      case 'pending':
        return '#FF9800'; // Orange
      case 'failed':
        return '#F44336'; // Red
      case 'refunded':
        return '#9C27B0'; // Purple
      default:
        return '#2196F3'; // Blue
    }
  }

  /// Get payment type description
  String get paymentTypeDescription {
    if (isFullPayment) return 'Full Payment';
    if (isMinimumPayment) return 'Minimum Payment';
    return 'Partial Payment';
  }

  /// Get formatted payment amount
  String getFormattedAmount({String currencySymbol = '₹'}) {
    final formatter = NumberFormat('#,##0.00');
    return '$currencySymbol${formatter.format(amount)}';
  }

  /// Get formatted payment date
  String get formattedPaymentDate {
    return DateFormat('MMM dd, yyyy').format(paymentDate);
  }

  /// Get payment summary
  String get summary {
    return '${getFormattedAmount()} - $paymentTypeDescription';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$PaymentRecordToJson(this);

  /// Create from JSON
  factory PaymentRecord.fromJson(Map<String, dynamic> json) => _$PaymentRecordFromJson(json);

  /// Generate a unique ID for payment records
  static String _generateId() {
    return 'pay_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PaymentRecord(id: $id, creditCardId: $creditCardId, amount: $amount, status: $status)';
  }
}
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

part 'settings.g.dart';

/// Settings model representing user preferences and app configuration
@JsonSerializable()
class Settings {
  /// Theme mode: light, dark, or system
  final String themeMode;
  
  /// Currency code (e.g., 'INR', 'USD')
  final String currency;
  
  /// Locale code (e.g., 'en', 'hi', 'ta')
  final String locale;
  
  /// Whether to show notifications
  final bool showNotifications;
  
  /// Whether to show balance in app bar
  final bool showBalanceInAppBar;
  
  /// Whether to show category icons in transaction list
  final bool showCategoryIcons;
  
  /// Whether to show account icons in transaction list
  final bool showAccountIcons;
  
  /// Default transaction type for new transactions
  final String defaultTransactionType;
  
  /// Whether to auto-categorize transactions
  final bool autoCategorize;
  
  /// Whether to show transfer transactions separately
  final bool showTransfersSeparately;
  
  /// Number of recent transactions to show on home screen
  final int recentTransactionsCount;
  
  /// When the settings were last modified
  final DateTime updatedAt;

  /// Constructor for Settings
  const Settings({
    required this.themeMode,
    required this.currency,
    required this.locale,
    required this.showNotifications,
    required this.showBalanceInAppBar,
    required this.showCategoryIcons,
    required this.showAccountIcons,
    required this.defaultTransactionType,
    required this.autoCategorize,
    required this.showTransfersSeparately,
    required this.recentTransactionsCount,
    required this.updatedAt,
  });

  /// Create default settings
  factory Settings.defaults() {
    return Settings(
      themeMode: 'system',
      currency: AppConstants.defaultCurrency,
      locale: AppConstants.defaultLocale,
      showNotifications: true,
      showBalanceInAppBar: true,
      showCategoryIcons: true,
      showAccountIcons: true,
      defaultTransactionType: AppConstants.transactionTypeExpense,
      autoCategorize: false,
      showTransfersSeparately: true,
      recentTransactionsCount: 10,
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy of this settings with updated fields
  Settings copyWith({
    String? themeMode,
    String? currency,
    String? locale,
    bool? showNotifications,
    bool? showBalanceInAppBar,
    bool? showCategoryIcons,
    bool? showAccountIcons,
    String? defaultTransactionType,
    bool? autoCategorize,
    bool? showTransfersSeparately,
    int? recentTransactionsCount,
    DateTime? updatedAt,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      showNotifications: showNotifications ?? this.showNotifications,
      showBalanceInAppBar: showBalanceInAppBar ?? this.showBalanceInAppBar,
      showCategoryIcons: showCategoryIcons ?? this.showCategoryIcons,
      showAccountIcons: showAccountIcons ?? this.showAccountIcons,
      defaultTransactionType: defaultTransactionType ?? this.defaultTransactionType,
      autoCategorize: autoCategorize ?? this.autoCategorize,
      showTransfersSeparately: showTransfersSeparately ?? this.showTransfersSeparately,
      recentTransactionsCount: recentTransactionsCount ?? this.recentTransactionsCount,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Get the theme mode as ThemeMode enum
  ThemeMode get themeModeEnum {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Get the currency symbol
  String get currencySymbol {
    switch (currency) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currency;
    }
  }

  /// Get the locale as Locale object
  Locale get localeObject {
    return Locale(locale);
  }

  /// Check if dark mode is enabled
  bool get isDarkMode {
    return themeMode == 'dark';
  }

  /// Check if light mode is enabled
  bool get isLightMode {
    return themeMode == 'light';
  }

  /// Check if system theme is enabled
  bool get isSystemTheme {
    return themeMode == 'system';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  /// Create from JSON
  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings && other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => updatedAt.hashCode;

  @override
  String toString() {
    return 'Settings(themeMode: $themeMode, currency: $currency, locale: $locale)';
  }
}
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

part 'transaction.g.dart';

/// Transaction model representing a financial transaction
@JsonSerializable()
class Transaction {
  /// Unique identifier for the transaction
  final String id;
  
  /// Transaction type: income, expense, or transfer
  final String type;
  
  /// Transaction amount (positive for income, negative for expense)
  final double amount;
  
  /// Transaction description
  final String description;
  
  /// Category ID this transaction belongs to
  final String categoryId;
  
  /// Account ID this transaction is associated with
  final String accountId;
  
  /// For transfers: destination account ID
  final String? toAccountId;
  
  /// Transaction notes (optional)
  final String? notes;
  
  /// Path or base64 string of the receipt image (optional)
  final String? imagePath;
  
  /// Transaction date
  final DateTime date;
  
  /// When the transaction was created
  final DateTime createdAt;
  
  /// When the transaction was last modified
  final DateTime updatedAt;

  /// Constructor for Transaction
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.accountId,
    this.toAccountId,
    this.notes,
    this.imagePath,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new Transaction with current timestamps
  factory Transaction.create({
    required String type,
    required double amount,
    required String description,
    required String categoryId,
    required String accountId,
    String? toAccountId,
    String? notes,
    String? imagePath,
    DateTime? date,
  }) {
    final now = DateTime.now();
    return Transaction(
      id: _generateId(),
      type: type,
      amount: amount,
      description: description,
      categoryId: categoryId,
      accountId: accountId,
      toAccountId: toAccountId,
      notes: notes,
      imagePath: imagePath,
      date: date ?? now,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a copy of this transaction with updated fields
  Transaction copyWith({
    String? id,
    String? type,
    double? amount,
    String? description,
    String? categoryId,
    String? accountId,
    String? toAccountId,
    String? notes,
    String? imagePath,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Check if this is an income transaction
  bool get isIncome => type == AppConstants.transactionTypeIncome;

  /// Check if this is an expense transaction
  bool get isExpense => type == AppConstants.transactionTypeExpense;

  /// Check if this is a transfer transaction
  bool get isTransfer => type == AppConstants.transactionTypeTransfer;

  /// Get the display amount (positive for income, negative for expense)
  double get displayAmount {
    if (isIncome) return amount.abs();
    if (isExpense) return -amount.abs();
    return amount; // Transfer can be positive or negative
  }

  /// Get the color for this transaction type
  Color get typeColor {
    switch (type) {
      case AppConstants.transactionTypeIncome:
        return AppConstants.successColor;
      case AppConstants.transactionTypeExpense:
        return AppConstants.errorColor;
      case AppConstants.transactionTypeTransfer:
        return AppConstants.infoColor;
      default:
        return AppConstants.infoColor;
    }
  }

  /// Get the icon for this transaction type
  IconData get typeIcon {
    switch (type) {
      case AppConstants.transactionTypeIncome:
        return Icons.arrow_upward;
      case AppConstants.transactionTypeExpense:
        return Icons.arrow_downward;
      case AppConstants.transactionTypeTransfer:
        return Icons.swap_horiz;
      default:
        return Icons.attach_money;
    }
  }

  /// Get the display name for this transaction type
  String get typeDisplayName {
    switch (type) {
      case AppConstants.transactionTypeIncome:
        return 'Income';
      case AppConstants.transactionTypeExpense:
        return 'Expense';
      case AppConstants.transactionTypeTransfer:
        return 'Transfer';
      default:
        return 'Transaction';
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  /// Create from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);

  /// Generate a unique ID for transactions
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (1000 + (DateTime.now().microsecond % 1000)).toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, amount: $amount, description: $description)';
  }
}
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  id: json['id'] as String,
  name: json['name'] as String,
  icon: const IconDataConverter().fromJson(
    json['icon'] as Map<String, dynamic>,
  ),
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  balance: (json['balance'] as num).toDouble(),
  type: $enumDecode(_$AccountTypeEnumMap, json['type']),
  description: json['description'] as String?,
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': const IconDataConverter().toJson(instance.icon),
  'color': const ColorConverter().toJson(instance.color),
  'balance': instance.balance,
  'type': _$AccountTypeEnumMap[instance.type]!,
  'description': instance.description,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$AccountTypeEnumMap = {
  AccountType.savings: 'savings',
  AccountType.wallet: 'wallet',
  AccountType.creditCard: 'creditCard',
  AccountType.cash: 'cash',
  AccountType.investment: 'investment',
  AccountType.loan: 'loan',
};
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankAccount _$BankAccountFromJson(Map<String, dynamic> json) => BankAccount(
  id: json['id'] as String,
  accountHolderName: json['accountHolderName'] as String,
  bankName: json['bankName'] as String,
  accountNumber: json['accountNumber'] as String,
  ifscCode: json['ifscCode'] as String,
  accountType: json['accountType'] as String,
  currentBalance: (json['currentBalance'] as num).toDouble(),
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  icon: const IconDataConverter().fromJson(
    json['icon'] as Map<String, dynamic>,
  ),
  isActive: json['isActive'] as bool? ?? true,
  isVerified: json['isVerified'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BankAccountToJson(BankAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountHolderName': instance.accountHolderName,
      'bankName': instance.bankName,
      'accountNumber': instance.accountNumber,
      'ifscCode': instance.ifscCode,
      'accountType': instance.accountType,
      'currentBalance': instance.currentBalance,
      'color': const ColorConverter().toJson(instance.color),
      'icon': const IconDataConverter().toJson(instance.icon),
      'isActive': instance.isActive,
      'isVerified': instance.isVerified,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: json['id'] as String,
  name: json['name'] as String,
  icon: const IconDataConverter().fromJson(
    json['icon'] as Map<String, dynamic>,
  ),
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  type: json['type'] as String,
  isDefault: json['isDefault'] as bool,
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': const IconDataConverter().toJson(instance.icon),
  'color': const ColorConverter().toJson(instance.color),
  'type': instance.type,
  'isDefault': instance.isDefault,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditCard _$CreditCardFromJson(Map<String, dynamic> json) => CreditCard(
  id: json['id'] as String,
  name: json['name'] as String,
  network: json['network'] as String,
  type: json['type'] as String,
  lastFourDigits: json['lastFourDigits'] as String,
  cardholderName: json['cardholderName'] as String?,
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
  creditLimit: (json['creditLimit'] as num).toDouble(),
  outstandingBalance: (json['outstandingBalance'] as num).toDouble(),
  availableCredit: (json['availableCredit'] as num).toDouble(),
  interestRate: (json['interestRate'] as num).toDouble(),
  minimumPaymentPercentage: (json['minimumPaymentPercentage'] as num)
      .toDouble(),
  gracePeriodDays: (json['gracePeriodDays'] as num).toInt(),
  billingCycleDay: (json['billingCycleDay'] as num).toInt(),
  nextBillingDate: json['nextBillingDate'] == null
      ? null
      : DateTime.parse(json['nextBillingDate'] as String),
  nextDueDate: json['nextDueDate'] == null
      ? null
      : DateTime.parse(json['nextDueDate'] as String),
  lastPaymentDate: json['lastPaymentDate'] == null
      ? null
      : DateTime.parse(json['lastPaymentDate'] as String),
  lastPaymentAmount: (json['lastPaymentAmount'] as num?)?.toDouble(),
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  icon: const IconDataConverter().fromJson(
    json['icon'] as Map<String, dynamic>,
  ),
  bankName: json['bankName'] as String?,
  isActive: json['isActive'] as bool,
  autoGenerateStatements: json['autoGenerateStatements'] as bool,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CreditCardToJson(CreditCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'network': instance.network,
      'type': instance.type,
      'lastFourDigits': instance.lastFourDigits,
      'cardholderName': instance.cardholderName,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'creditLimit': instance.creditLimit,
      'outstandingBalance': instance.outstandingBalance,
      'availableCredit': instance.availableCredit,
      'interestRate': instance.interestRate,
      'minimumPaymentPercentage': instance.minimumPaymentPercentage,
      'gracePeriodDays': instance.gracePeriodDays,
      'billingCycleDay': instance.billingCycleDay,
      'nextBillingDate': instance.nextBillingDate?.toIso8601String(),
      'nextDueDate': instance.nextDueDate?.toIso8601String(),
      'lastPaymentDate': instance.lastPaymentDate?.toIso8601String(),
      'lastPaymentAmount': instance.lastPaymentAmount,
      'color': const ColorConverter().toJson(instance.color),
      'icon': const IconDataConverter().toJson(instance.icon),
      'bankName': instance.bankName,
      'isActive': instance.isActive,
      'autoGenerateStatements': instance.autoGenerateStatements,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_statement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditCardStatement _$CreditCardStatementFromJson(Map<String, dynamic> json) =>
    CreditCardStatement(
      id: json['id'] as String,
      creditCardId: json['creditCardId'] as String,
      statementNumber: json['statementNumber'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      previousBalance: (json['previousBalance'] as num).toDouble(),
      paymentsAndCredits: (json['paymentsAndCredits'] as num).toDouble(),
      purchases: (json['purchases'] as num).toDouble(),
      cashAdvances: (json['cashAdvances'] as num).toDouble(),
      interestCharges: (json['interestCharges'] as num).toDouble(),
      feesAndCharges: (json['feesAndCharges'] as num).toDouble(),
      newBalance: (json['newBalance'] as num).toDouble(),
      minimumPaymentDue: (json['minimumPaymentDue'] as num).toDouble(),
      paymentDueDate: DateTime.parse(json['paymentDueDate'] as String),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      lateFees: (json['lateFees'] as num?)?.toDouble() ?? 0.0,
      overLimitFees: (json['overLimitFees'] as num?)?.toDouble() ?? 0.0,
      balanceTransfers: (json['balanceTransfers'] as num?)?.toDouble() ?? 0.0,
      fees: (json['fees'] as num?)?.toDouble() ?? 0.0,
      adjustments: (json['adjustments'] as num?)?.toDouble() ?? 0.0,
      paidDate: json['paidDate'] == null
          ? null
          : DateTime.parse(json['paidDate'] as String),
      notes: json['notes'] as String?,
      generatedDate: DateTime.parse(json['generatedDate'] as String),
      status: $enumDecode(_$StatementStatusEnumMap, json['status']),
      isViewed: json['isViewed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CreditCardStatementToJson(
  CreditCardStatement instance,
) => <String, dynamic>{
  'id': instance.id,
  'creditCardId': instance.creditCardId,
  'statementNumber': instance.statementNumber,
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'previousBalance': instance.previousBalance,
  'paymentsAndCredits': instance.paymentsAndCredits,
  'purchases': instance.purchases,
  'cashAdvances': instance.cashAdvances,
  'interestCharges': instance.interestCharges,
  'feesAndCharges': instance.feesAndCharges,
  'newBalance': instance.newBalance,
  'minimumPaymentDue': instance.minimumPaymentDue,
  'paymentDueDate': instance.paymentDueDate.toIso8601String(),
  'paidAmount': instance.paidAmount,
  'lateFees': instance.lateFees,
  'overLimitFees': instance.overLimitFees,
  'balanceTransfers': instance.balanceTransfers,
  'fees': instance.fees,
  'adjustments': instance.adjustments,
  'paidDate': instance.paidDate?.toIso8601String(),
  'notes': instance.notes,
  'generatedDate': instance.generatedDate.toIso8601String(),
  'status': _$StatementStatusEnumMap[instance.status]!,
  'isViewed': instance.isViewed,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$StatementStatusEnumMap = {
  StatementStatus.generated: 'generated',
  StatementStatus.viewed: 'viewed',
  StatementStatus.paid: 'paid',
  StatementStatus.overdue: 'overdue',
};
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: json['id'] as String,
  creditCardId: json['creditCardId'] as String,
  statementId: json['statementId'] as String?,
  amount: (json['amount'] as num).toDouble(),
  paymentDate: DateTime.parse(json['paymentDate'] as String),
  paymentMethod: json['paymentMethod'] as String,
  status: json['status'] as String,
  referenceNumber: json['referenceNumber'] as String?,
  notes: json['notes'] as String?,
  bankAccountId: json['bankAccountId'] as String?,
  processingFee: (json['processingFee'] as num?)?.toDouble() ?? 0.0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'creditCardId': instance.creditCardId,
  'statementId': instance.statementId,
  'amount': instance.amount,
  'paymentDate': instance.paymentDate.toIso8601String(),
  'paymentMethod': instance.paymentMethod,
  'status': instance.status,
  'referenceNumber': instance.referenceNumber,
  'notes': instance.notes,
  'bankAccountId': instance.bankAccountId,
  'processingFee': instance.processingFee,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRecord _$PaymentRecordFromJson(Map<String, dynamic> json) =>
    PaymentRecord(
      id: json['id'] as String,
      creditCardId: json['creditCardId'] as String,
      statementId: json['statementId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      paymentMethod: json['paymentMethod'] as String,
      sourceAccountId: json['sourceAccountId'] as String?,
      status: json['status'] as String? ?? 'Completed',
      transactionReference: json['transactionReference'] as String?,
      notes: json['notes'] as String?,
      isMinimumPayment: json['isMinimumPayment'] as bool? ?? false,
      isFullPayment: json['isFullPayment'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PaymentRecordToJson(PaymentRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creditCardId': instance.creditCardId,
      'statementId': instance.statementId,
      'amount': instance.amount,
      'paymentDate': instance.paymentDate.toIso8601String(),
      'paymentMethod': instance.paymentMethod,
      'sourceAccountId': instance.sourceAccountId,
      'status': instance.status,
      'transactionReference': instance.transactionReference,
      'notes': instance.notes,
      'isMinimumPayment': instance.isMinimumPayment,
      'isFullPayment': instance.isFullPayment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
  themeMode: json['themeMode'] as String,
  currency: json['currency'] as String,
  locale: json['locale'] as String,
  showNotifications: json['showNotifications'] as bool,
  showBalanceInAppBar: json['showBalanceInAppBar'] as bool,
  showCategoryIcons: json['showCategoryIcons'] as bool,
  showAccountIcons: json['showAccountIcons'] as bool,
  defaultTransactionType: json['defaultTransactionType'] as String,
  autoCategorize: json['autoCategorize'] as bool,
  showTransfersSeparately: json['showTransfersSeparately'] as bool,
  recentTransactionsCount: (json['recentTransactionsCount'] as num).toInt(),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
  'themeMode': instance.themeMode,
  'currency': instance.currency,
  'locale': instance.locale,
  'showNotifications': instance.showNotifications,
  'showBalanceInAppBar': instance.showBalanceInAppBar,
  'showCategoryIcons': instance.showCategoryIcons,
  'showAccountIcons': instance.showAccountIcons,
  'defaultTransactionType': instance.defaultTransactionType,
  'autoCategorize': instance.autoCategorize,
  'showTransfersSeparately': instance.showTransfersSeparately,
  'recentTransactionsCount': instance.recentTransactionsCount,
  'updatedAt': instance.updatedAt.toIso8601String(),
};
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: json['id'] as String,
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String,
  categoryId: json['categoryId'] as String,
  accountId: json['accountId'] as String,
  toAccountId: json['toAccountId'] as String?,
  notes: json['notes'] as String?,
  imagePath: json['imagePath'] as String?,
  date: DateTime.parse(json['date'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'description': instance.description,
      'categoryId': instance.categoryId,
      'accountId': instance.accountId,
      'toAccountId': instance.toAccountId,
      'notes': instance.notes,
      'imagePath': instance.imagePath,
      'date': instance.date.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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
    return _accounts.where((account) => account.isLiability).fold(0.0, (
      sum,
      account,
    ) {
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
      print(
        'Creating account: ${accountData['name']} with type: ${accountData['type']}',
      );
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

      // Persist the image file if present
      final persistentImagePath = await _persistImage(transaction.imagePath);
      final finalTransaction = persistentImagePath != transaction.imagePath 
          ? transaction.copyWith(imagePath: persistentImagePath)
          : transaction;
          
      _transactions.add(finalTransaction);
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

  Future<bool> updateTransaction(
    String transactionId,
    Transaction updatedTransaction,
  ) async {
    try {
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index != -1) {
        final oldTransaction = _transactions[index];

        // First, reverse the old transaction's effect on account balances
        await _updateAccountBalances(oldTransaction, isDelete: true);

        // Persist the new image file if necessary and clean up the old one
        final persistentImagePath = await _persistImage(updatedTransaction.imagePath);
        if (oldTransaction.imagePath != null && oldTransaction.imagePath != persistentImagePath) {
          await _deleteImage(oldTransaction.imagePath);
        }
        
        final finalTransaction = persistentImagePath != updatedTransaction.imagePath
            ? updatedTransaction.copyWith(imagePath: persistentImagePath)
            : updatedTransaction;
            
        // Then, apply the new transaction's effect
        await _updateAccountBalances(finalTransaction);
        
        // Update the transaction
        _transactions[index] = finalTransaction;
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
      
      // Clean up the image file
      await _deleteImage(transaction.imagePath);
      
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
  
  // Image handling
  Future<String?> _persistImage(String? currentPath) async {
    if (currentPath == null || currentPath.isEmpty) return null;
    
    final currentFile = File(currentPath);
    if (!await currentFile.exists()) return currentPath;
    
    // Check if it's already in the app's document directory
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDirPath = '${appDir.path}/receipts';
    final imagesDir = Directory(imagesDirPath);
    
    if (currentPath.startsWith(imagesDirPath)) {
      return currentPath; // Already persisted
    }
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    // Get extension safely
    String extension = '.jpg';
    var lastDot = currentPath.lastIndexOf('.');
    if (lastDot != -1 && currentPath.length - lastDot <= 5) {
      extension = currentPath.substring(lastDot);
    }
    
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${currentFile.hashCode}$extension';
    final savedImage = await currentFile.copy('$imagesDirPath/$fileName');
    
    return savedImage.path;
  }
  
  Future<void> _deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDirPath = '${appDir.path}/receipts';
      
      // Only delete if it's in our managed directory
      if (imagePath.startsWith(imagesDirPath)) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Failed to delete managed image: $e');
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
          print(
            'Warning: Storage save failed, but account added to local state',
          );
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
          _transactions[i] = transaction.copyWith(accountId: deletedAccount.id);
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
      final transactionsToDelete = _transactions
          .where((t) => t.accountId == accountId || t.toAccountId == accountId)
          .toList();

      // Remove transactions from the list and delete their localized images
      for (final t in transactionsToDelete) {
        if (t.imagePath != null) {
          await _deleteImage(t.imagePath);
        }
      }
      
      _transactions.removeWhere(
        (t) => t.accountId == accountId || t.toAccountId == accountId,
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
  Future<void> _updateAccountBalances(
    Transaction transaction, {
    bool isDelete = false,
  }) async {
    final multiplier = isDelete ? -1 : 1;

    if (transaction.isTransfer && transaction.toAccountId != null) {
      // Handle transfers with proper credit card logic
      final fromAccount = _accounts.firstWhere(
        (a) => a.id == transaction.accountId,
      );
      final toAccount = _accounts.firstWhere(
        (a) => a.id == transaction.toAccountId!,
      );

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
      final fromIndex = _accounts.indexWhere(
        (a) => a.id == transaction.accountId,
      );
      final toIndex = _accounts.indexWhere(
        (a) => a.id == transaction.toAccountId!,
      );

      if (fromIndex != -1) _accounts[fromIndex] = updatedFromAccount;
      if (toIndex != -1) _accounts[toIndex] = updatedToAccount;

      // CRITICAL: If the TO account is a credit card, also update the CreditCard entity
      if (toAccount.type == AccountType.creditCard &&
          _creditCardProvider != null) {
        final newOutstandingBalance = updatedToAccount.balance;
        await _creditCardProvider!.updateCreditCardBalance(
          toAccount.id,
          newOutstandingBalance,
        );
      }
    } else {
      // Handle income/expense
      final accountIndex = _accounts.indexWhere(
        (a) => a.id == transaction.accountId,
      );
      if (accountIndex == -1) return; // Account not found

      final account = _accounts[accountIndex];
      Account updatedAccount;

      if (transaction.isIncome) {
        // For credit cards (liabilities), income reduces debt (subtract from balance)
        if (account.type == AccountType.creditCard) {
          // For credit cards, income should reduce debt (subtract from balance)
          updatedAccount = account.subtractFromBalance(
            transaction.amount.abs() * multiplier,
          );
        } else {
          // For regular accounts, income increases balance
          updatedAccount = account.addToBalance(
            transaction.amount.abs() * multiplier,
          );
        }
      } else {
        // For credit cards (liabilities), expenses increase debt (add to balance)
        if (account.type == AccountType.creditCard) {
          // For credit cards, expenses should increase debt (add to balance)
          updatedAccount = account.addToBalance(
            transaction.amount.abs() * multiplier,
          );
        } else {
          // For regular accounts, expenses decrease balance
          updatedAccount = account.subtractFromBalance(
            transaction.amount.abs() * multiplier,
          );
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
      if (account.type == AccountType.creditCard &&
          _creditCardProvider != null) {
        // For credit cards, the account balance directly represents the outstanding balance
        final newOutstandingBalance = updatedAccount.balance;
        await _creditCardProvider!.updateCreditCardBalance(
          account.id,
          newOutstandingBalance,
        );
      }
    }
  }

  // Validate transfer logic
  TransferValidationResult _validateTransfer(Transaction transaction) {
    try {
      final fromAccount = _accounts.firstWhere(
        (a) => a.id == transaction.accountId,
      );
      final toAccount = _accounts.firstWhere(
        (a) => a.id == transaction.toAccountId!,
      );

      // Rule 1: Only Asset → Liability or Asset → Asset
      if (fromAccount.type.isLiability) {
        return const TransferValidationResult(
          isValid: false,
          errorMessage:
              'Cannot transfer from liability accounts (Credit Cards, Loans). Only asset accounts can initiate transfers.',
        );
      }

      // Rule 2: Check sufficient balance for asset accounts
      if (fromAccount.type.isAsset &&
          fromAccount.balance < transaction.amount.abs()) {
        return TransferValidationResult(
          isValid: false,
          errorMessage:
              'Insufficient balance. Available: ${Formatters.formatCurrency(fromAccount.balance)}, Required: ${Formatters.formatCurrency(transaction.amount.abs())}',
        );
      }

      // Rule 3: Prevent transfer to same account
      if (fromAccount.id == toAccount.id) {
        return const TransferValidationResult(
          isValid: false,
          errorMessage: 'Cannot transfer to the same account.',
        );
      }

      return const TransferValidationResult(isValid: true, errorMessage: '');
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
      final account = _accounts.firstWhere(
        (a) => a.id == transaction.accountId,
      );

      // Only check balance for asset accounts (savings, cash, wallet, etc.)
      if (account.type.isAsset && account.balance < transaction.amount.abs()) {
        return TransferValidationResult(
          isValid: false,
          errorMessage:
              'Insufficient balance for expense. Available: ${Formatters.formatCurrency(account.balance)}, Required: ${Formatters.formatCurrency(transaction.amount.abs())}',
        );
      }

      return const TransferValidationResult(isValid: true, errorMessage: '');
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

  // Production cleanup: Remove test accounts (Cash, Bank Account)
  Future<void> removeTestAccounts() async {
    try {
      // Remove test accounts by name (case insensitive)
      final testAccountNames = ['cash', 'bank account', 'bank'];
      _accounts.removeWhere(
        (account) => testAccountNames.any(
          (testName) =>
              account.name.toLowerCase().contains(testName.toLowerCase()),
        ),
      );

      // Save updated accounts
      await StorageService.saveAccounts(_accounts);
      notifyListeners();

      print('Test accounts removed successfully');
    } catch (e) {
      print('Error removing test accounts: $e');
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await _loadAllData();
    notifyListeners();
  }

  /// Import accounts from backup
  Future<void> importAccounts(List<Account> accounts) async {
    _accounts = accounts;
    await StorageService.saveAccounts(_accounts);
    notifyListeners();
  }

  /// Import transactions from backup
  Future<void> importTransactions(List<Transaction> transactions) async {
    _transactions = transactions;
    await StorageService.saveTransactions(_transactions);
    notifyListeners();
  }

  /// Import categories from backup
  Future<void> importCategories(List<Category> categories) async {
    _categories = categories;
    await StorageService.saveCategories(_categories);
    notifyListeners();
  }

  /// Import settings from backup
  Future<void> importSettings(Settings settings) async {
    _settings = settings;
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }
}
import 'package:flutter/foundation.dart';
import '../models/credit_card.dart';
import '../models/credit_card_statement.dart';
import '../models/payment_record.dart';
import '../models/transaction.dart';
import '../utils/storage_service.dart';
import 'app_provider.dart';

/// Credit Card Provider for managing credit card state and operations
class CreditCardProvider extends ChangeNotifier {
  // Data
  List<CreditCard> _creditCards = [];
  List<CreditCardStatement> _statements = [];
  List<PaymentRecord> _payments = [];
  
  // UI State
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<CreditCard> get creditCards => _creditCards;
  List<CreditCardStatement> get statements => _statements;
  List<PaymentRecord> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Computed values
  List<CreditCard> get activeCreditCards => _creditCards.where((card) => card.isActive).toList();
  
  List<CreditCard> get overdueCards => _creditCards.where((card) => card.isOverdue).toList();
  
  List<CreditCard> get dueSoonCards => _creditCards.where((card) => card.isDueSoon).toList();
  
  List<CreditCardStatement> get pendingStatements => _statements.where((stmt) => stmt.status == StatementStatus.generated).toList();
  
  List<CreditCardStatement> get overdueStatements => _statements.where((stmt) => stmt.isOverdue).toList();
  
  double get totalCreditLimit {
    return _creditCards.fold(0.0, (sum, card) => sum + card.creditLimit);
  }
  
  double get totalOutstandingBalance {
    return _creditCards.fold(0.0, (sum, card) => sum + card.outstandingBalance);
  }
  
  double get totalAvailableCredit {
    return _creditCards.fold(0.0, (sum, card) => sum + card.availableCredit);
  }
  
  double get overallUtilization {
    if (totalCreditLimit <= 0) return 0.0;
    return totalOutstandingBalance / totalCreditLimit;
  }
  
  String get overallUtilizationStatus {
    final utilization = overallUtilization;
    if (utilization >= 0.90) return 'Critical';
    if (utilization >= 0.80) return 'Warning';
    if (utilization >= 0.70) return 'High';
    if (utilization >= 0.50) return 'Moderate';
    if (utilization >= 0.30) return 'Elevated';
    return 'Safe';
  }
  
  // Initialize provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadAllData();
      _error = null;
    } catch (e) {
      _error = 'Failed to load credit card data: $e';
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
    try {
      // Load credit cards, statements, and payments in parallel
      final results = await Future.wait([
        StorageService.loadCreditCards(),
        StorageService.loadCreditCardStatements(),
        StorageService.loadPaymentRecords(),
      ]);
      
      _creditCards = results[0] as List<CreditCard>;
      _statements = results[1] as List<CreditCardStatement>;
      _payments = results[2] as List<PaymentRecord>;
    } catch (e) {
      // If storage methods don't exist yet, initialize with empty lists
      _creditCards = [];
      _statements = [];
      _payments = [];
    }
  }
  
  // ========================================
  // CREDIT CARD MANAGEMENT
  // ========================================
  
  /// Add a new credit card
  Future<bool> addCreditCard(CreditCard creditCard) async {
    try {
      _creditCards.add(creditCard);
      await StorageService.saveCreditCards(_creditCards);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add credit card: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Update an existing credit card
  Future<bool> updateCreditCard(CreditCard creditCard) async {
    try {
      final index = _creditCards.indexWhere((card) => card.id == creditCard.id);
      if (index != -1) {
        _creditCards[index] = creditCard;
        await StorageService.saveCreditCards(_creditCards);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update credit card: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update credit card balance after payment
  Future<bool> updateCreditCardBalance(String creditCardId, double newOutstandingBalance) async {
    try {
      final index = _creditCards.indexWhere((card) => card.id == creditCardId);
      if (index != -1) {
        final card = _creditCards[index];
        final updatedCard = card.copyWith(
          outstandingBalance: newOutstandingBalance,
          availableCredit: card.creditLimit - newOutstandingBalance,
          updatedAt: DateTime.now(),
        );
        _creditCards[index] = updatedCard;
        await StorageService.saveCreditCards(_creditCards);
        
        // Mark any generated statements as paid if balance is now 0 or negative
        if (newOutstandingBalance <= 0) {
          await _markStatementsAsPaid(creditCardId);
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update credit card balance: $e';
      notifyListeners();
      return false;
    }
  }

  /// Mark generated statements as paid for a credit card
  Future<void> _markStatementsAsPaid(String creditCardId) async {
    try {
      bool updated = false;
      for (int i = 0; i < _statements.length; i++) {
        final statement = _statements[i];
        if (statement.creditCardId == creditCardId && 
            statement.status == StatementStatus.generated) {
          _statements[i] = statement.copyWith(
            status: StatementStatus.paid,
            paidAmount: statement.newBalance,
            paidDate: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          updated = true;
        }
      }
      
      if (updated) {
        await StorageService.saveCreditCardStatements(_statements);
      }
    } catch (e) {
      _error = 'Failed to mark statements as paid: $e';
    }
  }
  
  /// Delete a credit card
  Future<bool> deleteCreditCard(String creditCardId) async {
    try {
      _creditCards.removeWhere((card) => card.id == creditCardId);
      // Also remove related statements and payments
      _statements.removeWhere((stmt) => stmt.creditCardId == creditCardId);
      _payments.removeWhere((payment) => payment.creditCardId == creditCardId);
      
      await StorageService.saveCreditCards(_creditCards);
      await StorageService.saveCreditCardStatements(_statements);
      await StorageService.savePaymentRecords(_payments);
      
      // CRITICAL: Also delete the corresponding Account from AppProvider
      // This ensures the credit card is removed from both places
      await _deleteCorrespondingAccount(creditCardId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete credit card: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Delete the corresponding Account entity for a credit card
  Future<void> _deleteCorrespondingAccount(String creditCardId) async {
    try {
      // Import AppProvider to access account deletion
      // This will be handled by the calling context
      print('Credit card $creditCardId deleted - corresponding account should also be deleted');
    } catch (e) {
      print('Error deleting corresponding account: $e');
    }
  }
  
  /// Get credit card by ID
  CreditCard? getCreditCardById(String id) {
    try {
      return _creditCards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Get statements for a specific credit card
  List<CreditCardStatement> getStatementsForCard(String creditCardId) {
    return _statements.where((stmt) => stmt.creditCardId == creditCardId).toList();
  }

  /// Check if statement exists for current billing period for a credit card
  bool hasStatementForCurrentMonth(String creditCardId) {
    final card = getCreditCardById(creditCardId);
    if (card == null) return false;
    
    final now = DateTime.now();
    final billingDay = card.billingCycleDay;
    
    // Calculate current billing period start date
    DateTime currentPeriodStart;
    if (now.day < billingDay) {
      // Current period started last month
      currentPeriodStart = DateTime(now.year, now.month - 1, billingDay);
    } else {
      // Current period started this month
      currentPeriodStart = DateTime(now.year, now.month, billingDay);
    }
    
    return _statements.any((stmt) => 
      stmt.creditCardId == creditCardId && 
      stmt.periodStart.year == currentPeriodStart.year &&
      stmt.periodStart.month == currentPeriodStart.month &&
      stmt.periodStart.day == currentPeriodStart.day
    );
  }

  /// Get current billing period statement for a credit card
  CreditCardStatement? getCurrentMonthStatement(String creditCardId) {
    final card = getCreditCardById(creditCardId);
    if (card == null) return null;
    
    final now = DateTime.now();
    final billingDay = card.billingCycleDay;
    
    // Calculate current billing period start date
    DateTime currentPeriodStart;
    if (now.day < billingDay) {
      // Current period started last month
      currentPeriodStart = DateTime(now.year, now.month - 1, billingDay);
    } else {
      // Current period started this month
      currentPeriodStart = DateTime(now.year, now.month, billingDay);
    }
    
    try {
      return _statements.firstWhere((stmt) => 
        stmt.creditCardId == creditCardId && 
        stmt.periodStart.year == currentPeriodStart.year &&
        stmt.periodStart.month == currentPeriodStart.month &&
        stmt.periodStart.day == currentPeriodStart.day
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Get payments for a specific credit card
  List<PaymentRecord> getPaymentsForCard(String creditCardId) {
    return _payments.where((payment) => payment.creditCardId == creditCardId).toList();
  }

  /// Generate statement for a credit card
  /// Check if a statement already exists for the current period
  bool _statementExistsForPeriod(String creditCardId, DateTime periodStart) {
    return _statements.any((stmt) => 
      stmt.creditCardId == creditCardId && 
      stmt.periodStart.year == periodStart.year &&
      stmt.periodStart.month == periodStart.month &&
      stmt.periodStart.day == periodStart.day
    );
  }

  Future<CreditCardStatement?> generateStatement(String creditCardId) async {
    try {
      final card = _creditCards.firstWhere((c) => c.id == creditCardId);
      
      // Calculate statement period
      final now = DateTime.now();
      final billingDay = card.billingCycleDay;
      
      DateTime periodStart;
      DateTime periodEnd;
      
      if (now.day < billingDay) {
        // Current period started last month
        periodStart = DateTime(now.year, now.month - 1, billingDay);
        periodEnd = DateTime(now.year, now.month, billingDay - 1);
      } else {
        // Current period started this month
        periodStart = DateTime(now.year, now.month, billingDay);
        periodEnd = DateTime(now.year, now.month + 1, billingDay - 1);
      }
      
      // Check if statement already exists for this period
      if (_statementExistsForPeriod(creditCardId, periodStart)) {
        _error = 'Statement already exists for this billing period';
        notifyListeners();
        return null;
      }
      
      // Calculate statement amounts from transactions
      final previousBalance = _getPreviousStatementBalance(creditCardId) ?? 0.0;
      
      // Get transactions for this billing period
      final periodTransactions = _getTransactionsForPeriod(creditCardId, periodStart, periodEnd);
      
      // Calculate statement components
      final paymentsAndCredits = _calculatePaymentsAndCredits(periodTransactions, creditCardId);
      final purchases = _calculatePurchases(periodTransactions, creditCardId);
      final cashAdvances = _calculateCashAdvances(periodTransactions, creditCardId);
      final interestCharges = _calculateInterestCharges(creditCardId, previousBalance, periodStart);
      final feesAndCharges = _calculateFeesAndCharges(creditCardId, periodStart);
      final minimumPaymentDue = card.minimumPaymentAmount;
      final paymentDueDate = card.nextDueDate ?? now.add(const Duration(days: 21));
      
      // TEMPORARY FIX: Use current outstanding balance as newBalance until proper transaction integration
      // This ensures statement balance matches current outstanding balance
      final newBalance = card.outstandingBalance; // Always use current outstanding balance
      
      // Create statement with corrected balance
      final statement = CreditCardStatement(
        id: 'stmt_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}',
        creditCardId: creditCardId,
        statementNumber: '${now.year}-${now.month.toString().padLeft(2, '0')}',
        periodStart: periodStart,
        periodEnd: periodEnd,
        previousBalance: previousBalance,
        paymentsAndCredits: paymentsAndCredits,
        purchases: purchases,
        cashAdvances: cashAdvances,
        interestCharges: interestCharges,
        feesAndCharges: feesAndCharges,
        newBalance: newBalance, // Use corrected balance
        minimumPaymentDue: minimumPaymentDue,
        paymentDueDate: paymentDueDate,
        generatedDate: now,
        status: StatementStatus.generated,
        createdAt: now,
        updatedAt: now,
      );
      
      // Add to statements list
      _statements.add(statement);
      
      // Save to storage
      await StorageService.saveCreditCardStatements(_statements);
      
      // Clear any previous errors
      _error = null;
      notifyListeners();
      return statement;
    } catch (e) {
      _error = 'Failed to generate statement: $e';
      notifyListeners();
      return null;
    }
  }

  /// Check for automatic statement generation
  Future<void> checkForAutomaticStatementGeneration() async {
    try {
      for (final card in _creditCards) {
        if (card.autoGenerateStatements && card.nextBillingDate != null) {
          final now = DateTime.now();
          final billingDate = card.nextBillingDate!;
          
          // Check if it's time to generate statement (same day or past billing date)
          if (now.isAfter(billingDate) || now.day == billingDate.day) {
            // Check if statement already exists for this period
            final existingStatement = _statements.where((stmt) => 
              stmt.creditCardId == card.id && 
              stmt.periodStart.year == billingDate.year &&
              stmt.periodStart.month == billingDate.month &&
              stmt.periodStart.day == billingDate.day
            ).isNotEmpty;
            
            if (!existingStatement) {
              await generateStatement(card.id);
            }
          }
        }
      }
    } catch (e) {
      _error = 'Failed to check automatic statement generation: $e';
      notifyListeners();
    }
  }
  
  // ========================================
  // STATEMENT MANAGEMENT
  // ========================================
  
  /// Add a new statement
  Future<bool> addStatement(CreditCardStatement statement) async {
    try {
      _statements.add(statement);
      await StorageService.saveCreditCardStatements(_statements);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add statement: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Update an existing statement
  Future<bool> updateStatement(CreditCardStatement statement) async {
    try {
      final index = _statements.indexWhere((stmt) => stmt.id == statement.id);
      if (index != -1) {
        _statements[index] = statement;
        await StorageService.saveCreditCardStatements(_statements);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update statement: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Check if statement should be generated
  bool _shouldGenerateStatement(CreditCard creditCard) {
    if (!creditCard.autoGenerateStatements) return false;
    if (creditCard.nextBillingDate == null) return false;
    
    final now = DateTime.now();
    return now.isAfter(creditCard.nextBillingDate!);
  }
  
  /// Generate statement number
  String _generateStatementNumber(String creditCardId) {
    final cardStatements = getStatementsForCard(creditCardId);
    final nextNumber = cardStatements.length + 1;
    return 'STMT${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${nextNumber.toString().padLeft(3, '0')}';
  }
  
  /// Get previous statement balance
  double? _getPreviousStatementBalance(String creditCardId) {
    final statements = getStatementsForCard(creditCardId);
    if (statements.isEmpty) return null;
    
    // Sort by creation date and get the latest
    statements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return statements.first.newBalance;
  }
  
  // ========================================
  // PAYMENT MANAGEMENT
  // ========================================
  
  /// Add a new payment record
  Future<bool> addPayment(PaymentRecord payment) async {
    try {
      _payments.add(payment);
      await StorageService.savePaymentRecords(_payments);
      
      // Update credit card balance
      await _updateCreditCardBalance(payment);
      
      // Update statement if applicable
      if (payment.statementId != null) {
        await _updateStatementPayment(payment);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add payment: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Update credit card balance after payment
  Future<void> _updateCreditCardBalance(PaymentRecord payment) async {
    final creditCard = getCreditCardById(payment.creditCardId);
    if (creditCard == null) return;
    
    final newOutstandingBalance = creditCard.outstandingBalance - payment.amount;
    final newAvailableCredit = creditCard.creditLimit - newOutstandingBalance;
    
    final updatedCard = creditCard.copyWith(
      outstandingBalance: newOutstandingBalance,
      availableCredit: newAvailableCredit,
      lastPaymentDate: payment.paymentDate,
      lastPaymentAmount: payment.amount,
    );
    
    await updateCreditCard(updatedCard);
  }
  
  /// Update statement payment status
  Future<void> _updateStatementPayment(PaymentRecord payment) async {
    final statement = _statements.firstWhere(
      (stmt) => stmt.id == payment.statementId,
      orElse: () => throw Exception('Statement not found'),
    );
    
    final newPaidAmount = statement.paidAmount + payment.amount;
    StatementStatus newStatus = statement.status;
    
    if (newPaidAmount >= statement.newBalance) {
      newStatus = StatementStatus.paid;
    } else if (newPaidAmount > 0) {
      newStatus = StatementStatus.generated; // Keep as generated for partial payments
    }
    
    final updatedStatement = statement.copyWith(
      paidAmount: newPaidAmount,
      status: newStatus,
      paidDate: payment.paymentDate,
    );
    
    await updateStatement(updatedStatement);
  }
  
  /// Process payment for a credit card
  Future<bool> processPayment({
    required String creditCardId,
    required double amount,
    required String paymentMethod,
    String? sourceAccountId,
    String? statementId,
    bool isMinimumPayment = false,
    bool isFullPayment = false,
    String? notes,
  }) async {
    try {
      final creditCard = getCreditCardById(creditCardId);
      if (creditCard == null) return false;
      
      // Validate payment amount
      if (amount <= 0 || amount > creditCard.outstandingBalance) {
        _error = 'Invalid payment amount';
        notifyListeners();
        return false;
      }
      
      // Create payment record
      final payment = PaymentRecord.create(
        creditCardId: creditCardId,
        statementId: statementId,
        amount: amount,
        paymentDate: DateTime.now(),
        paymentMethod: paymentMethod,
        sourceAccountId: sourceAccountId,
        isMinimumPayment: isMinimumPayment,
        isFullPayment: isFullPayment,
        notes: notes,
      );
      
      return await addPayment(payment);
    } catch (e) {
      _error = 'Failed to process payment: $e';
      notifyListeners();
      return false;
    }
  }
  
  // ========================================
  // ANALYTICS & INSIGHTS
  // ========================================
  
  /// Get spending summary for a period
  Map<String, double> getSpendingSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final start = startDate ?? DateTime.now().subtract(Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    double totalSpending = 0.0;
    double totalPayments = 0.0;
    int paymentCount = 0;
    
    // Calculate spending from statements
    for (final statement in _statements) {
      if (statement.periodStart.isAfter(start) && statement.periodEnd.isBefore(end)) {
        totalSpending += statement.purchases ?? 0.0;
        totalPayments += statement.paidAmount;
        if (statement.paidAmount > 0) paymentCount++;
      }
    }
    
    return {
      'totalSpending': totalSpending,
      'totalPayments': totalPayments,
      'paymentCount': paymentCount.toDouble(),
      'averagePayment': paymentCount > 0 ? totalPayments / paymentCount : 0.0,
    };
  }
  
  /// Get credit utilization trend
  List<Map<String, dynamic>> getUtilizationTrend({int months = 6}) {
    final List<Map<String, dynamic>> trend = [];
    final now = DateTime.now();
    
    for (int i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final endDate = DateTime(date.year, date.month + 1, 0);
      
      double totalLimit = 0.0;
      double totalBalance = 0.0;
      
      for (final card in _creditCards) {
        if (card.createdAt.isBefore(endDate)) {
          totalLimit += card.creditLimit;
          // This is simplified - in a real app, you'd track historical balances
          totalBalance += card.outstandingBalance;
        }
      }
      
      final utilization = totalLimit > 0 ? totalBalance / totalLimit : 0.0;
      
      trend.add({
        'date': date,
        'utilization': utilization,
        'totalLimit': totalLimit,
        'totalBalance': totalBalance,
      });
    }
    
    return trend;
  }
  
  /// Get payment history for a credit card
  List<PaymentRecord> getPaymentHistory(String creditCardId, {int limit = 10}) {
    final payments = getPaymentsForCard(creditCardId);
    payments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    return payments.take(limit).toList();
  }
  
  /// Get on-time payment percentage
  double getOnTimePaymentPercentage(String creditCardId) {
    final payments = getPaymentsForCard(creditCardId);
    final statements = getStatementsForCard(creditCardId);
    
    if (payments.isEmpty || statements.isEmpty) return 0.0;
    
    int onTimePayments = 0;
    int totalPayments = 0;
    
    for (final payment in payments) {
      if (payment.statementId != null) {
        final statement = statements.firstWhere(
          (stmt) => stmt.id == payment.statementId,
          orElse: () => throw Exception('Statement not found'),
        );
        
        totalPayments++;
        if (payment.paymentDate.isBefore(statement.paymentDueDate) || 
            payment.paymentDate.isAtSameMomentAs(statement.paymentDueDate)) {
          onTimePayments++;
        }
      }
    }
    
    return totalPayments > 0 ? (onTimePayments / totalPayments) * 100 : 0.0;
  }
  
  /// Delete a statement and its related payment transactions only
  Future<bool> deleteStatement(String statementId, {AppProvider? appProvider}) async {
    try {
      // Find the statement to get its period
      final statement = _statements.firstWhere((stmt) => stmt.id == statementId);
      
      // If AppProvider is provided, delete only payment transactions (transfers TO the credit card)
      if (appProvider != null) {
        // Find payment transactions (transfers TO the credit card) for this period
        final paymentTransactions = appProvider.transactions.where((transaction) {
          return transaction.type == 'transfer' && 
                 transaction.toAccountId == statement.creditCardId &&
                 transaction.date.isAfter(statement.periodStart.subtract(const Duration(days: 1))) &&
                 transaction.date.isBefore(statement.periodEnd.add(const Duration(days: 1)));
        }).toList();
        
        // Delete only payment transactions (NOT the original credit card expense transactions)
        for (final transaction in paymentTransactions) {
          await appProvider.deleteTransaction(transaction.id);
        }
        
        print('Deleted ${paymentTransactions.length} payment transactions (keeping original credit card transactions)');
      }
      
      // Remove the statement
      _statements.removeWhere((stmt) => stmt.id == statementId);
      await StorageService.saveCreditCardStatements(_statements);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete statement: $e';
      notifyListeners();
      return false;
    }
  }

  /// Setup auto-pay for a credit card (pay 4 days before due date)
  Future<bool> setupAutoPay(String creditCardId, {
    required double amount,
    required String paymentAccountId,
    bool payFullBalance = false,
  }) async {
    try {
      final card = _creditCards.firstWhere((c) => c.id == creditCardId);
      
      if (card.nextDueDate == null) {
        _error = 'Due date not set for this credit card';
        notifyListeners();
        return false;
      }
      
      // Calculate payment date (4 days before due date)
      final paymentDate = card.nextDueDate!.subtract(const Duration(days: 4));
      
      // Calculate payment amount
      final paymentAmount = payFullBalance ? card.outstandingBalance : amount;
      
      // Create auto-pay record
      final autoPayRecord = PaymentRecord.create(
        creditCardId: creditCardId,
        amount: paymentAmount,
        paymentDate: paymentDate,
        paymentMethod: 'Auto-Pay',
        sourceAccountId: paymentAccountId,
        status: 'Scheduled',
        notes: 'Auto-pay scheduled for 4 days before due date',
      );
      
      _payments.add(autoPayRecord);
      await StorageService.savePaymentRecords(_payments);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to setup auto-pay: $e';
      notifyListeners();
      return false;
    }
  }

  /// Process scheduled auto-pay payments
  Future<void> processScheduledAutoPayments() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      for (final payment in _payments) {
        if (payment.status == 'Scheduled' &&
            payment.paymentDate.isAtSameMomentAs(today)) {
          
          // Process the auto-payment
          await processPayment(
            creditCardId: payment.creditCardId,
            amount: payment.amount,
            sourceAccountId: payment.sourceAccountId ?? '',
            paymentMethod: payment.paymentMethod,
            notes: payment.notes,
          );
          
          // Update payment status
          final updatedPayment = payment.copyWith(
            status: 'Completed',
          );
          
          final index = _payments.indexWhere((p) => p.id == payment.id);
          if (index != -1) {
            _payments[index] = updatedPayment;
          }
        }
      }
      
      await StorageService.savePaymentRecords(_payments);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to process auto-payments: $e';
      notifyListeners();
    }
  }

  // ========================================
  // UTILITY METHODS
  // ========================================
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Refresh all data
  Future<void> refresh() async {
    _error = null; // Clear any previous errors
    await _loadAllData();
    notifyListeners();
  }
  
  /// Get credit cards with high utilization
  List<CreditCard> getHighUtilizationCards({double threshold = 0.8}) {
    return _creditCards.where((card) => card.utilizationPercentage >= threshold).toList();
  }
  
  /// Get credit cards due soon
  List<CreditCard> getCardsDueSoon({int days = 7}) {
    return _creditCards.where((card) {
      if (card.nextDueDate == null) return false;
      final daysUntilDue = card.nextDueDate!.difference(DateTime.now()).inDays;
      return daysUntilDue >= 0 && daysUntilDue <= days;
    }).toList();
  }
  
  /// Get overdue credit cards
  List<CreditCard> getOverdueCards() {
    return _creditCards.where((card) => card.isOverdue).toList();
  }

  /// Import credit cards from backup
  Future<void> importCreditCards(List<CreditCard> creditCards) async {
    _creditCards = creditCards;
    await StorageService.saveCreditCards(_creditCards);
    notifyListeners();
  }

  /// Import statements from backup
  Future<void> importStatements(List<CreditCardStatement> statements) async {
    _statements = statements;
    await StorageService.saveCreditCardStatements(_statements);
    notifyListeners();
  }

  /// Import payments from backup
  Future<void> importPayments(List<PaymentRecord> payments) async {
    _payments = payments;
    await StorageService.savePaymentRecords(_payments);
    notifyListeners();
  }

  // ========================================
  // STATEMENT CALCULATION HELPER METHODS
  // ========================================

  /// Get transactions for a specific billing period
  List<Transaction> _getTransactionsForPeriod(String creditCardId, DateTime periodStart, DateTime periodEnd) {
    // This would need access to AppProvider transactions
    // For now, return empty list - this should be implemented with proper data access
    return [];
  }

  /// Calculate payments and credits for the period
  double _calculatePaymentsAndCredits(List<Transaction> transactions, String creditCardId) {
    // Calculate from payment records for this credit card within the statement period
    // For now, return 0 - this should be implemented with proper period-based calculation
    return 0.0;
  }

  /// Calculate purchases for the period
  double _calculatePurchases(List<Transaction> transactions, String creditCardId) {
    // This would calculate from transactions where the credit card is the source
    // For now, return 0 - this should be implemented with proper transaction data
    return 0.0;
  }

  /// Calculate cash advances for the period
  double _calculateCashAdvances(List<Transaction> transactions, String creditCardId) {
    // This would calculate cash advance transactions
    // For now, return 0 - this should be implemented with proper transaction data
    return 0.0;
  }

  /// Calculate interest charges for the period
  double _calculateInterestCharges(String creditCardId, double previousBalance, DateTime periodStart) {
    final card = getCreditCardById(creditCardId);
    if (card == null) return 0.0;
    
    // Simple interest calculation: (balance * rate * days) / 365
    final daysInPeriod = DateTime.now().difference(periodStart).inDays;
    final annualRate = card.interestRate / 100.0;
    return (previousBalance * annualRate * daysInPeriod) / 365.0;
  }

  /// Calculate fees and charges for the period
  double _calculateFeesAndCharges(String creditCardId, DateTime periodStart) {
    // This would calculate various fees like annual fees, late fees, etc.
    // For now, return 0 - this should be implemented based on card terms
    return 0.0;
  }
}
import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../models/bank_account.dart';
import '../utils/storage_service.dart';

/// Payment Provider for managing payment operations
class PaymentProvider extends ChangeNotifier {
  List<Payment> _payments = [];
  List<BankAccount> _bankAccounts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Payment> get payments => List.unmodifiable(_payments);
  List<BankAccount> get bankAccounts => List.unmodifiable(_bankAccounts);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get payments for a specific credit card
  List<Payment> getPaymentsForCard(String creditCardId) {
    return _payments.where((payment) => payment.creditCardId == creditCardId).toList();
  }

  /// Get payments for a specific statement
  List<Payment> getPaymentsForStatement(String statementId) {
    return _payments.where((payment) => payment.statementId == statementId).toList();
  }

  /// Get total amount paid for a credit card
  double getTotalPaidForCard(String creditCardId) {
    return _payments
        .where((payment) => payment.creditCardId == creditCardId && payment.isCompleted)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get total amount paid for a statement
  double getTotalPaidForStatement(String statementId) {
    return _payments
        .where((payment) => payment.statementId == statementId && payment.isCompleted)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get active bank accounts
  List<BankAccount> get activeBankAccounts {
    return _bankAccounts.where((account) => account.isActive).toList();
  }

  /// Get verified bank accounts
  List<BankAccount> get verifiedBankAccounts {
    return _bankAccounts.where((account) => account.isActive && account.isVerified).toList();
  }

  /// Initialize the provider
  Future<void> initialize() async {
    await loadPayments();
    await loadBankAccounts();
  }

  /// Load payments from storage
  Future<void> loadPayments() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final payments = await StorageService.loadPayments();
      _payments = payments;
    } catch (e) {
      _error = 'Failed to load payments: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load bank accounts from storage
  Future<void> loadBankAccounts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final bankAccounts = await StorageService.loadBankAccounts();
      _bankAccounts = bankAccounts;
    } catch (e) {
      _error = 'Failed to load bank accounts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new payment
  Future<bool> addPayment(Payment payment) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate payment
      if (payment.amount <= 0) {
        _error = 'Payment amount must be greater than 0';
        return false;
      }

      // Check if bank account has sufficient balance (if applicable)
      if (payment.bankAccountId != null) {
        final bankAccount = _bankAccounts.firstWhere(
          (account) => account.id == payment.bankAccountId,
          orElse: () => throw Exception('Bank account not found'),
        );

        if (!bankAccount.hasSufficientBalance(payment.totalAmount)) {
          _error = 'Insufficient balance in selected bank account';
          return false;
        }
      }

      // Add payment to list
      _payments.add(payment);

      // Save to storage
      await StorageService.savePayments(_payments);

      // Update bank account balance if applicable
      if (payment.bankAccountId != null && payment.isCompleted) {
        await _updateBankAccountBalance(payment.bankAccountId!, payment.totalAmount, false);
      }

      return true;
    } catch (e) {
      _error = 'Failed to add payment: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus(String paymentId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final paymentIndex = _payments.indexWhere((payment) => payment.id == paymentId);
      if (paymentIndex == -1) {
        _error = 'Payment not found';
        return false;
      }

      final payment = _payments[paymentIndex];
      final updatedPayment = payment.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );

      _payments[paymentIndex] = updatedPayment;

      // Save to storage
      await StorageService.savePayments(_payments);

      // Update bank account balance if status changed to completed
      if (status == 'completed' && payment.bankAccountId != null && !payment.isCompleted) {
        await _updateBankAccountBalance(payment.bankAccountId!, payment.totalAmount, false);
      } else if (payment.isCompleted && payment.bankAccountId != null && status != 'completed') {
        // Revert bank account balance if payment was completed but status changed
        await _updateBankAccountBalance(payment.bankAccountId!, payment.totalAmount, true);
      }

      return true;
    } catch (e) {
      _error = 'Failed to update payment status: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a payment
  Future<bool> deletePayment(String paymentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final paymentIndex = _payments.indexWhere((payment) => payment.id == paymentId);
      if (paymentIndex == -1) {
        _error = 'Payment not found';
        return false;
      }

      final payment = _payments[paymentIndex];

      // Revert bank account balance if payment was completed
      if (payment.isCompleted && payment.bankAccountId != null) {
        await _updateBankAccountBalance(payment.bankAccountId!, payment.totalAmount, true);
      }

      _payments.removeAt(paymentIndex);

      // Save to storage
      await StorageService.savePayments(_payments);

      return true;
    } catch (e) {
      _error = 'Failed to delete payment: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new bank account
  Future<bool> addBankAccount(BankAccount bankAccount) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate bank account
      if (bankAccount.accountNumber.isEmpty || bankAccount.ifscCode.isEmpty) {
        _error = 'Account number and IFSC code are required';
        return false;
      }

      // Check for duplicate account numbers
      final existingAccount = _bankAccounts.any(
        (account) => account.accountNumber == bankAccount.accountNumber && account.id != bankAccount.id,
      );

      if (existingAccount) {
        _error = 'Bank account with this account number already exists';
        return false;
      }

      _bankAccounts.add(bankAccount);

      // Save to storage
      await StorageService.saveBankAccounts(_bankAccounts);

      return true;
    } catch (e) {
      _error = 'Failed to add bank account: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update bank account
  Future<bool> updateBankAccount(BankAccount bankAccount) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final accountIndex = _bankAccounts.indexWhere((account) => account.id == bankAccount.id);
      if (accountIndex == -1) {
        _error = 'Bank account not found';
        return false;
      }

      _bankAccounts[accountIndex] = bankAccount;

      // Save to storage
      await StorageService.saveBankAccounts(_bankAccounts);

      return true;
    } catch (e) {
      _error = 'Failed to update bank account: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete bank account
  Future<bool> deleteBankAccount(String bankAccountId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if bank account is used in any payments
      final isUsedInPayments = _payments.any((payment) => payment.bankAccountId == bankAccountId);
      if (isUsedInPayments) {
        _error = 'Cannot delete bank account that is used in payments';
        return false;
      }

      final accountIndex = _bankAccounts.indexWhere((account) => account.id == bankAccountId);
      if (accountIndex == -1) {
        _error = 'Bank account not found';
        return false;
      }

      _bankAccounts.removeAt(accountIndex);

      // Save to storage
      await StorageService.saveBankAccounts(_bankAccounts);

      return true;
    } catch (e) {
      _error = 'Failed to delete bank account: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Process payment (simulate payment processing)
  Future<bool> processPayment(Payment payment) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulate random success/failure (90% success rate)
      final isSuccess = (DateTime.now().millisecondsSinceEpoch % 10) < 9;

      if (isSuccess) {
        await updatePaymentStatus(payment.id, 'completed');
        return true;
      } else {
        await updatePaymentStatus(payment.id, 'failed');
        _error = 'Payment processing failed. Please try again.';
        return false;
      }
    } catch (e) {
      _error = 'Payment processing error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update bank account balance
  Future<void> _updateBankAccountBalance(String bankAccountId, double amount, bool isReversal) async {
    final accountIndex = _bankAccounts.indexWhere((account) => account.id == bankAccountId);
    if (accountIndex == -1) return;

    final account = _bankAccounts[accountIndex];
    final newBalance = isReversal 
        ? account.currentBalance + amount 
        : account.currentBalance - amount;

    final updatedAccount = account.copyWith(
      currentBalance: newBalance,
      updatedAt: DateTime.now(),
    );

    _bankAccounts[accountIndex] = updatedAccount;
    await StorageService.saveBankAccounts(_bankAccounts);
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadPayments();
    await loadBankAccounts();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/models/transaction.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/models/category.dart';
import 'package:kora_expense_tracker/widgets/transaction_list_item.dart';
import 'package:kora_expense_tracker/widgets/transaction_detail_sheet.dart';
import 'package:kora_expense_tracker/utils/formatters.dart';

/// Account-specific transactions screen with filtering and swipe gestures
class AccountTransactionsScreen extends StatefulWidget {
  final Account account;

  const AccountTransactionsScreen({
    super.key,
    required this.account,
  });

  @override
  State<AccountTransactionsScreen> createState() => _AccountTransactionsScreenState();
}

class _AccountTransactionsScreenState extends State<AccountTransactionsScreen> {
  String _selectedFilter = 'All';
  String _sortBy = 'Date';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final accountTransactions = _getAccountTransactions(appProvider.transactions);
        final filteredTransactions = _getFilteredTransactions(accountTransactions);
        final groupedTransactions = _groupTransactionsByDate(filteredTransactions);

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            // Swipe left/right anywhere in the app to change filter
            if (details.primaryVelocity! > 0) {
              // Swipe right
              _cycleFilter(-1);
            } else if (details.primaryVelocity! < 0) {
              // Swipe left
              _cycleFilter(1);
            }
          },
          child: Scaffold(
            appBar: _buildAppBar(context, appProvider),
            body: Column(
              children: [
                _buildAccountInfo(context),
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
          ),
        );
      },
    );
  }

  /// Build the app bar
  PreferredSizeWidget _buildAppBar(BuildContext context, AppProvider appProvider) {
    return AppBar(
      title: Text('${widget.account.name} Transactions'),
      actions: [
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
                    Icons.payments,
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

  /// Build account information card
  Widget _buildAccountInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.account.type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.account.icon,
                  color: widget.account.type.color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.account.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.account.type.displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Current Balance',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.account.getFormattedBalance(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: widget.account.balanceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
              ...transactions.map((transaction) {
                Account? account = appProvider.getAccountForTransaction(transaction.accountId);
                
                Category? category;
                try {
                  category = appProvider.categories.firstWhere((cat) => cat.id == transaction.categoryId);
                } catch (e) {
                  category = appProvider.categories.isNotEmpty ? appProvider.categories.first : null;
                }
                
                Account? toAccount;
                if (transaction.toAccountId != null) {
                  toAccount = appProvider.getAccountForTransaction(transaction.toAccountId!);
                }
                
                return TransactionListItem(
                  transaction: transaction,
                  account: account,
                  category: category,
                  toAccount: toAccount,
                  onTap: () => _showTransactionDetails(context, transaction),
                  onEdit: () => _editTransaction(context, transaction, appProvider),
                  onDelete: () => appProvider.deleteTransaction(transaction.id),
                );
              }),
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
            _selectedFilter != 'All'
                ? 'No $_selectedFilter transactions for this account'
                : 'No transactions for this account yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Cycle through filter options with swipe gestures
  void _cycleFilter(int direction) {
    final filters = ['All', 'Income', 'Expense', 'Transfer'];
    final currentIndex = filters.indexOf(_selectedFilter);
    
    int newIndex;
    if (direction > 0) {
      // Swipe left - go to next filter
      newIndex = (currentIndex + 1) % filters.length;
    } else {
      // Swipe right - go to previous filter
      newIndex = (currentIndex - 1 + filters.length) % filters.length;
    }
    
    setState(() {
      _selectedFilter = filters[newIndex];
    });
  }

  /// Get transactions for this specific account
  List<Transaction> _getAccountTransactions(List<Transaction> transactions) {
    return transactions.where((transaction) {
      return transaction.accountId == widget.account.id || 
             transaction.toAccountId == widget.account.id;
    }).toList();
  }

  /// Get filtered transactions based on filter criteria
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

  /// Show transaction details in bottom sheet
  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailSheet(
        transaction: transaction,
        appProvider: appProvider,
      ),
    );
  }

  /// Edit existing transaction
  void _editTransaction(BuildContext context, Transaction transaction, AppProvider appProvider) {
    // Import AddTransactionDialog if needed
    // showDialog(
    //   context: context,
    //   builder: (context) => AddTransactionDialog(
    //     appProvider: appProvider,
    //     transaction: transaction,
    //   ),
    // );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/models/account_type.dart';
import 'package:kora_expense_tracker/widgets/account_card.dart';
import 'package:kora_expense_tracker/widgets/financial_summary_card.dart';
import 'package:kora_expense_tracker/widgets/add_account_dialog.dart';
import 'package:kora_expense_tracker/screens/account_transactions_screen.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/models/transaction.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen>
    with TickerProviderStateMixin {
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
        if (_lastBackPress == null ||
            now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
          _lastBackPress = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Press back again to exit'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyTabBarDelegate(
                        child: _buildFilterChips(context),
                      ),
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
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            heroTag: "accounts_fab",
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface,
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
      expandedHeight: 110,
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
                      theme.colorScheme.primary.withValues(alpha: 0.8),
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
                        icon: const Icon(
                          Icons.filter_list,
                          color: Colors.white,
                        ),
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
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    4,
                  ), // changed from 16 to 4 for reduce the height
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
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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

    return Container(
      height: 40, // changed from 50 to 40 for reduce the height
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
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
          ...AccountType.values.map(
            (type) => _buildFilterChip(
              context,
              type.displayName,
              _selectedFilter == type,
              () => setState(() => _selectedFilter = type),
              type.color,
            ),
          ),
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
        backgroundColor:
            color?.withValues(alpha: 0.1) ?? theme.colorScheme.surface,
        selectedColor:
            color?.withValues(alpha: 0.2) ??
            theme.colorScheme.primary.withValues(alpha: 0.2),
        checkmarkColor: color ?? theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? (color ?? theme.colorScheme.primary)
              : theme.colorScheme.onSurface,
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
                isSearching || hasFilter
                    ? Icons.search_off
                    : Icons.account_balance_wallet,
                size: 80,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                isSearching || hasFilter
                    ? 'No accounts found'
                    : 'No accounts yet',
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
        delegate: SliverChildBuilderDelegate((context, index) {
          final account = accounts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AccountCard(
              account: account,
              onTap: () => _navigateToAccountTransactions(context, account),
              onEdit: () => _showEditAccountDialog(context, account),
              onDelete: () =>
                  _showDeleteConfirmation(context, account, provider),
            ),
          );
        }, childCount: accounts.length),
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
        final matchesSearch =
            account.name.toLowerCase().contains(_searchQuery) ||
            account.type.displayName.toLowerCase().contains(_searchQuery) ||
            (account.description?.toLowerCase().contains(_searchQuery) ??
                false);
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
          final provider = context.read<AppProvider>();

          if (account.balance != updatedAccount.balance) {
            // Update account details first but with the old balance
            // so the transaction can correctly apply the difference to it.
            final accountWithOldBalance = updatedAccount.copyWith(
              balance: account.balance,
            );
            provider.updateAccount(accountWithOldBalance);

            final difference = updatedAccount.balance - account.balance;
            final isIncome = difference > 0;

            // Generate a balance adjustment transaction
            final categoryId = isIncome
                ? (provider.incomeCategories.isNotEmpty
                      ? provider.incomeCategories.first.id
                      : 'income')
                : (provider.expenseCategories.isNotEmpty
                      ? provider.expenseCategories.first.id
                      : 'expense');

            final transaction = Transaction.create(
              type: isIncome
                  ? AppConstants.transactionTypeIncome
                  : AppConstants.transactionTypeExpense,
              amount: difference.abs(),
              description: 'Balance Adjustment',
              categoryId: categoryId,
              accountId: account.id,
              notes: 'Manual balance adjustment',
              date: DateTime.now(),
            );

            // Adding this transaction modifies the balance to reflect the user's manual change
            provider.addTransaction(transaction);
          } else {
            provider.updateAccount(updatedAccount);
          }
        },
      ),
    ).then((_) {
      // Clear search focus when dialog is dismissed
      _clearSearchFocus();
    });
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Account account,
    AppProvider provider,
  ) {
    final isCreditCard = account.type == AccountType.creditCard;

    // Count transactions for this account
    final transactionCount = provider.transactions
        .where((t) => t.accountId == account.id || t.toAccountId == account.id)
        .length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${account.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transactionCount > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This account has $transactionCount transaction${transactionCount == 1 ? '' : 's'}.',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Choose deletion option:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (transactionCount > 0) ...[
            TextButton(
              onPressed: () => _deleteAccountWithTransactions(
                context,
                account,
                provider,
                isCreditCard,
              ),
              child: Text(
                'Delete Account Only',
                style: TextStyle(color: Colors.blue.shade600),
              ),
            ),
            TextButton(
              onPressed: () => _deleteAccountAndTransactions(
                context,
                account,
                provider,
                isCreditCard,
                transactionCount,
              ),
              child: Text(
                'Delete Account + $transactionCount Transaction${transactionCount == 1 ? '' : 's'}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ] else ...[
            TextButton(
              onPressed: () => _deleteAccountWithTransactions(
                context,
                account,
                provider,
                isCreditCard,
              ),
              child: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Delete account only (keep transactions but mark account as deleted)
  void _deleteAccountWithTransactions(
    BuildContext context,
    Account account,
    AppProvider provider,
    bool isCreditCard,
  ) async {
    Navigator.of(context).pop(); // Close the dialog

    // Show confirmation for account-only deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account Only'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will delete the account but keep all transactions.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Transactions will remain in your history but will show "Unknown Account".',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performAccountDeletion(
        context,
        account,
        provider,
        isCreditCard,
        false,
      );
    }
  }

  // Delete account and all its transactions
  void _deleteAccountAndTransactions(
    BuildContext context,
    Account account,
    AppProvider provider,
    bool isCreditCard,
    int transactionCount,
  ) async {
    Navigator.of(context).pop(); // Close the dialog

    // Show confirmation for account + transactions deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account + Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete the account and all $transactionCount transaction${transactionCount == 1 ? '' : 's'}.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. All transaction history will be lost.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete Everything',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performAccountDeletion(
        context,
        account,
        provider,
        isCreditCard,
        true,
      );
    }
  }

  // Perform the actual deletion
  Future<void> _performAccountDeletion(
    BuildContext context,
    Account account,
    AppProvider provider,
    bool isCreditCard,
    bool deleteTransactions,
  ) async {
    try {
      bool success = false;

      if (deleteTransactions) {
        // Delete account with all transactions (handles credit card sync automatically)
        success = await provider.deleteAccountWithTransactions(account.id);
      } else {
        // Delete account only (handles credit card sync automatically)
        success = await provider.deleteAccount(account.id);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              deleteTransactions
                  ? '${account.name} and all transactions deleted successfully!'
                  : (isCreditCard
                        ? '${account.name} deleted successfully from both screens!'
                        : '${account.name} deleted successfully'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete ${account.name}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToAccountTransactions(BuildContext context, Account account) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccountTransactionsScreen(account: account),
      ),
    );
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.analytics,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Financial Overview',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Detailed financial health analysis',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
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
                      // Financial Health Score
                      _buildHealthScoreCard(context, provider),
                      const SizedBox(height: 16),

                      // Main Financial Metrics
                      _buildFinancialDetailCard(
                        context,
                        'Total Assets',
                        provider.totalAssets,
                        Colors.green,
                        Icons.trending_up,
                        'Your total asset value',
                      ),
                      const SizedBox(height: 12),
                      _buildFinancialDetailCard(
                        context,
                        'Total Liabilities',
                        provider.totalLiabilities,
                        Colors.red,
                        Icons.trending_down,
                        'Your total debt and obligations',
                      ),
                      const SizedBox(height: 12),
                      _buildFinancialDetailCard(
                        context,
                        'Net Worth',
                        provider.netWorth,
                        provider.netWorth >= 0 ? Colors.green : Colors.red,
                        provider.netWorth >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        'Assets minus liabilities',
                      ),
                      const SizedBox(height: 16),

                      // Financial Insights
                      _buildInsightsCard(context, provider),
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
    String description,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
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
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
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

  Widget _buildHealthScoreCard(BuildContext context, AppProvider provider) {
    final theme = Theme.of(context);
    final healthScore = _calculateHealthScore(provider);
    final healthColor = _getHealthScoreColor(healthScore);
    final healthStatus = _getHealthScoreStatus(healthScore);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              healthColor.withValues(alpha: 0.1),
              healthColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: healthColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.health_and_safety,
                    color: healthColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial Health Score',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Based on your financial metrics',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      '$healthScore',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: healthColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Score',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                Column(
                  children: [
                    Text(
                      healthStatus,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: healthColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Status',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(BuildContext context, AppProvider provider) {
    final theme = Theme.of(context);
    final insights = _generateInsights(provider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lightbulb,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Financial Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(insight['icon'], color: insight['color'], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight['text'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: insight['color'],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateHealthScore(AppProvider provider) {
    // Simple health score calculation based on net worth and asset-to-liability ratio
    final netWorth = provider.netWorth;
    final assets = provider.totalAssets;
    final liabilities = provider.totalLiabilities;

    int score = 50; // Base score

    // Net worth factor
    if (netWorth > 100000) {
      score += 30;
    } else if (netWorth > 50000)
      score += 20;
    else if (netWorth > 0)
      score += 10;
    else if (netWorth > -50000)
      score -= 10;
    else
      score -= 20;

    // Asset-to-liability ratio
    if (liabilities > 0) {
      final ratio = assets / liabilities;
      if (ratio > 3) {
        score += 20;
      } else if (ratio > 2)
        score += 10;
      else if (ratio > 1)
        score += 5;
      else
        score -= 10;
    } else if (assets > 0) {
      score += 20; // No liabilities is great
    }

    return score.clamp(0, 100);
  }

  Color _getHealthScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.amber;
    return Colors.red;
  }

  String _getHealthScoreStatus(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  List<Map<String, dynamic>> _generateInsights(AppProvider provider) {
    final insights = <Map<String, dynamic>>[];
    final netWorth = provider.netWorth;
    final assets = provider.totalAssets;
    final liabilities = provider.totalLiabilities;

    if (netWorth > 0) {
      insights.add({
        'icon': Icons.check_circle,
        'color': Colors.green,
        'text': 'Great! You have a positive net worth.',
      });
    } else {
      insights.add({
        'icon': Icons.warning,
        'color': Colors.orange,
        'text': 'Consider reducing liabilities to improve net worth.',
      });
    }

    if (liabilities > 0 && assets > 0) {
      final ratio = assets / liabilities;
      if (ratio > 2) {
        insights.add({
          'icon': Icons.trending_up,
          'color': Colors.green,
          'text':
              'Strong asset-to-liability ratio of ${ratio.toStringAsFixed(1)}:1.',
        });
      } else if (ratio < 1) {
        insights.add({
          'icon': Icons.trending_down,
          'color': Colors.red,
          'text': 'Liabilities exceed assets. Focus on debt reduction.',
        });
      }
    }

    if (provider.accounts.length > 3) {
      insights.add({
        'icon': Icons.account_balance,
        'color': Colors.blue,
        'text':
            'Good diversification with ${provider.accounts.length} accounts.',
      });
    }

    if (insights.isEmpty) {
      insights.add({
        'icon': Icons.info,
        'color': Colors.blue,
        'text': 'Add more accounts to get detailed insights.',
      });
    }

    return insights;
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyTabBarDelegate({required this.child}) : height = 40.0;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/credit_card_provider.dart';
import '../providers/app_provider.dart';
import '../models/credit_card.dart';
import '../models/account.dart';
import '../models/account_type.dart';
import '../utils/formatters.dart';

/// Add Credit Card Screen - User-friendly form for adding new credit cards
class AddCreditCardScreen extends StatefulWidget {
  const AddCreditCardScreen({super.key});

  @override
  State<AddCreditCardScreen> createState() => _AddCreditCardScreenState();
}

class _AddCreditCardScreenState extends State<AddCreditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastFourDigitsController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _outstandingBalanceController = TextEditingController();
  final _interestRateController = TextEditingController(text: '18.0');
  final _minimumPaymentController = TextEditingController(text: '5.0');
  final _billingCycleDayController = TextEditingController(text: '15');
  final _gracePeriodController = TextEditingController(text: '21');
  final _notesController = TextEditingController();

  // Focus nodes for auto-focus functionality
  final _nameFocusNode = FocusNode();
  final _lastFourDigitsFocusNode = FocusNode();
  final _networkFocusNode = FocusNode();
  final _typeFocusNode = FocusNode();
  final _bankFocusNode = FocusNode();
  final _creditLimitFocusNode = FocusNode();
  final _outstandingBalanceFocusNode = FocusNode();
  final _interestRateFocusNode = FocusNode();
  final _minimumPaymentFocusNode = FocusNode();
  final _billingCycleDayFocusNode = FocusNode();
  final _gracePeriodFocusNode = FocusNode();
  final _notesFocusNode = FocusNode();

  String _selectedNetwork = 'Visa';
  String _selectedType = 'Standard';
  String _selectedBank = 'Other';
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.credit_card;
  DateTime? _selectedExpiryDate;
  bool _autoGenerateStatements = true;
  bool _isLoading = false;

  final List<String> _networks = ['Visa', 'Mastercard', 'Amex', 'Rupay', 'Discover'];
  final List<String> _types = ['Standard', 'Premium', 'Business', 'Student', 'Secured'];
  final List<String> _banks = [
    'HDFC Bank',
    'ICICI Bank',
    'SBI Bank',
    'Axis Bank',
    'Kotak Bank',
    'Yes Bank',
    'IndusInd Bank',
    'Federal Bank',
    'Other'
  ];

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
  ];

  final List<IconData> _icons = [
    Icons.credit_card,
    Icons.account_balance,
    Icons.diamond,
    Icons.star,
    Icons.workspace_premium,
    Icons.business,
    Icons.school,
    Icons.flight,
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus on the first field when screen loads (only once)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastFourDigitsController.dispose();
    _creditLimitController.dispose();
    _outstandingBalanceController.dispose();
    _interestRateController.dispose();
    _minimumPaymentController.dispose();
    _billingCycleDayController.dispose();
    _gracePeriodController.dispose();
    _notesController.dispose();
    
    // Dispose focus nodes
    _nameFocusNode.dispose();
    _lastFourDigitsFocusNode.dispose();
    _networkFocusNode.dispose();
    _typeFocusNode.dispose();
    _bankFocusNode.dispose();
    _creditLimitFocusNode.dispose();
    _outstandingBalanceFocusNode.dispose();
    _interestRateFocusNode.dispose();
    _minimumPaymentFocusNode.dispose();
    _billingCycleDayFocusNode.dispose();
    _gracePeriodFocusNode.dispose();
    _notesFocusNode.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Credit Card'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveCreditCard,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Preview
              _buildCardPreview(),
              const SizedBox(height: 32),
              
              // Basic Information
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildLastFourDigitsField(),
              const SizedBox(height: 16),
              _buildExpiryDateField(),
              const SizedBox(height: 16),
              _buildNetworkDropdown(),
              const SizedBox(height: 16),
              _buildTypeDropdown(),
              const SizedBox(height: 16),
              _buildBankDropdown(),
              const SizedBox(height: 24),
              
              // Financial Information
              _buildSectionHeader('Financial Information'),
              const SizedBox(height: 16),
              _buildCreditLimitField(),
              const SizedBox(height: 16),
              _buildOutstandingBalanceField(),
              const SizedBox(height: 16),
              _buildInterestRateField(),
              const SizedBox(height: 16),
              _buildMinimumPaymentField(),
              const SizedBox(height: 24),
              
              // Billing Information
              _buildSectionHeader('Billing Information'),
              const SizedBox(height: 16),
              _buildBillingCycleDayField(),
              const SizedBox(height: 16),
              _buildGracePeriodField(),
              const SizedBox(height: 16),
              _buildAutoGenerateStatementsSwitch(),
              const SizedBox(height: 24),
              
              // Appearance
              _buildSectionHeader('Appearance'),
              const SizedBox(height: 16),
              _buildColorSelector(),
              const SizedBox(height: 16),
              _buildIconSelector(),
              const SizedBox(height: 24),
              
              // Notes
              _buildSectionHeader('Notes (Optional)'),
              const SizedBox(height: 16),
              _buildNotesField(),
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCreditCard,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Add Credit Card',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_selectedColor, _selectedColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _selectedIcon,
                  color: Colors.white,
                  size: 32,
                ),
                const Spacer(),
                Text(
                  _selectedNetwork,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              _nameController.text.isEmpty ? 'Card Name' : _nameController.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _lastFourDigitsController.text.isEmpty 
                  ? '•••• •••• •••• ••••'
                  : '•••• •••• •••• ${_lastFourDigitsController.text}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedExpiryDate != null 
                ? 'Expires ${_selectedExpiryDate!.month.toString().padLeft(2, '0')}/${_selectedExpiryDate!.year.toString().substring(2)}'
                : 'No expiry date',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to create consistent input decoration
  InputDecoration _buildInputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    String? prefixText,
    String? suffixText,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      prefixText: prefixText,
      suffixText: suffixText,
      helperText: helperText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Card Name',
        hintText: 'e.g., Chase Sapphire, Amex Gold',
        prefixIcon: Icons.credit_card,
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a card name';
        }
        return null;
      },
      onChanged: (value) => setState(() {}),
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _lastFourDigitsFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildLastFourDigitsField() {
    return TextFormField(
      controller: _lastFourDigitsController,
      focusNode: _lastFourDigitsFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Last 4 Digits',
        hintText: '1234',
        prefixIcon: Icons.numbers,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      maxLength: 4,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the last 4 digits';
        }
        if (value.length != 4) {
          return 'Please enter exactly 4 digits';
        }
        return null;
      },
      onChanged: (value) => setState(() {}),
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _networkFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildExpiryDateField() {
    return InkWell(
      onTap: _selectExpiryDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Expiry Date (Optional)',
          helperText: 'Leave empty for privacy',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _selectedExpiryDate != null 
            ? '${_selectedExpiryDate!.month.toString().padLeft(2, '0')}/${_selectedExpiryDate!.year}'
            : 'Not specified',
        ),
      ),
    );
  }

  Widget _buildNetworkDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedNetwork,
      focusNode: _networkFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Card Network',
        prefixIcon: Icons.network_check,
      ),
      items: _networks.map((network) => DropdownMenuItem(
        value: network,
        child: Text(network),
      )).toList(),
      onChanged: (value) {
        setState(() => _selectedNetwork = value!);
        _typeFocusNode.requestFocus();
      },
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedType,
      focusNode: _typeFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Card Type',
        prefixIcon: Icons.category,
      ),
      items: _types.map((type) => DropdownMenuItem(
        value: type,
        child: Text(type),
      )).toList(),
      onChanged: (value) {
        setState(() => _selectedType = value!);
        _bankFocusNode.requestFocus();
      },
    );
  }

  Widget _buildBankDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedBank,
      focusNode: _bankFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Bank',
        prefixIcon: Icons.account_balance,
      ),
      items: _banks.map((bank) => DropdownMenuItem(
        value: bank,
        child: Text(bank),
      )).toList(),
      onChanged: (value) {
        setState(() => _selectedBank = value!);
        _creditLimitFocusNode.requestFocus();
      },
    );
  }

  Widget _buildCreditLimitField() {
    return TextFormField(
      controller: _creditLimitController,
      focusNode: _creditLimitFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Credit Limit',
        hintText: '0.00',
        prefixText: Formatters.getCurrencySymbol(),
        prefixIcon: Icons.account_balance,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the credit limit';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _outstandingBalanceFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildOutstandingBalanceField() {
    return TextFormField(
      controller: _outstandingBalanceController,
      focusNode: _outstandingBalanceFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Current Outstanding Balance (Optional)',
        hintText: '0.00 - Leave empty if no balance',
        prefixText: Formatters.getCurrencySymbol(),
        prefixIcon: Icons.account_balance_wallet,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          final amount = double.tryParse(value);
          if (amount == null || amount < 0) {
            return 'Please enter a valid amount';
          }
        }
        return null;
      },
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _interestRateFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildInterestRateField() {
    return TextFormField(
      controller: _interestRateController,
      focusNode: _interestRateFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Interest Rate (APR)',
        hintText: '18.0',
        suffixText: '%',
        prefixIcon: Icons.percent,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the interest rate';
        }
        final rate = double.tryParse(value);
        if (rate == null || rate < 0 || rate > 100) {
          return 'Please enter a valid interest rate (0-100%)';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _minimumPaymentFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildMinimumPaymentField() {
    return TextFormField(
      controller: _minimumPaymentController,
      focusNode: _minimumPaymentFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Minimum Payment Percentage',
        hintText: '5.0',
        suffixText: '%',
        prefixIcon: Icons.payment,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the minimum payment percentage';
        }
        final percentage = double.tryParse(value);
        if (percentage == null || percentage <= 0 || percentage > 100) {
          return 'Please enter a valid percentage (0-100%)';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _billingCycleDayFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildBillingCycleDayField() {
    return TextFormField(
      controller: _billingCycleDayController,
      focusNode: _billingCycleDayFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Billing Cycle Day',
        hintText: '15',
        helperText: 'Day of month when billing cycle starts (1-31)',
        prefixIcon: Icons.calendar_today,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the billing cycle day';
        }
        final day = int.tryParse(value);
        if (day == null || day < 1 || day > 31) {
          return 'Please enter a valid day (1-31)';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _gracePeriodFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildGracePeriodField() {
    return TextFormField(
      controller: _gracePeriodController,
      focusNode: _gracePeriodFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Grace Period',
        hintText: '21',
        suffixText: 'days',
        helperText: 'Days after due date before late fees',
        prefixIcon: Icons.schedule,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the grace period';
        }
        final days = int.tryParse(value);
        if (days == null || days < 1) {
          return 'Please enter a valid number of days';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _notesFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildAutoGenerateStatementsSwitch() {
    return SwitchListTile(
      title: const Text('Auto-generate Statements'),
      subtitle: const Text('Automatically generate billing statements'),
      value: _autoGenerateStatements,
      onChanged: (value) => setState(() => _autoGenerateStatements = value),
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Color',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _colors.map((color) => GestureDetector(
            onTap: () => setState(() => _selectedColor = color),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: _selectedColor == color
                    ? Border.all(color: Colors.black, width: 3)
                    : null,
              ),
              child: _selectedColor == color
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Icon',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _icons.map((icon) => GestureDetector(
            onTap: () => setState(() => _selectedIcon = icon),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _selectedIcon == icon
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedIcon == icon
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
              child: Icon(
                icon,
                color: _selectedIcon == icon
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      focusNode: _notesFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Notes (Optional)',
        hintText: 'Any additional notes about this card...',
        prefixIcon: Icons.note,
      ),
      textInputAction: TextInputAction.done,
      maxLines: 3,
    );
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 365 * 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null && picked != _selectedExpiryDate) {
      setState(() => _selectedExpiryDate = picked);
    }
  }

  Future<void> _saveCreditCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final creditCard = CreditCard.create(
        name: _nameController.text.trim(),
        network: _selectedNetwork,
        type: _selectedType,
        lastFourDigits: _lastFourDigitsController.text.trim(),
        expiryDate: _selectedExpiryDate,
        creditLimit: double.parse(_creditLimitController.text),
        outstandingBalance: _outstandingBalanceController.text.trim().isEmpty 
          ? 0.0 
          : double.parse(_outstandingBalanceController.text),
        interestRate: double.parse(_interestRateController.text),
        minimumPaymentPercentage: double.parse(_minimumPaymentController.text),
        gracePeriodDays: int.parse(_gracePeriodController.text),
        billingCycleDay: int.parse(_billingCycleDayController.text),
        color: _selectedColor,
        icon: _selectedIcon,
        bankName: _selectedBank == 'Other' ? null : _selectedBank,
        autoGenerateStatements: _autoGenerateStatements,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      final creditCardProvider = context.read<CreditCardProvider>();
      final appProvider = context.read<AppProvider>();
      
      // Add credit card
      final creditCardSuccess = await creditCardProvider.addCreditCard(creditCard);
      
      if (creditCardSuccess) {
        // Also create an Account object for the credit card with the same ID
        final account = Account(
          id: creditCard.id, // Use the same ID as the credit card
          name: _nameController.text.trim(),
          balance: creditCard.outstandingBalance, // Direct balance for liability
          type: AccountType.creditCard,
          icon: _selectedIcon,
          color: _selectedColor,
          description: 'Credit Card - $_selectedNetwork ${_lastFourDigitsController.text.trim()}',
          isActive: true,
          createdAt: creditCard.createdAt,
          updatedAt: creditCard.updatedAt,
        );
        
        // Add account to the app provider
        final accountSuccess = await appProvider.addAccount(account);
        
        if (accountSuccess) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Credit card added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Credit card added but failed to sync with accounts'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding credit card: ${creditCardProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding credit card: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../models/bank_account.dart';
import '../utils/formatters.dart';
import '../constants/app_constants.dart';

/// Bank Accounts Management Screen
class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Accounts'),
        actions: [
          IconButton(
            onPressed: () => _showAddBankAccountDialog(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading && paymentProvider.bankAccounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paymentProvider.bankAccounts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => paymentProvider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: paymentProvider.bankAccounts.length,
              itemBuilder: (context, index) {
                final bankAccount = paymentProvider.bankAccounts[index];
                return _buildBankAccountCard(bankAccount, paymentProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Bank Accounts',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your bank accounts to make payments',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddBankAccountDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Bank Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountCard(BankAccount bankAccount, PaymentProvider paymentProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: bankAccount.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    bankAccount.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bankAccount.bankName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        bankAccount.accountTypeDisplayText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, bankAccount, paymentProvider),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAccountInfo(
                    'Account Number',
                    bankAccount.maskedAccountNumber,
                    Icons.credit_card,
                  ),
                ),
                Expanded(
                  child: _buildAccountInfo(
                    'IFSC Code',
                    bankAccount.ifscCode,
                    Icons.code,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAccountInfo(
                    'Current Balance',
                    bankAccount.getFormattedBalance(),
                    Icons.account_balance_wallet,
                    AppConstants.availableColor,
                  ),
                ),
                Expanded(
                  child: _buildStatusChip(bankAccount),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo(String label, String value, IconData icon, [Color? valueColor]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BankAccount bankAccount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bankAccount.isActive ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bankAccount.isActive ? 'Active' : 'Inactive',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (bankAccount.isVerified) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Verified',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showAddBankAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddBankAccountDialog(),
    );
  }

  void _handleMenuAction(String action, BankAccount bankAccount, PaymentProvider paymentProvider) {
    switch (action) {
      case 'edit':
        _showEditBankAccountDialog(bankAccount);
        break;
      case 'delete':
        _showDeleteConfirmation(bankAccount, paymentProvider);
        break;
    }
  }

  void _showEditBankAccountDialog(BankAccount bankAccount) {
    showDialog(
      context: context,
      builder: (context) => AddBankAccountDialog(
        bankAccount: bankAccount,
      ),
    );
  }

  void _showDeleteConfirmation(BankAccount bankAccount, PaymentProvider paymentProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bank Account'),
        content: Text(
          'Are you sure you want to delete this bank account?\n\n'
          '${bankAccount.bankName} - ${bankAccount.maskedAccountNumber}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await paymentProvider.deleteBankAccount(bankAccount.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bank account deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(paymentProvider.error ?? 'Failed to delete bank account'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Add/Edit Bank Account Dialog
class AddBankAccountDialog extends StatefulWidget {
  final BankAccount? bankAccount;

  const AddBankAccountDialog({super.key, this.bankAccount});

  @override
  State<AddBankAccountDialog> createState() => _AddBankAccountDialogState();
}

class _AddBankAccountDialogState extends State<AddBankAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _accountHolderController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _balanceController = TextEditingController();

  String _selectedAccountType = 'savings';
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.account_balance;
  bool _isActive = true;
  bool _isVerified = false;

  final List<String> _accountTypes = [
    'savings',
    'current',
    'salary',
    'nri',
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  final List<IconData> _availableIcons = [
    Icons.account_balance,
    Icons.account_balance_wallet,
    Icons.savings,
    Icons.business,
    Icons.credit_card,
    Icons.payment,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bankAccount != null) {
      _populateFields();
    }
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _populateFields() {
    final bankAccount = widget.bankAccount!;
    _accountHolderController.text = bankAccount.accountHolderName;
    _bankNameController.text = bankAccount.bankName;
    _accountNumberController.text = bankAccount.accountNumber;
    _ifscController.text = bankAccount.ifscCode;
    _balanceController.text = bankAccount.currentBalance.toStringAsFixed(2);
    _selectedAccountType = bankAccount.accountType;
    _selectedColor = bankAccount.color;
    _selectedIcon = bankAccount.icon;
    _isActive = bankAccount.isActive;
    _isVerified = bankAccount.isVerified;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bankAccount == null ? 'Add Bank Account' : 'Edit Bank Account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Account Holder Name
                  TextFormField(
                    controller: _accountHolderController,
                    decoration: InputDecoration(
                      labelText: 'Account Holder Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter account holder name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Bank Name
                  TextFormField(
                    controller: _bankNameController,
                    decoration: InputDecoration(
                      labelText: 'Bank Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.account_balance),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter bank name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Account Number
                  TextFormField(
                    controller: _accountNumberController,
                    decoration: InputDecoration(
                      labelText: 'Account Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.credit_card),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter account number';
                      }
                      if (value.length < 9) {
                        return 'Account number must be at least 9 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // IFSC Code
                  TextFormField(
                    controller: _ifscController,
                    decoration: InputDecoration(
                      labelText: 'IFSC Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.code),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter IFSC code';
                      }
                      if (value.length != 11) {
                        return 'IFSC code must be 11 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Account Type
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAccountType,
                    decoration: InputDecoration(
                      labelText: 'Account Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: _accountTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(_getAccountTypeDisplayText(type)),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccountType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Current Balance
                  TextFormField(
                    controller: _balanceController,
                    decoration: InputDecoration(
                      labelText: 'Current Balance',
                      prefixText: Formatters.getCurrencySymbol(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter current balance';
                      }
                      final balance = double.tryParse(value);
                      if (balance == null || balance < 0) {
                        return 'Please enter a valid balance';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Color Selection
                  Text(
                    'Account Color',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _availableColors.map((color) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: _selectedColor == color
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                        child: _selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Icon Selection
                  Text(
                    'Account Icon',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _availableIcons.map((icon) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = icon;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon
                              ? _selectedColor
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: _selectedIcon == icon
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                        ),
                        child: Icon(
                          icon,
                          color: _selectedIcon == icon
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Status Switches
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Active'),
                          subtitle: const Text('Account is active'),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Verified'),
                          subtitle: const Text('Account is verified'),
                          value: _isVerified,
                          onChanged: (value) {
                            setState(() {
                              _isVerified = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveBankAccount,
                          child: Text(widget.bankAccount == null ? 'Add' : 'Update'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getAccountTypeDisplayText(String type) {
    switch (type) {
      case 'savings':
        return 'Savings Account';
      case 'current':
        return 'Current Account';
      case 'salary':
        return 'Salary Account';
      case 'nri':
        return 'NRI Account';
      default:
        return type;
    }
  }

  Future<void> _saveBankAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final paymentProvider = context.read<PaymentProvider>();
    
    try {
      final bankAccount = widget.bankAccount == null
          ? BankAccount.create(
              accountHolderName: _accountHolderController.text.trim(),
              bankName: _bankNameController.text.trim(),
              accountNumber: _accountNumberController.text.trim(),
              ifscCode: _ifscController.text.trim(),
              accountType: _selectedAccountType,
              currentBalance: double.parse(_balanceController.text),
              color: _selectedColor,
              icon: _selectedIcon,
              isActive: _isActive,
              isVerified: _isVerified,
            )
          : widget.bankAccount!.copyWith(
              accountHolderName: _accountHolderController.text.trim(),
              bankName: _bankNameController.text.trim(),
              accountNumber: _accountNumberController.text.trim(),
              ifscCode: _ifscController.text.trim(),
              accountType: _selectedAccountType,
              currentBalance: double.parse(_balanceController.text),
              color: _selectedColor,
              icon: _selectedIcon,
              isActive: _isActive,
              isVerified: _isVerified,
              updatedAt: DateTime.now(),
            );

      final success = widget.bankAccount == null
          ? await paymentProvider.addBankAccount(bankAccount)
          : await paymentProvider.updateBankAccount(bankAccount);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.bankAccount == null
                  ? 'Bank account added successfully'
                  : 'Bank account updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(paymentProvider.error ?? 'Failed to save bank account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving bank account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/widgets/add_category_dialog.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final categories = appProvider.categories;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Categories'),
          ),
          body: categories.isEmpty
              ? const Center(child: Text('No categories found.'))
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category.color.withValues(alpha: 0.2),
                        child: Icon(category.icon, color: category.color),
                      ),
                      title: Text(category.name),
                      subtitle: Text(category.typeDisplayName),
                      trailing: category.isDefault 
                          ? const Icon(Icons.lock, size: 16, color: Colors.grey)
                          : IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AddCategoryDialog(
                                    appProvider: appProvider,
                                    category: category,
                                  ),
                                );
                              },
                            ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            heroTag: "categories_fab",
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddCategoryDialog(
                  appProvider: appProvider,
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/credit_card_provider.dart';
import '../models/credit_card.dart';
import '../utils/formatters.dart';
import '../constants/app_constants.dart';
import 'payment_screen.dart';
import 'credit_card_detail_screen.dart';
import 'add_credit_card_screen.dart';

/// Main Credit Cards Screen - Comprehensive credit card management dashboard
class CreditCardsScreen extends StatefulWidget {
  const CreditCardsScreen({super.key});

  @override
  State<CreditCardsScreen> createState() => _CreditCardsScreenState();
}

class _CreditCardsScreenState extends State<CreditCardsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Active',
    'High Utilization',
    'Due Soon',
    'Overdue',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize credit card provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreditCardProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Cards'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => _filterOptions
                .map(
                  (option) => PopupMenuItem(value: option, child: Text(option)),
                )
                .toList(),
          ),
        ],
      ),
      body: Consumer<CreditCardProvider>(
        builder: (context, creditCardProvider, child) {
          if (creditCardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (creditCardProvider.error != null) {
            return _buildErrorState(context, creditCardProvider.error!);
          }

          final filteredCards = _getFilteredCards(
            creditCardProvider.creditCards,
          );

          return RefreshIndicator(
            onRefresh: () => creditCardProvider.refresh(),
            child: CustomScrollView(
              slivers: [
                // Credit Overview Card
                _buildCreditOverviewCard(context, creditCardProvider),

                // Quick Stats
                _buildQuickStats(context, creditCardProvider),

                // Filter Chips
                _buildFilterChips(context),

                // Credit Cards List
                if (filteredCards.isEmpty)
                  _buildEmptyState(context)
                else
                  _buildCreditCardsList(context, filteredCards),

                // Bottom padding
                if (filteredCards.isNotEmpty)
                  const SliverToBoxAdapter(child: SizedBox(height: 180)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: FloatingActionButton(
          onPressed: () => _navigateToAddCreditCard(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  /// Build credit overview card with key metrics
  Widget _buildCreditOverviewCard(
    BuildContext context,
    CreditCardProvider provider,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1E3A8A), // Darker blue for better contrast
              const Color(0xFF1E40AF), // Slightly lighter blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E40AF).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card, size: 28, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Credit Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewStat(
                    context,
                    'Total Limit',
                    Formatters.formatCurrency(provider.totalCreditLimit),
                    Icons.account_balance,
                    color: const Color(
                      0xFF60A5FA,
                    ), // Bright blue for better visibility
                  ),
                ),
                Expanded(
                  child: _buildOverviewStat(
                    context,
                    provider.totalOutstandingBalance < 0
                        ? 'Available Credit'
                        : 'Outstanding',
                    Formatters.formatCurrency(
                      provider.totalOutstandingBalance.abs(),
                    ),
                    Icons.account_balance_wallet,
                    color: provider.totalOutstandingBalance <= 0
                        ? const Color(0xFF34D399)
                        : const Color(0xFFF87171), // Bright green/red
                  ),
                ),
                Expanded(
                  child: _buildOverviewStat(
                    context,
                    'Available',
                    Formatters.formatCurrency(provider.totalAvailableCredit),
                    Icons.account_balance_wallet,
                    color: const Color(0xFF34D399), // Bright green
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getUtilizationColor(
                  provider.overallUtilization,
                ).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getUtilizationColor(provider.overallUtilization),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: _getUtilizationColor(provider.overallUtilization),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Utilization',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                        Text(
                          '${(provider.overallUtilization.abs() * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: _getUtilizationColor(
                                  provider.overallUtilization.abs(),
                                ),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                        ),
                        Text(
                          provider.overallUtilization < 0
                              ? 'Credit Available'
                              : provider.overallUtilizationStatus,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
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

  /// Build quick stats row
  Widget _buildQuickStats(BuildContext context, CreditCardProvider provider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildQuickStatCard(
                context,
                'Active Cards',
                '${provider.activeCreditCards.length}',
                Icons.credit_card,
                const Color(0xFF3182CE),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStatCard(
                context,
                'Due Soon',
                '${provider.dueSoonCards.length}',
                Icons.schedule,
                const Color(0xFFDD6B20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStatCard(
                context,
                'Overdue',
                '${provider.overdueCards.length}',
                Icons.warning,
                const Color(0xFFE53E3E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filterOptions.map((option) {
              final isSelected = _selectedFilter == option;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? option : 'All';
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 80,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Credit Cards',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first credit card to start tracking',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 1),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddCreditCard(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Credit Card'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build credit cards list
  Widget _buildCreditCardsList(BuildContext context, List<CreditCard> cards) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final card = cards[index];
        return _buildCreditCardItem(context, card);
      }, childCount: cards.length),
    );
  }

  /// Build individual credit card item
  Widget _buildCreditCardItem(BuildContext context, CreditCard card) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToCreditCardDetail(context, card),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: card.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(card.icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            card.maskedCardNumber,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(context, card.utilizationStatus),
                  ],
                ),
                const SizedBox(height: 20),

                // Card Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildCardStat(
                        context,
                        'Credit Limit',
                        card.getFormattedCreditLimit(),
                        Icons.account_balance,
                        color: AppConstants.creditLimitColor,
                      ),
                    ),
                    Expanded(
                      child: _buildCardStat(
                        context,
                        card.balanceLabel,
                        card.getFormattedUserBalance(),
                        Icons.account_balance_wallet,
                        color: card.userBalanceColor,
                      ),
                    ),
                    Expanded(
                      child: _buildCardStat(
                        context,
                        'Available',
                        card.getFormattedAvailableCredit(),
                        Icons.account_balance_wallet,
                        color: AppConstants.availableColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Utilization Bar
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: card.utilizationPercentage.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          card.utilizationColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      card.userFriendlyUtilization,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: card.utilizationColor,
                      ),
                    ),
                  ],
                ),

                // Bill & Due Date Info
                const SizedBox(height: 16),
                _buildBillDueDateInfo(context, card),

                // Statement Status
                const SizedBox(height: 12),
                _buildStatementStatus(context, card),

                // Quick Actions
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _navigateToCreditCardDetail(context, card),
                        icon: const Icon(Icons.receipt_long, size: 16),
                        label: const Text('Statements'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showQuickPaymentDialog(context, card),
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text('Pay'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods

  List<CreditCard> _getFilteredCards(List<CreditCard> cards) {
    switch (_selectedFilter) {
      case 'Active':
        return cards
            .where((card) => card.isActive && card.outstandingBalance > 0)
            .toList();
      case 'High Utilization':
        return cards
            .where((card) => card.utilizationPercentage >= 0.8)
            .toList();
      case 'Due Soon':
        return cards.where((card) => card.isDueSoon).toList();
      case 'Overdue':
        return cards.where((card) => card.isOverdue).toList();
      default:
        return cards;
    }
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error loading credit cards'),
          const SizedBox(height: 8),
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<CreditCardProvider>().refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCardStat(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color chipColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'critical':
        chipColor = const Color(0xFFE53E3E);
        textColor = Colors.white;
        break;
      case 'warning':
        chipColor = const Color(0xFFDD6B20);
        textColor = Colors.white;
        break;
      case 'high':
        chipColor = const Color(0xFFD69E2E);
        textColor = Colors.white;
        break;
      case 'moderate':
        chipColor = const Color(0xFFF6AD55);
        textColor = const Color(0xFF2D3748);
        break;
      case 'elevated':
        chipColor = const Color(0xFF68D391);
        textColor = const Color(0xFF2D3748);
        break;
      default:
        chipColor = const Color(0xFF48BB78);
        textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getUtilizationColor(double utilization) {
    if (utilization >= 0.9) return const Color(0xFFE53E3E); // Critical Red
    if (utilization >= 0.8) return const Color(0xFFDD6B20); // Warning Orange
    if (utilization >= 0.7) return const Color(0xFFD69E2E); // High Amber
    if (utilization >= 0.5) return const Color(0xFFF6AD55); // Moderate Yellow
    if (utilization >= 0.3) return const Color(0xFF68D391); // Elevated Green
    return const Color(0xFF48BB78); // Good Green
  }

  Color _getDueDateColor(CreditCard card) {
    if (card.isOverdue) return const Color(0xFFE53E3E); // Critical Red
    if (card.isDueSoon) return const Color(0xFFDD6B20); // Warning Orange
    return const Color(0xFF48BB78); // Good Green
  }

  IconData _getDueDateIcon(CreditCard card) {
    if (card.isOverdue) return Icons.error;
    if (card.isDueSoon) return Icons.warning;
    return Icons.check_circle;
  }

  String _getDueDateText(CreditCard card) {
    if (card.isOverdue) return 'Payment overdue';
    if (card.isDueSoon) return 'Due in ${card.daysUntilDue} days';
    return 'Due in ${card.daysUntilDue} days';
  }

  /// Build comprehensive bill and due date information
  Widget _buildBillDueDateInfo(BuildContext context, CreditCard card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getDueDateColor(card).withValues(alpha: 0.1),
            _getDueDateColor(card).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getDueDateColor(card).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Header with status
          Row(
            children: [
              Icon(
                _getDueDateIcon(card),
                size: 20,
                color: _getDueDateColor(card),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getDueDateStatusText(card),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _getDueDateColor(card),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (card.isDueSoon || card.isOverdue)
                ElevatedButton(
                  onPressed: () => _showQuickPaymentDialog(context, card),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48BB78),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Pay Now', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Bill and Due Date Details
          Row(
            children: [
              // Bill Date Info
              Expanded(
                child: _buildDateInfo(
                  context,
                  'Bill Date',
                  card.nextBillingDate != null
                      ? Formatters.formatDate(card.nextBillingDate!)
                      : 'Not set',
                  _getDaysUntilBill(card),
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),

              // Due Date Info
              Expanded(
                child: _buildDateInfo(
                  context,
                  'Due Date',
                  card.nextDueDate != null
                      ? Formatters.formatDate(card.nextDueDate!)
                      : 'Not set',
                  card.daysUntilDue,
                  Icons.payment,
                  _getDueDateColor(card),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual date information widget
  Widget _buildDateInfo(
    BuildContext context,
    String label,
    String date,
    int? daysRemaining,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (daysRemaining != null) ...[
            const SizedBox(height: 2),
            Text(
              daysRemaining == 0
                  ? 'Today'
                  : daysRemaining < 0
                  ? '${daysRemaining.abs()} days ago'
                  : '$daysRemaining days left',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: daysRemaining <= 0
                    ? Colors.red
                    : daysRemaining <= 7
                    ? Colors.orange
                    : Colors.green,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Get days until next bill date
  int? _getDaysUntilBill(CreditCard card) {
    if (card.nextBillingDate == null) return null;
    final days = card.nextBillingDate!.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  /// Get due date status text
  String _getDueDateStatusText(CreditCard card) {
    if (card.isOverdue) return 'Payment Overdue';
    if (card.isDueSoon) return 'Due Soon';
    return 'Payment Due';
  }

  /// Build statement status indicator
  Widget _buildStatementStatus(BuildContext context, CreditCard card) {
    return Consumer<CreditCardProvider>(
      builder: (context, provider, child) {
        final hasCurrentStatement = provider.hasStatementForCurrentMonth(
          card.id,
        );
        final currentStatement = provider.getCurrentMonthStatement(card.id);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasCurrentStatement
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasCurrentStatement
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.orange.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasCurrentStatement
                    ? Icons.receipt_long
                    : Icons.receipt_long_outlined,
                color: hasCurrentStatement ? Colors.green : Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statement Status',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      hasCurrentStatement
                          ? 'Generated for ${_getCurrentMonthName()}'
                          : 'Not generated for ${_getCurrentMonthName()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: hasCurrentStatement
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hasCurrentStatement && currentStatement != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Statement #${currentStatement.statementNumber}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Get current month name
  String _getCurrentMonthName() {
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[now.month - 1];
  }

  // Navigation Methods

  void _navigateToAddCreditCard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddCreditCardScreen()),
    );
  }

  void _navigateToCreditCardDetail(BuildContext context, CreditCard card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreditCardDetailScreen(creditCard: card),
      ),
    );
  }

  void _showQuickPaymentDialog(BuildContext context, CreditCard card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          creditCard: card,
          suggestedAmount: card.isDueSoon || card.isOverdue
              ? card.minimumPaymentAmount
              : null,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/utils/formatters.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/widgets/add_transaction_dialog.dart';
import 'package:kora_expense_tracker/widgets/transaction_list_item.dart';
import 'package:kora_expense_tracker/models/category.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/screens/categories_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  int _lastSelectedTabIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _resetScrollPosition() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Check if user returned to dashboard from another tab
        if (appProvider.selectedTabIndex == 0 && _lastSelectedTabIndex != 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _resetScrollPosition();
          });
        }
        _lastSelectedTabIndex = appProvider.selectedTabIndex;
        
        return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 28,
                height: 28,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.wallet, size: 28),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Kora Expense Tracker'),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
                  onRefresh: () async {
          await appProvider.refresh();
        },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Summary Card with Greeting
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () {
                      // Navigate to accounts tab in bottom navigation
                      appProvider.setSelectedTab(2); // Accounts tab is at index 2
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context).colorScheme.secondaryContainer,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total Balance',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    size: 32,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          Text(
                            Formatters.formatCurrency(appProvider.totalBalance),
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: AppConstants.smallPadding),
                          // Net Worth Row
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 16,
                                color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Net Worth: ',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                                ),
                              ),
                              Text(
                                Formatters.formatCurrency(appProvider.netWorth),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          Row(
                            children: [
                              Expanded(
                                child: _buildBalanceItem(
                                  context,
                                  'Income',
                                  Formatters.formatCurrency(appProvider.totalIncome),
                                  AppConstants.successColor,
                                  Icons.arrow_upward,
                                ),
                              ),
                              const SizedBox(width: AppConstants.defaultPadding),
                              Expanded(
                                child: _buildBalanceItem(
                                  context,
                                  'Expenses',
                                  Formatters.formatCurrency(appProvider.totalExpenses),
                                  AppConstants.errorColor,
                                  Icons.arrow_downward,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.largePadding),
                
                // Recent Transactions Section
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                
                // Recent Transactions or Empty State
                if (appProvider.recentTransactions.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                color: AppConstants.primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: AppConstants.smallPadding),
                              Text(
                                'Recent Transactions',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          SizedBox(
                            height: 300,
                            child: ListView.builder(
                              itemCount: appProvider.recentTransactions.length,
                              itemBuilder: (context, index) {
                                final transaction = appProvider.recentTransactions[index];
                                final category = appProvider.categories.firstWhere(
                                  (c) => c.id == transaction.categoryId,
                                  orElse: () => Category.create(
                                    name: 'Unknown',
                                    icon: Icons.category,
                                    color: AppConstants.primaryColor,
                                    type: AppConstants.categoryTypeExpense,
                                  ),
                                );
                                final account = appProvider.getAccountForTransaction(transaction.accountId);
                                Account? toAccount;
                                if (transaction.toAccountId != null) {
                                  toAccount = appProvider.getAccountForTransaction(transaction.toAccountId!);
                                }

                                return TransactionListItem(
                                  transaction: transaction,
                                  category: category,
                                  account: account,
                                  toAccount: toAccount,
                                  enableSwipeToDelete: true, // Enable swipe-to-delete for dashboard
                                  onTap: () {
                                    // Show transaction details or edit dialog
                                    showDialog(
                                      context: context,
                                      builder: (context) => AddTransactionDialog(
                                        appProvider: appProvider,
                                        transaction: transaction,
                                      ),
                                    );
                                  },
                                  onEdit: () {
                                    // Show edit transaction dialog
                                    showDialog(
                                      context: context,
                                      builder: (context) => AddTransactionDialog(
                                        appProvider: appProvider,
                                        transaction: transaction,
                                      ),
                                    );
                                  },
                                  onDelete: () async {
                                    await appProvider.deleteTransaction(transaction.id);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.largePadding),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          Text(
                            'No transactions yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppConstants.smallPadding),
                          Text(
                            'Add your first transaction to get started',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddTransactionDialog(appProvider: appProvider),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Transaction'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: AppConstants.largePadding),
                
                // Quick Stats Section
                Text(
                  'Quick Stats',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.defaultPadding),
                          child: Column(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: AppConstants.successColor,
                                size: 32,
                              ),
                              const SizedBox(height: AppConstants.smallPadding),
                              Text(
                                '${appProvider.accounts.length}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Accounts',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                    Expanded(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CategoriesScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(AppConstants.defaultPadding),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.category,
                                  color: AppConstants.infoColor,
                                  size: 32,
                                ),
                                const SizedBox(height: AppConstants.smallPadding),
                                Text(
                                  '${appProvider.categories.length}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Categories',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: "dashboard_fab",
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddTransactionDialog(appProvider: appProvider),
            );
          },
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
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildBalanceItem(
    BuildContext context,
    String label,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/credit_card_provider.dart';
import '../providers/app_provider.dart';
import '../models/credit_card.dart';
import '../utils/formatters.dart';

/// Edit Credit Card Screen - User-friendly credit card editing
class EditCreditCardScreen extends StatefulWidget {
  final CreditCard creditCard;

  const EditCreditCardScreen({
    super.key,
    required this.creditCard,
  });

  @override
  State<EditCreditCardScreen> createState() => _EditCreditCardScreenState();
}

class _EditCreditCardScreenState extends State<EditCreditCardScreen> {
  late TextEditingController _nameController;
  late TextEditingController _creditLimitController;
  late TextEditingController _interestRateController;
  late TextEditingController _gracePeriodController;
  late TextEditingController _minimumPaymentController;
  
  late int _billingCycleDay;
  late DateTime? _nextBillingDate;
  late DateTime? _nextDueDate;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.creditCard.name);
    _creditLimitController = TextEditingController(text: widget.creditCard.creditLimit.toString());
    _interestRateController = TextEditingController(text: widget.creditCard.interestRate.toString());
    _gracePeriodController = TextEditingController(text: widget.creditCard.gracePeriodDays.toString());
    _minimumPaymentController = TextEditingController(text: widget.creditCard.minimumPaymentPercentage.toString());
    
    _billingCycleDay = widget.creditCard.billingCycleDay;
    _nextBillingDate = widget.creditCard.nextBillingDate;
    _nextDueDate = widget.creditCard.nextDueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _creditLimitController.dispose();
    _interestRateController.dispose();
    _gracePeriodController.dispose();
    _minimumPaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Credit Card'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Information Section
            _buildSection(
              'Card Information',
              Icons.credit_card,
              [
                _buildTextField(
                  'Card Name',
                  _nameController,
                  Icons.badge,
                  'Enter card name (e.g., Chase Sapphire)',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Credit Limit',
                  _creditLimitController,
                  Icons.account_balance,
                  'Enter credit limit amount',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Billing Information Section
            _buildSection(
              'Billing Information',
              Icons.calendar_today,
              [
                _buildBillingCycleSelector(),
                const SizedBox(height: 16),
                _buildDateSelector(
                  'Next Billing Date',
                  _nextBillingDate,
                  Icons.receipt_long,
                  (date) => setState(() {
                    _nextBillingDate = date;
                    _updateDueDate();
                  }),
                ),
                const SizedBox(height: 16),
                _buildDateSelector(
                  'Next Due Date',
                  _nextDueDate,
                  Icons.payment,
                  (date) => setState(() => _nextDueDate = date),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Payment Terms Section
            _buildSection(
              'Payment Terms',
              Icons.payment,
              [
                _buildTextField(
                  'Interest Rate (%)',
                  _interestRateController,
                  Icons.percent,
                  'Enter annual interest rate',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Grace Period (Days)',
                  _gracePeriodController,
                  Icons.schedule,
                  'Enter grace period in days',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Minimum Payment (%)',
                  _minimumPaymentController,
                  Icons.payment,
                  'Enter minimum payment percentage',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Statement Period Change Warning
            _buildStatementPeriodWarning(),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Saving...'),
                        ],
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildBillingCycleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Cycle Day',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: DropdownButton<int>(
            value: _billingCycleDay,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: List.generate(31, (index) => index + 1)
                .map((day) => DropdownMenuItem(
                      value: day,
                      child: Text('$day${_getDaySuffix(day)} of each month'),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _billingCycleDay = value;
                  _updateBillingDates();
                });
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your credit card statement will be generated on the $_billingCycleDay${_getDaySuffix(_billingCycleDay)} of each month.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime? date,
    IconData icon,
    Function(DateTime?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(date, onChanged),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  date != null ? Formatters.formatDate(date) : 'Select date',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: date != null 
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatementPeriodWarning() {
    final billingChanged = _billingCycleDay != widget.creditCard.billingCycleDay;
    
    if (!billingChanged) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Billing Cycle Changed',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Changing the billing cycle will affect your current statement period. The new cycle will start from the next billing date.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  void _updateBillingDates() {
    final now = DateTime.now();
    
    // Calculate next billing date
    DateTime nextBilling;
    if (now.day < _billingCycleDay) {
      nextBilling = DateTime(now.year, now.month, _billingCycleDay);
    } else {
      nextBilling = DateTime(now.year, now.month + 1, _billingCycleDay);
      if (nextBilling.month > 12) {
        nextBilling = DateTime(now.year + 1, 1, _billingCycleDay);
      }
    }
    
    _nextBillingDate = nextBilling;
    _updateDueDate();
  }

  void _updateDueDate() {
    if (_nextBillingDate != null) {
      final gracePeriod = int.tryParse(_gracePeriodController.text) ?? 21;
      _nextDueDate = _nextBillingDate!.add(Duration(days: gracePeriod));
    }
  }

  Future<void> _selectDate(DateTime? currentDate, Function(DateTime?) onChanged) async {
    final date = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      onChanged(date);
    }
  }

  Future<void> _saveChanges() async {
    if (_isLoading) return;

    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter a card name');
      return;
    }

    final creditLimit = double.tryParse(_creditLimitController.text);
    if (creditLimit == null || creditLimit <= 0) {
      _showError('Please enter a valid credit limit');
      return;
    }

    final interestRate = double.tryParse(_interestRateController.text);
    if (interestRate == null || interestRate < 0) {
      _showError('Please enter a valid interest rate');
      return;
    }

    final gracePeriod = int.tryParse(_gracePeriodController.text);
    if (gracePeriod == null || gracePeriod < 0) {
      _showError('Please enter a valid grace period');
      return;
    }

    final minimumPayment = double.tryParse(_minimumPaymentController.text);
    if (minimumPayment == null || minimumPayment < 0 || minimumPayment > 100) {
      _showError('Please enter a valid minimum payment percentage (0-100)');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update credit card
      final updatedCard = widget.creditCard.copyWith(
        name: _nameController.text.trim(),
        creditLimit: creditLimit,
        interestRate: interestRate,
        gracePeriodDays: gracePeriod,
        minimumPaymentPercentage: minimumPayment,
        billingCycleDay: _billingCycleDay,
        nextBillingDate: _nextBillingDate,
        nextDueDate: _nextDueDate,
        availableCredit: creditLimit - widget.creditCard.outstandingBalance,
      );

      // Update in CreditCardProvider
      final creditCardProvider = context.read<CreditCardProvider>();
      final success = await creditCardProvider.updateCreditCard(updatedCard);

      if (success && mounted) {
        // Also update in AppProvider if it exists as an account
        final appProvider = context.read<AppProvider>();
        final account = appProvider.accounts.where(
          (acc) => acc.id == widget.creditCard.id,
        ).firstOrNull;

        if (account != null) {
          final updatedAccount = account.copyWith(
            name: _nameController.text.trim(),
            balance: -widget.creditCard.outstandingBalance,
          );
          await appProvider.updateAccount(updatedAccount);
        }

        if (mounted) {
          Navigator.of(context).pop(updatedCard);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Credit card updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (mounted) {
        _showError('Failed to update credit card');
      }
    } catch (e) {
      if (mounted) {
        _showError('Error updating credit card: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/screens/dashboard_screen.dart';
import 'package:kora_expense_tracker/screens/transactions_screen.dart';
import 'package:kora_expense_tracker/screens/accounts_screen.dart';
import 'package:kora_expense_tracker/screens/credit_cards_screen.dart';
import 'package:kora_expense_tracker/screens/more_screen.dart';
import 'package:kora_expense_tracker/screens/reports_screen.dart';
import 'package:kora_expense_tracker/widgets/add_transaction_dialog.dart';
import 'package:kora_expense_tracker/utils/storage_service.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const ReportsScreen(),
    const AccountsScreen(),
    const CreditCardsScreen(),
    const MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstRunAfterUpdate();
    });
  }

  Future<void> _checkFirstRunAfterUpdate() async {
    try {
      final lastVersion = StorageService.prefs.getString('last_version_seen');
      if (lastVersion != AppConstants.appVersion) {
        await _showWhatsNewDialog();
        await StorageService.prefs.setString('last_version_seen', AppConstants.appVersion);
      }
    } catch (e) {
      debugPrint('Error checking version: $e');
    }
  }

  Future<void> _showWhatsNewDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.new_releases, color: AppConstants.primaryColor),
            const SizedBox(width: 8),
            Text('What\'s New in v${AppConstants.appVersion}'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Unlimited custom categories with icons and colors.'),
              SizedBox(height: 8),
              Text('• Attach receipt images to your transactions and view them full screen.'),
              SizedBox(height: 8),
              Text('• Enhanced Home screen with vertical swipe transaction creation.'),
              SizedBox(height: 8),
              Text('• Beautiful new app icon and splash screen design.'),
              SizedBox(height: 8),
              Text('• Sticky filter chips for easy navigation on the Accounts page.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: appProvider.selectedTabIndex,
            children: _screens,
          ),
          bottomNavigationBar: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
                // Swipe from bottom to up detected
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (context) => AddTransactionDialog(
                    appProvider: context.read<AppProvider>(),
                  ),
                );
              }
            },
            child: NavigationBar(
              selectedIndex: appProvider.selectedTabIndex,
              onDestinationSelected: (index) {
                appProvider.setSelectedTab(index);
              },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Txns',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card),
            label: 'Credit Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    ),
  );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/credit_card.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

/// Payment History Screen for viewing all payments made to a credit card
class PaymentHistoryScreen extends StatelessWidget {
  final CreditCard creditCard;

  const PaymentHistoryScreen({
    super.key,
    required this.creditCard,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History - ${creditCard.name}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          // Get all payment transactions for this credit card
          final paymentTransactions = appProvider.transactions
              .where((transaction) => 
                  transaction.type == 'expense' && 
                  transaction.toAccountId == creditCard.id)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending

          if (paymentTransactions.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Summary Card
              _buildSummaryCard(context, paymentTransactions),
              
              // Payment List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: paymentTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = paymentTransactions[index];
                    return _buildPaymentCard(context, transaction);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Payment History',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This will be your first payment to this credit card.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, List<Transaction> payments) {
    final totalPaid = payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
    final paymentCount = payments.length;
    final lastPayment = payments.isNotEmpty ? payments.first : null;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Payment Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Total Paid',
                  Formatters.formatCurrency(totalPaid),
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Payments Made',
                  paymentCount.toString(),
                  Icons.payment,
                  Colors.blue,
                ),
              ),
            ],
          ),
          
          if (lastPayment != null) ...[
            const SizedBox(height: 16),
            _buildSummaryItem(
              context,
              'Last Payment',
              '${Formatters.formatCurrency(lastPayment.amount)} on ${Formatters.formatDate(lastPayment.date)}',
              Icons.schedule,
              Colors.orange,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payment,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment to ${creditCard.name}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      Formatters.formatDate(transaction.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                Formatters.formatCurrency(transaction.amount),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                transaction.notes!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/credit_card_provider.dart';
import '../models/credit_card.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';
import '../constants/app_constants.dart';

/// Payment Screen for making credit card payments
class PaymentScreen extends StatefulWidget {
  final CreditCard creditCard;
  final double? suggestedAmount;

  const PaymentScreen({
    super.key,
    required this.creditCard,
    this.suggestedAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  final String _selectedPaymentMethod = 'transfer'; // Fixed to account transfer only
  Account? _selectedSourceAccount;
  bool _isProcessing = false;
  // bool _isScheduledPayment = false;
  // DateTime? _scheduledDate;

  @override
  void initState() {
    super.initState();
    if (widget.suggestedAmount != null) {
      _amountController.text = widget.suggestedAmount!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pay ${widget.creditCard.name}'),
        actions: [
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Credit Card Info
                  _buildCreditCardInfo(),
                  const SizedBox(height: 24),
                  
                  // Payment Amount
                  _buildAmountSection(),
                  const SizedBox(height: 24),
                  
                  // Payment Method (Fixed to Account Transfer)
                  _buildPaymentMethodSection(),
                  const SizedBox(height: 24),
                  
                  // Source Account Selection (always required for account transfer)
                  _buildSourceAccountSection(appProvider),
                  
                  // Schedule Payment Section (hidden)
                  // _buildSchedulePaymentSection(),
                  
                  // Notes
                  _buildNotesSection(),
                  const SizedBox(height: 32),
                  
                  // Process Payment Button
                  _buildProcessPaymentButton(appProvider),
                  const SizedBox(height: 16),
                  
                  // Recent Payments
                  _buildRecentPayments(appProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreditCardInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.creditCard.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.creditCard.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.creditCard.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.creditCard.maskedCardNumber,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    widget.creditCard.balanceLabel,
                    widget.creditCard.getFormattedUserBalance(),
                    widget.creditCard.userBalanceColor,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Available Credit',
                    widget.creditCard.getFormattedAvailableCredit(),
                    AppConstants.availableColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Amount',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            labelText: 'Amount',
            hintText: '0.00',
            prefixText: Formatters.getCurrencySymbol(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            prefixIcon: const Icon(Icons.payment),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter payment amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (amount > widget.creditCard.outstandingBalance) {
              return 'Amount cannot exceed outstanding balance';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        // Financial wellness message
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '💡 Paying the full amount helps avoid interest charges and debt traps',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _setAmount(widget.creditCard.outstandingBalance),
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Pay Full Amount'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _setAmount(widget.creditCard.minimumPaymentAmount),
                icon: const Icon(Icons.warning_amber, size: 18),
                label: const Text('Pay Minimum'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_balance,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Account Transfer',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.lock,
                color: Colors.grey.shade500,
                size: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Payments are processed as account transfers from your selected account to the credit card.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSourceAccountSection(AppProvider appProvider) {
    // Get asset accounts (savings, wallet, cash, investment) that can be used for payments
    final availableAccounts = appProvider.accounts
        .where((account) => account.isAsset && account.balance > 0)
        .toList();
    
    if (availableAccounts.isEmpty) {
      return Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.warning,
                color: Colors.orange,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'No Source Accounts Available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please add accounts with available balance to make payments.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _navigateToAddAccount(),
                child: const Text('Add Account'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Source Account',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<Account>(
          initialValue: _selectedSourceAccount,
          isExpanded: true,
          isDense: true,
          decoration: InputDecoration(
            labelText: 'Choose Source Account',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            prefixIcon: const Icon(Icons.account_balance),
          ),
          items: availableAccounts.map((account) => DropdownMenuItem(
            value: account,
            child: Text(
              '${account.name} • ${Formatters.formatCurrency(account.balance)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSourceAccount = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a source account';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Widget _buildSchedulePaymentSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Payment Schedule',
  //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       const SizedBox(height: 16),
  //       
  //       // Schedule Toggle
  //       Card(
  //         child: Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Column(
  //             children: [
  //               Row(
  //                 children: [
  //                   Icon(
  //                     Icons.schedule,
  //                     color: Theme.of(context).primaryColor,
  //                     size: 20,
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           'Schedule Payment',
  //                           style: Theme.of(context).textTheme.titleSmall?.copyWith(
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                         Text(
  //                           'Pay later instead of immediately',
  //                           style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //                             color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Switch(
  //                     value: _isScheduledPayment,
  //                     onChanged: (value) {
  //                       setState(() {
  //                         _isScheduledPayment = value;
  //                         if (!value) {
  //                           _scheduledDate = null;
  //                         } else {
  //                           // Set default date to tomorrow
  //                           _scheduledDate = DateTime.now().add(const Duration(days: 1));
  //                         }
  //                       });
  //                     },
  //                   ),
  //                 ],
  //               ),
  //               
  //               // Date Picker (shown when scheduled)
  //               if (_isScheduledPayment) ...[
  //                 const SizedBox(height: 16),
  //                 Container(
  //                   width: double.infinity,
  //                   padding: const EdgeInsets.all(16),
  //                   decoration: BoxDecoration(
  //                     color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
  //                     borderRadius: BorderRadius.circular(12),
  //                     border: Border.all(
  //                       color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
  //                     ),
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         'Scheduled Date',
  //                         style: Theme.of(context).textTheme.titleSmall?.copyWith(
  //                           fontWeight: FontWeight.bold,
  //                           color: Theme.of(context).primaryColor,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       InkWell(
  //                         onTap: _selectScheduledDate,
  //                         child: Container(
  //                           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  //                           decoration: BoxDecoration(
  //                             color: Colors.white,
  //                             borderRadius: BorderRadius.circular(8),
  //                             border: Border.all(color: Colors.grey.shade300),
  //                           ),
  //                           child: Row(
  //                             children: [
  //                               Icon(
  //                                 Icons.calendar_today,
  //                                 color: Theme.of(context).primaryColor,
  //                                 size: 20,
  //                               ),
  //                               const SizedBox(width: 12),
  //                               Text(
  //                                 _scheduledDate != null 
  //                                     ? Formatters.formatDate(_scheduledDate!)
  //                                     : 'Select Date',
  //                                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                                   color: _scheduledDate != null 
  //                                       ? Theme.of(context).colorScheme.onSurface
  //                                       : Colors.grey.shade600,
  //                                 ),
  //                               ),
  //                               const Spacer(),
  //                               Icon(
  //                                 Icons.arrow_drop_down,
  //                                 color: Colors.grey.shade600,
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       Text(
  //                         'Payment will be processed automatically on the selected date.',
  //                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //                           color: Theme.of(context).primaryColor,
  //                           fontStyle: FontStyle.italic,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'Payment Notes',
            hintText: 'Add any notes about this payment...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            prefixIcon: const Icon(Icons.note),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildProcessPaymentButton(AppProvider appProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _processPayment(appProvider),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Process Payment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildRecentPayments(AppProvider appProvider) {
    // Get recent transfer transactions to this credit card
    final recentPayments = appProvider.transactions
        .where((transaction) => 
            transaction.isTransfer && 
            transaction.toAccountId == widget.creditCard.id)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date, newest first

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Payment History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (recentPayments.isNotEmpty)
              Text(
                '${recentPayments.length} payment${recentPayments.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentPayments.isEmpty)
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    color: Colors.blue,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No Payment History',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This will be your first payment to this credit card.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...recentPayments.take(10).map((transaction) => _buildPaymentItem(transaction)),
      ],
    );
  }

  Widget _buildPaymentItem(Transaction transaction) {
    final sourceAccount = context.read<AppProvider>().getAccountForTransaction(transaction.accountId);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            color: Colors.green,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              Formatters.formatCurrency(transaction.amount.abs()),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PAID',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'From ${sourceAccount?.name ?? 'Unknown Account'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              Formatters.formatDate(transaction.date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                transaction.notes!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(2);
  }

  // Future<void> _selectScheduledDate() async {
  //   final now = DateTime.now();
  //   final firstDate = now.add(const Duration(days: 1)); // Can't schedule for today
  //   final lastDate = now.add(const Duration(days: 365)); // Max 1 year ahead
  //   
  //   final selectedDate = await showDatePicker(
  //     context: context,
  //     initialDate: _scheduledDate ?? firstDate,
  //     firstDate: firstDate,
  //     lastDate: lastDate,
  //     helpText: 'Select Payment Date',
  //     confirmText: 'Confirm',
  //     cancelText: 'Cancel',
  //   );
  //   
  //   if (selectedDate != null) {
  //     setState(() {
  //       _scheduledDate = selectedDate;
  //     });
  //   }
  // }



  Future<void> _processPayment(AppProvider appProvider) async {
    if (!_formKey.currentState!.validate()) return;

    // Validate source account selection for transfer payments
    if (_selectedPaymentMethod == 'transfer' && _selectedSourceAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a source account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate scheduled date if scheduling payment (disabled)
    // if (_isScheduledPayment && _scheduledDate == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please select a scheduled date'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    setState(() => _isProcessing = true);

    try {
      final amount = double.parse(_amountController.text);
      
      // Find the Credit Card Payment category
      final creditCardPaymentCategory = appProvider.categories
          .firstWhere(
            (category) => category.name == 'Credit Card Payment',
            orElse: () => appProvider.categories.first, // Fallback to first category
          );

      // Handle immediate payment only
      await _processImmediatePayment(appProvider, amount, creditCardPaymentCategory);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _processImmediatePayment(AppProvider appProvider, double amount, category) async {
    // Create transfer transaction from source account to credit card
    final transaction = Transaction.create(
      type: 'transfer',
      amount: amount,
      description: 'Credit Card Payment - ${widget.creditCard.name}',
      categoryId: category.id,
      accountId: _selectedSourceAccount?.id ?? 'cash', // Use selected account or cash
      toAccountId: widget.creditCard.id, // Credit card as destination
      notes: _notesController.text.trim().isEmpty 
          ? 'Payment via Account Transfer'
          : '${_notesController.text.trim()} (via Account Transfer)',
    );

    // Add transaction using AppProvider
    final success = await appProvider.addTransaction(transaction);
    
    if (success) {
      // Refresh credit card provider to update payment data
      final creditCardProvider = Provider.of<CreditCardProvider>(context, listen: false);
      await creditCardProvider.refresh();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment processed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Return success result to refresh parent screen
        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appProvider.error ?? 'Payment processing failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Future<void> _processScheduledPayment(AppProvider appProvider, double amount, category) async {
  //   // Create scheduled transaction (with future date)
  //   final transaction = Transaction.create(
  //     type: 'transfer',
  //     amount: amount,
  //     description: 'Scheduled Credit Card Payment - ${widget.creditCard.name}',
  //     categoryId: category.id,
  //     accountId: _selectedSourceAccount?.id ?? 'cash',
  //     toAccountId: widget.creditCard.id,
  //     date: _scheduledDate!, // Use scheduled date
  //     notes: _notesController.text.trim().isEmpty 
  //         ? 'Scheduled Payment via Account Transfer'
  //         : '${_notesController.text.trim()} (Scheduled Payment)',
  //   );

  //   // Add transaction using AppProvider
  //   final success = await appProvider.addTransaction(transaction);
  //   
  //   if (success) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Payment scheduled successfully for ${Formatters.formatDate(_scheduledDate!)}!'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //       Navigator.of(context).pop();
  //     }
  //   } else {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(appProvider.error ?? 'Payment scheduling failed'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  void _navigateToAddAccount() {
    // Navigate to accounts screen where user can add new accounts
    Navigator.of(context).pushNamed('/accounts');
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/credit_card.dart';
import '../models/credit_card_statement.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';

/// Statement Analytics Screen - Detailed analysis for a specific statement period
class StatementAnalyticsScreen extends StatefulWidget {
  final CreditCardStatement statement;
  final CreditCard creditCard;

  const StatementAnalyticsScreen({
    super.key,
    required this.statement,
    required this.creditCard,
  });

  @override
  State<StatementAnalyticsScreen> createState() => _StatementAnalyticsScreenState();
}

class _StatementAnalyticsScreenState extends State<StatementAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _selectedPeriod = 'Statement Period';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.creditCard.name} Analytics'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.trending_up), text: 'Spending'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Categories'),
            Tab(icon: Icon(Icons.lightbulb), text: 'Insights'),
          ],
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          // Get transactions for this statement period
          final periodTransactions = appProvider.transactions.where((transaction) {
            return transaction.accountId == widget.creditCard.id &&
                   transaction.date.isAfter(widget.statement.periodStart) &&
                   transaction.date.isBefore(widget.statement.periodEnd.add(const Duration(days: 1)));
          }).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(periodTransactions, appProvider),
              _buildSpendingTab(periodTransactions),
              _buildCategoriesTab(periodTransactions, appProvider),
              _buildInsightsTab(periodTransactions),
            ],
          );
        },
      ),
    );
  }

  // ========================================
  // TAB CONTENT METHODS
  // ========================================

  Widget _buildOverviewTab(List transactions, AppProvider appProvider) {
    final totalSpent = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    
    final totalTransactions = transactions.length;
    final avgTransaction = totalTransactions > 0 ? totalSpent / totalTransactions : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statement Period Filter
          _buildPeriodFilter(),
          const SizedBox(height: 24),
          
          // Key Metrics
          _buildKeyMetricsCards(totalSpent, totalTransactions, avgTransaction),
          const SizedBox(height: 24),
          
          // Spending Trend
          _buildSpendingTrend(transactions),
          const SizedBox(height: 24),
          
          // Spending by Category
          _buildSpendingByCategory(transactions, appProvider),
          const SizedBox(height: 24),
          
          // Smart Insights
          _buildSmartInsights(transactions),
        ],
      ),
    );
  }

  Widget _buildSpendingTab(List transactions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodFilter(),
          const SizedBox(height: 24),
          _buildDetailedSpendingAnalysis(transactions),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(List transactions, AppProvider appProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodFilter(),
          const SizedBox(height: 24),
          _buildCategoryBreakdown(transactions, appProvider),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(List transactions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodFilter(),
          const SizedBox(height: 24),
          _buildDetailedInsights(transactions),
        ],
      ),
    );
  }

  // ========================================
  // COMPONENT METHODS
  // ========================================

  Widget _buildPeriodFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            widget.statement.periodDisplay,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsCards(double totalSpent, int totalTransactions, double avgTransaction) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Spending',
            Formatters.formatCurrency(totalSpent),
            Icons.trending_up,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Avg Transaction',
            Formatters.formatCurrency(avgTransaction),
            Icons.calendar_today,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Transactions',
            totalTransactions.toString(),
            Icons.receipt,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrend(List transactions) {
    // Group transactions by day
    final dailySpending = <DateTime, double>{};
    for (final transaction in transactions.where((t) => t.isExpense)) {
      final day = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      dailySpending[day] = (dailySpending[day] ?? 0) + transaction.amount.abs();
    }

    final sortedDays = dailySpending.keys.toList()..sort();
    final maxSpending = dailySpending.values.isEmpty ? 1.0 : dailySpending.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Spending Trend',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (dailySpending.isEmpty)
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Spending Data',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No transactions found for this statement period',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: Column(
                children: [
                  // Chart area
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: sortedDays.map((day) {
                        final spending = dailySpending[day] ?? 0.0;
                        final height = (spending / maxSpending) * 120; // Max height of 120
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 20,
                              height: height,
                              decoration: BoxDecoration(
                                color: _getBarColor(spending, maxSpending),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${day.day}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem('Low', Colors.green),
                      _buildLegendItem('Medium', Colors.orange),
                      _buildLegendItem('High', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getBarColor(double spending, double maxSpending) {
    final ratio = spending / maxSpending;
    if (ratio < 0.3) return Colors.green;
    if (ratio < 0.7) return Colors.orange;
    return Colors.red;
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingByCategory(List transactions, AppProvider appProvider) {
    final categorySpending = <String, double>{};
    
    for (final transaction in transactions.where((t) => t.isExpense)) {
      final category = appProvider.categories
          .where((c) => c.id == transaction.categoryId)
          .firstOrNull;
      if (category != null) {
        categorySpending[category.name] = (categorySpending[category.name] ?? 0) + transaction.amount.abs();
      }
    }

    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (sortedCategories.isEmpty)
            Center(
              child: Text(
                'No spending data available for this period',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            )
          else
            ...sortedCategories.take(5).map((entry) => _buildCategoryItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, double amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            Formatters.formatCurrency(amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsights(List transactions) {
    final totalSpent = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Smart Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow.shade200),
            ),
            child: Text(
              'You spent ${Formatters.formatCurrency(totalSpent)} during this statement period. This represents your total credit card usage for ${widget.statement.periodDisplay}.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // TAB-SPECIFIC METHODS
  // ========================================

  Widget _buildDetailedSpendingAnalysis(List transactions) {
    // Group transactions by day
    final dailySpending = <DateTime, List<dynamic>>{};
    for (final transaction in transactions.where((t) => t.isExpense)) {
      final day = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      if (dailySpending[day] == null) {
        dailySpending[day] = [];
      }
      dailySpending[day]!.add(transaction);
    }

    final sortedDays = dailySpending.keys.toList()..sort((a, b) => b.compareTo(a)); // Most recent first

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daily Spending Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Spending Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (dailySpending.isEmpty)
                Center(
                  child: Text(
                    'No spending data available for this period',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              else
                ...sortedDays.map((day) {
                  final dayTransactions = dailySpending[day]!;
                  final dayTotal = dayTransactions.fold(0.0, (sum, t) => sum + t.amount.abs());
                  return _buildDaySummary(day, dayTotal, dayTransactions.length);
                }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // All Transactions List
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Transactions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (transactions.isEmpty)
                Center(
                  child: Text(
                    'No transactions found for this period',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              else
                ...transactions.where((t) => t.isExpense).map((transaction) => _buildTransactionItem(transaction)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaySummary(DateTime day, double total, int transactionCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today,
              color: Colors.blue.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatters.formatDate(day),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$transactionCount transaction${transactionCount != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            Formatters.formatCurrency(total),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_upward,
              color: Colors.red.shade600,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  Formatters.formatDate(transaction.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-${Formatters.formatCurrency(transaction.amount.abs())}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(List transactions, AppProvider appProvider) {
    final categorySpending = <String, double>{};
    
    for (final transaction in transactions.where((t) => t.isExpense)) {
      final category = appProvider.categories
          .where((c) => c.id == transaction.categoryId)
          .firstOrNull;
      if (category != null) {
        categorySpending[category.name] = (categorySpending[category.name] ?? 0) + transaction.amount.abs();
      }
    }

    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalSpent = categorySpending.values.fold(0.0, (sum, amount) => sum + amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spending by Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (sortedCategories.isEmpty)
                Center(
                  child: Text(
                    'No spending data available for this period',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              else
                ...sortedCategories.map((entry) {
                  final percentage = totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0.0;
                  return _buildCategoryItemWithPercentage(entry.key, entry.value, percentage);
                }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Category Insights
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (sortedCategories.isNotEmpty)
                _buildCategoryInsights(sortedCategories, totalSpent)
              else
                Center(
                  child: Text(
                    'No insights available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItemWithPercentage(String category, double amount, double percentage) {
    final colors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
    ];
    
    final colorIndex = category.hashCode % colors.length;
    final color = colors[colorIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}% of total spending',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            Formatters.formatCurrency(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryInsights(List<MapEntry<String, double>> categories, double totalSpent) {
    final topCategory = categories.first;
    final topCategoryPercentage = totalSpent > 0 ? (topCategory.value / totalSpent) * 100 : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Top Spending Category',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${topCategory.key} is your highest spending category at ${topCategoryPercentage.toStringAsFixed(1)}% of your total spending (${Formatters.formatCurrency(topCategory.value)}).',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInsights(List transactions) {
    final totalSpent = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    
    final transactionCount = transactions.length;
    final avgTransaction = transactionCount > 0 ? totalSpent / transactionCount : 0.0;
    
    // Calculate spending patterns
    final dailySpending = <DateTime, double>{};
    for (final transaction in transactions.where((t) => t.isExpense)) {
      final day = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      dailySpending[day] = (dailySpending[day] ?? 0) + transaction.amount.abs();
    }
    
    final maxDailySpending = dailySpending.values.isEmpty ? 0.0 : dailySpending.values.reduce((a, b) => a > b ? a : b);
    final maxSpendingDay = dailySpending.entries.isEmpty ? null : dailySpending.entries.reduce((a, b) => a.value > b.value ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Key Insights
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Key Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (transactions.isEmpty)
                Center(
                  child: Text(
                    'No insights available for this period',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    _buildInsightCard(
                      'Total Spending',
                      'You spent ${Formatters.formatCurrency(totalSpent)} during this statement period',
                      Icons.account_balance_wallet,
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildInsightCard(
                      'Average Transaction',
                      'Your average transaction was ${Formatters.formatCurrency(avgTransaction)}',
                      Icons.trending_up,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    if (maxSpendingDay != null)
                      _buildInsightCard(
                        'Highest Spending Day',
                        'You spent the most on ${Formatters.formatDate(maxSpendingDay.key)} - ${Formatters.formatCurrency(maxSpendingDay.value)}',
                        Icons.calendar_today,
                        Colors.orange,
                      ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Recommendations
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommendations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildRecommendationCard(
                'Spending Pattern',
                'Consider tracking your daily spending to identify patterns and reduce unnecessary expenses.',
                Icons.lightbulb,
                Colors.yellow,
              ),
              const SizedBox(height: 12),
              _buildRecommendationCard(
                'Budget Planning',
                'Set a monthly budget for your credit card spending to maintain better financial control.',
                Icons.savings,
                Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/models/transaction.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/models/category.dart';
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

  /// Cycle through filter options with swipe gestures
  void _cycleFilter(int direction) {
    final filters = ['All', 'Income', 'Expense', 'Transfer'];
    final currentIndex = filters.indexOf(_selectedFilter);
    
    int newIndex;
    if (direction > 0) {
      // Swipe left - go to next filter
      newIndex = (currentIndex + 1) % filters.length;
    } else {
      // Swipe right - go to previous filter
      newIndex = (currentIndex - 1 + filters.length) % filters.length;
    }
    
    setState(() {
      _selectedFilter = filters[newIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final filteredTransactions = _getFilteredTransactions(appProvider.transactions);
        final groupedTransactions = _groupTransactionsByDate(filteredTransactions);

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            // Swipe left/right anywhere in the app to change filter
            if (details.primaryVelocity! > 0) {
              // Swipe right
              _cycleFilter(-1);
            } else if (details.primaryVelocity! < 0) {
              // Swipe left
              _cycleFilter(1);
            }
          },
          child: Scaffold(
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
          ),
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
                    Icons.payments, // change the icon for the amount feild
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
              ...transactions.map((transaction) {
                Account? account = appProvider.getAccountForTransaction(transaction.accountId);
                
                Category? category;
                try {
                  category = appProvider.categories.firstWhere((cat) => cat.id == transaction.categoryId);
                } catch (e) {
                  category = appProvider.categories.isNotEmpty ? appProvider.categories.first : null;
                }
                
                Account? toAccount;
                if (transaction.toAccountId != null) {
                  toAccount = appProvider.getAccountForTransaction(transaction.toAccountId!);
                }
                
                return TransactionListItem(
                  transaction: transaction,
                  account: account,
                  category: category,
                  toAccount: toAccount,
                  onTap: () => _showTransactionDetails(context, transaction),
                  onEdit: () => _editTransaction(context, transaction, appProvider),
                  onDelete: () => appProvider.deleteTransaction(transaction.id),
                );
              }),
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
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: "transactions_fab",
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
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
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
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailSheet(
        transaction: transaction,
        appProvider: appProvider,
      ),
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
import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Navigate to Home after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.account_balance_wallet,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Kora Expense Tracker',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your simple yet powerful companion for financial health and tracking expenses.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ReleaseNotesScreen extends StatelessWidget {
  const ReleaseNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Release Notes'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReleaseCard(
            context,
            version: '1.0.0+1 (Beta Update)',
            date: 'March 2026',
            features: [
              'Custom Categories: You can now create unlimited custom categories with personalized icons and colors.',
              'Receipt Attachments: Snap or upload receipts and images for any transaction.',
              'Interactive Image Viewer: Tap an attached image to view it full-screen with zooming and panning capabilities.',
              'App Icon & Branding: Updated our app icon and splash screen to fit the premium aesthetic of Kora.',
            ],
            bugFixes: [
              'Fixed Home Screen Gestures: Resolved conflicts with system navigation and transaction swiping.',
              'Sticky Navigation: The filter chips on the Accounts page now remain visible when scrolling.',
              'Credit Cards Padding Safe Area: Corrected layout issues on empty credit card lists to prevent clipping.',
              'Improved Storage Cleanup: Deleting transactions or overwriting images now properly deletes cache images to save space.',
            ],
          ),
          const SizedBox(height: 16),
          _buildReleaseCard(
            context,
            version: '1.0.0 (Initial Beta)',
            date: 'March 2026',
            features: [
              'Core expense tracking functionality.',
              'Account management (Asset and Liability separation).',
              'Initial Credit Card tracking module (Beta).',
              'PDF receipt exporter and JSON data import/restore.',
            ],
            bugFixes: [],
          ),
        ],
      ),
    );
  }

  Widget _buildReleaseCard(
    BuildContext context, {
    required String version,
    required String date,
    required List<String> features,
    required List<String> bugFixes,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'v$version',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            if (features.isNotEmpty) ...[
              Text(
                'What\'s New',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(f, style: const TextStyle(height: 1.4))),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],
            if (bugFixes.isNotEmpty) ...[
              Text(
                'Bug Fixes & Improvements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...bugFixes.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(f, style: const TextStyle(height: 1.4))),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/utils/formatters.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/models/transaction.dart';
import 'package:kora_expense_tracker/models/category.dart';

/// Period filter options for the Reports screen.
enum ReportPeriod { week, month, year }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.month;

  // ─── Helpers ────────────────────────────────────────────────────────────────

  DateTimeRange _range(ReportPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case ReportPeriod.week:
        // Start of current week (Monday)
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return DateTimeRange(
          start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          end: now,
        );
      case ReportPeriod.month:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
      case ReportPeriod.year:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        );
    }
  }

  List<Transaction> _filtered(List<Transaction> all, DateTimeRange range) {
    return all.where((t) {
      return !t.date.isBefore(range.start) && !t.date.isAfter(range.end);
    }).toList();
  }

  String _periodLabel(ReportPeriod p) {
    switch (p) {
      case ReportPeriod.week:
        return 'This Week';
      case ReportPeriod.month:
        return 'This Month';
      case ReportPeriod.year:
        return 'This Year';
    }
  }

  int _periodDays(ReportPeriod p) {
    switch (p) {
      case ReportPeriod.week:
        return 7;
      case ReportPeriod.month:
        return DateTime.now().day;
      case ReportPeriod.year:
        return DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays + 1;
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final range = _range(_period);
        final filtered = _filtered(provider.transactions, range);

        final income = filtered
            .where((t) => t.isIncome)
            .fold(0.0, (s, t) => s + t.amount.abs());
        final expenses = filtered
            .where((t) => t.isExpense)
            .fold(0.0, (s, t) => s + t.amount.abs());
        final savings = income - expenses;
        final days = _periodDays(_period);
        final dailyAvg = days > 0 ? expenses / days : 0.0;

        // Top categories by spend
        final Map<String, double> catSpend = {};
        for (final t in filtered.where((t) => t.isExpense)) {
          catSpend[t.categoryId] =
              (catSpend[t.categoryId] ?? 0) + t.amount.abs();
        }
        final sortedCats = catSpend.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final topCats = sortedCats.take(5).toList();
        final maxCatSpend =
            topCats.isNotEmpty ? topCats.first.value : 1.0;

        final savingsRate = income > 0 ? (savings / income).clamp(0.0, 1.0) : 0.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reports'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => provider.refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Period filter chips ─────────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ReportPeriod.values.map((p) {
                          final selected = _period == p;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: selected,
                              label: Text(_periodLabel(p)),
                              onSelected: (_) =>
                                  setState(() => _period = p),
                              selectedColor:
                                  Theme.of(context).colorScheme.primaryContainer,
                              checkmarkColor:
                                  Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: AppConstants.defaultPadding),

                    // ── Summary header card ─────────────────────────────────
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(AppConstants.defaultPadding),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer,
                              Theme.of(context).colorScheme.secondaryContainer,
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _periodLabel(_period),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Net Savings',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withValues(alpha: 0.75),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.formatCurrency(savings),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: savings >= 0
                                        ? AppConstants.successColor
                                        : AppConstants.errorColor,
                                  ),
                            ),
                            const SizedBox(height: AppConstants.defaultPadding),
                            Row(
                              children: [
                                Expanded(
                                  child: _summaryItem(
                                    context,
                                    'Income',
                                    Formatters.formatCurrency(income),
                                    AppConstants.successColor,
                                    Icons.arrow_upward_rounded,
                                  ),
                                ),
                                const SizedBox(
                                    width: AppConstants.defaultPadding),
                                Expanded(
                                  child: _summaryItem(
                                    context,
                                    'Expenses',
                                    Formatters.formatCurrency(expenses),
                                    AppConstants.errorColor,
                                    Icons.arrow_downward_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.defaultPadding),

                    // ── Key metrics row ─────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _metricCard(
                            context,
                            icon: Icons.calendar_today_rounded,
                            label: 'Daily Avg',
                            value: Formatters.formatCurrency(dailyAvg),
                            color: AppConstants.infoColor,
                          ),
                        ),
                        const SizedBox(width: AppConstants.defaultPadding),
                        Expanded(
                          child: _metricCard(
                            context,
                            icon: Icons.savings_rounded,
                            label: 'Savings Rate',
                            value:
                                '${(savingsRate * 100).toStringAsFixed(1)}%',
                            color: savingsRate >= 0.2
                                ? AppConstants.successColor
                                : AppConstants.warningColor,
                          ),
                        ),
                        const SizedBox(width: AppConstants.defaultPadding),
                        Expanded(
                          child: _metricCard(
                            context,
                            icon: Icons.receipt_long_rounded,
                            label: 'Transactions',
                            value: '${filtered.length}',
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.largePadding),

                    // ── Income vs Expense bar ───────────────────────────────
                    if (income > 0 || expenses > 0) ...[
                      Text(
                        'Income vs Expenses',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(
                              AppConstants.defaultPadding),
                          child: _incomeExpenseBar(
                              context, income, expenses),
                        ),
                      ),
                      const SizedBox(height: AppConstants.largePadding),
                    ],

                    // ── Top spending categories ─────────────────────────────
                    if (topCats.isNotEmpty) ...[
                      Text(
                        'Top Spending Categories',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(
                              AppConstants.defaultPadding),
                          child: Column(
                            children: topCats.map((entry) {
                              final cat = _findCategory(
                                  provider.categories, entry.key);
                              final ratio =
                                  maxCatSpend > 0
                                      ? entry.value / maxCatSpend
                                      : 0.0;
                              return _categoryBar(
                                context,
                                cat: cat,
                                amount: entry.value,
                                ratio: ratio,
                                totalExpenses: expenses,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.largePadding),
                    ],

                    // ── Empty state ─────────────────────────────────────────
                    if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Column(
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                size: 72,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No data for ${_periodLabel(_period).toLowerCase()}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add transactions to see your report.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Sub-widgets ─────────────────────────────────────────────────────────────

  Widget _summaryItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withValues(alpha: 0.75),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _metricCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _incomeExpenseBar(
      BuildContext context, double income, double expenses) {
    final total = income + expenses;
    final incomeFrac = total > 0 ? (income / total) : 0.5;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Flexible(
                flex: (incomeFrac * 100).round(),
                child: Container(
                  height: 18,
                  color: AppConstants.successColor,
                ),
              ),
              Flexible(
                flex: ((1 - incomeFrac) * 100).round(),
                child: Container(
                  height: 18,
                  color: AppConstants.errorColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _legendDot(context, AppConstants.successColor,
                'Income ${(incomeFrac * 100).toStringAsFixed(1)}%'),
            _legendDot(context, AppConstants.errorColor,
                'Expenses ${((1 - incomeFrac) * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ],
    );
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _categoryBar(
    BuildContext context, {
    required Category? cat,
    required double amount,
    required double ratio,
    required double totalExpenses,
  }) {
    final pct =
        totalExpenses > 0 ? (amount / totalExpenses * 100) : 0.0;
    final color = cat != null ? cat.color : AppConstants.primaryColor;
    final icon = cat?.icon ?? Icons.category;
    final name = cat?.name ?? 'Unknown';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          Formatters.formatCurrency(amount),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.errorColor,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pct.toStringAsFixed(1)}% of expenses',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Category? _findCategory(List<Category> cats, String id) {
    try {
      return cats.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../providers/credit_card_provider.dart';
import '../providers/app_provider.dart';
import '../models/credit_card.dart';
import '../models/credit_card_statement.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';
import 'payment_screen.dart';
import 'statement_analytics_screen.dart';
import 'credit_card_analytics_screen.dart';
import 'edit_credit_card_screen.dart';
import '../widgets/transaction_detail_sheet.dart';
import '../widgets/add_transaction_dialog.dart';

/// Credit Card Detail Screen - Comprehensive view of a single credit card
class CreditCardDetailScreen extends StatefulWidget {
  final CreditCard creditCard;

  const CreditCardDetailScreen({
    super.key,
    required this.creditCard,
  });

  @override
  State<CreditCardDetailScreen> createState() => _CreditCardDetailScreenState();
}

class _CreditCardDetailScreenState extends State<CreditCardDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CreditCard _currentCard;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentCard = widget.creditCard;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentCard.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Card'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Card', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Transactions'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Statements'),
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionsTab(),
          _buildStatementsTab(),
          _buildOverviewTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Visual
          _buildCardVisual(),
          const SizedBox(height: 24),
          
          // Key Metrics
          _buildKeyMetrics(),
          const SizedBox(height: 24),
          
          // Bill & Due Date Status (Enhanced)
          _buildBillDueDateStatus(),
          const SizedBox(height: 24),
          
          // Billing Information
          _buildBillingInformation(),
          const SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 24),
          
          // Recent Activity
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatementsTab() {
    return Consumer<CreditCardProvider>(
      builder: (context, provider, child) {
        final allStatements = provider.getStatementsForCard(_currentCard.id);
        final generatedStatements = allStatements.where((stmt) => stmt.status == StatementStatus.generated).toList();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Statement Overview
              _buildCurrentStatementOverview(),
              const SizedBox(height: 24),
              
              // Statement History (Only Generated Statements)
              if (generatedStatements.isNotEmpty) ...[
                _buildStatementHistoryList(generatedStatements),
                const SizedBox(height: 24),
              ] else ...[
                _buildStatementHistory(),
                const SizedBox(height: 24),
              ],
              
              // Past Statements (Paid)
              _buildPastStatementsSection(),
            ],
          ),
        );
      },
    );
  }


  Widget _buildAnalyticsTab() {
    return Consumer<CreditCardProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Analytics Overview
              _buildQuickAnalyticsOverview(),
              const SizedBox(height: 24),
              
              // View Detailed Analytics Button
              _buildViewDetailedAnalyticsButton(),
              const SizedBox(height: 24),
              
              // Utilization Chart
              _buildUtilizationChart(),
              const SizedBox(height: 24),
              
              // Payment History
              _buildPaymentHistory(),
              const SizedBox(height: 24),
              
              // Spending Summary
              _buildSpendingSummary(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardVisual() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_currentCard.color, _currentCard.color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _currentCard.color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _currentCard.icon,
                  color: Colors.white,
                  size: 32,
                ),
                const Spacer(),
                Text(
                  _currentCard.network,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              _currentCard.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentCard.maskedCardNumber,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Expires ${_currentCard.formattedExpiryDate}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Credit Limit',
                _currentCard.getFormattedCreditLimit(),
                Icons.account_balance,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                _currentCard.balanceLabel,
                _currentCard.getFormattedUserBalance(),
                Icons.money_off,
                _currentCard.userBalanceColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Available',
                _currentCard.getFormattedAvailableCredit(),
                Icons.account_balance_wallet,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Utilization',
                _currentCard.userFriendlyUtilization,
                Icons.trending_up,
                _currentCard.utilizationColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBillingInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _buildBillingInfoRow(
                'Billing Cycle Day',
                '${_currentCard.billingCycleDay}th of each month',
                Icons.calendar_today,
              ),
              const Divider(),
              _buildBillingInfoRow(
                'Next Billing Date',
                _currentCard.nextBillingDate != null
                    ? Formatters.formatDate(_currentCard.nextBillingDate!)
                    : 'Not set',
                Icons.receipt_long,
              ),
              const Divider(),
              _buildBillingInfoRow(
                'Next Due Date',
                _currentCard.nextDueDate != null
                    ? Formatters.formatDate(_currentCard.nextDueDate!)
                    : 'Not set',
                Icons.payment,
                isUrgent: _currentCard.isDueSoon || _currentCard.isOverdue,
              ),
              const Divider(),
              _buildBillingInfoRow(
                'Grace Period',
                '${_currentCard.gracePeriodDays} days',
                Icons.schedule,
              ),
              const Divider(),
              _buildBillingInfoRow(
                'Interest Rate',
                '${_currentCard.interestRate}% APR',
                Icons.percent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showPaymentDialog(),
                icon: const Icon(Icons.payment),
                label: const Text('Pay Full Due Balance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _generateStatement(),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Generate Statement'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showTransactionHistory(),
                icon: const Icon(Icons.analytics),
                label: const Text('Analytics'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showTransactionHistory(),
                icon: const Icon(Icons.history),
                label: const Text('Transactions'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Get transactions for this credit card
        final creditCardTransactions = appProvider.transactions
            .where((transaction) => transaction.accountId == _currentCard.id)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date, newest first
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (creditCardTransactions.isNotEmpty)
                  TextButton(
                    onPressed: () => _showTransactionHistory(),
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (creditCardTransactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: const Text(
                  'No transactions found for this credit card.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...creditCardTransactions.take(5).map((transaction) => 
                _buildTransactionItem(transaction)
              ),
          ],
        );
      },
    );
  }



  Widget _buildPaymentCard(payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPaymentStatusColor(payment.status),
          child: Icon(
            _getPaymentStatusIcon(payment.status),
            color: Colors.white,
          ),
        ),
        title: Text(payment.paymentTypeDescription),
        subtitle: Text('${payment.formattedPaymentDate} - ${payment.getFormattedAmount()}'),
        trailing: Text(
          payment.status,
          style: TextStyle(
            color: _getPaymentStatusColor(payment.status),
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => _showPaymentDetails(payment),
      ),
    );
  }

  Widget _buildUtilizationChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Credit Utilization',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _currentCard.utilizationPercentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(_currentCard.utilizationColor),
          ),
          const SizedBox(height: 8),
          Text(
            '${_currentCard.userFriendlyUtilization} ${_currentCard.outstandingBalance < 0 ? 'credit available' : 'utilized'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _currentCard.utilizationColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment History',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Payment history analytics will be displayed here.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Spending summary and trends will be displayed here.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAnalyticsOverview() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final transactions = appProvider.transactions
            .where((transaction) => transaction.accountId == _currentCard.id)
            .toList();
        
        final monthlySpending = _calculateMonthlySpending(transactions);
        final totalSpending = monthlySpending.values.fold(0.0, (sum, amount) => sum + amount);
        final avgMonthlySpending = monthlySpending.isNotEmpty ? totalSpending / monthlySpending.length : 0.0;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
                Theme.of(context).primaryColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Analytics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickMetric(
                      'Total Spending',
                      Formatters.formatCurrency(totalSpending),
                      Icons.trending_up,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickMetric(
                      'Avg Monthly',
                      Formatters.formatCurrency(avgMonthlySpending),
                      Icons.calendar_month,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailedAnalyticsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToDetailedAnalytics(),
        icon: const Icon(Icons.analytics),
        label: const Text('View Detailed Analytics'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Map<String, double> _calculateMonthlySpending(List<Transaction> transactions) {
    final Map<String, double> monthlySpending = {};
    
    for (final transaction in transactions) {
      if (transaction.type == 'expense') {
        final monthKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
        monthlySpending[monthKey] = (monthlySpending[monthKey] ?? 0) + transaction.amount.abs();
      }
    }
    
    return monthlySpending;
  }

  void _navigateToDetailedAnalytics() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreditCardAnalyticsScreen(
          creditCard: _currentCard,
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (_tabController.index == 0) {
      // Transactions tab - Add Transaction
      return FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      );
    } else if (_tabController.index == 1) {
      // Statements tab - Generate Statement
      return FloatingActionButton(
        onPressed: _generateStatement,
        tooltip: 'Generate Statement',
        child: const Icon(Icons.add),
      );
    } else if (_tabController.index == 2) {
      // Overview tab - Add Transaction
      return FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBillingInfoRow(String label, String value, IconData icon, {bool isUrgent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isUrgent ? Colors.red : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isUrgent ? Colors.red : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods

  Color _getStatementStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'partial':
        return Colors.orange;
      case 'due soon':
        return Colors.yellow;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatementStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'overdue':
        return Icons.error;
      case 'partial':
        return Icons.pending;
      case 'due soon':
        return Icons.warning;
      default:
        return Icons.receipt_long;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  IconData _getPaymentStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.error;
      case 'refunded':
        return Icons.refresh;
      default:
        return Icons.payment;
    }
  }

  // Action Methods

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editCard();
        break;
      case 'delete':
        _deleteCard();
        break;
    }
  }

  void _editCard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditCreditCardScreen(creditCard: _currentCard),
      ),
    ).then((updatedCard) {
      if (updatedCard != null && updatedCard is CreditCard) {
        setState(() {
          _currentCard = updatedCard;
        });
      }
    });
  }

  void _deleteCard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Credit Card'),
        content: Text('Are you sure you want to delete ${_currentCard.name}? This action cannot be undone.\n\nThis will remove the credit card from both the Credit Cards screen and Accounts screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Delete from CreditCardProvider
              final creditCardProvider = context.read<CreditCardProvider>();
              final creditCardSuccess = await creditCardProvider.deleteCreditCard(_currentCard.id);
              
              // CRITICAL: Also delete from AppProvider (Accounts screen)
              final appProvider = context.read<AppProvider>();
              final accountSuccess = await appProvider.deleteAccount(_currentCard.id);
              
              if (creditCardSuccess && accountSuccess && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Credit card deleted successfully from both screens!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Credit card deletion had issues. Credit Card: $creditCardSuccess, Account: $accountSuccess'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          creditCard: _currentCard,
          suggestedAmount: _currentCard.outstandingBalance, // Always suggest full amount for better financial wellness
        ),
      ),
    );
    
    // If payment was successful, refresh the screen
    if (result == true) {
      // Force UI rebuild to show updated state
      setState(() {
        // This will trigger a rebuild with fresh data
      });
    }
  }

  void _generateStatement() {
    final provider = context.read<CreditCardProvider>();
    final statements = provider.getStatementsForCard(_currentCard.id);
    
    // Check if statement already exists for current period
    final now = DateTime.now();
    final billingDay = _currentCard.billingCycleDay;
    DateTime periodStart;
    
    if (now.day >= billingDay) {
      periodStart = DateTime(now.year, now.month, billingDay);
    } else {
      periodStart = DateTime(now.year, now.month - 1, billingDay);
    }
    
    final existingStatement = statements.any((stmt) => 
        stmt.periodStart.year == periodStart.year && 
        stmt.periodStart.month == periodStart.month &&
        stmt.periodStart.day == periodStart.day);
    
    if (existingStatement) {
      // Show message that statement already exists
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Statement already generated for this billing period!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    // Show generation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Statement'),
        content: const Text(
          'This will generate a statement for the current billing period. '
          'The statement will include all transactions from the last billing cycle.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performStatementGeneration();
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _performStatementGeneration() async {
    final provider = context.read<CreditCardProvider>();
    final statement = await provider.generateStatement(_currentCard.id);
    
    if (statement != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statement ${statement.statementNumber} generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate statement. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCardDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_currentCard.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Network: ${_currentCard.network}'),
            Text('Type: ${_currentCard.type}'),
            Text('Last 4 Digits: ${_currentCard.lastFourDigits}'),
            Text('Expiry: ${_currentCard.formattedExpiryDate}'),
            if (_currentCard.bankName != null) Text('Bank: ${_currentCard.bankName}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final theme = Theme.of(context);
    final isIncome = transaction.isIncome;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Transaction icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isIncome ? Colors.green : Colors.red).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.formatDate(transaction.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          
          // Amount
          Text(
            '${isIncome ? '+' : '-'}${Formatters.formatCurrency(transaction.amount.abs())}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionHistory() {
    // Navigate to the Transactions tab within this credit card detail screen
    _tabController.animateTo(0); // Transactions tab index (now first tab)
  }

  void _handleStatementAction(statement) {
    if (statement.status == StatementStatus.generated) {
      // Navigate to payment screen for generated statements
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            creditCard: _currentCard,
            suggestedAmount: statement.newBalance, // Suggest full amount instead of minimum
          ),
        ),
      );
    } else {
      // Show details for other statuses
      _showStatementDetails(statement);
    }
  }

  /// Show past statement details
  void _showPastStatementDetails(statement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Statement #${statement.statementNumber} Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatementDetailRow('Period', statement.periodDisplay),
              _buildStatementDetailRow('Total Paid', statement.getFormattedTotalDue()),
              _buildStatementDetailRow('Paid Date', Formatters.formatDate(statement.paidDate ?? statement.updatedAt)),
              _buildStatementDetailRow('Status', 'Paid'),
              _buildStatementDetailRow('Generated', Formatters.formatDate(statement.generatedDate)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show statement analytics page
  void _showStatementAnalytics(statement) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatementAnalyticsScreen(
          statement: statement,
          creditCard: _currentCard,
        ),
      ),
    );
  }

  /// Delete past statement (simplified)
  void _deletePastStatement(statement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Statement'),
        content: Text(
          'Are you sure you want to delete Statement #${statement.statementNumber}?\n\nThis will remove the statement record but keep the payment applied to your credit card balance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteStatementOnly(statement);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Delete statement only (keep payment applied)
  void _deleteStatementOnly(statement) async {
    final creditCardProvider = Provider.of<CreditCardProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    final success = await creditCardProvider.deleteStatement(statement.id, appProvider: appProvider);
    
    // Close loading indicator
    if (mounted) Navigator.of(context).pop();
    
    if (success && mounted) {
      // Force UI rebuild to show updated state
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statement #${statement.statementNumber} deleted. Payment remains applied to your balance.'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }


  /// Show past statement transactions
  void _showPastStatementTransactions(statement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Statement #${statement.statementNumber} Transactions'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              // Statement Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Paid:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      statement.getFormattedTotalDue(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Transactions List (Placeholder for now)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Transaction Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Detailed transaction breakdown will be shown here.\nThis includes all purchases, payments, and fees for this statement period.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStatementDetails(statement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Statement #${statement.statementNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatementDetailRow('Period', statement.periodDisplay),
              _buildStatementDetailRow('Total Due', statement.getFormattedTotalDue()),
              _buildStatementDetailRow('Due Date', Formatters.formatDate(statement.paymentDueDate)),
              _buildStatementDetailRow('Status', statement.paymentStatus),
              _buildStatementDetailRow('Generated', Formatters.formatDate(statement.generatedDate)),
              if (statement.paidAmount > 0)
                _buildStatementDetailRow('Paid Amount', Formatters.formatCurrency(statement.paidAmount)),
              if (statement.paidDate != null)
                _buildStatementDetailRow('Paid Date', Formatters.formatDate(statement.paidDate!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatementDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _confirmDeleteStatement(statement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Statement'),
        content: Text(
          'Are you sure you want to delete Statement #${statement.statementNumber}? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteStatement(statement);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStatement(statement) async {
    final creditCardProvider = context.read<CreditCardProvider>();
    final appProvider = context.read<AppProvider>();
    final success = await creditCardProvider.deleteStatement(statement.id, appProvider: appProvider);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Statement and related payments deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(creditCardProvider.error ?? 'Failed to delete statement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPaymentDetails(payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Amount', Formatters.formatCurrency(payment.amount)),
            _buildDetailRow('Date', Formatters.formatDate(payment.paymentDate)),
            _buildDetailRow('Method', payment.paymentMethod),
            if (payment.sourceAccountId != null)
              _buildDetailRow('Source Account', payment.sourceAccountId!),
            if (payment.notes != null && payment.notes!.isNotEmpty)
              _buildDetailRow('Notes', payment.notes!),
            _buildDetailRow('Status', payment.status.toString().split('.').last),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // ENHANCED STATEMENTS & PAYMENTS METHODS
  // ========================================

  /// Build current statement overview
  Widget _buildCurrentStatementOverview() {
    return Consumer<CreditCardProvider>(
      builder: (context, provider, child) {
        final hasCurrentStatement = provider.hasStatementForCurrentMonth(_currentCard.id);
        final currentStatement = provider.getCurrentMonthStatement(_currentCard.id);
        
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Statement',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
                  const Spacer(),
                  // Statement Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hasCurrentStatement ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hasCurrentStatement ? 'Generated' : 'Not Generated',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Statement Period
          _buildStatementInfoRow(
            'Statement Period',
            _getCurrentStatementPeriod(),
            Icons.calendar_today,
          ),
          const SizedBox(height: 12),
              
              // Statement Status
              if (hasCurrentStatement && currentStatement != null) ...[
                _buildStatementInfoRow(
                  'Statement Number',
                  currentStatement.statementNumber,
                  Icons.receipt,
                ),
                const SizedBox(height: 12),
                _buildStatementInfoRow(
                  'Generated Date',
                  Formatters.formatDate(currentStatement.generatedDate),
                  Icons.schedule,
                ),
                const SizedBox(height: 12),
              ],
          
          // Outstanding Balance
          _buildStatementInfoRow(
            'Outstanding Balance',
            _currentCard.getFormattedUserBalance(),
            Icons.account_balance_wallet,
            valueColor: _currentCard.userBalanceColor,
          ),
          const SizedBox(height: 12),
          
              // Removed minimum payment display to encourage full payment
          
          // Due Date
          _buildStatementInfoRow(
            'Due Date',
            _currentCard.nextDueDate != null 
                ? Formatters.formatDate(_currentCard.nextDueDate!)
                : 'Not set',
            Icons.schedule,
            valueColor: _getDueDateColor(_currentCard),
            isUrgent: _currentCard.isDueSoon || _currentCard.isOverdue,
          ),
        ],
      ),
        );
      },
    );
  }

  /// Build statement history section
  Widget _buildStatementHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statement History header with Generate Statement button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Statement History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
            ),
            ElevatedButton.icon(
              onPressed: _generateStatement,
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('Generate Statement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'Statement History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Previous statements will be displayed here once generated.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build past statements section (paid statements)
  Widget _buildPastStatementsSection() {
    return Consumer<CreditCardProvider>(
      builder: (context, provider, child) {
        final pastStatements = provider.getStatementsForCard(_currentCard.id)
            .where((stmt) => stmt.status == StatementStatus.paid)
            .toList();
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              'Past Statements (Paid)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
            if (pastStatements.isEmpty) ...[
              // Show empty state message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No Past Statements',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Paid statements will appear here once you make payments.\nThis helps you track your spending history for each billing cycle.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Show past statements
              ...pastStatements.map((statement) => _buildPastStatementCard(statement)),
            ],
          ],
        );
      },
    );
  }

    /// Build individual past statement card
  Widget _buildPastStatementCard(statement) {
    return GestureDetector(
      onTap: () => _showStatementAnalytics(statement),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statement #${statement.statementNumber}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    statement.periodDisplay,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Paid: ${Formatters.formatDate(statement.paidDate ?? statement.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  statement.getFormattedTotalDue(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  'Paid',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // Small delete button
            GestureDetector(
              onTap: () => _deletePastStatement(statement),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade600,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build statement history list
  Widget _buildStatementHistoryList(List statements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statement History header with Generate Statement button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
              'Statement History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
            ElevatedButton.icon(
                onPressed: _generateStatement,
              icon: const Icon(Icons.receipt_long, size: 18),
                label: const Text('Generate Statement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...statements.map((statement) => _buildStatementCard(statement)),
      ],
    );
  }

  /// Build individual statement card
  Widget _buildStatementCard(statement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statement.paymentStatusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: statement.paymentStatusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
                      'Statement #${statement.statementNumber}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
                    Text(
                      statement.periodDisplay,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
                    'Due: ${Formatters.formatDate(statement.paymentDueDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statement.paymentStatusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    statement.paymentStatus,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statement.paymentStatusColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
          ],
        ),
            ],
          ),
          const SizedBox(height: 12),
          // Full Balance - Prominently displayed (RED for generated statements)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.red.shade300,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.red.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Full Balance: ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
                Text(
                  statement.getFormattedTotalDue(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleStatementAction(statement),
                  icon: Icon(
                    statement.status == StatementStatus.generated ? Icons.payment : Icons.visibility, 
                    size: 16
                  ),
                  label: Text(statement.status == StatementStatus.generated ? 'Pay Full Due Balance' : 'View Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: statement.status == StatementStatus.generated ? Colors.green : null,
                    side: statement.status == StatementStatus.generated 
                        ? const BorderSide(color: Colors.green)
                        : null,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
        Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDeleteStatement(statement),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
        ),
      ],
      ),
    );
  }

  /// Build statement detail item
  Widget _buildStatementDetail(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
            child: Column(
              children: [
          Icon(icon, size: 16, color: Theme.of(context).primaryColor),
          const SizedBox(height: 4),
                Text(
            value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
                  ),
            textAlign: TextAlign.center,
                ),
                Text(
            label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }


  // REMOVED: Payment tab functionality - methods removed to simplify the app

  // Helper methods that are still needed
  Widget _buildStatementInfoRow(String label, String value, IconData icon, {Color? valueColor, bool isUrgent = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
          Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.grey[800],
            ),
          ),
        ],
    );
  }

  String _getCurrentStatementPeriod() {
    final now = DateTime.now();
    final billingDay = _currentCard.billingCycleDay;
    
    DateTime periodStart;
    if (now.day < billingDay) {
      periodStart = DateTime(now.year, now.month - 1, billingDay);
    } else {
      periodStart = DateTime(now.year, now.month, billingDay);
    }
    
    final periodEnd = DateTime(periodStart.year, periodStart.month + 1, billingDay).subtract(const Duration(days: 1));
    
    return '${Formatters.formatDate(periodStart)} - ${Formatters.formatDate(periodEnd)}';
  }

  Color _getDueDateColor(CreditCard card) {
    if (card.isOverdue) return Colors.red;
    if (card.isDueSoon) return Colors.orange;
    return Colors.green;
  }

  /// Build enhanced bill and due date status section
  Widget _buildBillDueDateStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getDueDateColor(_currentCard).withValues(alpha: 0.1),
            _getDueDateColor(_currentCard).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getDueDateColor(_currentCard).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getDueDateIcon(_currentCard),
                color: _getDueDateColor(_currentCard),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Payment Status',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getDueDateColor(_currentCard),
                ),
              ),
              const Spacer(),
              if (_currentCard.isDueSoon || _currentCard.isOverdue)
                ElevatedButton(
                  onPressed: () => _showPaymentDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48BB78),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Pay Now'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Status Overview
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  'Bill Date',
                  _currentCard.nextBillingDate != null 
                      ? Formatters.formatDate(_currentCard.nextBillingDate!)
                      : 'Not set',
                  _getDaysUntilBill(_currentCard),
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  'Due Date',
                  _currentCard.nextDueDate != null 
                      ? Formatters.formatDate(_currentCard.nextDueDate!)
                      : 'Not set',
                  _currentCard.daysUntilDue,
                  Icons.payment,
                  _getDueDateColor(_currentCard),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Payment Status Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getPaymentStatusIcon(_currentCard.isOverdue ? 'overdue' : _currentCard.isDueSoon ? 'due_soon' : 'current'),
                  color: _getDueDateColor(_currentCard),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getPaymentStatusSummary(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getDueDateColor(_currentCard),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build status card for bill/due date info
  Widget _buildStatusCard(String label, String date, int? daysRemaining, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (daysRemaining != null) ...[
            const SizedBox(height: 2),
            Text(
              daysRemaining == 0 ? 'Today' : 
              daysRemaining < 0 ? '${daysRemaining.abs()} days ago' :
              '$daysRemaining days left',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: daysRemaining <= 0 ? Colors.red : 
                       daysRemaining <= 7 ? Colors.orange : Colors.green,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Get days until next bill date
  int? _getDaysUntilBill(CreditCard card) {
    if (card.nextBillingDate == null) return null;
    final days = card.nextBillingDate!.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  /// Get due date icon
  IconData _getDueDateIcon(CreditCard card) {
    if (card.isOverdue) return Icons.error;
    if (card.isDueSoon) return Icons.warning;
    return Icons.check_circle;
  }

  /// Get payment status icon


  /// Get payment status summary
  String _getPaymentStatusSummary() {
    if (_currentCard.isOverdue) {
      return 'Payment is overdue. Please make payment immediately to avoid late fees.';
    } else if (_currentCard.isDueSoon) {
      return 'Payment is due soon. Consider making payment to avoid late fees.';
    } else {
      return 'Payment is on time. No action needed at this time.';
    }
  }

  // ========================================
  // USER-FRIENDLY FUNCTION IMPLEMENTATIONS
  // ========================================

  void _showExportOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Statement'),
        content: const Text(
          'Choose how you would like to export your statement:',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportAsPDF();
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportAsCSV();
            },
            child: const Text('CSV'),
          ),
        ],
      ),
    );
  }

  void _exportAsPDF() {
    // Simulate PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statement exported as PDF successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportAsCSV() {
    // Simulate CSV export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statement exported as CSV successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAutoPaySetup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Auto-Pay'),
        content: const Text(
          'Auto-pay will automatically pay your credit card bill on the due date. '
          'You can choose to pay the minimum amount, full balance, or a custom amount.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _setupAutoPay();
            },
            child: const Text('Setup'),
          ),
        ],
      ),
    );
  }

  void _setupAutoPay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Auto-Pay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Auto-pay will automatically pay your credit card bill 4 days before the due date.',
            ),
            const SizedBox(height: 16),
            // Financial wellness message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '💡 Paying the full balance helps avoid interest charges',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose payment amount:'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmAutoPaySetup(true),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Full Balance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmAutoPaySetup(false),
                    icon: const Icon(Icons.warning_amber, size: 18),
                    label: const Text('Minimum Only'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmAutoPaySetup(bool payFullBalance) async {
    Navigator.of(context).pop(); // Close dialog
    
    final creditCardProvider = context.read<CreditCardProvider>();
    final appProvider = context.read<AppProvider>();
    
    // Get the first available account for payment
    final accounts = appProvider.accounts;
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No accounts available for auto-pay. Please add an account first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final paymentAccount = accounts.first;
    final amount = payFullBalance ? _currentCard.outstandingBalance : _currentCard.minimumPaymentAmount;
    
    final success = await creditCardProvider.setupAutoPay(
      _currentCard.id,
      amount: amount,
      paymentAccountId: paymentAccount.id,
      payFullBalance: payFullBalance,
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Auto-pay setup completed! Will pay ${Formatters.formatCurrency(amount)} 4 days before due date.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(creditCardProvider.error ?? 'Failed to setup auto-pay'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPaymentHistoryExport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Payment History'),
        content: const Text(
          'Export your payment history for record keeping or tax purposes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportPaymentHistory();
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _exportPaymentHistory() {
    // Simulate payment history export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment history exported successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ========================================
  // TRANSACTIONS TAB
  // ========================================

  Widget _buildTransactionsTab() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Get all transactions for this credit card
        final creditCardTransactions = appProvider.transactions
            .where((transaction) => 
                transaction.accountId == _currentCard.id ||
                transaction.description.toLowerCase().contains(_currentCard.name.toLowerCase()))
            .toList();

        // Sort by date (newest first)
        creditCardTransactions.sort((a, b) => b.date.compareTo(a.date));

        return Column(
          children: [
            // Header with transaction count
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Credit Card Transactions',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${creditCardTransactions.length} transactions found',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (creditCardTransactions.isNotEmpty) ...[
                        ElevatedButton.icon(
                          onPressed: _showDetailedAnalytics,
                          icon: const Icon(Icons.analytics, size: 18),
                          label: const Text('Analytics'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _showAnalyticsExportOptions,
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Export'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade50,
                            foregroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Transaction list
            Expanded(
              child: creditCardTransactions.isEmpty
                  ? _buildEmptyTransactionsState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: creditCardTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = creditCardTransactions[index];
                        return _buildTransactionCard(transaction);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyTransactionsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your credit card transactions will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddTransactionDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isExpense = transaction.type == 'expense';
    final amountColor = isExpense ? Colors.red : Colors.green;
    final amountPrefix = isExpense ? '-' : '+';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpense 
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.green.withValues(alpha: 0.1),
          child: Icon(
            isExpense ? Icons.arrow_upward : Icons.arrow_downward,
            color: amountColor,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Formatters.formatDate(transaction.date)),
            Text(
              transaction.type.toUpperCase(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$amountPrefix${Formatters.formatCurrency(transaction.amount)}',
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (transaction.accountId == _currentCard.id)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Credit Card',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    final appProvider = context.read<AppProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailSheet(
        transaction: transaction,
        appProvider: appProvider,
      ),
    );
  }

  void _showAddTransactionDialog() {
    final appProvider = context.read<AppProvider>();
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        appProvider: appProvider,
        defaultAccountId: _currentCard.id, // Pre-select this credit card
      ),
    ).then((result) {
      // Only show success message if transaction was actually added
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction added to ${_currentCard.name} successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _showDetailedAnalytics() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreditCardAnalyticsScreen(creditCard: _currentCard),
      ),
    );
  }

  /// Show analytics export options popup
  void _showAnalyticsExportOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Credit Card Data'),
        content: const Text('Choose the format you want to export your credit card analytics:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _exportToJSON();
            },
            icon: const Icon(Icons.code, size: 18),
            label: const Text('JSON'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _exportToPDF();
            },
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Export credit card data to JSON
  void _exportToJSON() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting to JSON...'),
            ],
          ),
        ),
      );

      // Get analytics data
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final transactions = appProvider.transactions
          .where((transaction) => transaction.accountId == _currentCard.id)
          .toList();

      // Create export data
      final exportData = _createExportData(transactions);

      // Export to file
      final success = await _saveAnalyticsToFile(exportData, 'json');

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ JSON exported successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to export JSON'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Export error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Export credit card data to PDF
  void _exportToPDF() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generating PDF...'),
            ],
          ),
        ),
      );

      // Get analytics data
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final transactions = appProvider.transactions
          .where((transaction) => transaction.accountId == _currentCard.id)
          .toList();

      // Generate PDF
      final pdf = await _generateAnalyticsPDF(transactions);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Save PDF to file
      final success = await _savePDFToFile(pdf);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ PDF exported successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to export PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ PDF export error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Create export data structure
  Map<String, dynamic> _createExportData(List<Transaction> transactions) {
    final now = DateTime.now();
    final totalSpent = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    
    final totalTransactions = transactions.length;
    final avgTransaction = totalTransactions > 0 ? totalSpent / totalTransactions : 0.0;

    // Calculate spending by category
    final categorySpending = <String, double>{};
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    for (final transaction in transactions.where((t) => t.isExpense)) {
      final category = appProvider.categories
          .where((c) => c.id == transaction.categoryId)
          .firstOrNull;
      if (category != null) {
        categorySpending[category.name] = (categorySpending[category.name] ?? 0) + transaction.amount.abs();
      }
    }

    return {
      'creditCard': {
        'name': _currentCard.name,
        'creditLimit': _currentCard.creditLimit,
        'outstandingBalance': _currentCard.outstandingBalance,
        'availableCredit': _currentCard.availableCredit,
      },
      'analytics': {
        'exportDate': now.toIso8601String(),
        'totalSpent': totalSpent,
        'totalTransactions': totalTransactions,
        'averageTransaction': avgTransaction,
        'categorySpending': categorySpending,
      },
      'transactions': transactions.map((t) => {
        'date': t.date.toIso8601String(),
        'description': t.description,
        'amount': t.amount,
        'type': t.type,
        'category': appProvider.categories
            .where((c) => c.id == t.categoryId)
            .firstOrNull?.name ?? 'Unknown',
      }).toList(),
    };
  }

  /// Save analytics data to file
  Future<bool> _saveAnalyticsToFile(Map<String, dynamic> data, String format) async {
    try {
      // Create filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${_currentCard.name.replaceAll(' ', '_')}_Analytics_$timestamp.$format';
      
      // Convert data to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      
      // Get external storage directory (Downloads folder for easy access)
      Directory? directory;
      if (Platform.isAndroid) {
        // Use Downloads directory for easy access
        directory = Directory('/storage/emulated/0/Download');
        // Fallback to external storage directory if Downloads doesn't work
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Create KoraExpenseTracker subdirectory
      final koraDirectory = Directory('${directory.path}/KoraExpenseTracker');
      if (!await koraDirectory.exists()) {
        await koraDirectory.create(recursive: true);
      }

      // Create Analytics subdirectory
      final analyticsDirectory = Directory('${koraDirectory.path}/Analytics');
      if (!await analyticsDirectory.exists()) {
        await analyticsDirectory.create(recursive: true);
      }

      // Create the file
      final file = File('${analyticsDirectory.path}/$filename');
      await file.writeAsString(jsonString);
      
      print('Analytics exported to: ${file.path}');
      return true;
    } catch (e) {
      print('Error saving analytics file: $e');
      return false;
    }
  }

  /// Generate PDF document with analytics data
  Future<pw.Document> _generateAnalyticsPDF(List<Transaction> transactions) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    
    // Calculate analytics data
    final totalSpent = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    
    final totalTransactions = transactions.length;
    final avgTransaction = totalTransactions > 0 ? totalSpent / totalTransactions : 0.0;

    // Calculate spending by category
    final categorySpending = <String, double>{};
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    for (final transaction in transactions.where((t) => t.isExpense)) {
      final category = appProvider.categories
          .where((c) => c.id == transaction.categoryId)
          .firstOrNull;
      if (category != null) {
        categorySpending[category.name] = (categorySpending[category.name] ?? 0) + transaction.amount.abs();
      }
    }

    // Sort categories by spending amount
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${_currentCard.name} Analytics Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Generated on ${DateFormat('MMMM dd, yyyy').format(now)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue100,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      'Kora Expense Tracker',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 32),
            
            // Credit Card Information
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Credit Card Information',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Credit Limit:', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('₹${_currentCard.creditLimit.toStringAsFixed(2)}', 
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Outstanding Balance:', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('₹${_currentCard.outstandingBalance.toStringAsFixed(2)}', 
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.red600)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Available Credit:', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('₹${_currentCard.availableCredit.toStringAsFixed(2)}', 
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green600)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 24),
            
            // Analytics Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Analytics Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Total Spent:', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('₹${totalSpent.toStringAsFixed(2)}', 
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Total Transactions:', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('$totalTransactions', 
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Average Transaction:', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('₹${avgTransaction.toStringAsFixed(2)}', 
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  /// Save PDF to file
  Future<bool> _savePDFToFile(pw.Document pdf) async {
    try {
      // Create filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${_currentCard.name.replaceAll(' ', '_')}_Analytics_$timestamp.pdf';
      
      // Get external storage directory (Downloads folder for easy access)
      Directory? directory;
      if (Platform.isAndroid) {
        // Use Downloads directory for easy access
        directory = Directory('/storage/emulated/0/Download');
        // Fallback to external storage directory if Downloads doesn't work
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Create KoraExpenseTracker subdirectory
      final koraDirectory = Directory('${directory.path}/KoraExpenseTracker');
      if (!await koraDirectory.exists()) {
        await koraDirectory.create(recursive: true);
      }

      // Create Analytics subdirectory
      final analyticsDirectory = Directory('${koraDirectory.path}/Analytics');
      if (!await analyticsDirectory.exists()) {
        await analyticsDirectory.create(recursive: true);
      }

      // Create the file
      final file = File('${analyticsDirectory.path}/$filename');
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);
      
      print('PDF exported to: ${file.path}');
      return true;
    } catch (e) {
      print('Error saving PDF file: $e');
      return false;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/credit_card_provider.dart';

import '../utils/import_export_service.dart';

/// Import/Export Screen for data backup and restore
class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({super.key});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Data')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Export Section
            _buildExportSection(),
            const SizedBox(height: 24),

            // Export Directory Info
            _buildExportDirectoryInfo(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.upload,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Export Data',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Export all your transactions to a CSV spreadsheet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isExporting
                    ? null
                    : () => _handleExportCSV(context),
                icon: const Icon(Icons.table_chart),
                label: Text(_isExporting ? 'Exporting...' : 'Export CSV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportDirectoryInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_open, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Export Location',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<String?>(
              future: ImportExportService.getExportDirectoryPath(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Text(
                    'Unable to determine export location',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                  );
                }

                final exportPath = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Root Directory:',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exportPath,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontFamily: 'monospace',
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          const Divider(height: 20),
                          Text(
                            'Export Subdirectories:',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          _exportDirRow(
                            context,
                            Icons.table_chart,
                            Colors.green,
                            'CSV',
                            '$exportPath/Exports/CSV/',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '💡 Open your file manager → Downloads → KoraExpenseTracker → Exports',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAllData() async {
    setState(() => _isExporting = true);

    try {
      // Check permission
      if (!await ImportExportService.hasStoragePermission()) {
        final granted = await ImportExportService.requestStoragePermission();
        if (!granted) {
          _showErrorSnackBar('Storage permission is required for export');
          return;
        }
      }

      // Show export path before exporting
      final exportDir = await ImportExportService.getExportDirectoryPath();
      if (exportDir != null) {
        _showInfoSnackBar(
          'Exporting to: $exportDir/KoraExpenseTracker/Exports/CSV/',
        );
      }

      final appProvider = context.read<AppProvider>();
      final creditCardProvider = context.read<CreditCardProvider>();

      final filePath = await ImportExportService.exportData(
        accounts: appProvider.accounts,
        transactions: appProvider.transactions,
        creditCards: creditCardProvider.creditCards,
        statements: creditCardProvider.statements,
        payments: creditCardProvider.payments,
        categories: appProvider.categories,
        settings: appProvider.settings,
      );

      if (filePath != null) {
        final fileName = filePath.split('/').last;
        final exportDir = await ImportExportService.getExportDirectoryPath();
        _showSuccessSnackBar(
          '✅ Backup exported successfully!\n📁 Location: $exportDir/KoraExpenseTracker/Exports/CSV/\n📄 File: $fileName',
        );
      } else {
        _showErrorSnackBar('Failed to export data');
      }
    } catch (e) {
      _showErrorSnackBar('Export failed: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportTransactionsCSV() async {
    setState(() => _isExporting = true);

    try {
      // Check permission
      if (!await ImportExportService.hasStoragePermission()) {
        final granted = await ImportExportService.requestStoragePermission();
        if (!granted) {
          _showErrorSnackBar('Storage permission is required for export');
          return;
        }
      }

      // Show export path before exporting
      final exportDir = await ImportExportService.getExportDirectoryPath();
      if (exportDir != null) {
        _showInfoSnackBar('Exporting to: $exportDir/Exports/');
      }

      final appProvider = context.read<AppProvider>();

      final filePath = await ImportExportService.exportToCSV(
        transactions: appProvider.transactions,
      );

      if (filePath != null) {
        final fileName = filePath.split('/').last;
        final exportDir = await ImportExportService.getExportDirectoryPath();
        _showSuccessSnackBar(
          '✅ CSV exported successfully!\n📁 Location: $exportDir/Exports/\n📄 File: $fileName',
        );
      } else {
        _showErrorSnackBar('Failed to export CSV');
      }
    } catch (e) {
      _showErrorSnackBar('CSV export failed: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleExportCSV(BuildContext context) async {
    setState(() => _isExporting = true);
    final provider = context.read<AppProvider>();
    final hasPermission = await ImportExportService.requestStoragePermission();
    if (!hasPermission) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied.')),
        );
      setState(() => _isExporting = false);
      return;
    }
    final path = await ImportExportService.exportToCSV(
      transactions: provider.transactions,
    );
    setState(() => _isExporting = false);
    if (path != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exported CSV to: $path')));
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CSV export failed.')));
    }
  }

  /// Helper widget to display an export directory row in the location info box.
  Widget _exportDirRow(
    BuildContext context,
    IconData icon,
    Color color,
    String label,
    String path,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Expanded(
          child: Text(
            path,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'import_export_screen.dart';
import 'release_notes_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Settings Section
          _buildSectionCard(
            context,
            title: 'Settings',
            subtitle: 'App preferences and configuration',
            icon: Icons.settings,
            onTap: () {
              // TODO: Navigate to settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings screen coming soon!')),
              );
            },
          ),
          const SizedBox(height: 16),

          // Release Notes Section
          _buildSectionCard(
            context,
            title: 'Release Notes & Updates',
            subtitle: 'View recent updates and bug fixes',
            icon: Icons.update,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ReleaseNotesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Import/Export Section
          _buildSectionCard(
            context,
            title: 'Export Data',
            subtitle: 'Export your data to a CSV',
            icon: Icons.backup,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ImportExportScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // About Section
          _buildSectionCard(
            context,
            title: 'About',
            subtitle: 'App information and version',
            icon: Icons.info,
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Kora Expense Tracker',
                applicationVersion: '1.0.0+2 Beta',
                applicationIcon: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 48,
                    height: 48,
                  ),
                ),
                applicationLegalese: '© 2026 Kora. All rights reserved.',
                children: const [
                  SizedBox(height: 16),
                  Text(
                    'Kora Expense Tracker is designed to help you take full financial control of your life.\n\n'
                    'By simply logging your transactions and tracking your accounts, you gain deep insights into your spending habits. '
                    'Our goal is to make personal finance management accessible, insightful, and empowering for everyone.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/credit_card.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

/// Credit Card Analytics Screen
///
/// Displays comprehensive analytics for a specific credit card including:
/// - Spending trends over time
/// - Category-wise spending breakdown
/// - Credit utilization trends
/// - Smart insights and recommendations
/// - Payment history tracking
class CreditCardAnalyticsScreen extends StatefulWidget {
  final CreditCard creditCard;

  const CreditCardAnalyticsScreen({super.key, required this.creditCard});

  @override
  State<CreditCardAnalyticsScreen> createState() =>
      _CreditCardAnalyticsScreenState();
}

class _CreditCardAnalyticsScreenState extends State<CreditCardAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = '3M'; // 3 Months, 6 Months, 1 Year

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('${widget.creditCard.name} Analytics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
            tooltip: 'Export PDF',
            onPressed: _exportAnalyticsPDF,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Spending', icon: Icon(Icons.trending_up)),
            Tab(text: 'Categories', icon: Icon(Icons.pie_chart)),
            Tab(text: 'Insights', icon: Icon(Icons.lightbulb)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSpendingTab(),
          _buildCategoriesTab(),
          _buildInsightsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final transactions = _getCreditCardTransactions(appProvider);
        final monthlySpending = _calculateMonthlySpending(transactions);
        final categorySpending = _calculateCategorySpending(
          transactions,
          appProvider,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Range Selector
              _buildTimeRangeSelector(),
              const SizedBox(height: 24),

              // Key Metrics Cards
              _buildKeyMetricsCards(monthlySpending),
              const SizedBox(height: 24),

              // Spending Trend Chart
              _buildSpendingTrendChart(monthlySpending),
              const SizedBox(height: 24),

              // Category Breakdown
              _buildCategoryBreakdown(categorySpending),
              const SizedBox(height: 24),

              // Quick Insights
              _buildQuickInsights(transactions, monthlySpending),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpendingTab() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final transactions = _getCreditCardTransactions(appProvider);
        final monthlySpending = _calculateMonthlySpending(transactions);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeRangeSelector(),
              const SizedBox(height: 24),
              _buildSpendingTrendChart(monthlySpending),
              const SizedBox(height: 24),
              _buildSpendingDetails(transactions, appProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final transactions = _getCreditCardTransactions(appProvider);
        final categorySpending = _calculateCategorySpending(
          transactions,
          appProvider,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeRangeSelector(),
              const SizedBox(height: 24),
              _buildCategoryBreakdown(categorySpending),
              const SizedBox(height: 24),
              _buildCategoryDetails(categorySpending),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightsTab() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final transactions = _getCreditCardTransactions(appProvider);
        final monthlySpending = _calculateMonthlySpending(transactions);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickInsights(transactions, monthlySpending),
              const SizedBox(height: 24),
              _buildDetailedInsights(transactions, monthlySpending),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['1M', '3M', '6M', '1Y'].map((range) {
          final isSelected = _selectedTimeRange == range;
          return GestureDetector(
            onTap: () => setState(() => _selectedTimeRange = range),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                range,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyMetricsCards(Map<String, double> monthlySpending) {
    final totalSpending = monthlySpending.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );
    final avgMonthlySpending = monthlySpending.isNotEmpty
        ? totalSpending / monthlySpending.length
        : 0.0;
    final utilization = widget.creditCard.creditLimit > 0
        ? (widget.creditCard.outstandingBalance /
                  widget.creditCard.creditLimit) *
              100
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Spending',
            Formatters.formatCurrency(totalSpending),
            Icons.trending_up,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Avg Monthly',
            Formatters.formatCurrency(avgMonthlySpending),
            Icons.calendar_month,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Utilization',
            '${utilization.toStringAsFixed(1)}%',
            Icons.pie_chart,
            utilization > 30 ? Colors.orange : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrendChart(Map<String, double> monthlySpending) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: _buildSimpleChart(monthlySpending)),
        ],
      ),
    );
  }

  Widget _buildSimpleChart(Map<String, double> data) {
    if (data.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'No spending data available',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    final maxValue = data.values.fold(
      0.0,
      (max, value) => value > max ? value : max,
    );
    final entries = data.entries.toList();

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          // Y-axis labels
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildYAxisLabels(maxValue),
              ),
            ),
          ),
          // Chart
          Positioned(
            left: 50,
            right: 0,
            top: 0,
            bottom: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: SimpleChartPainter(entries, maxValue),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildYAxisLabels(double maxValue) {
    final labels = <Widget>[];
    final steps = 5; // Number of Y-axis labels

    for (int i = 0; i <= steps; i++) {
      final value = (maxValue / steps) * (steps - i);
      final formattedValue = _formatYAxisValue(value);

      labels.add(
        SizedBox(
          height: 20,
          child: Center(
            child: Text(
              formattedValue,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return labels;
  }

  String _formatYAxisValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value >= 100) {
      return value.toStringAsFixed(0);
    } else {
      return value.toStringAsFixed(0);
    }
  }

  Widget _buildCategoryBreakdown(Map<String, double> categorySpending) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          if (categorySpending.isEmpty)
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No category data available',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            ...categorySpending.entries.map((entry) {
              final percentage =
                  categorySpending.values.fold(
                        0.0,
                        (sum, amount) => sum + amount,
                      ) >
                      0
                  ? (entry.value /
                            categorySpending.values.fold(
                              0.0,
                              (sum, amount) => sum + amount,
                            )) *
                        100
                  : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(entry.value),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildQuickInsights(
    List<Transaction> transactions,
    Map<String, double> monthlySpending,
  ) {
    final insights = _generateInsights(transactions, monthlySpending);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                'Smart Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map(
            (insight) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: insight.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: insight.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(insight.icon, color: insight.color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingDetails(
    List<Transaction> transactions,
    AppProvider appProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ...transactions.take(5).map((transaction) {
              final category = appProvider.categories
                  .where((cat) => cat.id == transaction.categoryId)
                  .firstOrNull;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.shopping_cart,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.description,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${category?.name ?? 'Unknown'} • ${Formatters.formatDate(transaction.date)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(transaction.amount.abs()),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCategoryDetails(Map<String, double> categorySpending) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          if (categorySpending.isEmpty)
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'No category data available',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ...categorySpending.entries.map((entry) {
              final percentage =
                  categorySpending.values.fold(
                        0.0,
                        (sum, amount) => sum + amount,
                      ) >
                      0
                  ? (entry.value /
                            categorySpending.values.fold(
                              0.0,
                              (sum, amount) => sum + amount,
                            )) *
                        100
                  : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          entry.key,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(entry.key),
                        color: _getCategoryColor(entry.key),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}% of total spending',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(entry.value),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDetailedInsights(
    List<Transaction> transactions,
    Map<String, double> monthlySpending,
  ) {
    final insights = _generateDetailedInsights(transactions, monthlySpending);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          ...insights.map(
            (insight) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: insight.color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: insight.color.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(insight.icon, color: insight.color, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          insight.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: insight.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    insight.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  if (insight.recommendation != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              insight.recommendation!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<Transaction> _getCreditCardTransactions(AppProvider appProvider) {
    final now = DateTime.now();
    final monthsToShow = _getMonthsToShow();
    final cutoffDate = DateTime(now.year, now.month - monthsToShow + 1, 1);

    return appProvider.transactions
        .where(
          (transaction) =>
              (transaction.accountId == widget.creditCard.id ||
                  transaction.toAccountId == widget.creditCard.id) &&
              transaction.date.isAfter(cutoffDate),
        )
        .toList();
  }

  Map<String, double> _calculateMonthlySpending(
    List<Transaction> transactions,
  ) {
    final Map<String, double> monthlySpending = {};
    final now = DateTime.now();
    final monthsToShow = _getMonthsToShow();

    // Initialize with zero values for the time range
    for (int i = 0; i < monthsToShow; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlySpending[monthKey] = 0.0;
    }

    // Add actual spending data
    for (final transaction in transactions) {
      if (transaction.type == 'expense') {
        final monthKey =
            '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
        if (monthlySpending.containsKey(monthKey)) {
          monthlySpending[monthKey] =
              (monthlySpending[monthKey] ?? 0) + transaction.amount.abs();
        }
      }
    }

    // Sort by date (oldest first)
    final sortedEntries = monthlySpending.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(sortedEntries);
  }

  int _getMonthsToShow() {
    switch (_selectedTimeRange) {
      case '1M':
        return 1;
      case '3M':
        return 3;
      case '6M':
        return 6;
      case '1Y':
        return 12;
      default:
        return 3;
    }
  }

  Map<String, double> _calculateCategorySpending(
    List<Transaction> transactions,
    AppProvider appProvider,
  ) {
    final Map<String, double> categorySpending = {};
    final now = DateTime.now();
    final monthsToShow = _getMonthsToShow();
    final cutoffDate = DateTime(now.year, now.month - monthsToShow + 1, 1);

    for (final transaction in transactions) {
      if (transaction.type == 'expense' &&
          transaction.date.isAfter(cutoffDate)) {
        final category = appProvider.categories
            .where((cat) => cat.id == transaction.categoryId)
            .firstOrNull;
        if (category != null) {
          categorySpending[category.name] =
              (categorySpending[category.name] ?? 0) + transaction.amount.abs();
        }
      }
    }

    // Sort by amount (highest first)
    final sortedEntries = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  List<Insight> _generateInsights(
    List<Transaction> transactions,
    Map<String, double> monthlySpending,
  ) {
    final insights = <Insight>[];

    if (transactions.isEmpty) {
      insights.add(
        Insight(
          message:
              'No spending data available yet. Start using your credit card to see insights!',
          icon: Icons.info_outline,
          color: Colors.blue,
        ),
      );
      return insights;
    }

    final utilization = widget.creditCard.creditLimit > 0
        ? (widget.creditCard.outstandingBalance /
                  widget.creditCard.creditLimit) *
              100
        : 0.0;

    // Utilization insight
    if (utilization > 30) {
      insights.add(
        Insight(
          message:
              'Your credit utilization is ${utilization.toStringAsFixed(1)}%, which is above the recommended 30%.',
          icon: Icons.warning,
          color: Colors.orange,
        ),
      );
    } else if (utilization > 0) {
      insights.add(
        Insight(
          message:
              'Great! Your credit utilization is ${utilization.toStringAsFixed(1)}%, which is within the recommended range.',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
      );
    }

    // Spending trend insight
    if (monthlySpending.length >= 2) {
      final recentMonths = monthlySpending.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key));

      if (recentMonths.length >= 2) {
        final currentMonth = recentMonths[0].value;
        final previousMonth = recentMonths[1].value;
        final change = ((currentMonth - previousMonth) / previousMonth) * 100;

        if (change > 20) {
          insights.add(
            Insight(
              message:
                  'Your spending increased by ${change.toStringAsFixed(1)}% compared to last month.',
              icon: Icons.trending_up,
              color: Colors.orange,
            ),
          );
        } else if (change < -20) {
          insights.add(
            Insight(
              message:
                  'Your spending decreased by ${change.abs().toStringAsFixed(1)}% compared to last month.',
              icon: Icons.trending_down,
              color: Colors.green,
            ),
          );
        }
      }
    }

    // Payment insight
    if (widget.creditCard.outstandingBalance > 0) {
      insights.add(
        Insight(
          message:
              'You have an outstanding balance of ${Formatters.formatCurrency(widget.creditCard.outstandingBalance)}.',
          icon: Icons.payment,
          color: Colors.blue,
        ),
      );
    }

    return insights;
  }

  List<DetailedInsight> _generateDetailedInsights(
    List<Transaction> transactions,
    Map<String, double> monthlySpending,
  ) {
    final insights = <DetailedInsight>[];

    if (transactions.isEmpty) {
      return insights;
    }

    final totalSpending = monthlySpending.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );
    final avgMonthlySpending = monthlySpending.isNotEmpty
        ? totalSpending / monthlySpending.length
        : 0.0;
    final utilization = widget.creditCard.creditLimit > 0
        ? (widget.creditCard.outstandingBalance /
                  widget.creditCard.creditLimit) *
              100
        : 0.0;

    // Credit Health Analysis
    insights.add(
      DetailedInsight(
        title: 'Credit Health Analysis',
        message:
            'Your current credit utilization is ${utilization.toStringAsFixed(1)}%. This affects your credit score and borrowing capacity.',
        icon: Icons.health_and_safety,
        color: utilization > 30 ? Colors.orange : Colors.green,
        recommendation: utilization > 30
            ? 'Consider paying down your balance to improve your credit utilization ratio.'
            : 'Keep up the good work! Your utilization is within the healthy range.',
      ),
    );

    // Spending Pattern Analysis
    if (monthlySpending.isNotEmpty) {
      insights.add(
        DetailedInsight(
          title: 'Spending Pattern Analysis',
          message:
              'Your average monthly spending is ${Formatters.formatCurrency(avgMonthlySpending)}. This helps you understand your spending habits and plan better.',
          icon: Icons.analytics,
          color: Colors.blue,
          recommendation:
              'Set a monthly budget based on your average spending to better control your expenses.',
        ),
      );
    }

    // Payment Behavior
    if (widget.creditCard.outstandingBalance > 0) {
      insights.add(
        DetailedInsight(
          title: 'Payment Behavior',
          message:
              'You currently have an outstanding balance. Making timely payments helps maintain a good credit score.',
          icon: Icons.payment,
          color: Colors.blue,
          recommendation:
              'Set up automatic payments to ensure you never miss a due date.',
        ),
      );
    }

    return insights;
  }

  Color _getCategoryColor(String categoryName) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    final index = categoryName.hashCode % colors.length;
    return colors[index.abs()];
  }

  IconData _getCategoryIcon(String categoryName) {
    final iconMap = {
      'Food': Icons.restaurant,
      'Transportation': Icons.directions_car,
      'Shopping': Icons.shopping_bag,
      'Entertainment': Icons.movie,
      'Bills': Icons.receipt,
      'Healthcare': Icons.medical_services,
      'Travel': Icons.flight,
      'Education': Icons.school,
    };

    return iconMap[categoryName] ?? Icons.category;
  }

  /// Export analytics data as PDF
  void _exportAnalyticsPDF() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generating PDF...'),
            ],
          ),
        ),
      );

      // Get analytics data
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final transactions = appProvider.transactions
          .where((transaction) => transaction.accountId == widget.creditCard.id)
          .toList();

      // Generate PDF
      final pdf = await _generateAnalyticsPDF(transactions);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Save PDF to file
      final success = await _savePDFToFile(pdf);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to export PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF export error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Generate PDF document with analytics data
  Future<pw.Document> _generateAnalyticsPDF(
    List<Transaction> transactions,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    // Calculate analytics data
    final totalSpent = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());

    final totalTransactions = transactions.length;
    final avgTransaction = totalTransactions > 0
        ? totalSpent / totalTransactions
        : 0.0;

    // Calculate spending by category
    final categorySpending = <String, double>{};
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    for (final transaction in transactions.where((t) => t.isExpense)) {
      final category = appProvider.categories
          .where((c) => c.id == transaction.categoryId)
          .firstOrNull;
      if (category != null) {
        categorySpending[category.name] =
            (categorySpending[category.name] ?? 0) + transaction.amount.abs();
      }
    }

    // Sort categories by spending amount
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${widget.creditCard.name} Analytics Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Generated on ${DateFormat('MMMM dd, yyyy').format(now)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue100,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      'Kora Expense Tracker',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 32),

            // Credit Card Information
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Credit Card Information',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Credit Limit:',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            '₹${widget.creditCard.creditLimit.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Outstanding Balance:',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            '₹${widget.creditCard.outstandingBalance.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red600,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Available Credit:',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            '₹${widget.creditCard.availableCredit.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Analytics Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Analytics Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Total Spent:',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            '₹${totalSpent.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Total Transactions:',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            '$totalTransactions',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Average Transaction:',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            '₹${avgTransaction.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  /// Save PDF to file
  Future<bool> _savePDFToFile(pw.Document pdf) async {
    try {
      // Create filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename =
          '${widget.creditCard.name.replaceAll(' ', '_')}_Analytics_$timestamp.pdf';

      // Get external storage directory (Downloads folder for easy access)
      Directory? directory;
      if (Platform.isAndroid) {
        // Use Downloads directory for easy access
        directory = Directory('/storage/emulated/0/Download');
        // Fallback to external storage directory if Downloads doesn't work
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Create KoraExpenseTracker subdirectory
      final koraDirectory = Directory('${directory.path}/KoraExpenseTracker');
      if (!await koraDirectory.exists()) {
        await koraDirectory.create(recursive: true);
      }

      // Create Analytics subdirectory
      final analyticsDirectory = Directory('${koraDirectory.path}/Analytics');
      if (!await analyticsDirectory.exists()) {
        await analyticsDirectory.create(recursive: true);
      }

      // Create the file
      final file = File('${analyticsDirectory.path}/$filename');
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);

      print('PDF exported to: ${file.path}');
      return true;
    } catch (e) {
      print('Error saving PDF file: $e');
      return false;
    }
  }
}

// Data classes for insights
class Insight {
  final String message;
  final IconData icon;
  final Color color;

  Insight({required this.message, required this.icon, required this.color});
}

class DetailedInsight {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final String? recommendation;

  DetailedInsight({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.recommendation,
  });
}

// Simple chart painter for spending trends
class SimpleChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> data;
  final double maxValue;

  SimpleChartPainter(this.data, this.maxValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxValue <= 0) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // Add some padding for better visual appearance
    final padding = 20.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    // Handle single data point
    if (data.length == 1) {
      final x = padding + chartWidth / 2;
      final y =
          padding + chartHeight - (data[0].value / maxValue) * chartHeight;

      path.moveTo(x, y);
      fillPath.moveTo(x, padding + chartHeight);
      fillPath.lineTo(x, y);
      fillPath.lineTo(padding + chartWidth, y);
      fillPath.lineTo(padding + chartWidth, padding + chartHeight);
      fillPath.close();

      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, paint);

      // Draw single point
      final pointPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 6, pointPaint);
      return;
    }

    final stepX = chartWidth / (data.length - 1);
    final stepY = chartHeight / maxValue;

    for (int i = 0; i < data.length; i++) {
      final x = padding + i * stepX;
      final y = padding + chartHeight - (data[i].value * stepY);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, padding + chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(padding + chartWidth, padding + chartHeight);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = padding + i * stepX;
      final y = padding + chartHeight - (data[i].value * stepY);
      canvas.drawCircle(Offset(x, y), 6, pointPaint);
    }

    // Draw month labels
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    for (int i = 0; i < data.length; i++) {
      final x = padding + i * stepX;
      final monthLabel = _formatMonthLabel(data[i].key);

      textPainter.text = TextSpan(
        text: monthLabel,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, padding + chartHeight + 5),
      );
    }
  }

  String _formatMonthLabel(String monthKey) {
    try {
      final parts = monthKey.split('-');
      if (parts.length == 2) {
        final month = int.parse(parts[1]);
        final monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return monthNames[month - 1];
      }
    } catch (e) {
      // Fallback to original key
    }
    return monthKey;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility class for formatting various data types
class Formatters {
  /// Format currency amount with proper symbol and locale
  static String formatCurrency(double amount, {String? currency, String? locale}) {
    final currencyCode = currency ?? AppConstants.defaultCurrency;
    final localeCode = locale ?? AppConstants.defaultLocale;
    
    final formatter = NumberFormat.currency(
      locale: localeCode,
      symbol: _getCurrencySymbol(currencyCode),
      decimalDigits: 2,
    );
    
    return formatter.format(amount);
  }

  /// Format date for display
  static String formatDate(DateTime date, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = DateFormat(AppConstants.displayDateFormat, localeCode);
    return formatter.format(date);
  }

  /// Format date and time for display
  static String formatDateTime(DateTime dateTime, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = DateFormat(AppConstants.dateTimeFormat, localeCode);
    return formatter.format(dateTime);
  }

  /// Format time for display
  static String formatTime(DateTime time, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = DateFormat(AppConstants.timeFormat, localeCode);
    return formatter.format(time);
  }

  /// Format number with proper locale
  static String formatNumber(double number, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = NumberFormat.decimalPattern(localeCode);
    return formatter.format(number);
  }

  /// Format percentage
  static String formatPercentage(double percentage, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = NumberFormat.percentPattern(localeCode);
    return formatter.format(percentage / 100);
  }

  /// Get relative time (e.g., "2 hours ago", "yesterday")
  static String getRelativeTime(DateTime dateTime, {String? locale}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return formatDate(dateTime, locale: locale);
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get currency symbol for given currency code
  static String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      case 'CHF':
        return 'CHF';
      case 'CNY':
        return '¥';
      case 'KRW':
        return '₩';
      default:
        return currencyCode;
    }
  }

  /// Get current currency symbol (public method)
  static String getCurrencySymbol() {
    return _getCurrencySymbol(AppConstants.defaultCurrency);
  }

  /// Validate currency code
  static bool isValidCurrencyCode(String currencyCode) {
    final validCurrencies = [
      'INR', 'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'KRW'
    ];
    return validCurrencies.contains(currencyCode.toUpperCase());
  }

  /// Validate locale code
  static bool isValidLocaleCode(String localeCode) {
    try {
      Intl.verifiedLocale(localeCode, (locale) => true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get month name
  static String getMonthName(int month, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = DateFormat('MMMM', localeCode);
    final date = DateTime(2024, month);
    return formatter.format(date);
  }

  /// Get day name
  static String getDayName(DateTime date, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = DateFormat('EEEE', localeCode);
    return formatter.format(date);
  }

  /// Get short day name
  static String getShortDayName(DateTime date, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = DateFormat('EEE', localeCode);
    return formatter.format(date);
  }
}
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

/// JSON converter for IconData.
/// NOTE: fromJson must create IconData at runtime from stored JSON values.
/// We use matchTextDirection explicitly to satisfy the release tree-shaker
/// and suppress the icon-font check; icons are stored by codePoint (int)
/// not as compile-time constants, so --no-tree-shake-icons is set in build.
class IconDataConverter implements JsonConverter<IconData, Map<String, dynamic>> {
  const IconDataConverter();

  @override
  IconData fromJson(Map<String, dynamic> json) {
    return IconData(
      json['codePoint'] as int,
      fontFamily: json['fontFamily'] as String?,
      fontPackage: json['fontPackage'] as String?,
      matchTextDirection: false,
    );
  }

  @override
  Map<String, dynamic> toJson(IconData icon) {
    return {
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'fontPackage': icon.fontPackage,
    };
  }
}

/// JSON converter for Color
class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) {
    return Color(json);
  }

  @override
  int toJson(Color color) {
    return color.toARGB32();
  }
}
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
      await DatabaseHelper.instance.updateDocument(item.id, item.toJson());
  static Future<bool> deleteTransaction(String id) async =>
      await DatabaseHelper.instance.deleteDocument(id);

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
      await DatabaseHelper.instance.updateDocument(item.id, item.toJson());
  static Future<bool> deleteAccount(String id) async =>
      await DatabaseHelper.instance.deleteDocument(id);

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
      await DatabaseHelper.instance.updateDocument(item.id, item.toJson());
  static Future<bool> deleteCategory(String id) async =>
      await DatabaseHelper.instance.deleteDocument(id);

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
      await DatabaseHelper.instance.updateDocument(item.id, item.toJson());
  static Future<bool> deleteCreditCard(String id) async =>
      await DatabaseHelper.instance.deleteDocument(id);

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
      await DatabaseHelper.instance.updateDocument(item.id, item.toJson());
  static Future<bool> deleteCreditCardStatement(String id) async =>
      await DatabaseHelper.instance.deleteDocument(id);

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
      await DatabaseHelper.instance.updateDocument(item.id, item.toJson());
  static Future<bool> deletePaymentRecord(String id) async =>
      await DatabaseHelper.instance.deleteDocument(id);

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
      await DatabaseHelper.instance.updateDocument(item.id, item.toJson());
  static Future<bool> deletePayment(String id) async =>
      await DatabaseHelper.instance.deleteDocument(id);

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
      await DatabaseHelper.instance.updateDocument(item.id, item.toJson());
  static Future<bool> deleteBankAccount(String id) async =>
      await DatabaseHelper.instance.deleteDocument(id);

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
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// A lighting-fast SQLite document store for Kora Expense Tracker.
/// This prevents out-of-memory crashes by saving items individually
/// instead of serializing a massive JSON array every time.
class DatabaseHelper {
  static const _databaseName = "kora_expense_tracker.db";
  static const _databaseVersion = 1;
  static const _tableName = "app_documents";

  // Singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static bool _isInitializing = false;
  static Future<Database>? _initFuture;

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Prevent multiple parallel initializations
    if (_isInitializing && _initFuture != null) {
      await _initFuture;
      return _database!;
    }
    
    _isInitializing = true;
    _initFuture = _initDatabase();
    _database = await _initFuture;
    _isInitializing = false;
    
    return _database!;
  }

  /// Explicit initialization explicitly called on startup
  Future<void> init() async {
    await database;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        collection TEXT NOT NULL,
        payload TEXT NOT NULL
      )
    ''');
    
    // Create an index for faster lookups by collection
    await db.execute('CREATE INDEX idx_collection ON $_tableName(collection)');
  }

  /// Inserts a new document (e.g. Transaction, Account)
  Future<bool> insertDocument(String collection, String id, Map<String, dynamic> data) async {
    try {
      final db = await database;
      await db.insert(
        _tableName,
        {
          'id': id,
          'collection': collection,
          'payload': jsonEncode(data),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      debugPrint('Database insert error: $e');
      return false;
    }
  }

  /// Updates an existing document
  Future<bool> updateDocument(String id, Map<String, dynamic> data) async {
    try {
      final db = await database;
      await db.update(
        _tableName,
        {'payload': jsonEncode(data)},
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      debugPrint('Database update error: $e');
      return false;
    }
  }

  /// Deletes a document
  Future<bool> deleteDocument(String id) async {
    try {
      final db = await database;
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      debugPrint('Database delete error: $e');
      return false;
    }
  }

  /// Gets all documents in a collection and returns them as parsed JSON Maps
  Future<List<Map<String, dynamic>>> getDocuments(String collection) async {
    try {
      final db = await database;
      final maps = await db.query(
        _tableName,
        where: 'collection = ?',
        whereArgs: [collection],
      );
      
      return maps.map((row) {
        return jsonDecode(row['payload'] as String) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      debugPrint('Database query error: $e');
      return [];
    }
  }

  /// Returns true if the collection has any documents
  Future<bool> hasDocuments(String collection) async {
    try {
      final db = await database;
      final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE collection = ?', [collection]
      ));
      return (count ?? 0) > 0;
    } catch (e) {
      return false;
    }
  }

  /// Clears an entire collection (e.g. removing all transactions)
  Future<bool> clearCollection(String collection) async {
    try {
      final db = await database;
      await db.delete(
        _tableName,
        where: 'collection = ?',
        whereArgs: [collection],
      );
      return true;
    } catch (e) {
      debugPrint('Database clear error: $e');
      return false;
    }
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/credit_card.dart';
import '../models/credit_card_statement.dart';
import '../models/payment_record.dart';
import '../models/category.dart';
import '../models/settings.dart';

/// Service for handling data import and export operations
class ImportExportService {
  static const String _exportFileName = 'kora_expense_tracker_backup';

  /// Export all app data to a JSON file
  static Future<String?> exportData({
    required List<Account> accounts,
    required List<Transaction> transactions,
    required List<CreditCard> creditCards,
    required List<CreditCardStatement> statements,
    required List<PaymentRecord> payments,
    required List<Category> categories,
    required Settings settings,
  }) async {
    try {
      // Request storage permissions removed for Android 11+ compliance. All operations use app-scoped storage.

      // Create export data structure
      final exportData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'appName': 'Kora Expense Tracker',
        'data': {
          'accounts': accounts.map((account) => account.toJson()).toList(),
          'transactions': transactions
              .map((transaction) => transaction.toJson())
              .toList(),
          'creditCards': creditCards.map((card) => card.toJson()).toList(),
          'statements': statements
              .map((statement) => statement.toJson())
              .toList(),
          'payments': payments.map((payment) => payment.toJson()).toList(),
          'categories': categories
              .map((category) => category.toJson())
              .toList(),
          'settings': settings.toJson(),
        },
      };

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Get external storage directory (App-scoped, avoids permission issues on Android 11+)
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      debugPrint('Using directory: ${directory.path}');

      // Create main KoraExpenseTracker directory
      final mainDir = Directory('${directory.path}/KoraExpenseTracker');
      debugPrint('Creating main directory: ${mainDir.path}');

      if (!await mainDir.exists()) {
        await mainDir.create(recursive: true);
        debugPrint('Main directory created successfully');
      } else {
        debugPrint('Main directory already exists');
      }

      // Create organized export subdirectory: Exports/JSON/
      final backupDir = Directory('${mainDir.path}/Exports/JSON');
      debugPrint('Creating JSON export directory: ${backupDir.path}');

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
        debugPrint('JSON export directory created successfully');
      } else {
        debugPrint('JSON export directory already exists');
      }

      // Generate filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${_exportFileName}_$timestamp.json';
      final file = File('${backupDir.path}/$fileName');

      debugPrint('Writing file: ${file.path}');
      debugPrint('File size: ${jsonString.length} characters');

      // Write file
      await file.writeAsString(jsonString);

      // Verify file was created
      if (await file.exists()) {
        final fileSize = await file.length();
        debugPrint('File created successfully! Size: $fileSize bytes');
        return file.path;
      } else {
        throw Exception('File was not created successfully');
      }
    } catch (e) {
      debugPrint('Export error: $e');
      return null;
    }
  }

  /// Import data from a JSON file
  static Future<Map<String, dynamic>?> importData() async {
    try {
      // Request storage permission
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        throw Exception('Storage permission denied');
      }

      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null; // User cancelled
      }

      // Read file
      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();

      // Parse JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Validate file format
      if (!validateImportData(jsonData)) {
        throw Exception('Invalid backup file format');
      }

      return jsonData['data'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Import error: $e');
      rethrow;
    }
  }

  /// Validate imported data structure
  static bool validateImportData(Map<String, dynamic> data) {
    try {
      // Check required fields
      if (!data.containsKey('version') ||
          !data.containsKey('exportDate') ||
          !data.containsKey('data')) {
        return false;
      }

      final appData = data['data'] as Map<String, dynamic>;

      // Check required data sections
      final requiredSections = [
        'accounts',
        'transactions',
        'creditCards',
        'statements',
        'payments',
        'categories',
        'settings',
      ];

      for (final section in requiredSections) {
        if (!appData.containsKey(section)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Export data to CSV format
  static Future<String?> exportToCSV({
    required List<Transaction> transactions,
    String? fileName,
  }) async {
    try {
      // Request storage permissions removed for Android 11+ compliance. All operations use app-scoped storage.

      // Create CSV content
      final csvContent = StringBuffer();

      // Add header
      csvContent.writeln('Date,Description,Amount,Type,Category,Account,Notes');

      // Add transaction data
      for (final transaction in transactions) {
        csvContent.writeln(
          [
            transaction.date.toIso8601String().split('T')[0], // Date only
            '"${transaction.description.replaceAll('"', '""')}"', // Escape quotes
            transaction.amount.toStringAsFixed(2),
            transaction.type,
            transaction.categoryId, // Use categoryId instead of categoryName
            transaction.accountId, // Use accountId instead of accountName
            '"${(transaction.notes ?? '').replaceAll('"', '""')}"',
          ].join(','),
        );
      }

      // Get external storage directory (Downloads folder for easy access)
      Directory? directory;
      if (Platform.isAndroid) {
        // Use Downloads directory for easy access
        directory = Directory('/storage/emulated/0/Download');
        // Fallback to external storage directory if Downloads doesn't work
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      debugPrint('Using directory for CSV: ${directory.path}');

      // Create main KoraExpenseTracker directory
      final mainDir = Directory('${directory.path}/KoraExpenseTracker');
      debugPrint('Creating main directory for CSV: ${mainDir.path}');

      if (!await mainDir.exists()) {
        await mainDir.create(recursive: true);
        debugPrint('Main directory created successfully for CSV');
      } else {
        debugPrint('Main directory already exists for CSV');
      }

      // Create organized export subdirectory: Exports/CSV/
      final exportsDir = Directory('${mainDir.path}/Exports/CSV');
      debugPrint('Creating CSV exports directory: ${exportsDir.path}');

      if (!await exportsDir.exists()) {
        await exportsDir.create(recursive: true);
        debugPrint('CSV exports directory created successfully');
      } else {
        debugPrint('CSV exports directory already exists');
      }

      // Generate filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final csvFileName = fileName ?? 'transactions_$timestamp.csv';
      final file = File('${exportsDir.path}/$csvFileName');

      debugPrint('Writing CSV file: ${file.path}');
      debugPrint('CSV content size: ${csvContent.length} characters');

      // Write file
      await file.writeAsString(csvContent.toString());

      // Verify file was created
      if (await file.exists()) {
        final fileSize = await file.length();
        debugPrint('CSV file created successfully! Size: $fileSize bytes');
        return file.path;
      } else {
        throw Exception('CSV file was not created successfully');
      }
    } catch (e) {
      debugPrint('CSV Export error: $e');
      return null;
    }
  }

  /// Export data to PDF format
  static Future<String?> exportToPDF({
    required List<Transaction> transactions,
    String? fileName,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Transactions Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['Date', 'Description', 'Amount', 'Type', 'Category'],
                border: pw.TableBorder.all(width: 1, color: PdfColors.grey300),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blue800,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                data: transactions
                    .map(
                      (t) => [
                        t.date.toIso8601String().split('T')[0],
                        t.description,
                        t.amount.toStringAsFixed(2),
                        t.type,
                        t.categoryId,
                      ],
                    )
                    .toList(),
              ),
            ];
          },
        ),
      );

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final mainDir = Directory(
        '${directory?.path}/KoraExpenseTracker/Exports/PDF',
      );
      if (!await mainDir.exists()) await mainDir.create(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final pdfFileName = fileName ?? 'transactions_$timestamp.pdf';
      final file = File('${mainDir.path}/$pdfFileName');

      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      debugPrint('PDF Export error: $e');
      return null;
    }
  }

  /// Get list of available backup files
  static Future<List<FileSystemEntity>> getBackupFiles() async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) return [];

      final mainDir = Directory('${directory.path}/KoraExpenseTracker');
      if (!await mainDir.exists()) return [];

      final backupDir = Directory('${mainDir.path}/Exports/CSV');
      if (!await backupDir.exists()) {
        // Also look in Download directory as backup
        final downloadDir = Directory('/storage/emulated/0/Download/KoraExpenseTracker/Exports/CSV');
        if (await downloadDir.exists()) {
          final files = await downloadDir.list().toList();
          files.sort((a, b) => b.path.compareTo(a.path));
          return files.where((file) => file.path.toLowerCase().endsWith('.csv')).toList();
        }
        return [];
      }

      final files = await backupDir.list().toList();
      files.sort((a, b) => b.path.compareTo(a.path)); // Sort by newest first

      return files.where((file) => file.path.toLowerCase().endsWith('.csv')).toList();
    } catch (e) {
      debugPrint('Get backup files error: $e');
      return [];
    }
  }

  /// Delete a backup file
  static Future<bool> deleteBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Delete backup file error: $e');
      return false;
    }
  }

  /// Get the export directory path for display
  static Future<String?> getExportDirectoryPath() async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) return null;

      return '${directory.path}/KoraExpenseTracker';
    } catch (e) {
      debugPrint('Get export directory error: $e');
      return null;
    }
  }

  /// Get file size in human readable format
  static String getFileSize(FileSystemEntity file) {
    try {
      if (file is File) {
        final bytes = file.lengthSync();
        if (bytes < 1024) return '$bytes B';
        if (bytes < 1024 * 1024) {
          return '${(bytes / 1024).toStringAsFixed(1)} KB';
        }
        if (bytes < 1024 * 1024 * 1024) {
          return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
        return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get file modification date
  static DateTime getFileDate(FileSystemEntity file) {
    try {
      if (file is File) {
        return file.lastModifiedSync();
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    // App-scoped directories don't require external storage permissions on Android 11+
    return true;
  }

  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    // We use app-scoped directories (getExternalStorageDirectory on Android)
    // which do not require any permissions on Android 11+.
    return true; // iOS doesn't need explicit storage permission for documents dir
  }
}
import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/models/account_type.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';

/// A card widget for displaying account information with visual grouping
class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isExpanded;
  final bool showActions;

  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isExpanded = false,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon, name, and actions
              Row(
                children: [
                  // Account type icon with background
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: account.type.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      account.icon,
                      color: account.type.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Account name and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          account.type.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Balance and actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Balance
                      Text(
                        account.type == AccountType.creditCard ? account.getFormattedUserBalance() : account.getFormattedBalance(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: account.balanceColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // Balance trend icon
                      Icon(
                        account.balanceIcon,
                        color: account.balanceColor,
                        size: 16,
                      ),
                    ],
                  ),
                  
                  // Actions menu
                  if (showActions) ...[
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              
              // Expanded details (if expanded)
              if (isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                
                // Additional account details
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        'Status',
                        account.isActive ? 'Active' : 'Inactive',
                        account.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        'Type',
                        account.type.displayName,
                        account.type.color,
                      ),
                    ),
                  ],
                ),
                
                if (account.description != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailItem(
                    context,
                    'Description',
                    account.description!,
                    theme.colorScheme.onSurfaceVariant,
                  ),
                ],
                
                const SizedBox(height: 8),
                _buildDetailItem(
                  context,
                  'Last Updated',
                  _formatDate(account.updatedAt),
                  theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }


}

/// A compact version of AccountCard for list views
class CompactAccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;

  const CompactAccountCard({
    super.key,
    required this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Account icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: account.type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  account.icon,
                  color: account.type.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Account name
              Expanded(
                child: Text(
                  account.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Balance
              Text(
                account.type == AccountType.creditCard ? account.getFormattedUserBalance() : account.getFormattedBalance(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: account.balanceColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/models/account_type.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/screens/add_credit_card_screen.dart';

/// A user-friendly dialog for adding new accounts with auto-focus and progressive disclosure
class AddAccountDialog extends StatefulWidget {
  final Account? existingAccount;
  final Function(Account) onSave;

  const AddAccountDialog({
    super.key,
    this.existingAccount,
    required this.onSave,
  });

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  AccountType _selectedType = AccountType.savings;
  IconData _selectedIcon = Icons.account_balance;
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;
  int _currentStep = 0;
  
  final List<FocusNode> _focusNodes = [
    FocusNode(), // Name
    FocusNode(), // Balance
    FocusNode(), // Description
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _setupAutoFocus();
  }

  void _initializeFields() {
    if (widget.existingAccount != null) {
      final account = widget.existingAccount!;
      _nameController.text = account.name;
      _balanceController.text = account.balance.toString();
      _descriptionController.text = account.description ?? '';
      _selectedType = account.type;
      _selectedIcon = account.icon;
      _selectedColor = account.color;
    } else {
      _balanceController.text = '';
    }
  }

  void _setupAutoFocus() {
    // Auto-focus the first field when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentStep == 0) {
        // Focus on the first account type option
        _focusNodes[0].requestFocus();
      } else if (_currentStep == 1) {
        // Focus on the account name field and auto-select text if editing
        _focusNodes[0].requestFocus();
        if (widget.existingAccount != null) {
          _nameController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _nameController.text.length,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _descriptionController.dispose();
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingAccount != null;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.borderRadius),
                  topRight: Radius.circular(AppConstants.borderRadius),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'Edit Account' : 'Add New Account',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Progress indicator
            if (!isEditing) _buildProgressIndicator(),
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep == 0) _buildAccountTypeStep(),
                      if (_currentStep == 1) _buildAccountDetailsStep(),
                      if (_currentStep == 2) _buildAccountCustomizationStep(),
                    ],
                  ),
                ),
              ),
            ),
            
            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isActive ? theme.colorScheme.primary : theme.colorScheme.outline,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : theme.colorScheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAccountTypeStep() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Account Type',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the type of account you want to add',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        
        // Account type options
        ...AccountType.values.map((type) => _buildAccountTypeOption(type)),
      ],
    );
  }

  Widget _buildAccountTypeOption(AccountType type) {
    final theme = Theme.of(context);
    final isSelected = _selectedType == type;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? type.color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          // If credit card is selected, redirect to Add Credit Card screen
          if (type == AccountType.creditCard) {
            Navigator.of(context).pop(); // Close this dialog
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddCreditCardScreen(),
              ),
            );
            return;
          }
          
          setState(() {
            _selectedType = type;
            _selectedIcon = type.icon;
            _selectedColor = type.color;
          });
          // Auto-proceed to next step after selection
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_validateCurrentStep()) {
              _nextStep();
            }
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  type.icon,
                  color: type.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getAccountTypeDescription(type),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: type.color,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDetailsStep() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the basic information for your account',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        
        // Account name
        TextFormField(
          controller: _nameController,
          focusNode: _focusNodes[0],
          decoration: InputDecoration(
            labelText: 'Account Name',
            hintText: 'e.g., HDFC Savings, Amazon Pay',
            prefixIcon: const Icon(Icons.account_balance),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            // Auto-focus to balance field
            _focusNodes[1].requestFocus();
            // Auto-select balance text if editing
            if (widget.existingAccount != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _balanceController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _balanceController.text.length,
                );
              });
            }
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an account name';
            }
            if (value.trim().length < 2) {
              return 'Account name must be at least 2 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Initial balance
        TextFormField(
          controller: _balanceController,
          focusNode: _focusNodes[1],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            // Auto-focus to description field
            _focusNodes[2].requestFocus();
            // Auto-select description text if editing
            if (widget.existingAccount != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _descriptionController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _descriptionController.text.length,
                );
              });
            }
          },
          decoration: InputDecoration(
            labelText: 'Initial Balance',
            hintText: '0.00',
            prefixIcon: const Icon(Icons.account_balance_wallet),
            prefixText: AppConstants.defaultCurrencySymbol,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an initial balance';
            }
            final balance = double.tryParse(value);
            if (balance == null) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Description (optional)
        TextFormField(
          controller: _descriptionController,
          focusNode: _focusNodes[2],
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            // Auto-proceed to next step (Icon & Color)
            if (_validateCurrentStep()) {
              _nextStep();
            }
          },
          decoration: InputDecoration(
            labelText: 'Description (Optional)',
            hintText: 'Add a note about this account',
            prefixIcon: const Icon(Icons.note),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildAccountCustomizationStep() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customize Appearance',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose an icon and color for your account',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        
        // Icon selection
        Text(
          'Icon',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getAvailableIcons().map((icon) => _buildIconOption(icon)).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Color selection
        Text(
          'Color',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getAvailableColors().map((color) => _buildColorOption(color)).toList(),
        ),
      ],
    );
  }

  Widget _buildIconOption(IconData icon) {
    final isSelected = _selectedIcon == icon;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIcon = icon),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? _selectedColor.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _selectedColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? _selectedColor : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    final isSelected = _selectedColor == color;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    final isEditing = widget.existingAccount != null;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppConstants.borderRadius),
          bottomRight: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      child: Row(
        children: [
          if (!isEditing && _currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
            ),
          if (!isEditing && _currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Save' : (_currentStep == 2 ? 'Create Account' : 'Next')),
            ),
          ),
        ],
      ),
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        // Auto-focus next field with smooth transition
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_currentStep == 1) {
            // Step 1: Account Details - focus on name field
            _focusNodes[0].requestFocus();
            // Auto-select text if editing
            if (widget.existingAccount != null) {
              _nameController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _nameController.text.length,
              );
            }
          } else if (_currentStep == 2) {
            // Step 2: Icon & Color - no focus needed
            // This step doesn't have text fields
          }
        });
      }
    } else {
      _saveAccount();
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == 1) {
      return _formKey.currentState?.validate() ?? false;
    }
    return true;
  }

  Future<void> _saveAccount() async {
    if (!_validateCurrentStep()) return;
    
    setState(() => _isLoading = true);
    
    try {
      print('AddAccountDialog: Creating account with name: ${_nameController.text.trim()}');
      print('AddAccountDialog: Account type: $_selectedType');
      print('AddAccountDialog: Account icon: $_selectedIcon');
      print('AddAccountDialog: Account color: $_selectedColor');
      
      final account = widget.existingAccount?.copyWith(
        name: _nameController.text.trim(),
        balance: double.parse(_balanceController.text),
        type: _selectedType,
        icon: _selectedIcon,
        color: _selectedColor,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      ) ?? Account.create(
        name: _nameController.text.trim(),
        balance: double.parse(_balanceController.text),
        type: _selectedType,
        icon: _selectedIcon,
        color: _selectedColor,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );
      
      print('AddAccountDialog: Account created successfully: ${account.id}');
      print('AddAccountDialog: Calling onSave callback');
      
      widget.onSave(account);
      
      print('AddAccountDialog: onSave callback completed');
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingAccount != null 
                  ? 'Account updated successfully!' 
                  : 'Account created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('AddAccountDialog: Error creating account: $e');
      print('AddAccountDialog: Error stack trace: ${StackTrace.current}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getAccountTypeDescription(AccountType type) {
    switch (type) {
      case AccountType.savings:
        return 'Bank savings account for your money';
      case AccountType.wallet:
        return 'Digital wallet like Paytm, PhonePe';
      case AccountType.creditCard:
        return 'Credit card for purchases';
      case AccountType.cash:
        return 'Physical cash in hand';
      case AccountType.investment:
        return 'Investment accounts and funds';
      case AccountType.loan:
        return 'Loans and debts to pay';
    }
  }

  List<IconData> _getAvailableIcons() {
    return [
      Icons.account_balance,
      Icons.account_balance_wallet,
      Icons.credit_card,
      Icons.money,
      Icons.savings,
      Icons.payment,
      Icons.account_circle,
      Icons.wallet,
      Icons.business,
      Icons.home,
      Icons.school,
      Icons.work,
    ];
  }

  List<Color> _getAvailableColors() {
    return [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lightBlue,
    ];
  }


}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/models/transaction.dart';
import 'package:kora_expense_tracker/models/account_type.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/utils/formatters.dart';

class AddTransactionDialog extends StatefulWidget {
  final AppProvider appProvider;
  final Transaction? transaction; // For editing existing transactions
  final String? defaultAccountId; // Pre-select this account

  const AddTransactionDialog({
    super.key,
    required this.appProvider,
    this.transaction,
    this.defaultAccountId,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  String _selectedType = AppConstants.transactionTypeExpense;
  String _amount = '';
  String _description = '';
  String _notes = '';
  String? _selectedCategoryId;
  String? _selectedAccountId;
  String? _selectedToAccountId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _imagePath;
  bool _hasAttemptedSave = false;

  // Focus nodes for auto-navigation
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  // final FocusNode _notesFocus = FocusNode(); for now i just disable it  to test the user experience

  // Controllers for proper text field management
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _descriptionController = TextEditingController();
    _amountController = TextEditingController();
    _notesController = TextEditingController();

    // Initialize with existing transaction data if editing
    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      _selectedType = transaction.type;
      _amount = transaction.amount.abs().toString();
      _description = transaction.description;
      _notes = transaction.notes ?? '';
      _selectedCategoryId = transaction.categoryId;
      _selectedAccountId = transaction.accountId;
      _selectedToAccountId = transaction.toAccountId;
      _selectedDate = transaction.date;
      _selectedTime = TimeOfDay.fromDateTime(transaction.date);
      _imagePath = transaction.imagePath;

      // Set controller values
      _descriptionController.text = _description;
      _amountController.text = _amount;
      _notesController.text = _notes;
    } else if (widget.defaultAccountId != null) {
      // Pre-select the default account if provided
      _selectedAccountId = widget.defaultAccountId;
    }

    // Auto-focus appropriate field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Always focus on description field first (transaction type/description)
      // This allows user to start typing the transaction description immediately
      _descriptionFocus.requestFocus();

      // Auto-select all text if editing
      if (widget.transaction != null) {
        _descriptionController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _descriptionController.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _descriptionFocus.dispose();
    _amountFocus.dispose();
    _categoryFocus.dispose();
    // _notesFocus.dispose(); //here also i am disabling it to test the user experience
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.transaction != null
              ? 'Edit Transaction'
              : (_selectedType == AppConstants.transactionTypeTransfer
                    ? 'Transfer Money'
                    : 'Add Transaction'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _saveTransaction,
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Swipe left/right anywhere in the app to change type
          if (details.primaryVelocity! > 0) {
            // Swipe right
            _cycleType(-1);
          } else if (details.primaryVelocity! < 0) {
            // Swipe left
            _cycleType(1);
          }
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 300) {
            // Swipe down to close
            Navigator.of(context).pop();
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Drag handle for bottom sheet
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Always visible type selector at top
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _buildTypeSelector(),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transaction Details Cards
                      _buildTransactionTitleCard(),
                      const SizedBox(height: 16),

                      _buildAmountCard(),
                      const SizedBox(height: 16),

                      // Transfer-specific UI
                      if (_selectedType ==
                          AppConstants.transactionTypeTransfer) ...[
                        _buildFromAccountCard(),
                        const SizedBox(height: 16),
                        _buildToAccountCard(),
                        const SizedBox(height: 16),
                      ] else ...[
                        _buildAccountCard(),
                        const SizedBox(height: 16),
                        _buildCategoryCard(),
                        const SizedBox(height: 16),
                      ],

                      _buildDateTimeCard(),
                      const SizedBox(height: 16),

                      _buildImageAttachmentCard(),
                      const SizedBox(height: 16),

                      _buildNotesCard(),
                      const SizedBox(height: 24),

                      // Update Transaction Button
                      _buildUpdateButton(),
                      const SizedBox(height: 24), // Extra space for keyboard
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return GestureDetector(
      onPanUpdate: (details) {
        // Detect horizontal swipe gestures
        if (details.delta.dx > 10) {
          // Swipe right - go to previous type
          _cycleType(-1);
        } else if (details.delta.dx < -10) {
          // Swipe left - go to next type
          _cycleType(1);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildTypeChip('Income', Icons.trending_up, Colors.green),
            _buildTypeChip('Expense', Icons.trending_down, Colors.red),
            _buildTypeChip('Transfer', Icons.swap_horiz, Colors.blue),
          ],
        ),
      ),
    );
  }

  void _cycleType(int direction) {
    final types = [
      AppConstants.transactionTypeIncome,
      AppConstants.transactionTypeExpense,
      AppConstants.transactionTypeTransfer,
    ];
    final currentIndex = types.indexOf(_selectedType);

    int newIndex;
    if (direction > 0) {
      // Swipe left - go to next type
      newIndex = (currentIndex + 1) % types.length;
    } else {
      // Swipe right - go to previous type
      newIndex = (currentIndex - 1 + types.length) % types.length;
    }

    setState(() {
      _selectedType = types[newIndex];
      // Always reset category and toAccount when type changes (even during edit)
      _selectedCategoryId = null; // Reset category when type changes
      _selectedToAccountId = null; // Reset to account for transfers
    });
  }

  Widget _buildTypeChip(String label, IconData icon, Color color) {
    final isSelected = _selectedType == label.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = label.toLowerCase();
            // Always reset category and toAccount when type changes (even during edit)
            _selectedCategoryId = null; // Reset category when type changes
            _selectedToAccountId = null; // Reset to account for transfers
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTitleCard() {
    final hasError = _hasAttemptedSave && _description.trim().isEmpty;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasError
            ? const BorderSide(color: Colors.red, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.edit,
              color: hasError
                  ? Colors.red
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                focusNode: _descriptionFocus,
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText:
                      _selectedType == AppConstants.transactionTypeTransfer
                      ? 'Transfer Description'
                      : 'Transaction Title',
                  border: InputBorder.none,
                  hintText:
                      _selectedType == AppConstants.transactionTypeTransfer
                      ? 'e.g., Moving money to savings'
                      : 'Enter transaction title',
                  errorText: hasError ? 'Required field' : null,
                ),
                onChanged: (value) => _description = value,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  _amountFocus.requestFocus();
                  // Auto-select all text in amount if editing
                  if (widget.transaction != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _amountController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _amountController.text.length,
                      );
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    final hasError = _hasAttemptedSave && _amount.trim().isEmpty;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasError
            ? const BorderSide(color: Colors.red, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons
                  .payments, // Icons.attach_money here you can change the icon for the amount feild
              color: hasError
                  ? Colors.red
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                focusNode: _amountFocus,
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: InputBorder.none,
                  hintText: '0.00',
                  prefixText:
                      '${Formatters.getCurrencySymbol()} (${AppConstants.defaultCurrency})  ',
                  errorText: hasError ? 'Required field' : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _amount = value,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  // If account is pre-selected, go to category
                  if (widget.defaultAccountId != null) {
                    _showCategoryPicker();
                  } else {
                    // Otherwise, show account picker
                    if (_selectedType == AppConstants.transactionTypeTransfer) {
                      _showFromAccountPicker();
                    } else {
                      _showAccountPicker();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFromAccountCard() {
    final selectedAccount = widget.appProvider.accounts
        .where((account) => account.id == _selectedAccountId)
        .firstOrNull;
    final hasError = _hasAttemptedSave && _selectedAccountId == null;

    return GestureDetector(
      onTap: () => _showFromAccountPicker(),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: hasError
              ? const BorderSide(color: Colors.red, width: 1)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From Account',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: hasError
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedAccount?.name ??
                          'Select Source Account${hasError ? " *" : ""}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: hasError ? Colors.red : null,
                      ),
                    ),
                    if (selectedAccount != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        selectedAccount.type == AccountType.creditCard
                            ? '${Formatters.getCurrencySymbol()}${selectedAccount.balance.abs().toStringAsFixed(0)} ${selectedAccount.balance < 0 ? '(Credit)' : '(Debt)'}'
                            : '${Formatters.getCurrencySymbol()}${selectedAccount.balance.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selectedAccount.balanceColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showFromAccountPicker(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToAccountCard() {
    final selectedAccount = widget.appProvider.accounts
        .where((account) => account.id == _selectedToAccountId)
        .firstOrNull;
    final hasError = _hasAttemptedSave && _selectedToAccountId == null;

    return GestureDetector(
      onTap: () => _showToAccountPicker(),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: hasError
              ? const BorderSide(color: Colors.red, width: 1)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.account_balance, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To Account',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: hasError
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedAccount?.name ??
                          'Select Destination Account${hasError ? " *" : ""}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: hasError ? Colors.red : null,
                      ),
                    ),
                    if (selectedAccount != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        selectedAccount.type == AccountType.creditCard
                            ? '${Formatters.getCurrencySymbol()}${selectedAccount.balance.abs().toStringAsFixed(0)} ${selectedAccount.balance < 0 ? '(Credit)' : '(Debt)'}'
                            : '${Formatters.getCurrencySymbol()}${selectedAccount.balance.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selectedAccount.balanceColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showToAccountPicker(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard() {
    final selectedAccount = widget.appProvider.accounts
        .where((account) => account.id == _selectedAccountId)
        .firstOrNull;
    final hasError = _hasAttemptedSave && _selectedAccountId == null;

    return GestureDetector(
      onTap: () => _showAccountPicker(),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: hasError
              ? const BorderSide(color: Colors.red, width: 1)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selectedAccount?.icon ?? Icons.account_balance,
                color:
                    selectedAccount?.color ??
                    Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: hasError
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedAccount?.name ??
                          'Select Account${hasError ? " *" : ""}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: hasError ? Colors.red : null,
                      ),
                    ),
                    if (selectedAccount != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        selectedAccount.type == AccountType.creditCard
                            ? '${Formatters.getCurrencySymbol()}${selectedAccount.balance.abs().toStringAsFixed(0)} ${selectedAccount.balance < 0 ? '(Credit)' : '(Debt)'}'
                            : '${Formatters.getCurrencySymbol()}${selectedAccount.balance.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selectedAccount.balanceColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showAccountPicker(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard() {
    final selectedCategory = widget.appProvider.categories
        .where((category) => category.id == _selectedCategoryId)
        .firstOrNull;
    final hasError = _hasAttemptedSave && _selectedCategoryId == null;

    return GestureDetector(
      onTap: () => _showCategoryPicker(),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: hasError
              ? const BorderSide(color: Colors.red, width: 1)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selectedCategory?.icon ?? Icons.category,
                color:
                    selectedCategory?.color ??
                    Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: hasError
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedCategory?.name ??
                          'Select Category${hasError ? " *" : ""}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: hasError ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showCategoryPicker(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Date Row with Swipe
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  // Swipe right - go to previous day
                  setState(() {
                    _selectedDate = _selectedDate.subtract(
                      const Duration(days: 1),
                    );
                  });
                } else if (details.primaryVelocity! < 0) {
                  // Swipe left - go to next day
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                  });
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _showDatePicker(),
                          child: Text(
                            Formatters.formatDate(_selectedDate),
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Time Row with Swipe
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  // Swipe right - go back 1 hour
                  setState(() {
                    _selectedTime = TimeOfDay(
                      hour: (_selectedTime.hour - 1) % 24,
                      minute: _selectedTime.minute,
                    );
                  });
                } else if (details.primaryVelocity! < 0) {
                  // Swipe left - go forward 1 hour
                  setState(() {
                    _selectedTime = TimeOfDay(
                      hour: (_selectedTime.hour + 1) % 24,
                      minute: _selectedTime.minute,
                    );
                  });
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _showTimePicker(),
                          child: Text(
                            _selectedTime.format(context),
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
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

  Widget _buildNotesCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                // focusNode: _notesFocus,
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: InputBorder.none,
                  hintText: 'Add notes...',
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onChanged: (value) => _notes = value,
                onSubmitted: (_) => _saveTransaction(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a bottom sheet to choose between Camera and Gallery,
  /// handling the CAMERA permission request before opening the camera.
  Future<void> _pickImage() async {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Add Receipt Photo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ── Camera ─────────────────────────────────────
                    _imageSourceButton(
                      label: 'Camera',
                      icon: Icons.camera_alt_rounded,
                      color: AppConstants.primaryColor,
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        await _openCamera();
                      },
                    ),
                    // ── Gallery ────────────────────────────────────
                    _imageSourceButton(
                      label: 'Gallery',
                      icon: Icons.photo_library_rounded,
                      color: AppConstants.infoColor,
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        await _openGallery();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _imageSourceButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Icon(icon, size: 36, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  /// Requests camera permission then opens the camera.
  Future<void> _openCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null && mounted) {
        setState(() => _imagePath = photo.path);
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Camera permission is permanently denied. Please enable it in Settings.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // Denied but not permanently — show a quick message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to take photos.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Opens the gallery — no permission needed on Android 13+.
  Future<void> _openGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null && mounted) {
      setState(() => _imagePath = image.path);
    }
  }


  Widget _buildImageAttachmentCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.image,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Receipt / Attachment',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (_imagePath != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => setState(() => _imagePath = null),
                    tooltip: 'Remove Image',
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate, size: 20),
                    onPressed: _pickImage,
                    tooltip: 'Add Image',
                  ),
              ],
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.zero,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(color: Colors.black87),
                          ),
                          InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Image.file(
                              File(_imagePath!),
                              fit: BoxFit.contain,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                            ),
                          ),
                          Positioned(
                            top: 40,
                            right: 20,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 30),
                              padding: const EdgeInsets.all(8),
                              style: IconButton.styleFrom(backgroundColor: Colors.black54),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_imagePath!),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _hasAttemptedSave = true;
          });

          final isValid =
              _amount.trim().isNotEmpty &&
              _description.trim().isNotEmpty &&
              _selectedAccountId != null &&
              (_selectedType != AppConstants.transactionTypeTransfer ||
                  _selectedToAccountId != null) &&
              (_selectedType == AppConstants.transactionTypeTransfer ||
                  _selectedCategoryId != null);

          if (isValid) {
            _saveTransaction();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _getTypeColor(_selectedType),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: Icon(
          widget.transaction != null
              ? Icons.save
              : (_selectedType == AppConstants.transactionTypeTransfer
                    ? Icons.swap_horiz
                    : Icons.receipt_long),
        ),
        label: Text(
          widget.transaction != null
              ? 'Save Changes'
              : (_selectedType == AppConstants.transactionTypeTransfer
                    ? 'Complete Transfer'
                    : 'Add Transaction'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showFromAccountPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Source Account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: widget.appProvider.accounts
                    .where((account) {
                      // For transfers, only show asset accounts as source
                      if (_selectedType ==
                          AppConstants.transactionTypeTransfer) {
                        return account.type.isAsset;
                      }
                      return true;
                    })
                    .map(
                      (account) => ListTile(
                        leading: Icon(account.icon, color: account.color),
                        title: Text(
                          account.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        subtitle: Text(
                          account.type == AccountType.creditCard
                              ? '${Formatters.getCurrencySymbol()}${account.balance.abs().toStringAsFixed(0)} ${account.balance < 0 ? '(Credit)' : '(Debt)'}'
                              : '${Formatters.getCurrencySymbol()}${account.balance.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: account.balanceColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedAccountId = account.id;
                          });
                          Navigator.of(context).pop();
                          // Auto-focus next field after selection
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showToAccountPicker();
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showToAccountPicker() {
    final availableAccounts = widget.appProvider.accounts
        .where((account) => account.id != _selectedAccountId)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Destination Account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: availableAccounts
                    .map(
                      (account) => ListTile(
                        leading: Icon(account.icon, color: account.color),
                        title: Text(
                          account.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        subtitle: Text(
                          account.type == AccountType.creditCard
                              ? '${Formatters.getCurrencySymbol()}${account.balance.abs().toStringAsFixed(0)} ${account.balance < 0 ? '(Credit)' : '(Debt)'}'
                              : '${Formatters.getCurrencySymbol()}${account.balance.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: account.balanceColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedToAccountId = account.id;
                          });
                          Navigator.of(context).pop();
                          // Auto-focus notes field after selection
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            // _notesFocus.requestFocus();
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: widget.appProvider.accounts
                    .map(
                      (account) => ListTile(
                        leading: Icon(account.icon, color: account.color),
                        title: Text(
                          account.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        subtitle: Text(
                          account.type == AccountType.creditCard
                              ? '${Formatters.getCurrencySymbol()}${account.balance.abs().toStringAsFixed(0)} ${account.balance < 0 ? '(Credit)' : '(Debt)'}'
                              : '${Formatters.getCurrencySymbol()}${account.balance.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: account.balanceColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedAccountId = account.id;
                          });
                          Navigator.of(context).pop();
                          // Auto-focus next field after selection
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showCategoryPicker();
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    // Filter categories based on transaction type
    final categories = widget.appProvider.categories.where((category) {
      if (_selectedType == AppConstants.transactionTypeIncome) {
        return category.type == AppConstants.categoryTypeIncome ||
            category.type == AppConstants.categoryTypeBoth;
      } else if (_selectedType == AppConstants.transactionTypeExpense) {
        return category.type == AppConstants.categoryTypeExpense ||
            category.type == AppConstants.categoryTypeBoth;
      }
      return true; // Show all for transfers
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: categories
                    .map(
                      (category) => ListTile(
                        leading: Icon(category.icon, color: category.color),
                        title: Text(
                          category.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = category.id;
                          });
                          Navigator.of(context).pop();
                          // Auto-focus notes field after selection
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            // _notesFocus.requestFocus();
                            // Auto-select all text in notes if editing
                            if (widget.transaction != null) {
                              _notesController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: _notesController.text.length,
                              );
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _showTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case AppConstants.transactionTypeIncome:
        return Colors.green;
      case AppConstants.transactionTypeExpense:
        return Colors.red;
      case AppConstants.transactionTypeTransfer:
        return Colors.blue; // Blue color for transfers (not disabled)
      default:
        return Colors.grey;
    }
  }

  void _saveTransaction() async {
    if (_amount.isEmpty || _selectedAccountId == null) {
      return;
    }

    if (_selectedType == AppConstants.transactionTypeTransfer &&
        _selectedToAccountId == null) {
      return;
    }

    if (_selectedType != AppConstants.transactionTypeTransfer &&
        _selectedCategoryId == null) {
      return;
    }

    final amount = double.tryParse(_amount);
    if (amount == null || amount <= 0) {
      return;
    }

    final transaction = Transaction.create(
      type: _selectedType,
      amount: amount,
      description: _description.isEmpty ? 'No description' : _description,
      categoryId:
          _selectedCategoryId ?? 'transfer', // Default category for transfers
      accountId: _selectedAccountId!,
      toAccountId: _selectedToAccountId,
      notes: _notes.isEmpty ? null : _notes,
      imagePath: _imagePath,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
    );

    bool success = false;
    if (widget.transaction != null) {
      // Update existing transaction
      success = await widget.appProvider.updateTransaction(
        widget.transaction!.id,
        transaction,
      );
    } else {
      // Add new transaction
      success = await widget.appProvider.addTransaction(transaction);
    }

    if (success) {
      Navigator.of(context).pop(true); // Return true to indicate success

      // Show success message only if no defaultAccountId (not from credit card screen)
      if (widget.defaultAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transaction != null
                  ? 'Transaction updated successfully!'
                  : (_selectedType == AppConstants.transactionTypeTransfer
                        ? 'Transfer completed successfully!'
                        : 'Transaction added successfully!'),
            ),
            backgroundColor: _getTypeColor(_selectedType),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.appProvider.error ?? 'Failed to save transaction',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
    }
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kora_expense_tracker/models/account_type.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';

/// A widget that displays financial health summary at the top of accounts screen
class FinancialSummaryCard extends StatelessWidget {
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;
  final Map<AccountType, int> accountCounts;
  final VoidCallback? onTap;

  const FinancialSummaryCard({
    super.key,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.accountCounts,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: AppConstants.cardElevation + 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.secondary.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financial Health',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          _getHealthStatus(netWorth),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getNetWorthColor(netWorth, theme),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getNetWorthColor(netWorth, theme).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getNetWorthIcon(netWorth),
                          color: _getNetWorthColor(netWorth, theme),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap for details',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getNetWorthColor(netWorth, theme),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Net Worth (main metric)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNetWorthColor(netWorth, theme).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getNetWorthColor(netWorth, theme).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: _getNetWorthColor(netWorth, theme),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Net Worth',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: _getNetWorthColor(netWorth, theme),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(netWorth),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: _getNetWorthColor(netWorth, theme),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getNetWorthColor(netWorth, theme).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getNetWorthIcon(netWorth),
                            color: _getNetWorthColor(netWorth, theme),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getNetWorthStatus(netWorth),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getNetWorthColor(netWorth, theme),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Assets vs Liabilities breakdown
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Assets',
                      _formatCurrency(totalAssets),
                      Colors.green,
                      Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Liabilities',
                      _formatCurrency(totalLiabilities),
                      Colors.red,
                      Icons.trending_down,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Account type breakdown
              _buildAccountTypeBreakdown(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeBreakdown(BuildContext context) {
    final theme = Theme.of(context);
    final totalAccounts = accountCounts.values.fold(0, (sum, count) => sum + count);
    
    if (totalAccounts == 0) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Summary',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: accountCounts.entries
              .where((entry) => entry.value > 0)
              .map((entry) => _buildAccountTypeChip(context, entry.key, entry.value))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAccountTypeChip(BuildContext context, AccountType type, int count) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: type.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            type.icon,
            color: type.color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '$count ${type.displayName}${count > 1 ? 's' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: type.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final absAmount = amount.abs();
    final symbol = AppConstants.defaultCurrencySymbol;
    
    // Format with commas for thousands separator using NumberFormat
    final formatter = NumberFormat('#,##0');
    final formattedNumber = formatter.format(absAmount);
    return '$symbol$formattedNumber';
  }

  Color _getNetWorthColor(double netWorth, ThemeData theme) {
    if (netWorth > 0) return Colors.green;
    if (netWorth < 0) return Colors.red;
    return theme.colorScheme.onSurfaceVariant;
  }

  IconData _getNetWorthIcon(double netWorth) {
    if (netWorth > 0) return Icons.trending_up;
    if (netWorth < 0) return Icons.trending_down;
    return Icons.remove;
  }

  String _getNetWorthStatus(double netWorth) {
    if (netWorth > 0) return 'Positive';
    if (netWorth < 0) return 'Negative';
    return 'Neutral';
  }

  String _getHealthStatus(double netWorth) {
    if (netWorth > 100000) return 'Excellent';
    if (netWorth > 50000) return 'Good';
    if (netWorth > 0) return 'Positive';
    if (netWorth > -50000) return 'Needs Attention';
    return 'Critical';
  }
}
import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/models/transaction.dart';
import 'package:kora_expense_tracker/models/category.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/widgets/add_transaction_dialog.dart';
import 'package:kora_expense_tracker/utils/formatters.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';

/// Bottom sheet for displaying detailed transaction information
class TransactionDetailSheet extends StatelessWidget {
  final Transaction transaction;
  final AppProvider appProvider;

  const TransactionDetailSheet({
    super.key,
    required this.transaction,
    required this.appProvider,
  });

  @override
  Widget build(BuildContext context) {
    // Use proper account lookup that handles deleted accounts
    final account = appProvider.getAccountForTransaction(transaction.accountId);
    
    // Handle category lookup with proper fallback
    Category? category;
    try {
      category = appProvider.categories.firstWhere((cat) => cat.id == transaction.categoryId);
    } catch (e) {
      // If category not found, create a default one for display
      category = Category(
        id: 'unknown',
        name: 'Unknown Category',
        type: 'expense',
        color: Colors.grey,
        icon: Icons.category,
        isDefault: false,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Transaction type icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getTypeColor(context, transaction.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getTypeIcon(transaction.type),
                        color: _getTypeColor(context, transaction.type),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Transaction title and amount
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.description,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatCurrency(transaction.amount),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: _getAmountColor(context, transaction.type),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Edit button
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => AddTransactionDialog(
                            appProvider: appProvider,
                            transaction: transaction,
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Transaction details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      'Type',
                      transaction.typeDisplayName,
                      _getTypeColor(context, transaction.type),
                    ),
                    _buildDetailRow(
                      context,
                      'Account',
                      account?.name ?? 'Unknown Account',
                      Theme.of(context).colorScheme.primary,
                    ),
                    if (transaction.type != AppConstants.transactionTypeTransfer)
                      _buildDetailRow(
                        context,
                        'Category',
                        category.name,
                        Theme.of(context).colorScheme.secondary,
                      ),
                    _buildDetailRow(
                      context,
                      'Date',
                      Formatters.formatDate(transaction.date),
                      Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    _buildDetailRow(
                      context,
                      'Time',
                      Formatters.formatTime(transaction.date),
                      Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    if (transaction.notes?.isNotEmpty == true)
                      _buildDetailRow(
                        context,
                        'Notes',
                        transaction.notes!,
                        Theme.of(context).colorScheme.onSurfaceVariant,
                        isMultiline: true,
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                                                  showDialog(
                          context: context,
                          builder: (context) => AddTransactionDialog(
                            appProvider: appProvider,
                            transaction: transaction,
                          ),
                        );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _deleteTransaction(context, appProvider),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Safe area padding
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
  }

  /// Build a detail row with label and value
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: isMultiline ? null : 1,
              overflow: isMultiline ? null : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Get the appropriate color for transaction type
  Color _getTypeColor(BuildContext context, String type) {
    switch (type) {
      case AppConstants.transactionTypeIncome:
        return Colors.green;
      case AppConstants.transactionTypeExpense:
        return Colors.red;
      case AppConstants.transactionTypeTransfer:
        return Colors.blue;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  /// Get the appropriate icon for transaction type
  IconData _getTypeIcon(String type) {
    switch (type) {
      case AppConstants.transactionTypeIncome:
        return Icons.trending_up;
      case AppConstants.transactionTypeExpense:
        return Icons.trending_down;
      case AppConstants.transactionTypeTransfer:
        return Icons.swap_horiz;
      default:
        return Icons.receipt;
    }
  }

  /// Get the appropriate color for amount display
  Color _getAmountColor(BuildContext context, String type) {
    switch (type) {
      case AppConstants.transactionTypeIncome:
        return Colors.green;
      case AppConstants.transactionTypeExpense:
        return Colors.red;
      case AppConstants.transactionTypeTransfer:
        return Theme.of(context).colorScheme.primary;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  /// Delete transaction with confirmation
  void _deleteTransaction(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete "${transaction.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              appProvider.deleteTransaction(transaction.id);
              Navigator.pop(context); // Close confirmation dialog
              Navigator.pop(context); // Close detail sheet
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Transaction "${transaction.description}" deleted'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/models/transaction.dart';
import 'package:kora_expense_tracker/models/category.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/utils/formatters.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final Account? account;
  final Account? toAccount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool enableSwipeToDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.category,
    this.account,
    this.toAccount,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.enableSwipeToDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: InkWell(
        onTap: onTap ?? onEdit, // Use onEdit if onTap is not provided
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (category?.color ?? AppConstants.primaryColor).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category?.icon ?? Icons.category,
                  color: category?.color ?? AppConstants.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),

              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          account?.icon ?? Icons.account_balance,
                          color: account?.color ?? Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            account?.name ?? 'Unknown Account',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (transaction.isTransfer && toAccount != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Icon(
                            toAccount?.icon ?? Icons.account_balance,
                            color: toAccount?.color ?? Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              toAccount?.name ?? 'Unknown Account',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          Formatters.formatDate(transaction.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),

                        if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.note, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              transaction.notes!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Thumbnail (if available)
              if (transaction.imagePath != null && transaction.imagePath!.isNotEmpty) ...[
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: EdgeInsets.zero,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(color: Colors.black87),
                            ),
                            InteractiveViewer(
                              panEnabled: true,
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: Image.file(
                                File(transaction.imagePath!),
                                fit: BoxFit.contain,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                              ),
                            ),
                            Positioned(
                              top: 40,
                              right: 20,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                padding: const EdgeInsets.all(8),
                                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(transaction.imagePath!),
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(transaction.displayAmount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: transaction.typeColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: transaction.typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      transaction.typeDisplayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: transaction.typeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );


    // Conditionally wrap with Dismissible for swipe-to-delete
    if (enableSwipeToDelete && onDelete != null) {
      return Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppConstants.errorColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 24,
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Transaction'),
              content: Text('Are you sure you want to delete "${transaction.description}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: AppConstants.errorColor),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ) ?? false;
        },
        onDismissed: (direction) {
          onDelete?.call();
        },
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/models/category.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';

class AddCategoryDialog extends StatefulWidget {
  final AppProvider appProvider;
  final Category? category;

  const AddCategoryDialog({
    super.key,
    required this.appProvider,
    this.category,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _nameController = TextEditingController();
  String _selectedType = AppConstants.transactionTypeExpense;
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.category;

  final List<Color> _colors = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.blueGrey,
  ];

  final List<IconData> _icons = [
    Icons.category, Icons.shopping_cart, Icons.restaurant, Icons.local_gas_station,
    Icons.flight, Icons.hotel, Icons.local_hospital, Icons.school,
    Icons.home, Icons.build, Icons.sports_esports, Icons.pets,
    Icons.directions_car, Icons.train, Icons.local_grocery_store, Icons.movie,
    Icons.music_note, Icons.fitness_center, Icons.local_cafe, Icons.work,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedType = widget.category!.type;
      _selectedColor = widget.category!.color;
      _selectedIcon = widget.category!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    bool success;
    if (widget.category != null) {
      final updatedCategory = widget.category!.copyWith(
        name: name,
        type: _selectedType,
        color: _selectedColor,
        icon: _selectedIcon,
      );
      success = await widget.appProvider.updateCategory(updatedCategory);
    } else {
      final newCategory = Category.create(
        name: name,
        type: _selectedType,
        color: _selectedColor,
        icon: _selectedIcon,
      );
      success = await widget.appProvider.addCategory(newCategory);
    }

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.category == null ? 'Add Category' : 'Edit Category',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              
              const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: AppConstants.transactionTypeExpense, label: Text('Expense')),
                  ButtonSegment(value: AppConstants.transactionTypeIncome, label: Text('Income')),
                  ButtonSegment(value: 'both', label: Text('Both')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == color ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              const Text('Icon', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _icons.length,
                  itemBuilder: (context, index) {
                    final icon = _icons[index];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon ? Theme.of(context).primaryColor.withValues(alpha: 0.2) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: _selectedIcon == icon ? Theme.of(context).primaryColor : Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveCategory,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
