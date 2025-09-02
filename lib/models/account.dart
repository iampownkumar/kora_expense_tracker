import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
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

  /// Get the balance icon based on amount
  IconData get balanceIcon {
    if (balance > 0) return Icons.trending_up;
    if (balance < 0) return Icons.trending_down;
    return Icons.remove;
  }

  /// Check if this account is a liability (debt)
  bool get isLiability => type.isLiability;

  /// Check if this account is an asset
  bool get isAsset => type.isAsset;

  /// Get formatted balance with currency symbol
  String getFormattedBalance({String currencySymbol = '₹'}) {
    final absBalance = balance.abs();
    if (absBalance >= 10000000) {
      return '$currencySymbol${(absBalance / 10000000).toStringAsFixed(1)}Cr';
    } else if (absBalance >= 100000) {
      return '$currencySymbol${(absBalance / 100000).toStringAsFixed(1)}L';
    } else if (absBalance >= 1000) {
      return '$currencySymbol${(absBalance / 1000).toStringAsFixed(1)}K';
    } else {
      return '$currencySymbol${absBalance.toStringAsFixed(0)}';
    }
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
