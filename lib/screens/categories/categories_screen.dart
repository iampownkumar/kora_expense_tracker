import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/features/transactions/transaction_controller.dart';
import 'package:kora_expense_tracker/core/models/categories/category.dart';
import 'package:kora_expense_tracker/core/constants/app_constants.dart';
import 'package:kora_expense_tracker/widgets/add_category_dialog.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // Filter: 'all' | 'income' | 'expense' | 'both'
  String _filter = 'all';

  // Tracks which parent category IDs are expanded
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionController>(
      builder: (context, txnCtrl, child) {
        // Apply filter to top-level categories
        final allTop = txnCtrl.topLevelCategories;
        final filtered = _filter == 'all'
            ? allTop
            : allTop.where((c) => c.type == _filter).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Categories'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(
                    '${allTop.length} cat'
                    '${txnCtrl.subCategoryCount > 0 ? " · ${txnCtrl.subCategoryCount} sub" : ""}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Filter chips ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip(context, label: 'All', value: 'all',
                          icon: Icons.apps, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      _filterChip(context, label: 'Income', value: AppConstants.categoryTypeIncome,
                          icon: Icons.arrow_upward, color: Colors.green),
                      const SizedBox(width: 8),
                      _filterChip(context, label: 'Expense', value: AppConstants.categoryTypeExpense,
                          icon: Icons.arrow_downward, color: Colors.red),
                      const SizedBox(width: 8),
                      _filterChip(context, label: 'Both', value: AppConstants.categoryTypeBoth,
                          icon: Icons.swap_vert, color: Colors.purple),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),

              // ── Category list ────────────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.category_outlined,
                                size: 48,
                                color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text('No categories found',
                                style: Theme.of(context).textTheme.bodyLarge),
                            const SizedBox(height: 6),
                            TextButton.icon(
                              onPressed: () => _addCategory(context, txnCtrl),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Category'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final parent = filtered[index];
                          final subCats = txnCtrl.getSubCategories(parent.id);
                          final hasChildren = subCats.isNotEmpty;
                          final isExpanded = _expanded.contains(parent.id);
                          return _buildParentTile(
                            context, txnCtrl, parent, subCats, hasChildren, isExpanded,
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'categories_fab',
            onPressed: () => _addCategory(context, txnCtrl),
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
          ),
        );
      },
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _filter == value;
    return FilterChip(
      selected: isSelected,
      avatar: Icon(icon,
          size: 14,
          color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant),
      label: Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
          )),
      selectedColor: color.withValues(alpha: 0.15),
      checkmarkColor: color,
      side: isSelected
          ? BorderSide(color: color, width: 1.5)
          : BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  void _addCategory(BuildContext context, TransactionController txnCtrl) {
    showDialog(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );
  }

  Widget _buildParentTile(
    BuildContext context,
    TransactionController txnCtrl,
    Category parent,
    List<Category> subCats,
    bool hasChildren,
    bool isExpanded,
  ) {
    final theme = Theme.of(context);

    // Determine type color
    Color typeColor;
    if (parent.type == AppConstants.categoryTypeIncome) {
      typeColor = Colors.green;
    } else if (parent.type == AppConstants.categoryTypeExpense) {
      typeColor = Colors.red;
    } else {
      typeColor = Colors.purple;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Parent row ───────────────────────────────────────────────
          ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: parent.color.withValues(alpha: 0.15),
              child: Icon(parent.icon, color: parent.color, size: 18),
            ),
            title: Text(
              parent.name,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    parent.typeDisplayName,
                    style: TextStyle(
                        fontSize: 10,
                        color: typeColor,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                if (hasChildren) ...[
                  const SizedBox(width: 6),
                  Text(
                    '${subCats.length} sub',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!parent.isDefault)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => _editCategory(context, txnCtrl, parent),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    tooltip: 'Edit',
                  ),
                // Add sub-category button
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  onPressed: () => _addSubCategory(context, txnCtrl, parent),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  tooltip: 'Add sub-category',
                ),
                if (hasChildren)
                  IconButton(
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isExpanded) {
                          _expanded.remove(parent.id);
                        } else {
                          _expanded.add(parent.id);
                        }
                      });
                    },
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  )
                else
                  const SizedBox(width: 8),
              ],
            ),
          ),

          // ── Sub-category rows (expandable) ───────────────────────────
          if (hasChildren && isExpanded) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            ...subCats.map((sub) => _buildSubTile(context, txnCtrl, sub)),
          ],
        ],
      ),
    );
  }

  Widget _buildSubTile(
    BuildContext context,
    TransactionController txnCtrl,
    Category sub,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 52, right: 16),
      leading: CircleAvatar(
        radius: 13,
        backgroundColor: sub.color.withValues(alpha: 0.12),
        child: Icon(sub.icon, color: sub.color, size: 13),
      ),
      title: Text(sub.name, style: theme.textTheme.bodySmall),
      subtitle: Text(
        sub.typeDisplayName,
        style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!sub.isDefault)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 16),
              onPressed: () => _editCategory(context, txnCtrl, sub),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          if (!sub.isDefault)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 16),
              onPressed: () => _deleteCategory(context, txnCtrl, sub),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              color: Colors.red.withValues(alpha: 0.7),
            ),
        ],
      ),
    );
  }

  void _editCategory(
      BuildContext context, TransactionController txnCtrl, Category category) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(category: category),
    );
  }

  void _addSubCategory(
      BuildContext context, TransactionController txnCtrl, Category parent) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(parentCategory: parent),
    ).then((_) {
      if (mounted) setState(() => _expanded.add(parent.id));
    });
  }

  void _deleteCategory(
      BuildContext context, TransactionController txnCtrl, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sub-Category'),
        content: Text('Delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              txnCtrl.deleteCategory(category.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
