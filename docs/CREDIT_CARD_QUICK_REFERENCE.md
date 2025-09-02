# Credit Card Management - Quick Reference Guide

## 🚀 Quick Start
This guide helps developers quickly understand and implement credit card management features.

## 📋 Common Tasks

### Adding a New Credit Card
1. User goes to Accounts → Add Account → Credit Card
2. Redirects to `AddCreditCardScreen`
3. Creates both `Account` and `CreditCard` objects with same ID
4. Updates both `AppProvider` and `CreditCardProvider`

### Displaying Credit Card Balance
```dart
// Use user-friendly display
Text(card.getFormattedUserBalance()) // Shows "₹100" instead of "₹-100"

// Use proper label
Text(card.balanceLabel) // Shows "Available Credit" or "Outstanding"

// Use proper color
Color color = card.userBalanceColor // Green for credit, red for debt
```

### Transaction Dialog Account Display
```dart
// Show debt/credit context
Text(
  account.type == AccountType.creditCard 
    ? '${Formatters.getCurrencySymbol()}${account.balance.abs().toStringAsFixed(0)} ${account.balance < 0 ? '(Credit)' : '(Debt)'}'
    : '${Formatters.getCurrencySymbol()}${account.balance.toStringAsFixed(0)}',
  style: TextStyle(color: account.balanceColor),
)
```

## 🎯 Key Methods

### CreditCard Model
- `getFormattedUserBalance()` - User-friendly balance (no minus for credit)
- `balanceLabel` - "Available Credit" or "Outstanding"
- `userBalanceColor` - Green for credit/zero, red for debt
- `userFriendlyUtilization` - Positive percentage for credit
- `userUtilizationStatus` - "Credit Available" or "Paid Off"

### Account Model
- `getFormattedUserBalance()` - User-friendly balance for credit cards
- `balanceIcon` - Upward trend for credit cards with credit
- `balanceColor` - Proper color based on account type

### AppProvider
- `totalAssets` - Includes overpaid credit cards as assets
- `totalLiabilities` - Only positive balances count as debt
- `netWorth` - Assets minus liabilities (correct calculation)

## 🔧 Troubleshooting

### Balance Not Syncing
1. Check both objects use same ID
2. Verify `CreditCardProvider` reference in `AppProvider`
3. Check `_updateAccountBalances()` method

### Wrong Colors
1. Check `AccountType.getBalanceColor()` logic
2. Verify liability logic: `balance <= 0 ? green : red`

### Import Errors
1. Add `import 'package:kora_expense_tracker/models/account_type.dart';`
2. Check all `AccountType.creditCard` references

## 📁 Key Files
- `lib/models/credit_card.dart` - Credit card display logic
- `lib/models/account.dart` - Account display logic
- `lib/providers/app_provider.dart` - Net worth calculation
- `lib/widgets/add_transaction_dialog.dart` - Transaction dialog
- `lib/screens/credit_cards_screen.dart` - Credit overview

## 🎨 UI Principles
- **Green = Good** (no debt, available credit)
- **Red = Bad** (debt, overdue)
- **No minus signs** for credits
- **Clear labels** for context
- **Upward trends** for positive states

---
*Use this guide for quick reference during development. For detailed implementation, see the full documentation.*
