import 'package:flutter/foundation.dart';
import '../../core/models/accounts/account.dart';
import '../../core/models/accounts/account_type.dart';
import '../../core/models/transactions/transaction.dart';
import 'services/account_service.dart';

export 'services/account_service.dart' show ValidationResult;

/// Exposes account state to the UI.
/// Views use [Consumer<AccountController>] and call methods here.
/// Never imports Widget classes or calls StorageService directly.
class AccountController extends ChangeNotifier {
  final AccountService _service;

  // ── State ─────────────────────────────────────────────────────────────────
  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _error;

  AccountController({AccountService? service})
      : _service = service ?? AccountService();

  // ── Getters ───────────────────────────────────────────────────────────────
  List<Account> get accounts => _accounts;
  bool  get isLoading => _isLoading;
  String? get error   => _error;

  double get totalAssets {
    return _accounts.fold(0.0, (sum, a) {
      if (a.isAsset)                        return sum + a.balance;
      if (a.isLiability && a.balance < 0)   return sum + a.balance.abs();
      return sum;
    });
  }

  double get totalLiabilities => _accounts
      .where((a) => a.isLiability)
      .fold(0.0, (sum, a) => sum + (a.balance > 0 ? a.balance : 0));

  double get totalBalance  => totalAssets;
  double get netWorth      => totalAssets - totalLiabilities;

  Map<AccountType, List<Account>> get accountsByType {
    final map = <AccountType, List<Account>>{};
    for (final a in _accounts) {
      map.putIfAbsent(a.type, () => []).add(a);
    }
    return map;
  }

  List<Account> getByType(AccountType type) =>
      _accounts.where((a) => a.type == type).toList();

  Account? findById(String id) {
    try { return _accounts.firstWhere((a) => a.id == id); }
    catch (_) { return null; }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _setLoading(true);
    try {
      _accounts = await _service.loadAccounts();
      if (_accounts.isEmpty) {
        _accounts = await _service.createDefaultAccounts();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load accounts: $e';
      debugPrint('AccountController.initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    _accounts = await _service.loadAccounts();
    notifyListeners();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<bool> addAccount(Account account) async {
    try {
      await _service.addAccount(account);
      _accounts.add(account);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add account: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAccount(Account account) async {
    try {
      final idx = _accounts.indexWhere((a) => a.id == account.id);
      if (idx == -1) return false;
      await _service.updateAccount(account);
      _accounts[idx] = account;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update account: $e';
      notifyListeners();
      return false;
    }
  }

  /// Soft-delete: re-points transactions, saves placeholder (B3 fixed in service).
  Future<bool> deleteAccount(
    String accountId,
    List<Transaction> transactions,
  ) async {
    try {
      await _service.deleteAccount(accountId, _accounts, transactions);
      _accounts.removeWhere((a) => a.id == accountId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete account: $e';
      notifyListeners();
      return false;
    }
  }

  /// Hard-delete: removes account AND all its transactions.
  Future<bool> deleteAccountWithTransactions(
    String accountId,
    List<Transaction> transactions,
  ) async {
    try {
      await _service.deleteAccountWithTransactions(accountId, transactions);
      _accounts.removeWhere((a) => a.id == accountId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete account: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Balance management (called by TransactionController) ──────────────────

  Future<void> applyTransaction(Transaction t, {bool isDelete = false}) async {
    _accounts = await _service.applyTransactionToBalances(
      t, _accounts, isDelete: isDelete,
    );
    notifyListeners();
  }

  // ── Import ────────────────────────────────────────────────────────────────

  Future<void> importAccounts(List<Account> accounts) async {
    _accounts = accounts;
    await _service.loadAccounts(); // reload from storage after import
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  ValidationResult validateTransfer(Transaction t) =>
      _service.validateTransfer(t, _accounts);

  ValidationResult validateExpense(Transaction t) =>
      _service.validateExpense(t, _accounts);
}
