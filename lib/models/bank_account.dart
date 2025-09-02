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
