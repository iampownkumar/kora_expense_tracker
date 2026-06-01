import 'package:flutter/material.dart';
import '../../../core/models/account.dart';
import '../../../core/models/account_type.dart';
import '../../../core/models/transaction.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';

/// Result type for validation operations.
class ValidationResult {
  final bool isValid;
  final String errorMessage;
  const ValidationResult({required this.isValid, required this.errorMessage});
  const ValidationResult.ok() : isValid = true, errorMessage = '';
  const ValidationResult.fail(String msg) : isValid = false, errorMessage = msg;
}

/// Pure data layer for account operations. No Flutter/Widget imports needed.
/// Called by [AccountController]; never directly by UI.
class AccountService {
  // ── Load ─────────────────────────────────────────────────────────────────

  Future<List<Account>> loadAccounts() => StorageService.loadAccounts();

  // ── Create default accounts on first launch ───────────────────────────────

  Future<List<Account>> createDefaultAccounts() async {
    final List<Account> accounts = [];
    for (final data in AppConstants.defaultAccounts) {
      final account = Account.create(
        name: data['name'],
        icon: data['icon'],
        color: data['color'],
        balance: data['balance'],
        type: data['type'] as AccountType,
      );
      accounts.add(account);
    }
    await StorageService.saveAccounts(accounts);
    return accounts;
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<bool> addAccount(Account account) =>
      StorageService.addAccount(account);

  Future<bool> updateAccount(Account account) =>
      StorageService.updateAccount(account);

  /// Removes [account] and re-points its transactions to a placeholder.
  /// Fixes **Bug B3**: the placeholder is now saved to storage.
  Future<void> deleteAccount(
    String accountId,
    List<Account> accounts,
    List<Transaction> transactions,
  ) async {
    final account = accounts.firstWhere((a) => a.id == accountId);

    // Create a visible "Deleted Account" placeholder and SAVE it (B3 fix)
    final placeholder = Account.create(
      name: 'Deleted Account',
      icon: Icons.delete_outline,
      color: Colors.grey,
      type: account.type,
      description: 'This account has been deleted',
    );
    await StorageService.addAccount(placeholder);

    // Re-point all transactions that referenced the deleted account
    for (final t in transactions) {
      if (t.accountId == accountId) {
        await StorageService.updateTransaction(t.copyWith(accountId: placeholder.id));
      }
      if (t.toAccountId == accountId) {
        await StorageService.updateTransaction(t.copyWith(toAccountId: placeholder.id));
      }
    }

    await StorageService.deleteAccount(accountId);
  }

  /// Deletes account AND all its transactions (no placeholder needed).
  Future<void> deleteAccountWithTransactions(
    String accountId,
    List<Transaction> transactions,
  ) async {
    final related = transactions
        .where((t) => t.accountId == accountId || t.toAccountId == accountId)
        .toList();
    for (final t in related) {
      await StorageService.deleteTransaction(t.id);
    }
    await StorageService.deleteAccount(accountId);
  }

  // ── Balance updates ───────────────────────────────────────────────────────

  /// Applies or reverses a transaction's effect on account balances.
  /// Returns the updated list of accounts.
  Future<List<Account>> applyTransactionToBalances(
    Transaction transaction,
    List<Account> accounts, {
    bool isDelete = false,
  }) async {
    final updated = List<Account>.from(accounts);
    final multiplier = isDelete ? -1 : 1;

    if (transaction.isTransfer && transaction.toAccountId != null) {
      final fromIdx = updated.indexWhere((a) => a.id == transaction.accountId);
      final toIdx   = updated.indexWhere((a) => a.id == transaction.toAccountId!);
      if (fromIdx == -1 || toIdx == -1) return updated;

      final amount = transaction.amount.abs() * multiplier;
      final fromAcc = updated[fromIdx];
      final toAcc   = updated[toIdx];

      updated[fromIdx] = fromAcc.subtractFromBalance(amount);
      // Credit card: subtract = reduce debt. Other accounts: add = increase asset.
      updated[toIdx]   = toAcc.type == AccountType.creditCard
          ? toAcc.subtractFromBalance(amount)
          : toAcc.addToBalance(amount);

      await StorageService.updateAccount(updated[fromIdx]);
      await StorageService.updateAccount(updated[toIdx]);
    } else {
      final idx = updated.indexWhere((a) => a.id == transaction.accountId);
      if (idx == -1) return updated;

      final acc    = updated[idx];
      final amount = transaction.amount.abs() * multiplier;

      if (transaction.isIncome) {
        updated[idx] = acc.type == AccountType.creditCard
            ? acc.subtractFromBalance(amount)
            : acc.addToBalance(amount);
      } else {
        updated[idx] = acc.type == AccountType.creditCard
            ? acc.addToBalance(amount)
            : acc.subtractFromBalance(amount);
      }
      await StorageService.updateAccount(updated[idx]);
    }
    return updated;
  }

  // ── Validation ───────────────────────────────────────────────────────────

  ValidationResult validateTransfer(
    Transaction transaction,
    List<Account> accounts,
  ) {
    try {
      final from = accounts.firstWhere((a) => a.id == transaction.accountId);
      final to   = accounts.firstWhere((a) => a.id == transaction.toAccountId!);

      if (from.type.isLiability) {
        return const ValidationResult.fail(
          'Cannot transfer from a liability account (Credit Card / Loan).',
        );
      }
      if (from.id == to.id) {
        return const ValidationResult.fail('Cannot transfer to the same account.');
      }
      if (from.type.isAsset && from.balance < transaction.amount.abs()) {
        return ValidationResult.fail(
          'Insufficient balance. Available: ${Formatters.formatCurrency(from.balance)}, '
          'Required: ${Formatters.formatCurrency(transaction.amount.abs())}',
        );
      }
      return const ValidationResult.ok();
    } catch (_) {
      return const ValidationResult.fail('Account not found.');
    }
  }

  ValidationResult validateExpense(
    Transaction transaction,
    List<Account> accounts,
  ) {
    try {
      final acc = accounts.firstWhere((a) => a.id == transaction.accountId);
      if (acc.type.isAsset && acc.balance < transaction.amount.abs()) {
        return ValidationResult.fail(
          'Insufficient balance. Available: ${Formatters.formatCurrency(acc.balance)}, '
          'Required: ${Formatters.formatCurrency(transaction.amount.abs())}',
        );
      }
      return const ValidationResult.ok();
    } catch (_) {
      return const ValidationResult.fail('Account not found.');
    }
  }
}
