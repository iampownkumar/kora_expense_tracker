import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/features/accounts/account_controller.dart';
import 'package:kora_expense_tracker/features/transactions/transaction_controller.dart';
import 'package:kora_expense_tracker/core/models/account.dart';
import 'package:kora_expense_tracker/core/models/category.dart';
import 'package:kora_expense_tracker/core/constants/app_constants.dart';

void main() {
  group('AccountController Tests', () {
    late AccountController accountController;

    setUp(() {
      accountController = AccountController();
    });

    test('Initial state is empty', () {
      expect(accountController.accounts, isEmpty);
      expect(accountController.isLoading, isFalse);
      expect(accountController.error, isNull);
      expect(accountController.totalBalance, equals(0.0));
    });

    test('findById returns null for unknown id', () {
      expect(accountController.findById('nonexistent'), isNull);
    });

    test('totalBalance reflects accounts', () {
      expect(accountController.totalAssets, equals(0.0));
      expect(accountController.totalLiabilities, equals(0.0));
      expect(accountController.netWorth, equals(0.0));
    });
  });

  group('TransactionController Tests', () {
    late AccountController accountController;
    late TransactionController transactionController;

    setUp(() {
      accountController = AccountController();
      transactionController = TransactionController(
        accountController: accountController,
      );
    });

    test('Initial state is empty', () {
      expect(transactionController.transactions, isEmpty);
      expect(transactionController.categories, isEmpty);
      expect(transactionController.isLoading, isFalse);
      expect(transactionController.error, isNull);
      expect(transactionController.totalIncome, equals(0.0));
      expect(transactionController.totalExpenses, equals(0.0));
    });

    test('Category filtering', () {
      // Categories start empty until initialized
      expect(transactionController.incomeCategories, isEmpty);
      expect(transactionController.expenseCategories, isEmpty);
      expect(transactionController.topLevelCategories, isEmpty);
    });

    test('clearError resets error state', () {
      transactionController.clearError();
      expect(transactionController.error, isNull);
    });
  });

  group('Category model Tests', () {
    test('Category.create sets fields correctly', () {
      final category = Category.create(
        name: 'Test',
        icon: Icons.shopping_cart,
        color: Colors.red,
        type: AppConstants.transactionTypeExpense,
      );
      expect(category.name, equals('Test'));
      expect(category.isExpense, isTrue);
      expect(category.isIncome, isFalse);
      expect(category.id, isNotEmpty);
    });
  });

  group('Account model Tests', () {
    test('Account.create sets fields correctly', () {
      final account = Account.create(
        name: 'Savings',
        icon: Icons.savings,
        color: Colors.green,
        balance: 5000.0,
      );
      expect(account.name, equals('Savings'));
      expect(account.balance, equals(5000.0));
      expect(account.id, isNotEmpty);
    });
  });
}
