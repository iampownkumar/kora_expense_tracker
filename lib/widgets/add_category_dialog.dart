import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/models/category.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';

class AddCategoryDialog extends StatefulWidget {
  final AppProvider appProvider;
  final Category? category;

  const AddCategoryDialog({
    super.key,
    required this.appProvider,
    this.category,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _nameController = TextEditingController();
  String _selectedType = AppConstants.transactionTypeExpense;
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.category;

  final List<Color> _colors = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.blueGrey,
  ];

  final List<IconData> _icons = [
    Icons.category, Icons.shopping_cart, Icons.restaurant, Icons.local_gas_station,
    Icons.flight, Icons.hotel, Icons.local_hospital, Icons.school,
    Icons.home, Icons.build, Icons.sports_esports, Icons.pets,
    Icons.directions_car, Icons.train, Icons.local_grocery_store, Icons.movie,
    Icons.music_note, Icons.fitness_center, Icons.local_cafe, Icons.work,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedType = widget.category!.type;
      _selectedColor = widget.category!.color;
      _selectedIcon = widget.category!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    bool success;
    if (widget.category != null) {
      final updatedCategory = widget.category!.copyWith(
        name: name,
        type: _selectedType,
        color: _selectedColor,
        icon: _selectedIcon,
      );
      success = await widget.appProvider.updateCategory(updatedCategory);
    } else {
      final newCategory = Category.create(
        name: name,
        type: _selectedType,
        color: _selectedColor,
        icon: _selectedIcon,
      );
      success = await widget.appProvider.addCategory(newCategory);
    }

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.category == null ? 'Add Category' : 'Edit Category',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              
              const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: AppConstants.transactionTypeExpense, label: Text('Expense')),
                  ButtonSegment(value: AppConstants.transactionTypeIncome, label: Text('Income')),
                  ButtonSegment(value: 'both', label: Text('Both')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == color ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              const Text('Icon', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _icons.length,
                  itemBuilder: (context, index) {
                    final icon = _icons[index];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon ? Theme.of(context).primaryColor.withValues(alpha: 0.2) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: _selectedIcon == icon ? Theme.of(context).primaryColor : Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveCategory,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
