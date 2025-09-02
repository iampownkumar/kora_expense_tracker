import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/models/account_type.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';

/// A card widget for displaying account information with visual grouping
class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isExpanded;
  final bool showActions;

  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isExpanded = false,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon, name, and actions
              Row(
                children: [
                  // Account type icon with background
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: account.type.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      account.icon,
                      color: account.type.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Account name and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          account.type.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Balance and actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Balance
                      Text(
                        account.getFormattedBalance(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: account.balanceColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // Balance trend icon
                      Icon(
                        account.balanceIcon,
                        color: account.balanceColor,
                        size: 16,
                      ),
                    ],
                  ),
                  
                  // Actions menu
                  if (showActions) ...[
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              
              // Expanded details (if expanded)
              if (isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                
                // Additional account details
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        'Status',
                        account.isActive ? 'Active' : 'Inactive',
                        account.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        'Type',
                        account.type.displayName,
                        account.type.color,
                      ),
                    ),
                  ],
                ),
                
                if (account.description != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailItem(
                    context,
                    'Description',
                    account.description!,
                    theme.colorScheme.onSurfaceVariant,
                  ),
                ],
                
                const SizedBox(height: 8),
                _buildDetailItem(
                  context,
                  'Last Updated',
                  _formatDate(account.updatedAt),
                  theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// A compact version of AccountCard for list views
class CompactAccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;

  const CompactAccountCard({
    super.key,
    required this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Account icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: account.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  account.icon,
                  color: account.type.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Account name
              Expanded(
                child: Text(
                  account.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Balance
              Text(
                account.getFormattedBalance(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: account.balanceColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
