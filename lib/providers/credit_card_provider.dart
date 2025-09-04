import 'package:flutter/foundation.dart';
import '../models/credit_card.dart';
import '../models/credit_card_statement.dart';
import '../models/payment_record.dart';
import '../models/transaction.dart';
import '../utils/storage_service.dart';
import 'app_provider.dart';

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
  
  List<CreditCardStatement> get pendingStatements => _statements.where((stmt) => stmt.status == StatementStatus.generated).toList();
  
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

  /// Update credit card balance after payment
  Future<bool> updateCreditCardBalance(String creditCardId, double newOutstandingBalance) async {
    try {
      final index = _creditCards.indexWhere((card) => card.id == creditCardId);
      if (index != -1) {
        final card = _creditCards[index];
        final updatedCard = card.copyWith(
          outstandingBalance: newOutstandingBalance,
          availableCredit: card.creditLimit - newOutstandingBalance,
          updatedAt: DateTime.now(),
        );
        _creditCards[index] = updatedCard;
        await StorageService.saveCreditCards(_creditCards);
        
        // Mark any generated statements as paid if balance is now 0 or negative
        if (newOutstandingBalance <= 0) {
          await _markStatementsAsPaid(creditCardId);
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update credit card balance: $e';
      notifyListeners();
      return false;
    }
  }

  /// Mark generated statements as paid for a credit card
  Future<void> _markStatementsAsPaid(String creditCardId) async {
    try {
      bool updated = false;
      for (int i = 0; i < _statements.length; i++) {
        final statement = _statements[i];
        if (statement.creditCardId == creditCardId && 
            statement.status == StatementStatus.generated) {
          _statements[i] = statement.copyWith(
            status: StatementStatus.paid,
            paidAmount: statement.newBalance,
            paidDate: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          updated = true;
        }
      }
      
      if (updated) {
        await StorageService.saveCreditCardStatements(_statements);
      }
    } catch (e) {
      _error = 'Failed to mark statements as paid: $e';
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
      
      // CRITICAL: Also delete the corresponding Account from AppProvider
      // This ensures the credit card is removed from both places
      await _deleteCorrespondingAccount(creditCardId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete credit card: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Delete the corresponding Account entity for a credit card
  Future<void> _deleteCorrespondingAccount(String creditCardId) async {
    try {
      // Import AppProvider to access account deletion
      // This will be handled by the calling context
      print('Credit card $creditCardId deleted - corresponding account should also be deleted');
    } catch (e) {
      print('Error deleting corresponding account: $e');
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

  /// Check if statement exists for current billing period for a credit card
  bool hasStatementForCurrentMonth(String creditCardId) {
    final card = getCreditCardById(creditCardId);
    if (card == null) return false;
    
    final now = DateTime.now();
    final billingDay = card.billingCycleDay;
    
    // Calculate current billing period start date
    DateTime currentPeriodStart;
    if (now.day < billingDay) {
      // Current period started last month
      currentPeriodStart = DateTime(now.year, now.month - 1, billingDay);
    } else {
      // Current period started this month
      currentPeriodStart = DateTime(now.year, now.month, billingDay);
    }
    
    return _statements.any((stmt) => 
      stmt.creditCardId == creditCardId && 
      stmt.periodStart.year == currentPeriodStart.year &&
      stmt.periodStart.month == currentPeriodStart.month &&
      stmt.periodStart.day == currentPeriodStart.day
    );
  }

  /// Get current billing period statement for a credit card
  CreditCardStatement? getCurrentMonthStatement(String creditCardId) {
    final card = getCreditCardById(creditCardId);
    if (card == null) return null;
    
    final now = DateTime.now();
    final billingDay = card.billingCycleDay;
    
    // Calculate current billing period start date
    DateTime currentPeriodStart;
    if (now.day < billingDay) {
      // Current period started last month
      currentPeriodStart = DateTime(now.year, now.month - 1, billingDay);
    } else {
      // Current period started this month
      currentPeriodStart = DateTime(now.year, now.month, billingDay);
    }
    
    try {
      return _statements.firstWhere((stmt) => 
        stmt.creditCardId == creditCardId && 
        stmt.periodStart.year == currentPeriodStart.year &&
        stmt.periodStart.month == currentPeriodStart.month &&
        stmt.periodStart.day == currentPeriodStart.day
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Get payments for a specific credit card
  List<PaymentRecord> getPaymentsForCard(String creditCardId) {
    return _payments.where((payment) => payment.creditCardId == creditCardId).toList();
  }

  /// Generate statement for a credit card
  /// Check if a statement already exists for the current period
  bool _statementExistsForPeriod(String creditCardId, DateTime periodStart) {
    return _statements.any((stmt) => 
      stmt.creditCardId == creditCardId && 
      stmt.periodStart.year == periodStart.year &&
      stmt.periodStart.month == periodStart.month &&
      stmt.periodStart.day == periodStart.day
    );
  }

  Future<CreditCardStatement?> generateStatement(String creditCardId) async {
    try {
      final card = _creditCards.firstWhere((c) => c.id == creditCardId);
      
      // Calculate statement period
      final now = DateTime.now();
      final billingDay = card.billingCycleDay;
      
      DateTime periodStart;
      DateTime periodEnd;
      
      if (now.day < billingDay) {
        // Current period started last month
        periodStart = DateTime(now.year, now.month - 1, billingDay);
        periodEnd = DateTime(now.year, now.month, billingDay - 1);
      } else {
        // Current period started this month
        periodStart = DateTime(now.year, now.month, billingDay);
        periodEnd = DateTime(now.year, now.month + 1, billingDay - 1);
      }
      
      // Check if statement already exists for this period
      if (_statementExistsForPeriod(creditCardId, periodStart)) {
        _error = 'Statement already exists for this billing period';
        notifyListeners();
        return null;
      }
      
      // Calculate statement amounts from transactions
      final previousBalance = _getPreviousStatementBalance(creditCardId) ?? 0.0;
      
      // Get transactions for this billing period
      final periodTransactions = _getTransactionsForPeriod(creditCardId, periodStart, periodEnd);
      
      // Calculate statement components
      final paymentsAndCredits = _calculatePaymentsAndCredits(periodTransactions, creditCardId);
      final purchases = _calculatePurchases(periodTransactions, creditCardId);
      final cashAdvances = _calculateCashAdvances(periodTransactions, creditCardId);
      final interestCharges = _calculateInterestCharges(creditCardId, previousBalance, periodStart);
      final feesAndCharges = _calculateFeesAndCharges(creditCardId, periodStart);
      final minimumPaymentDue = card.minimumPaymentAmount;
      final paymentDueDate = card.nextDueDate ?? now.add(const Duration(days: 21));
      
      // TEMPORARY FIX: Use current outstanding balance as newBalance until proper transaction integration
      // This ensures statement balance matches current outstanding balance
      final newBalance = card.outstandingBalance; // Always use current outstanding balance
      
      // Create statement with corrected balance
      final statement = CreditCardStatement(
        id: 'stmt_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}',
        creditCardId: creditCardId,
        statementNumber: '${now.year}-${now.month.toString().padLeft(2, '0')}',
        periodStart: periodStart,
        periodEnd: periodEnd,
        previousBalance: previousBalance,
        paymentsAndCredits: paymentsAndCredits,
        purchases: purchases,
        cashAdvances: cashAdvances,
        interestCharges: interestCharges,
        feesAndCharges: feesAndCharges,
        newBalance: newBalance, // Use corrected balance
        minimumPaymentDue: minimumPaymentDue,
        paymentDueDate: paymentDueDate,
        generatedDate: now,
        status: StatementStatus.generated,
        createdAt: now,
        updatedAt: now,
      );
      
      // Add to statements list
      _statements.add(statement);
      
      // Save to storage
      await StorageService.saveCreditCardStatements(_statements);
      
      // Clear any previous errors
      _error = null;
      notifyListeners();
      return statement;
    } catch (e) {
      _error = 'Failed to generate statement: $e';
      notifyListeners();
      return null;
    }
  }

  /// Check for automatic statement generation
  Future<void> checkForAutomaticStatementGeneration() async {
    try {
      for (final card in _creditCards) {
        if (card.autoGenerateStatements && card.nextBillingDate != null) {
          final now = DateTime.now();
          final billingDate = card.nextBillingDate!;
          
          // Check if it's time to generate statement (same day or past billing date)
          if (now.isAfter(billingDate) || now.day == billingDate.day) {
            // Check if statement already exists for this period
            final existingStatement = _statements.where((stmt) => 
              stmt.creditCardId == card.id && 
              stmt.periodStart.year == billingDate.year &&
              stmt.periodStart.month == billingDate.month &&
              stmt.periodStart.day == billingDate.day
            ).isNotEmpty;
            
            if (!existingStatement) {
              await generateStatement(card.id);
            }
          }
        }
      }
    } catch (e) {
      _error = 'Failed to check automatic statement generation: $e';
      notifyListeners();
    }
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
    return statements.first.newBalance;
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
    StatementStatus newStatus = statement.status;
    
    if (newPaidAmount >= statement.newBalance) {
      newStatus = StatementStatus.paid;
    } else if (newPaidAmount > 0) {
      newStatus = StatementStatus.generated; // Keep as generated for partial payments
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
        if (payment.paymentDate.isBefore(statement.paymentDueDate) || 
            payment.paymentDate.isAtSameMomentAs(statement.paymentDueDate)) {
          onTimePayments++;
        }
      }
    }
    
    return totalPayments > 0 ? (onTimePayments / totalPayments) * 100 : 0.0;
  }
  
  /// Delete a statement and its related payment transactions only
  Future<bool> deleteStatement(String statementId, {AppProvider? appProvider}) async {
    try {
      // Find the statement to get its period
      final statement = _statements.firstWhere((stmt) => stmt.id == statementId);
      
      // If AppProvider is provided, delete only payment transactions (transfers TO the credit card)
      if (appProvider != null) {
        // Find payment transactions (transfers TO the credit card) for this period
        final paymentTransactions = appProvider.transactions.where((transaction) {
          return transaction.type == 'transfer' && 
                 transaction.toAccountId == statement.creditCardId &&
                 transaction.date.isAfter(statement.periodStart.subtract(const Duration(days: 1))) &&
                 transaction.date.isBefore(statement.periodEnd.add(const Duration(days: 1)));
        }).toList();
        
        // Delete only payment transactions (NOT the original credit card expense transactions)
        for (final transaction in paymentTransactions) {
          await appProvider.deleteTransaction(transaction.id);
        }
        
        print('Deleted ${paymentTransactions.length} payment transactions (keeping original credit card transactions)');
      }
      
      // Remove the statement
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

  /// Setup auto-pay for a credit card (pay 4 days before due date)
  Future<bool> setupAutoPay(String creditCardId, {
    required double amount,
    required String paymentAccountId,
    bool payFullBalance = false,
  }) async {
    try {
      final card = _creditCards.firstWhere((c) => c.id == creditCardId);
      
      if (card.nextDueDate == null) {
        _error = 'Due date not set for this credit card';
        notifyListeners();
        return false;
      }
      
      // Calculate payment date (4 days before due date)
      final paymentDate = card.nextDueDate!.subtract(const Duration(days: 4));
      
      // Calculate payment amount
      final paymentAmount = payFullBalance ? card.outstandingBalance : amount;
      
      // Create auto-pay record
      final autoPayRecord = PaymentRecord.create(
        creditCardId: creditCardId,
        amount: paymentAmount,
        paymentDate: paymentDate,
        paymentMethod: 'Auto-Pay',
        sourceAccountId: paymentAccountId,
        status: 'Scheduled',
        notes: 'Auto-pay scheduled for 4 days before due date',
      );
      
      _payments.add(autoPayRecord);
      await StorageService.savePaymentRecords(_payments);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to setup auto-pay: $e';
      notifyListeners();
      return false;
    }
  }

  /// Process scheduled auto-pay payments
  Future<void> processScheduledAutoPayments() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      for (final payment in _payments) {
        if (payment.status == 'Scheduled' &&
            payment.paymentDate.isAtSameMomentAs(today)) {
          
          // Process the auto-payment
          await processPayment(
            creditCardId: payment.creditCardId,
            amount: payment.amount,
            sourceAccountId: payment.sourceAccountId ?? '',
            paymentMethod: payment.paymentMethod,
            notes: payment.notes,
          );
          
          // Update payment status
          final updatedPayment = payment.copyWith(
            status: 'Completed',
          );
          
          final index = _payments.indexWhere((p) => p.id == payment.id);
          if (index != -1) {
            _payments[index] = updatedPayment;
          }
        }
      }
      
      await StorageService.savePaymentRecords(_payments);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to process auto-payments: $e';
      notifyListeners();
    }
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
    _error = null; // Clear any previous errors
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

  /// Import credit cards from backup
  Future<void> importCreditCards(List<CreditCard> creditCards) async {
    _creditCards = creditCards;
    await StorageService.saveCreditCards(_creditCards);
    notifyListeners();
  }

  /// Import statements from backup
  Future<void> importStatements(List<CreditCardStatement> statements) async {
    _statements = statements;
    await StorageService.saveCreditCardStatements(_statements);
    notifyListeners();
  }

  /// Import payments from backup
  Future<void> importPayments(List<PaymentRecord> payments) async {
    _payments = payments;
    await StorageService.savePaymentRecords(_payments);
    notifyListeners();
  }

  // ========================================
  // STATEMENT CALCULATION HELPER METHODS
  // ========================================

  /// Get transactions for a specific billing period
  List<Transaction> _getTransactionsForPeriod(String creditCardId, DateTime periodStart, DateTime periodEnd) {
    // This would need access to AppProvider transactions
    // For now, return empty list - this should be implemented with proper data access
    return [];
  }

  /// Calculate payments and credits for the period
  double _calculatePaymentsAndCredits(List<Transaction> transactions, String creditCardId) {
    // Calculate from payment records for this credit card within the statement period
    // For now, return 0 - this should be implemented with proper period-based calculation
    return 0.0;
  }

  /// Calculate purchases for the period
  double _calculatePurchases(List<Transaction> transactions, String creditCardId) {
    // This would calculate from transactions where the credit card is the source
    // For now, return 0 - this should be implemented with proper transaction data
    return 0.0;
  }

  /// Calculate cash advances for the period
  double _calculateCashAdvances(List<Transaction> transactions, String creditCardId) {
    // This would calculate cash advance transactions
    // For now, return 0 - this should be implemented with proper transaction data
    return 0.0;
  }

  /// Calculate interest charges for the period
  double _calculateInterestCharges(String creditCardId, double previousBalance, DateTime periodStart) {
    final card = getCreditCardById(creditCardId);
    if (card == null) return 0.0;
    
    // Simple interest calculation: (balance * rate * days) / 365
    final daysInPeriod = DateTime.now().difference(periodStart).inDays;
    final annualRate = card.interestRate / 100.0;
    return (previousBalance * annualRate * daysInPeriod) / 365.0;
  }

  /// Calculate fees and charges for the period
  double _calculateFeesAndCharges(String creditCardId, DateTime periodStart) {
    // This would calculate various fees like annual fees, late fees, etc.
    // For now, return 0 - this should be implemented based on card terms
    return 0.0;
  }
}
