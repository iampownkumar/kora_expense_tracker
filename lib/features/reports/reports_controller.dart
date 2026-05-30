import 'package:flutter/foundation.dart' hide Category;
import '../../core/models/transaction.dart';
import '../../core/models/category.dart';
import '../../core/models/account.dart';
import '../transactions/transaction_controller.dart';
import '../accounts/account_controller.dart';

/// Reports controller — read-only aggregator.
/// Never writes to storage. Pulls from TransactionController + AccountController.
/// Views use [Consumer<ReportsController>].
class ReportsController extends ChangeNotifier {
  final TransactionController _txController;
  final AccountController     _accController;

  ReportsController({
    required TransactionController transactionController,
    required AccountController accountController,
  })  : _txController  = transactionController,
        _accController = accountController;

  // ── Shortcut getters ──────────────────────────────────────────────────────

  List<Transaction> get allTransactions => _txController.transactions;
  List<Category>    get allCategories   => _txController.categories;
  List<Account>     get allAccounts     => _accController.accounts;

  // ── Date-filtered transactions ────────────────────────────────────────────

  List<Transaction> transactionsInRange(DateTime from, DateTime to) {
    return allTransactions
        .where((t) => !t.date.isBefore(from) && !t.date.isAfter(to))
        .toList();
  }

  List<Transaction> transactionsForMonth(int year, int month) {
    final from = DateTime(year, month, 1);
    final to   = DateTime(year, month + 1, 0, 23, 59, 59);
    return transactionsInRange(from, to);
  }

  // ── Aggregates ────────────────────────────────────────────────────────────

  double incomeInRange(DateTime from, DateTime to) => transactionsInRange(from, to)
      .where((t) => t.isIncome)
      .fold(0.0, (s, t) => s + t.amount.abs());

  double expensesInRange(DateTime from, DateTime to) => transactionsInRange(from, to)
      .where((t) => t.isExpense)
      .fold(0.0, (s, t) => s + t.amount.abs());

  double savingsInRange(DateTime from, DateTime to) =>
      incomeInRange(from, to) - expensesInRange(from, to);

  // ── Category breakdown ────────────────────────────────────────────────────

  /// Returns a map of category name → total spend, for the given date range.
  Map<String, double> expensesByCategory(DateTime from, DateTime to) {
    final txns = transactionsInRange(from, to).where((t) => t.isExpense);
    final result = <String, double>{};
    for (final t in txns) {
      try {
        final cat = allCategories.firstWhere((c) => c.id == t.categoryId);
        result[cat.name] = (result[cat.name] ?? 0.0) + t.amount.abs();
      } catch (_) {
        result['Uncategorized'] =
            (result['Uncategorized'] ?? 0.0) + t.amount.abs();
      }
    }
    return result;
  }

  /// Returns a map of sub-category name → total spend under a given parent category.
  Map<String, double> expensesBySubCategory(
    String parentCategoryId,
    DateTime from,
    DateTime to,
  ) {
    final subCatIds = allCategories
        .where((c) => c.parentCategoryId == parentCategoryId)
        .map((c) => c.id)
        .toSet();

    final txns = transactionsInRange(from, to)
        .where((t) => t.isExpense && subCatIds.contains(t.categoryId));

    final result = <String, double>{};
    for (final t in txns) {
      try {
        final cat = allCategories.firstWhere((c) => c.id == t.categoryId);
        result[cat.name] = (result[cat.name] ?? 0.0) + t.amount.abs();
      } catch (_) {}
    }
    return result;
  }

  // ── Monthly trend ─────────────────────────────────────────────────────────

  /// Returns the last [months] months as a list of
  /// {year, month, income, expenses, savings} maps.
  List<Map<String, dynamic>> monthlyTrend({int months = 6}) {
    final now = DateTime.now();
    return List.generate(months, (i) {
      final d = DateTime(now.year, now.month - (months - 1 - i), 1);
      final income   = incomeInRange(d, DateTime(d.year, d.month + 1, 0, 23, 59, 59));
      final expenses = expensesInRange(d, DateTime(d.year, d.month + 1, 0, 23, 59, 59));
      return {
        'year':     d.year,
        'month':    d.month,
        'income':   income,
        'expenses': expenses,
        'savings':  income - expenses,
      };
    });
  }

  // ── Net worth summary ─────────────────────────────────────────────────────

  double get netWorth       => _accController.netWorth;
  double get totalAssets    => _accController.totalAssets;
  double get totalLiabilities => _accController.totalLiabilities;

  /// Call this when underlying controllers change so reports re-render.
  void refresh() => notifyListeners();
}
