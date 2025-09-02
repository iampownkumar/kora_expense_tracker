import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/models/transaction.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/models/account_type.dart';
import 'package:kora_expense_tracker/models/category.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/widgets/add_transaction_dialog.dart';
import 'package:kora_expense_tracker/utils/formatters.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';

/// Bottom sheet for displaying detailed transaction information
class TransactionDetailSheet extends StatelessWidget {
  final Transaction transaction;
  final AppProvider appProvider;

  const TransactionDetailSheet({
    super.key,
    required this.transaction,
    required this.appProvider,
  });

  @override
  Widget build(BuildContext context) {
    final account = appProvider.accounts.isNotEmpty
        ? appProvider.accounts.firstWhere(
            (acc) => acc.id == transaction.accountId,
            orElse: () => appProvider.accounts.first,
          )
        : Account(
            id: 'default',
            name: 'Unknown Account',
            type: AccountType.cash,
            balance: 0.0,
            color: Colors.blue,
            icon: Icons.account_balance_wallet,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
    
    final category = appProvider.categories.isNotEmpty
        ? appProvider.categories.firstWhere(
            (cat) => cat.id == transaction.categoryId,
            orElse: () => appProvider.categories.first,
          )
        : Category(
            id: 'default',
            name: 'Unknown Category',
            type: 'expense',
            color: Colors.grey,
            icon: Icons.category,
            isDefault: false,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

    return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Transaction type icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getTypeColor(context, transaction.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getTypeIcon(transaction.type),
                        color: _getTypeColor(context, transaction.type),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Transaction title and amount
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.description,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatCurrency(transaction.amount),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: _getAmountColor(context, transaction.type),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Edit button
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => AddTransactionDialog(
                            appProvider: appProvider,
                            transaction: transaction,
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Transaction details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      'Type',
                      transaction.typeDisplayName,
                      _getTypeColor(context, transaction.type),
                    ),
                    _buildDetailRow(
                      context,
                      'Account',
                      account.name,
                      Theme.of(context).colorScheme.primary,
                    ),
                    if (transaction.type != AppConstants.transactionTypeTransfer)
                      _buildDetailRow(
                        context,
                        'Category',
                        category.name,
                        Theme.of(context).colorScheme.secondary,
                      ),
                    _buildDetailRow(
                      context,
                      'Date',
                      Formatters.formatDate(transaction.date),
                      Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    _buildDetailRow(
                      context,
                      'Time',
                      Formatters.formatTime(transaction.date),
                      Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    if (transaction.notes?.isNotEmpty == true)
                      _buildDetailRow(
                        context,
                        'Notes',
                        transaction.notes!,
                        Theme.of(context).colorScheme.onSurfaceVariant,
                        isMultiline: true,
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                                                  showDialog(
                          context: context,
                          builder: (context) => AddTransactionDialog(
                            appProvider: appProvider,
                            transaction: transaction,
                          ),
                        );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _deleteTransaction(context, appProvider),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Safe area padding
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
  }

  /// Build a detail row with label and value
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: isMultiline ? null : 1,
              overflow: isMultiline ? null : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Get the appropriate color for transaction type
  Color _getTypeColor(BuildContext context, String type) {
    switch (type) {
      case AppConstants.transactionTypeIncome:
        return Colors.green;
      case AppConstants.transactionTypeExpense:
        return Colors.red;
      case AppConstants.transactionTypeTransfer:
        return Colors.blue;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  /// Get the appropriate icon for transaction type
  IconData _getTypeIcon(String type) {
    switch (type) {
      case AppConstants.transactionTypeIncome:
        return Icons.trending_up;
      case AppConstants.transactionTypeExpense:
        return Icons.trending_down;
      case AppConstants.transactionTypeTransfer:
        return Icons.swap_horiz;
      default:
        return Icons.receipt;
    }
  }

  /// Get the appropriate color for amount display
  Color _getAmountColor(BuildContext context, String type) {
    switch (type) {
      case AppConstants.transactionTypeIncome:
        return Colors.green;
      case AppConstants.transactionTypeExpense:
        return Colors.red;
      case AppConstants.transactionTypeTransfer:
        return Theme.of(context).colorScheme.primary;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  /// Delete transaction with confirmation
  void _deleteTransaction(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete "${transaction.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              appProvider.deleteTransaction(transaction.id);
              Navigator.pop(context); // Close confirmation dialog
              Navigator.pop(context); // Close detail sheet
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Transaction "${transaction.description}" deleted'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
