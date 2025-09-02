import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../models/bank_account.dart';
import '../models/credit_card.dart';
import '../utils/storage_service.dart';
import '../constants/app_constants.dart';

/// Payment Provider for managing payment operations
class PaymentProvider extends ChangeNotifier {
  List<Payment> _payments = [];
  List<BankAccount> _bankAccounts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Payment> get payments => List.unmodifiable(_payments);
  List<BankAccount> get bankAccounts => List.unmodifiable(_bankAccounts);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get payments for a specific credit card
  List<Payment> getPaymentsForCard(String creditCardId) {
    return _payments.where((payment) => payment.creditCardId == creditCardId).toList();
  }

  /// Get payments for a specific statement
  List<Payment> getPaymentsForStatement(String statementId) {
    return _payments.where((payment) => payment.statementId == statementId).toList();
  }

  /// Get total amount paid for a credit card
  double getTotalPaidForCard(String creditCardId) {
    return _payments
        .where((payment) => payment.creditCardId == creditCardId && payment.isCompleted)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get total amount paid for a statement
  double getTotalPaidForStatement(String statementId) {
    return _payments
        .where((payment) => payment.statementId == statementId && payment.isCompleted)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get active bank accounts
  List<BankAccount> get activeBankAccounts {
    return _bankAccounts.where((account) => account.isActive).toList();
  }

  /// Get verified bank accounts
  List<BankAccount> get verifiedBankAccounts {
    return _bankAccounts.where((account) => account.isActive && account.isVerified).toList();
  }

  /// Initialize the provider
  Future<void> initialize() async {
    await loadPayments();
    await loadBankAccounts();
  }

  /// Load payments from storage
  Future<void> loadPayments() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final payments = await StorageService.loadPayments();
      _payments = payments;
    } catch (e) {
      _error = 'Failed to load payments: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load bank accounts from storage
  Future<void> loadBankAccounts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final bankAccounts = await StorageService.loadBankAccounts();
      _bankAccounts = bankAccounts;
    } catch (e) {
      _error = 'Failed to load bank accounts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new payment
  Future<bool> addPayment(Payment payment) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate payment
      if (payment.amount <= 0) {
        _error = 'Payment amount must be greater than 0';
        return false;
      }

      // Check if bank account has sufficient balance (if applicable)
      if (payment.bankAccountId != null) {
        final bankAccount = _bankAccounts.firstWhere(
          (account) => account.id == payment.bankAccountId,
          orElse: () => throw Exception('Bank account not found'),
        );

        if (!bankAccount.hasSufficientBalance(payment.totalAmount)) {
          _error = 'Insufficient balance in selected bank account';
          return false;
        }
      }

      // Add payment to list
      _payments.add(payment);

      // Save to storage
      await StorageService.savePayments(_payments);

      // Update bank account balance if applicable
      if (payment.bankAccountId != null && payment.isCompleted) {
        await _updateBankAccountBalance(payment.bankAccountId!, payment.totalAmount, false);
      }

      return true;
    } catch (e) {
      _error = 'Failed to add payment: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus(String paymentId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final paymentIndex = _payments.indexWhere((payment) => payment.id == paymentId);
      if (paymentIndex == -1) {
        _error = 'Payment not found';
        return false;
      }

      final payment = _payments[paymentIndex];
      final updatedPayment = payment.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );

      _payments[paymentIndex] = updatedPayment;

      // Save to storage
      await StorageService.savePayments(_payments);

      // Update bank account balance if status changed to completed
      if (status == 'completed' && payment.bankAccountId != null && !payment.isCompleted) {
        await _updateBankAccountBalance(payment.bankAccountId!, payment.totalAmount, false);
      } else if (payment.isCompleted && payment.bankAccountId != null && status != 'completed') {
        // Revert bank account balance if payment was completed but status changed
        await _updateBankAccountBalance(payment.bankAccountId!, payment.totalAmount, true);
      }

      return true;
    } catch (e) {
      _error = 'Failed to update payment status: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a payment
  Future<bool> deletePayment(String paymentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final paymentIndex = _payments.indexWhere((payment) => payment.id == paymentId);
      if (paymentIndex == -1) {
        _error = 'Payment not found';
        return false;
      }

      final payment = _payments[paymentIndex];

      // Revert bank account balance if payment was completed
      if (payment.isCompleted && payment.bankAccountId != null) {
        await _updateBankAccountBalance(payment.bankAccountId!, payment.totalAmount, true);
      }

      _payments.removeAt(paymentIndex);

      // Save to storage
      await StorageService.savePayments(_payments);

      return true;
    } catch (e) {
      _error = 'Failed to delete payment: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new bank account
  Future<bool> addBankAccount(BankAccount bankAccount) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate bank account
      if (bankAccount.accountNumber.isEmpty || bankAccount.ifscCode.isEmpty) {
        _error = 'Account number and IFSC code are required';
        return false;
      }

      // Check for duplicate account numbers
      final existingAccount = _bankAccounts.any(
        (account) => account.accountNumber == bankAccount.accountNumber && account.id != bankAccount.id,
      );

      if (existingAccount) {
        _error = 'Bank account with this account number already exists';
        return false;
      }

      _bankAccounts.add(bankAccount);

      // Save to storage
      await StorageService.saveBankAccounts(_bankAccounts);

      return true;
    } catch (e) {
      _error = 'Failed to add bank account: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update bank account
  Future<bool> updateBankAccount(BankAccount bankAccount) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final accountIndex = _bankAccounts.indexWhere((account) => account.id == bankAccount.id);
      if (accountIndex == -1) {
        _error = 'Bank account not found';
        return false;
      }

      _bankAccounts[accountIndex] = bankAccount;

      // Save to storage
      await StorageService.saveBankAccounts(_bankAccounts);

      return true;
    } catch (e) {
      _error = 'Failed to update bank account: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete bank account
  Future<bool> deleteBankAccount(String bankAccountId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if bank account is used in any payments
      final isUsedInPayments = _payments.any((payment) => payment.bankAccountId == bankAccountId);
      if (isUsedInPayments) {
        _error = 'Cannot delete bank account that is used in payments';
        return false;
      }

      final accountIndex = _bankAccounts.indexWhere((account) => account.id == bankAccountId);
      if (accountIndex == -1) {
        _error = 'Bank account not found';
        return false;
      }

      _bankAccounts.removeAt(accountIndex);

      // Save to storage
      await StorageService.saveBankAccounts(_bankAccounts);

      return true;
    } catch (e) {
      _error = 'Failed to delete bank account: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Process payment (simulate payment processing)
  Future<bool> processPayment(Payment payment) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulate random success/failure (90% success rate)
      final isSuccess = (DateTime.now().millisecondsSinceEpoch % 10) < 9;

      if (isSuccess) {
        await updatePaymentStatus(payment.id, 'completed');
        return true;
      } else {
        await updatePaymentStatus(payment.id, 'failed');
        _error = 'Payment processing failed. Please try again.';
        return false;
      }
    } catch (e) {
      _error = 'Payment processing error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update bank account balance
  Future<void> _updateBankAccountBalance(String bankAccountId, double amount, bool isReversal) async {
    final accountIndex = _bankAccounts.indexWhere((account) => account.id == bankAccountId);
    if (accountIndex == -1) return;

    final account = _bankAccounts[accountIndex];
    final newBalance = isReversal 
        ? account.currentBalance + amount 
        : account.currentBalance - amount;

    final updatedAccount = account.copyWith(
      currentBalance: newBalance,
      updatedAt: DateTime.now(),
    );

    _bankAccounts[accountIndex] = updatedAccount;
    await StorageService.saveBankAccounts(_bankAccounts);
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadPayments();
    await loadBankAccounts();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
