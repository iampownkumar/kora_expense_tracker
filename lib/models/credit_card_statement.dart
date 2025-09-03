import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '../utils/json_converters.dart';
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
}