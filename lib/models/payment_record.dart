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
