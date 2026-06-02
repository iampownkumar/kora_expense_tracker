import 'package:flutter/foundation.dart' hide Category;
import '../../core/models/transactions/transaction.dart';
import '../../core/models/categories/category.dart';
import '../../core/utils/storage_service.dart';
import '../../core/constants/app_constants.dart';
import '../accounts/account_controller.dart';
import 'services/transaction_service.dart';

/// Exposes transaction state to the UI.
/// Calls [AccountController.applyTransaction] to keep balances in sync
/// without direct coupling to storage inside the controller.
class TransactionController extends ChangeNotifier {
  final TransactionService _service;
  final AccountController _accountController;

  // ── State ─────────────────────────────────────────────────────────────────
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  TransactionController({
    required AccountController accountController,
    TransactionService? service,
  }) : _accountController = accountController,
       _service = service ?? TransactionService() {
    _accountController.addListener(_onAccountChanged);
  }

  void _onAccountChanged() {
    refresh();
  }

  @override
  void dispose() {
    _accountController.removeListener(_onAccountChanged);
    super.dispose();
  }

  // ── Getters ───────────────────────────────────────────────────────────────
  List<Transaction> get transactions => _transactions;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Transaction> get recentTransactions {
    final sorted = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(10).toList();
  }

  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (s, t) => s + t.amount.abs());

  double get totalExpenses => _transactions
      .where((t) => t.isExpense)
      .fold(0.0, (s, t) => s + t.amount.abs());

  // Category helpers
  List<Category> get incomeCategories =>
      _categories.where((c) => c.isIncome || c.isBoth).toList();

  List<Category> get expenseCategories =>
      _categories.where((c) => c.isExpense || c.isBoth).toList();

  List<Category> get topLevelCategories =>
      _categories.where((c) => !c.isSubCategory).toList();

  List<Category> get topLevelIncomeCategories =>
      topLevelCategories.where((c) => c.isIncome || c.isBoth).toList();

  List<Category> get topLevelExpenseCategories =>
      topLevelCategories.where((c) => c.isExpense || c.isBoth).toList();

  List<Category> getSubCategories(String parentId) =>
      _categories.where((c) => c.parentCategoryId == parentId).toList();

  int get subCategoryCount => _categories.where((c) => c.isSubCategory).length;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        StorageService.loadTransactions(),
        StorageService.loadCategories(),
      ]);
      _transactions = results[0] as List<Transaction>;
      _categories = results[1] as List<Category>;

      if (_categories.isEmpty) {
        _categories = await _createDefaultCategories();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load transactions: $e';
      debugPrint('TransactionController.initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    _transactions = await StorageService.loadTransactions();
    _categories = await StorageService.loadCategories();
    notifyListeners();
  }

  // ── Transaction CRUD ──────────────────────────────────────────────────────

  Future<bool> addTransaction(Transaction transaction) async {
    try {
      // Validate before proceeding
      if (transaction.isTransfer && transaction.toAccountId != null) {
        final v = _accountController.validateTransfer(transaction);
        if (!v.isValid) {
          _error = v.errorMessage;
          notifyListeners();
          return false;
        }
      } else if (transaction.isExpense) {
        final v = _accountController.validateExpense(transaction);
        if (!v.isValid) {
          _error = v.errorMessage;
          notifyListeners();
          return false;
        }
      }

      final saved = await _service.addTransaction(transaction);
      _transactions.add(saved);

      // Update account balances via AccountController
      await _accountController.applyTransaction(saved);

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add transaction: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(String id, Transaction updated) async {
    try {
      final idx = _transactions.indexWhere((t) => t.id == id);
      if (idx == -1) return false;

      final old = _transactions[idx];

      // Reverse old balance effect
      await _accountController.applyTransaction(old, isDelete: true);

      // Save with updated image path
      final saved = await _service.updateTransaction(old, updated);
      _transactions[idx] = saved;

      // Apply new balance effect
      await _accountController.applyTransaction(saved);

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update transaction: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      final transaction = _transactions.firstWhere((t) => t.id == id);
      await _service.deleteTransaction(transaction);
      _transactions.removeWhere((t) => t.id == id);
      await _accountController.applyTransaction(transaction, isDelete: true);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete transaction: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Category CRUD ─────────────────────────────────────────────────────────

  Future<bool> addCategory(Category category) async {
    try {
      await StorageService.addCategory(category);
      _categories.add(category);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add category: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      final idx = _categories.indexWhere((c) => c.id == category.id);
      if (idx == -1) return false;
      await StorageService.updateCategory(category);
      _categories[idx] = category;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update category: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await StorageService.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete category: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Import ────────────────────────────────────────────────────────────────

  Future<int> mergeImportedTransactions(List<Transaction> incoming) async {
    final defaultCatId = _categories.isNotEmpty
        ? _categories.first.id
        : 'uncategorized';
    final defaultAccId = _accountController.accounts.isNotEmpty
        ? _accountController.accounts.first.id
        : 'unknown';

    final added = await _service.mergeTransactions(
      incoming,
      _transactions,
      _categories,
      defaultCatId,
      defaultAccId,
    );

    if (added > 0) {
      _transactions = await StorageService.loadTransactions();
      notifyListeners();
    }
    return added;
  }

  /// Wipe all existing transactions and replace with the backup.
  Future<int> restoreFromImportedTransactions(List<Transaction> incoming) async {
    // Clear existing transactions from storage
    await StorageService.saveTransactions([]);
    _transactions = [];

    // Re-use merge logic but with empty existing list (so everything gets added)
    final defaultCatId = _categories.isNotEmpty ? _categories.first.id : 'uncategorized';
    final defaultAccId = _accountController.accounts.isNotEmpty
        ? _accountController.accounts.first.id
        : 'unknown';

    final added = await _service.mergeTransactions(
      incoming,
      [],
      _categories,
      defaultCatId,
      defaultAccId,
    );

    if (added > 0) {
      _transactions = await StorageService.loadTransactions();
      notifyListeners();
    }
    return added;
  }

  Future<void> importTransactions(List<Transaction> transactions) async {
    await StorageService.saveTransactions(transactions);
    _transactions = transactions;
    notifyListeners();
  }

  Future<void> importCategories(List<Category> categories) async {
    await StorageService.saveCategories(categories);
    _categories = categories;
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

  Future<List<Category>> _createDefaultCategories() async {
    final cats = <Category>[];
    for (final d in AppConstants.defaultCategories) {
      cats.add(
        Category.create(
          name: d['name'],
          icon: d['icon'],
          color: d['color'],
          type: d['type'],
          isDefault: true,
        ),
      );
    }
    await StorageService.saveCategories(cats);
    return cats;
  }
}
