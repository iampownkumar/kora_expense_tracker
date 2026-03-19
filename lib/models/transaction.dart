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
