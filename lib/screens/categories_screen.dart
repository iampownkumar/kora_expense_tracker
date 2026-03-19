import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/widgets/add_category_dialog.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final categories = appProvider.categories;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Categories'),
          ),
          body: categories.isEmpty
              ? const Center(child: Text('No categories found.'))
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category.color.withValues(alpha: 0.2),
                        child: Icon(category.icon, color: category.color),
                      ),
                      title: Text(category.name),
                      subtitle: Text(category.typeDisplayName),
                      trailing: category.isDefault 
                          ? const Icon(Icons.lock, size: 16, color: Colors.grey)
                          : IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AddCategoryDialog(
                                    appProvider: appProvider,
                                    category: category,
                                  ),
                                );
                              },
                            ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            heroTag: "categories_fab",
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
}
