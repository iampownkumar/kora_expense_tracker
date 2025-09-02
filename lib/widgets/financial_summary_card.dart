import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/models/account_type.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';

/// A widget that displays financial health summary at the top of accounts screen
class FinancialSummaryCard extends StatelessWidget {
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;
  final Map<AccountType, int> accountCounts;
  final VoidCallback? onTap;

  const FinancialSummaryCard({
    super.key,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.accountCounts,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: AppConstants.cardElevation + 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Financial Health',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.touch_app,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Net Worth (main metric)
              Center(
                child: Column(
                  children: [
                    Text(
                      'Net Worth',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(netWorth),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: _getNetWorthColor(netWorth, theme),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getNetWorthIcon(netWorth),
                          color: _getNetWorthColor(netWorth, theme),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getNetWorthStatus(netWorth),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getNetWorthColor(netWorth, theme),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Assets vs Liabilities breakdown
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Assets',
                      _formatCurrency(totalAssets),
                      Colors.green,
                      Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Liabilities',
                      _formatCurrency(totalLiabilities),
                      Colors.red,
                      Icons.trending_down,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Account type breakdown
              _buildAccountTypeBreakdown(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeBreakdown(BuildContext context) {
    final theme = Theme.of(context);
    final totalAccounts = accountCounts.values.fold(0, (sum, count) => sum + count);
    
    if (totalAccounts == 0) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Summary',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: accountCounts.entries
              .where((entry) => entry.value > 0)
              .map((entry) => _buildAccountTypeChip(context, entry.key, entry.value))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAccountTypeChip(BuildContext context, AccountType type, int count) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: type.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: type.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            type.icon,
            color: type.color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '$count ${type.displayName}${count > 1 ? 's' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: type.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final absAmount = amount.abs();
    final symbol = AppConstants.defaultCurrencySymbol;
    
    if (absAmount >= 10000000) {
      return '$symbol${(absAmount / 10000000).toStringAsFixed(1)}Cr';
    } else if (absAmount >= 100000) {
      return '$symbol${(absAmount / 100000).toStringAsFixed(1)}L';
    } else if (absAmount >= 1000) {
      return '$symbol${(absAmount / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol${absAmount.toStringAsFixed(0)}';
    }
  }

  Color _getNetWorthColor(double netWorth, ThemeData theme) {
    if (netWorth > 0) return Colors.green;
    if (netWorth < 0) return Colors.red;
    return theme.colorScheme.onSurfaceVariant;
  }

  IconData _getNetWorthIcon(double netWorth) {
    if (netWorth > 0) return Icons.trending_up;
    if (netWorth < 0) return Icons.trending_down;
    return Icons.remove;
  }

  String _getNetWorthStatus(double netWorth) {
    if (netWorth > 0) return 'Positive';
    if (netWorth < 0) return 'Negative';
    return 'Neutral';
  }
}
