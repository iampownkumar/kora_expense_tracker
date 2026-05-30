import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/models/category.dart';
import 'package:kora_expense_tracker/widgets/add_category_dialog.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // Tracks which parent category IDs are expanded
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final topLevel = appProvider.topLevelCategories;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Categories'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(
                    '${topLevel.length} categories'
                    '${appProvider.subCategoryCount > 0 ? " · ${appProvider.subCategoryCount} sub" : ""}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          body: topLevel.isEmpty
              ? const Center(child: Text('No categories found.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: topLevel.length,
                  itemBuilder: (context, index) {
                    final parent = topLevel[index];
                    final subCats =
                        appProvider.getSubCategories(parent.id);
                    final hasChildren = subCats.isNotEmpty;
                    final isExpanded = _expanded.contains(parent.id);

                    return _buildParentTile(
                      context,
                      appProvider,
                      parent,
                      subCats,
                      hasChildren,
                      isExpanded,
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'categories_fab',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddCategoryDialog(
                  appProvider: appProvider,
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildParentTile(
    BuildContext context,
    AppProvider appProvider,
    Category parent,
    List<Category> subCats,
    bool hasChildren,
    bool isExpanded,
  ) {
    final theme = Theme.of(context);

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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: parent.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    parent.typeDisplayName,
                    style: TextStyle(
                        fontSize: 10,
                        color: parent.color,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                if (hasChildren) ...[
                  const SizedBox(width: 6),
                  Text(
                    '${subCats.length} sub-categor${subCats.length == 1 ? "y" : "ies"}',
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
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _editCategory(context, appProvider, parent),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                // Add sub-category button
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  onPressed: () =>
                      _addSubCategory(context, appProvider, parent),
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
            ...subCats.map((sub) => _buildSubTile(context, appProvider, sub)),
          ],
        ],
      ),
    );
  }

  Widget _buildSubTile(
    BuildContext context,
    AppProvider appProvider,
    Category sub,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 48, right: 16),
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: sub.color.withValues(alpha: 0.12),
        child: Icon(sub.icon, color: sub.color, size: 14),
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
              icon: const Icon(Icons.edit, size: 16),
              onPressed: () => _editCategory(context, appProvider, sub),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          if (!sub.isDefault)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 16),
              onPressed: () => _deleteCategory(context, appProvider, sub),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  void _editCategory(
      BuildContext context, AppProvider appProvider, Category category) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        appProvider: appProvider,
        category: category,
      ),
    );
  }

  void _addSubCategory(
      BuildContext context, AppProvider appProvider, Category parent) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        appProvider: appProvider,
        parentCategory: parent,
      ),
    ).then((_) {
      // Expand parent after adding a sub-category
      if (mounted) {
        setState(() => _expanded.add(parent.id));
      }
    });
  }

  void _deleteCategory(
      BuildContext context, AppProvider appProvider, Category category) {
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
              appProvider.deleteCategory(category.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
