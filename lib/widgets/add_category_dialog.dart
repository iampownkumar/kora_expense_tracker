import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/core/constants/app_constants.dart';
import 'package:kora_expense_tracker/core/models/category.dart';
import 'package:kora_expense_tracker/features/transactions/transaction_controller.dart';

class AddCategoryDialog extends StatefulWidget {
  /// If editing an existing category
  final Category? category;

  /// If pre-filled from "Add sub-category" button on a parent
  final Category? parentCategory;

  const AddCategoryDialog({
    super.key,
    this.category,
    this.parentCategory,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _nameController = TextEditingController();
  String _selectedType = AppConstants.transactionTypeExpense;
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.category;

  /// Currently selected parent category id (null = top-level)
  String? _selectedParentId;

  final List<Color> _colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  final List<IconData> _icons = [
    Icons.category,
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.local_gas_station,
    Icons.flight,
    Icons.hotel,
    Icons.local_hospital,
    Icons.school,
    Icons.home,
    Icons.build,
    Icons.sports_esports,
    Icons.pets,
    Icons.directions_car,
    Icons.train,
    Icons.local_grocery_store,
    Icons.movie,
    Icons.music_note,
    Icons.fitness_center,
    Icons.local_cafe,
    Icons.work,
    Icons.wallet,
    Icons.savings,
    Icons.trending_up,
    Icons.payment,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedType = widget.category!.type;
      _selectedColor = widget.category!.color;
      _selectedIcon = widget.category!.icon;
      _selectedParentId = widget.category!.parentCategoryId;
    } else if (widget.parentCategory != null) {
      _selectedParentId = widget.parentCategory!.id;
      _selectedType = widget.parentCategory!.type;
      _selectedColor = widget.parentCategory!.color;
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

    final ctrl = context.read<TransactionController>();

    bool success;
    if (widget.category != null) {
      final updated = widget.category!.copyWith(
        name: name,
        type: _selectedType,
        color: _selectedColor,
        icon: _selectedIcon,
        parentCategoryId: _selectedParentId,
        clearParent: _selectedParentId == null,
      );
      success = await ctrl.updateCategory(updated);
    } else {
      final newCat = Category.create(
        name: name,
        type: _selectedType,
        color: _selectedColor,
        icon: _selectedIcon,
        parentCategoryId: _selectedParentId,
      );
      success = await ctrl.addCategory(newCat);
    }

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<TransactionController>();
    final topLevel = ctrl.topLevelCategories
        .where((c) => widget.category == null || c.id != widget.category!.id)
        .toList();

    final isEditing = widget.category != null;

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
                isEditing ? 'Edit Category' : 'Add Category',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),

              // ── Parent category picker ───────────────────────────────
              if (topLevel.isNotEmpty) ...[
                const Text('Parent Category (optional)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String?>(
                  initialValue: _selectedParentId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    hintText: 'None (top-level category)',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('None (top-level)',
                          style: TextStyle(fontSize: 13)),
                    ),
                    ...topLevel.map(
                      (c) => DropdownMenuItem<String?>(
                        value: c.id,
                        child: Row(
                          children: [
                            Icon(c.icon, color: c.color, size: 16),
                            const SizedBox(width: 8),
                            Text(c.name, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedParentId = val),
                ),
                const SizedBox(height: 14),
              ],

              // Type
              const Text('Type',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: AppConstants.transactionTypeExpense,
                      label: Text('Expense', style: TextStyle(fontSize: 12))),
                  ButtonSegment(
                      value: AppConstants.transactionTypeIncome,
                      label: Text('Income', style: TextStyle(fontSize: 12))),
                  ButtonSegment(
                      value: 'both',
                      label: Text('Both', style: TextStyle(fontSize: 12))),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<String> s) =>
                    setState(() => _selectedType = s.first),
              ),
              const SizedBox(height: 14),

              // Color
              const Text('Color',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        margin: const EdgeInsets.only(right: 7),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == color
                                ? Colors.black
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // Icon
              const Text('Icon',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _icons.length,
                  itemBuilder: (context, index) {
                    final icon = _icons[index];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        margin: const EdgeInsets.only(right: 7),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon
                              ? _selectedColor.withValues(alpha: 0.2)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: _selectedIcon == icon
                              ? _selectedColor
                              : Colors.grey,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Actions
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
