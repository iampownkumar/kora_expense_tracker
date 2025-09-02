import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'credit_card_statement.g.dart';

/// Credit Card Statement model for managing billing statements
@JsonSerializable()
class CreditCardStatement {
  /// Unique identifier for the statement
  final String id;
  
  /// Credit card ID this statement belongs to
  final String creditCardId;
  
  /// Statement number
  final String statementNumber;
  
  /// Billing period start date
  final DateTime periodStart;
  
  /// Billing period end date
  final DateTime periodEnd;
  
  /// Total amount due
  final double totalDue;
  
  /// Minimum payment required
  final double minimumDue;
  
  /// Amount paid so far
  final double paidAmount;
  
  /// Previous statement balance
  final double? previousBalance;
  
  /// Payment due date
  final DateTime dueDate;
  
  /// Statement status (Pending, Paid, Overdue, Partial)
  final String status;
  
  /// Interest charges
  final double? interestCharges;
  
  /// Late fees
  final double? lateFees;
  
  /// Over limit fees
  final double? overLimitFees;
  
  /// Purchases during cycle
  final double? purchases;
  
  /// Cash advances during cycle
  final double? cashAdvances;
  
  /// Balance transfers during cycle
  final double? balanceTransfers;
  
  /// Fees charged during cycle
  final double? fees;
  
  /// Adjustments (credits/refunds)
  final double? adjustments;
  
  /// Payment date (when paid)
  final DateTime? paidDate;
  
  /// Statement notes
  final String? notes;
  
  /// Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreditCardStatement({
    required this.id,
    required this.creditCardId,
    required this.statementNumber,
    required this.periodStart,
    required this.periodEnd,
    required this.totalDue,
    required this.minimumDue,
    this.paidAmount = 0.0,
    this.previousBalance,
    required this.dueDate,
    this.status = 'Pending',
    this.interestCharges,
    this.lateFees,
    this.overLimitFees,
    this.purchases,
    this.cashAdvances,
    this.balanceTransfers,
    this.fees,
    this.adjustments,
    this.paidDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new CreditCardStatement with current timestamps
  factory CreditCardStatement.create({
    required String creditCardId,
    required String statementNumber,
    required DateTime periodStart,
    required DateTime periodEnd,
    required double totalDue,
    required double minimumDue,
    required DateTime dueDate,
    double paidAmount = 0.0,
    double? previousBalance,
    String status = 'Pending',
    double? interestCharges,
    double? lateFees,
    double? overLimitFees,
    double? purchases,
    double? cashAdvances,
    double? balanceTransfers,
    double? fees,
    double? adjustments,
    DateTime? paidDate,
    String? notes,
  }) {
    final now = DateTime.now();
    return CreditCardStatement(
      id: _generateId(),
      creditCardId: creditCardId,
      statementNumber: statementNumber,
      periodStart: periodStart,
      periodEnd: periodEnd,
      totalDue: totalDue,
      minimumDue: minimumDue,
      paidAmount: paidAmount,
      previousBalance: previousBalance,
      dueDate: dueDate,
      status: status,
      interestCharges: interestCharges,
      lateFees: lateFees,
      overLimitFees: overLimitFees,
      purchases: purchases,
      cashAdvances: cashAdvances,
      balanceTransfers: balanceTransfers,
      fees: fees,
      adjustments: adjustments,
      paidDate: paidDate,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a copy of this statement with updated fields
  CreditCardStatement copyWith({
    String? id,
    String? creditCardId,
    String? statementNumber,
    DateTime? periodStart,
    DateTime? periodEnd,
    double? totalDue,
    double? minimumDue,
    double? paidAmount,
    double? previousBalance,
    DateTime? dueDate,
    String? status,
    double? interestCharges,
    double? lateFees,
    double? overLimitFees,
    double? purchases,
    double? cashAdvances,
    double? balanceTransfers,
    double? fees,
    double? adjustments,
    DateTime? paidDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreditCardStatement(
      id: id ?? this.id,
      creditCardId: creditCardId ?? this.creditCardId,
      statementNumber: statementNumber ?? this.statementNumber,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      totalDue: totalDue ?? this.totalDue,
      minimumDue: minimumDue ?? this.minimumDue,
      paidAmount: paidAmount ?? this.paidAmount,
      previousBalance: previousBalance ?? this.previousBalance,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      interestCharges: interestCharges ?? this.interestCharges,
      lateFees: lateFees ?? this.lateFees,
      overLimitFees: overLimitFees ?? this.overLimitFees,
      purchases: purchases ?? this.purchases,
      cashAdvances: cashAdvances ?? this.cashAdvances,
      balanceTransfers: balanceTransfers ?? this.balanceTransfers,
      fees: fees ?? this.fees,
      adjustments: adjustments ?? this.adjustments,
      paidDate: paidDate ?? this.paidDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // ========================================
  // CALCULATIONS & UTILITIES
  // ========================================

  /// Get remaining balance
  double get remainingBalance {
    return totalDue - paidAmount;
  }

  /// Check if statement is fully paid
  bool get isFullyPaid {
    return paidAmount >= totalDue;
  }

  /// Check if statement is partially paid
  bool get isPartiallyPaid {
    return paidAmount > 0 && paidAmount < totalDue;
  }

  /// Check if statement is overdue
  bool get isOverdue {
    if (isFullyPaid) return false;
    return DateTime.now().isAfter(dueDate);
  }

  /// Check if due soon (within 7 days)
  bool get isDueSoon {
    if (isFullyPaid) return false;
    final days = dueDate.difference(DateTime.now()).inDays;
    return days >= 0 && days <= 7;
  }

  /// Get days until due date
  int? get daysUntilDue {
    if (isFullyPaid) return null;
    final days = dueDate.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  /// Get payment status for display
  String get paymentStatus {
    if (isFullyPaid) return 'Paid';
    if (isOverdue) return 'Overdue';
    if (isPartiallyPaid) return 'Partial';
    if (isDueSoon) return 'Due Soon';
    return 'Pending';
  }

  /// Get payment status color
  String get paymentStatusColor {
    if (isFullyPaid) return '#4CAF50'; // Green
    if (isOverdue) return '#F44336'; // Red
    if (isPartiallyPaid) return '#FF9800'; // Orange
    if (isDueSoon) return '#FFC107'; // Yellow
    return '#2196F3'; // Blue
  }

  /// Get statement period display
  String get periodDisplay {
    final start = DateFormat('MMM dd').format(periodStart);
    final end = DateFormat('MMM dd, yyyy').format(periodEnd);
    return '$start - $end';
  }

  /// Get due date display
  String get dueDateDisplay {
    return DateFormat('MMM dd, yyyy').format(dueDate);
  }

  /// Get payment percentage
  double get paymentPercentage {
    if (totalDue <= 0) return 0.0;
    return (paidAmount / totalDue) * 100;
  }

  /// Get statement summary
  String get summary {
    return 'Statement #$statementNumber - $periodDisplay';
  }

  /// Get formatted total due
  String getFormattedTotalDue({String currencySymbol = '₹'}) {
    final formatter = NumberFormat('#,##0.00');
    return '$currencySymbol${formatter.format(totalDue)}';
  }

  /// Get formatted minimum due
  String getFormattedMinimumDue({String currencySymbol = '₹'}) {
    final formatter = NumberFormat('#,##0.00');
    return '$currencySymbol${formatter.format(minimumDue)}';
  }

  /// Get formatted paid amount
  String getFormattedPaidAmount({String currencySymbol = '₹'}) {
    final formatter = NumberFormat('#,##0.00');
    return '$currencySymbol${formatter.format(paidAmount)}';
  }

  /// Get formatted remaining balance
  String getFormattedRemainingBalance({String currencySymbol = '₹'}) {
    final formatter = NumberFormat('#,##0.00');
    return '$currencySymbol${formatter.format(remainingBalance)}';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$CreditCardStatementToJson(this);

  /// Create from JSON
  factory CreditCardStatement.fromJson(Map<String, dynamic> json) => _$CreditCardStatementFromJson(json);

  /// Generate a unique ID for statements
  static String _generateId() {
    return 'stmt_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
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
    return 'CreditCardStatement(id: $id, cardId: $creditCardId, statementNumber: $statementNumber, totalDue: $totalDue, status: $status)';
  }
}
