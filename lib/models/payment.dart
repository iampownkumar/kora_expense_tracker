import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '../utils/json_converters.dart';

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
