import 'package:flutter/foundation.dart';
import '../models/credit_card.dart';
import '../models/credit_card_statement.dart';
import '../models/payment_record.dart';
import '../utils/storage_service.dart';

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
  
  List<CreditCardStatement> get pendingStatements => _statements.where((stmt) => stmt.status == 'Pending').toList();
  
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
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete credit card: $e';
      notifyListeners();
      return false;
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
  
  /// Get payments for a specific credit card
  List<PaymentRecord> getPaymentsForCard(String creditCardId) {
    return _payments.where((payment) => payment.creditCardId == creditCardId).toList();
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
  
  /// Delete a statement
  Future<bool> deleteStatement(String statementId) async {
    try {
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
  
  /// Generate statement for a credit card
  Future<CreditCardStatement?> generateStatement(String creditCardId) async {
    try {
      final creditCard = getCreditCardById(creditCardId);
      if (creditCard == null) return null;
      
      // Check if we need to generate a new statement
      if (!_shouldGenerateStatement(creditCard)) return null;
      
      // Calculate billing period
      final billingCycleStart = creditCard.nextBillingCycleStart;
      final billingCycleEnd = creditCard.nextBillingCycleEnd;
      
      // Generate statement number
      final statementNumber = _generateStatementNumber(creditCardId);
      
      // Create new statement
      final statement = CreditCardStatement.create(
        creditCardId: creditCardId,
        statementNumber: statementNumber,
        periodStart: billingCycleStart,
        periodEnd: billingCycleEnd,
        totalDue: creditCard.outstandingBalance,
        minimumDue: creditCard.minimumPaymentAmount,
        dueDate: billingCycleEnd.add(Duration(days: creditCard.gracePeriodDays)),
        previousBalance: _getPreviousStatementBalance(creditCardId),
      );
      
      await addStatement(statement);
      
      // Update credit card's next billing date
      final updatedCard = creditCard.copyWith(
        nextBillingDate: creditCard.nextBillingCycleStart,
        nextDueDate: statement.dueDate,
      );
      await updateCreditCard(updatedCard);
      
      return statement;
    } catch (e) {
      _error = 'Failed to generate statement: $e';
      notifyListeners();
      return null;
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
    return statements.first.totalDue;
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
    String newStatus = statement.status;
    
    if (newPaidAmount >= statement.totalDue) {
      newStatus = 'Paid';
    } else if (newPaidAmount > 0) {
      newStatus = 'Partial';
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
        if (payment.paymentDate.isBefore(statement.dueDate) || 
            payment.paymentDate.isAtSameMomentAs(statement.dueDate)) {
          onTimePayments++;
        }
      }
    }
    
    return totalPayments > 0 ? (onTimePayments / totalPayments) * 100 : 0.0;
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
}
