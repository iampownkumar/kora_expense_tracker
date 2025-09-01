import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/models/transaction.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/models/category.dart';
import 'package:kora_expense_tracker/models/settings.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';

void main() {
  group('Model Tests', () {
    test('Transaction model creation and serialization', () {
      final transaction = Transaction.create(
        type: AppConstants.transactionTypeExpense,
        amount: 100.0,
        description: 'Test transaction',
        categoryId: 'test-category',
        accountId: 'test-account',
      );

      expect(transaction.type, equals(AppConstants.transactionTypeExpense));
      expect(transaction.amount, equals(100.0));
      expect(transaction.description, equals('Test transaction'));
      expect(transaction.isExpense, isTrue);
      expect(transaction.isIncome, isFalse);
      expect(transaction.isTransfer, isFalse);

      // Test JSON serialization
      final json = transaction.toJson();
      final fromJson = Transaction.fromJson(json);
      
      expect(fromJson.id, equals(transaction.id));
      expect(fromJson.type, equals(transaction.type));
      expect(fromJson.amount, equals(transaction.amount));
      expect(fromJson.description, equals(transaction.description));
    });

    test('Account model creation and serialization', () {
      final account = Account.create(
        name: 'Test Account',
        icon: Icons.account_balance,
        color: Colors.blue,
        balance: 1000.0,
      );

      expect(account.name, equals('Test Account'));
      expect(account.balance, equals(1000.0));
      expect(account.isActive, isTrue);

      // Test balance operations
      final updatedAccount = account.addToBalance(500.0);
      expect(updatedAccount.balance, equals(1500.0));

      final subtractedAccount = updatedAccount.subtractFromBalance(200.0);
      expect(subtractedAccount.balance, equals(1300.0));

      // Test JSON serialization
      final json = account.toJson();
      final fromJson = Account.fromJson(json);
      
      expect(fromJson.name, equals(account.name));
      expect(fromJson.balance, equals(account.balance));
      expect(fromJson.icon.codePoint, equals(account.icon.codePoint));
    });

    test('Category model creation and serialization', () {
      final category = Category.create(
        name: 'Test Category',
        icon: Icons.shopping_cart,
        color: Colors.red,
        type: AppConstants.transactionTypeExpense,
      );

      expect(category.name, equals('Test Category'));
      expect(category.type, equals(AppConstants.transactionTypeExpense));
      expect(category.isExpense, isTrue);
      expect(category.isIncome, isFalse);
      expect(category.canBeUsedFor(AppConstants.transactionTypeExpense), isTrue);
      expect(category.canBeUsedFor(AppConstants.transactionTypeIncome), isFalse);

      // Test JSON serialization
      final json = category.toJson();
      final fromJson = Category.fromJson(json);
      
      expect(fromJson.name, equals(category.name));
      expect(fromJson.type, equals(category.type));
      expect(fromJson.icon.codePoint, equals(category.icon.codePoint));
    });

    test('Settings model creation and serialization', () {
      final settings = Settings.defaults();

      expect(settings.themeMode, equals('system'));
      expect(settings.currency, equals(AppConstants.defaultCurrency));
      expect(settings.locale, equals(AppConstants.defaultLocale));
      expect(settings.showNotifications, isTrue);

      // Test theme mode conversion
      expect(settings.themeModeEnum, equals(ThemeMode.system));
      expect(settings.isSystemTheme, isTrue);
      expect(settings.isDarkMode, isFalse);
      expect(settings.isLightMode, isFalse);

      // Test JSON serialization
      final json = settings.toJson();
      final fromJson = Settings.fromJson(json);
      
      expect(fromJson.themeMode, equals(settings.themeMode));
      expect(fromJson.currency, equals(settings.currency));
      expect(fromJson.locale, equals(settings.locale));
    });

    test('Transaction type colors and icons', () {
      final incomeTransaction = Transaction.create(
        type: AppConstants.transactionTypeIncome,
        amount: 100.0,
        description: 'Income',
        categoryId: 'test-category',
        accountId: 'test-account',
      );

      final expenseTransaction = Transaction.create(
        type: AppConstants.transactionTypeExpense,
        amount: 100.0,
        description: 'Expense',
        categoryId: 'test-category',
        accountId: 'test-account',
      );

      final transferTransaction = Transaction.create(
        type: AppConstants.transactionTypeTransfer,
        amount: 100.0,
        description: 'Transfer',
        categoryId: 'test-category',
        accountId: 'test-account',
      );

      expect(incomeTransaction.typeColor, equals(AppConstants.successColor));
      expect(expenseTransaction.typeColor, equals(AppConstants.errorColor));
      expect(transferTransaction.typeColor, equals(AppConstants.infoColor));

      expect(incomeTransaction.typeIcon, equals(Icons.arrow_upward));
      expect(expenseTransaction.typeIcon, equals(Icons.arrow_downward));
      expect(transferTransaction.typeIcon, equals(Icons.swap_horiz));
    });

    test('Account balance validation', () {
      final account = Account.create(
        name: 'Test Account',
        icon: Icons.account_balance,
        color: Colors.blue,
        balance: 1000.0,
      );

      expect(account.hasSufficientBalance(500.0), isTrue);
      expect(account.hasSufficientBalance(1000.0), isTrue);
      expect(account.hasSufficientBalance(1500.0), isFalse);

      expect(account.balanceColor, equals(Colors.green));
      expect(account.balanceIcon, equals(Icons.trending_up));
    });
  });
}
