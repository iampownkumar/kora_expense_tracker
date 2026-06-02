import 'package:flutter/foundation.dart';
import '../../core/models/credit_cards/credit_card.dart';
import '../../core/models/credit_cards/credit_card_statement.dart';
import '../../core/models/credit_cards/payment_record.dart';
import '../transactions/transaction_controller.dart';
import '../accounts/account_controller.dart';
import 'services/credit_card_service.dart';

/// Exposes credit card state to the UI.
/// Replaces [CreditCardProvider] from the old providers/ folder.
/// Fix B1: all print() replaced with debugPrint().
/// Fix B6: no longer needs AppProvider reference — uses TransactionController instead.
class CreditCardController extends ChangeNotifier {
  final CreditCardService _service;
  final TransactionController _transactionController;
  final AccountController _accountController;

  // ── State ─────────────────────────────────────────────────────────────────
  List<CreditCard>          _creditCards = [];
  List<CreditCardStatement> _statements  = [];
  List<PaymentRecord>       _payments    = [];
  bool    _isLoading = false;
  String? _error;

  CreditCardController({
    required TransactionController transactionController,
    required AccountController accountController,
    CreditCardService? service,
  })  : _transactionController = transactionController,
        _accountController = accountController,
        _service = service ?? CreditCardService() {
    _transactionController.addListener(_onTransactionChanged);
    _accountController.addListener(_onAccountChanged);
  }

  void _onTransactionChanged() {
    refresh();
  }

  void _onAccountChanged() {
    refresh();
  }

  @override
  void dispose() {
    _transactionController.removeListener(_onTransactionChanged);
    _accountController.removeListener(_onAccountChanged);
    super.dispose();
  }

  // ── Getters ───────────────────────────────────────────────────────────────
  List<CreditCard>          get creditCards => _creditCards;
  List<CreditCardStatement> get statements  => _statements;
  List<PaymentRecord>       get payments    => _payments;
  bool    get isLoading => _isLoading;
  String? get error     => _error;

  List<CreditCard> get activeCreditCards =>
      _creditCards.where((c) => c.isActive).toList();

  List<CreditCard> get overdueCards =>
      _creditCards.where((c) => c.isOverdue).toList();

  List<CreditCard> get dueSoonCards =>
      _creditCards.where((c) => c.isDueSoon).toList();

  List<CreditCardStatement> get pendingStatements =>
      _statements.where((s) => s.status == StatementStatus.generated).toList();

  List<CreditCardStatement> get overdueStatements =>
      _statements.where((s) => s.isOverdue).toList();

  double get totalCreditLimit =>
      _creditCards.fold(0.0, (s, c) => s + c.creditLimit);

  double get totalOutstandingBalance =>
      _creditCards.fold(0.0, (s, c) => s + c.outstandingBalance);

  double get totalAvailableCredit =>
      _creditCards.fold(0.0, (s, c) => s + c.availableCredit);

  double get overallUtilization =>
      totalCreditLimit <= 0 ? 0.0 : totalOutstandingBalance / totalCreditLimit;

  String get overallUtilizationStatus {
    final u = overallUtilization;
    if (u >= 0.90) return 'Critical';
    if (u >= 0.80) return 'Warning';
    if (u >= 0.70) return 'High';
    if (u >= 0.50) return 'Moderate';
    if (u >= 0.30) return 'Elevated';
    return 'Safe';
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _service.loadCreditCards(),
        _service.loadStatements(),
        _service.loadPaymentRecords(),
      ]);
      _creditCards = results[0] as List<CreditCard>;
      _statements  = results[1] as List<CreditCardStatement>;
      _payments    = results[2] as List<PaymentRecord>;
      _error = null;
    } catch (e) {
      _error = 'Failed to load credit card data: $e';
      debugPrint('CreditCardController.initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    _creditCards = await _service.loadCreditCards();
    _statements  = await _service.loadStatements();
    _payments    = await _service.loadPaymentRecords();
    notifyListeners();
  }

  // ── Credit Card CRUD ──────────────────────────────────────────────────────

  Future<bool> addCreditCard(CreditCard card) async {
    try {
      await _service.addCreditCard(card);
      _creditCards.add(card);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add credit card: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCreditCard(CreditCard card) async {
    try {
      final idx = _creditCards.indexWhere((c) => c.id == card.id);
      if (idx == -1) return false;
      await _service.saveCreditCard(card);
      _creditCards[idx] = card;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update credit card: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCreditCardBalance(String id, double newBalance) async {
    try {
      final idx = _creditCards.indexWhere((c) => c.id == id);
      if (idx == -1) return false;

      final card = _creditCards[idx];
      final updated = card.copyWith(
        outstandingBalance: newBalance,
        availableCredit: card.creditLimit - newBalance,
        updatedAt: DateTime.now(),
      );
      _creditCards[idx] = updated;
      await _service.saveCreditCard(updated);

      if (newBalance <= 0) await _markStatementsAsPaid(id);

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update balance: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCreditCard(String id) async {
    try {
      await _service.deleteCreditCard(id);
      _creditCards.removeWhere((c) => c.id == id);
      _statements.removeWhere((s) => s.creditCardId == id);
      _payments.removeWhere((p) => p.creditCardId == id);
      await _service.saveStatements(_statements);
      await _service.savePaymentRecords(_payments);

      // B6 fix: delete payment transactions via TransactionController (no AppProvider needed)
      final paymentTxns = _transactionController.transactions
          .where((t) => t.isTransfer && t.toAccountId == id)
          .toList();
      for (final t in paymentTxns) {
        await _transactionController.deleteTransaction(t.id);
      }

      // Consolidate deletion: delete matching account from AccountController
      await _accountController.deleteAccount(id, _transactionController.transactions);

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete credit card: $e';
      notifyListeners();
      return false;
    }
  }

  CreditCard? getCreditCardById(String id) {
    try { return _creditCards.firstWhere((c) => c.id == id); }
    catch (_) { return null; }
  }

  // ── Statement management ──────────────────────────────────────────────────

  List<CreditCardStatement> getStatementsForCard(String cardId) =>
      _statements.where((s) => s.creditCardId == cardId).toList();

  /// Returns true if a statement already exists for the current billing month.
  bool hasStatementForCurrentMonth(String cardId) {
    final now = DateTime.now();
    return _statements.any((s) =>
        s.creditCardId == cardId &&
        s.periodStart.year == now.year &&
        s.periodStart.month == now.month);
  }

  /// Returns the current month's statement for a card, or null.
  CreditCardStatement? getCurrentMonthStatement(String cardId) {
    final now = DateTime.now();
    try {
      return _statements.firstWhere((s) =>
          s.creditCardId == cardId &&
          s.periodStart.year == now.year &&
          s.periodStart.month == now.month);
    } catch (_) {
      return null;
    }
  }

  Future<bool> addStatement(CreditCardStatement statement) async {
    try {
      await _service.addStatement(statement);
      _statements.add(statement);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add statement: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatement(CreditCardStatement statement) async {
    try {
      final idx = _statements.indexWhere((s) => s.id == statement.id);
      if (idx == -1) return false;
      await _service.updateStatement(statement);
      _statements[idx] = statement;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update statement: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStatement(String statementId) async {
    try {
      // B6 fix: use TransactionController, not AppProvider
      final stmt = _statements.firstWhere((s) => s.id == statementId);
      final paymentTxns = _transactionController.transactions.where((t) =>
          t.isTransfer &&
          t.toAccountId == stmt.creditCardId &&
          t.date.isAfter(stmt.periodStart.subtract(const Duration(days: 1))) &&
          t.date.isBefore(stmt.periodEnd.add(const Duration(days: 1)))).toList();

      for (final t in paymentTxns) {
        await _transactionController.deleteTransaction(t.id);
      }
      debugPrint('CreditCardController: deleted ${paymentTxns.length} payment transactions');

      await _service.deleteStatement(statementId);
      _statements.removeWhere((s) => s.id == statementId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete statement: $e';
      notifyListeners();
      return false;
    }
  }

  Future<CreditCardStatement?> generateStatement(String cardId) async {
    try {
      final card = _creditCards.firstWhere((c) => c.id == cardId);
      final now = DateTime.now();
      final billingDay = card.billingCycleDay;

      final DateTime periodStart;
      final DateTime periodEnd;
      if (now.day < billingDay) {
        periodStart = DateTime(now.year, now.month - 1, billingDay);
        periodEnd   = DateTime(now.year, now.month, billingDay - 1);
      } else {
        periodStart = DateTime(now.year, now.month, billingDay);
        periodEnd   = DateTime(now.year, now.month + 1, billingDay - 1);
      }

      // Prevent duplicate statements for the same period
      final exists = _statements.any((s) =>
          s.creditCardId == cardId &&
          s.periodStart.year  == periodStart.year &&
          s.periodStart.month == periodStart.month &&
          s.periodStart.day   == periodStart.day);
      if (exists) {
        _error = 'Statement already exists for this billing period';
        notifyListeners();
        return null;
      }

      final previousBalance = getStatementsForCard(cardId)
          .map((s) => s.newBalance)
          .fold<double?>(null, (prev, b) => prev == null || b > prev ? b : prev) ?? 0.0;

      final statement = CreditCardStatement(
        id: 'stmt_${now.millisecondsSinceEpoch}_${now.microsecond}',
        creditCardId: cardId,
        statementNumber: '${now.year}-${now.month.toString().padLeft(2, '0')}',
        periodStart: periodStart,
        periodEnd: periodEnd,
        previousBalance: previousBalance,
        paymentsAndCredits: 0.0,
        purchases: 0.0,
        cashAdvances: 0.0,
        interestCharges: 0.0,
        feesAndCharges: 0.0,
        newBalance: card.outstandingBalance,
        minimumPaymentDue: card.minimumPaymentAmount,
        paymentDueDate: card.nextDueDate ?? now.add(const Duration(days: 21)),
        generatedDate: now,
        status: StatementStatus.generated,
        createdAt: now,
        updatedAt: now,
      );

      await _service.addStatement(statement);
      _statements.add(statement);
      _error = null;
      notifyListeners();
      return statement;
    } catch (e) {
      _error = 'Failed to generate statement: $e';
      notifyListeners();
      return null;
    }
  }

  // ── Payment management ────────────────────────────────────────────────────

  List<PaymentRecord> getPaymentsForCard(String cardId) =>
      _payments.where((p) => p.creditCardId == cardId).toList();

  Future<bool> processPayment({
    required String creditCardId,
    required double amount,
    required String paymentMethod,
    String? sourceAccountId,
    String? statementId,
    bool isMinimumPayment = false,
    bool isFullPayment    = false,
    String? notes,
  }) async {
    try {
      final card = getCreditCardById(creditCardId);
      if (card == null) return false;
      if (amount <= 0 || amount > card.outstandingBalance) {
        _error = 'Invalid payment amount';
        notifyListeners();
        return false;
      }

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

      await _service.addPaymentRecord(payment);
      _payments.add(payment);

      // Update credit card balance
      final newBalance = card.outstandingBalance - amount;
      final updatedCard = card.copyWith(
        outstandingBalance: newBalance,
        availableCredit: card.creditLimit - newBalance,
        lastPaymentDate: payment.paymentDate,
        lastPaymentAmount: amount,
      );
      await updateCreditCard(updatedCard);

      // Update statement if linked
      if (statementId != null) {
        final stmtIdx = _statements.indexWhere((s) => s.id == statementId);
        if (stmtIdx != -1) {
          final stmt = _statements[stmtIdx];
          final paid = stmt.paidAmount + amount;
          final status = paid >= stmt.newBalance ? StatementStatus.paid : stmt.status;
          final updatedStmt = stmt.copyWith(
            paidAmount: paid,
            status: status,
            paidDate: payment.paymentDate,
          );
          await updateStatement(updatedStmt);
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to process payment: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Analytics ─────────────────────────────────────────────────────────────

  double getOnTimePaymentPercentage(String cardId) {
    final pays  = getPaymentsForCard(cardId);
    final stmts = getStatementsForCard(cardId);
    if (pays.isEmpty || stmts.isEmpty) return 0.0;

    int onTime = 0, total = 0;
    for (final p in pays) {
      if (p.statementId == null) continue;
      try {
        final s = stmts.firstWhere((s) => s.id == p.statementId);
        total++;
        if (!p.paymentDate.isAfter(s.paymentDueDate)) onTime++;
      } catch (_) {}
    }
    return total > 0 ? (onTime / total) * 100 : 0.0;
  }

  List<PaymentRecord> getPaymentHistory(String cardId, {int limit = 10}) {
    final pays = getPaymentsForCard(cardId)
      ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    return pays.take(limit).toList();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _markStatementsAsPaid(String cardId) async {
    bool updated = false;
    for (int i = 0; i < _statements.length; i++) {
      final s = _statements[i];
      if (s.creditCardId == cardId && s.status == StatementStatus.generated) {
        _statements[i] = s.copyWith(
          status: StatementStatus.paid,
          paidAmount: s.newBalance,
          paidDate: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        updated = true;
      }
    }
    if (updated) await _service.saveStatements(_statements);
  }

  /// Configure auto-pay for a card (stub — full auto-pay scheduling is a future feature).
  Future<bool> setupAutoPay(
    String cardId, {
    required double amount,
    required String paymentAccountId,
    required bool payFullBalance,
  }) async {
    try {
      final card = getCreditCardById(cardId);
      if (card == null) return false;
      debugPrint('CreditCardController.setupAutoPay: card=$cardId amount=$amount payFull=$payFullBalance');
      // TODO: Persist auto-pay config when model is extended
      return true;
    } catch (e) {
      _error = 'Failed to setup auto-pay: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
