import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/core/models/transactions/transaction.dart';
import 'package:kora_expense_tracker/core/models/categories/category.dart';
import 'package:kora_expense_tracker/core/models/accounts/account.dart';
import 'package:kora_expense_tracker/core/constants/app_constants.dart';
import 'package:kora_expense_tracker/core/utils/formatters.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final Account? account;
  final Account? toAccount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool enableSwipeToDelete;

  /// Compact mode: smaller height, no image thumbnail, no notes text
  final bool compact;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.category,
    this.account,
    this.toAccount,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.enableSwipeToDelete = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 36.0 : 48.0;
    final iconInnerSize = compact ? 18.0 : 24.0;
    final itemPadding = compact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : const EdgeInsets.all(AppConstants.defaultPadding);

    final cardWidget = Card(
      margin: EdgeInsets.only(bottom: compact ? 4 : AppConstants.smallPadding),
      child: InkWell(
        onTap: onTap ?? onEdit,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: itemPadding,
          child: Row(
            children: [
              // ── Category Icon ────────────────────────────────────────────
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: (category?.color ?? AppConstants.primaryColor)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(compact ? 8 : 12),
                ),
                child: Icon(
                  category?.icon ?? Icons.category,
                  color: category?.color ?? AppConstants.primaryColor,
                  size: iconInnerSize,
                ),
              ),
              SizedBox(width: compact ? 10 : AppConstants.defaultPadding),

              // ── Transaction Details ──────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Text(
                      transaction.description,
                      style: (compact
                              ? Theme.of(context).textTheme.bodyMedium
                              : Theme.of(context).textTheme.titleMedium)
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!compact) const SizedBox(height: 4),

                    // Account row
                    Row(
                      children: [
                        Icon(
                          account?.icon ?? Icons.account_balance,
                          color: account?.color ?? Colors.grey,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            account?.name ?? 'Unknown Account',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (transaction.isTransfer && toAccount != null) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            toAccount?.icon ?? Icons.account_balance,
                            color: toAccount?.color ?? Colors.grey,
                            size: 13,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              toAccount?.name ?? '',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Date + notes row
                    if (!compact) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            Formatters.formatDate(transaction.date),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (transaction.notes != null &&
                              transaction.notes!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.note,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                transaction.notes!,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ] else ...[
                      // Compact: tiny date + indicator icons for notes/image
                      Row(
                        children: [
                          Text(
                            Formatters.formatDate(transaction.date),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                          if (transaction.notes != null &&
                              transaction.notes!.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Icon(
                                Icons.note_outlined,
                                size: 10,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ── Image thumbnail (shown in both modes; smaller in compact) ──
              if (transaction.imagePath != null &&
                  transaction.imagePath!.isNotEmpty) ...[
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: EdgeInsets.zero,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(color: Colors.black87),
                            ),
                            InteractiveViewer(
                              panEnabled: true,
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: Image.file(
                                File(transaction.imagePath!),
                                fit: BoxFit.contain,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                              ),
                            ),
                            Positioned(
                              top: 40,
                              right: 20,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                padding: const EdgeInsets.all(8),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(transaction.imagePath!),
                      // 32px in compact, 44px in full
                      width: compact ? 32 : 44,
                      height: compact ? 32 : 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // ── Amount ───────────────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(transaction.displayAmount),
                    style: (compact
                            ? Theme.of(context).textTheme.bodyMedium
                            : Theme.of(context).textTheme.titleMedium)
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: transaction.typeColor,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: transaction.typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transaction.typeDisplayName,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: transaction.typeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap with Dismissible for swipe-to-delete
    if (enableSwipeToDelete && onDelete != null) {
      return Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppConstants.errorColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: const Icon(Icons.delete, color: Colors.white, size: 24),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Transaction'),
              content: Text(
                'Are you sure you want to delete "${transaction.description}"?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppConstants.errorColor,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ) ?? false;
        },
        onDismissed: (direction) {
          onDelete?.call();
        },
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}