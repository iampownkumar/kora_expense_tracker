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
    return calculated > 25.0 ? calculated : 25.0; // Minimum ₹25
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
