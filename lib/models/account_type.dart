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
      // For liabilities, lower balance is better (less debt)
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
        'color': Colors.blue.shade800,
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
