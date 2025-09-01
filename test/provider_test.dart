import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/models/transaction.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/models/category.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';

void main() {
  group('AppProvider Tests', () {
    late AppProvider appProvider;

    setUp(() {
      appProvider = AppProvider();
    });

    test('Initial state', () {
      expect(appProvider.transactions, isEmpty);
      expect(appProvider.accounts, isEmpty);
      expect(appProvider.categories, isEmpty);
      expect(appProvider.totalBalance, equals(0.0));
      expect(appProvider.totalIncome, equals(0.0));
      expect(appProvider.totalExpenses, equals(0.0));
      expect(appProvider.isLoading, isFalse);
      expect(appProvider.error, isNull);
      expect(appProvider.selectedTabIndex, equals(0));
    });

    test('Add transaction updates totals', () {
      // Create test data
      final account = Account.create(
        name: 'Test Account',
        icon: Icons.account_balance,
        color: Colors.blue,
        balance: 1000.0,
      );

      final category = Category.create(
        name: 'Test Category',
        icon: Icons.shopping_cart,
        color: Colors.red,
        type: AppConstants.transactionTypeExpense,
      );

      final transaction = Transaction.create(
        type: AppConstants.transactionTypeExpense,
        amount: 100.0,
        description: 'Test expense',
        categoryId: category.id,
        accountId: account.id,
      );

      // Add to provider
      appProvider.addAccount(account);
      appProvider.addCategory(category);
      appProvider.addTransaction(transaction);

      // Verify totals
      expect(appProvider.totalExpenses, equals(100.0));
      expect(appProvider.totalIncome, equals(0.0));
      expect(appProvider.totalBalance, equals(900.0)); // 1000 - 100
      expect(appProvider.transactions.length, equals(1));
    });

    test('Tab navigation', () {
      expect(appProvider.selectedTabIndex, equals(0));
      
      appProvider.setSelectedTab(2);
      expect(appProvider.selectedTabIndex, equals(2));
      
      appProvider.setSelectedTab(4);
      expect(appProvider.selectedTabIndex, equals(4));
    });

    test('Error handling', () {
      expect(appProvider.error, isNull);
      
      appProvider.clearError();
      expect(appProvider.error, isNull);
    });

    test('Category filtering', () {
      // Add mixed categories
      final incomeCategory = Category.create(
        name: 'Income',
        icon: Icons.work,
        color: Colors.green,
        type: AppConstants.transactionTypeIncome,
      );

      final expenseCategory = Category.create(
        name: 'Expense',
        icon: Icons.shopping_cart,
        color: Colors.red,
        type: AppConstants.transactionTypeExpense,
      );

      final bothCategory = Category.create(
        name: 'Both',
        icon: Icons.category,
        color: Colors.blue,
        type: 'both',
      );

      appProvider.addCategory(incomeCategory);
      appProvider.addCategory(expenseCategory);
      appProvider.addCategory(bothCategory);

      expect(appProvider.incomeCategories.length, equals(2)); // income + both
      expect(appProvider.expenseCategories.length, equals(2)); // expense + both
    });
  });
}
