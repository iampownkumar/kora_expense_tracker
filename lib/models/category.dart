import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/json_converters.dart';

part 'category.g.dart';

/// Category model representing a transaction category
@JsonSerializable()
class Category {
  /// Unique identifier for the category
  final String id;
  
  /// Category name
  final String name;
  
  /// Category icon
  @IconDataConverter()
  final IconData icon;
  
  /// Category color
  @ColorConverter()
  final Color color;
  
  /// Category type: income, expense, or both
  final String type;
  
  /// Whether this is a default category
  final bool isDefault;
  
  /// Whether the category is active
  final bool isActive;
  
  /// When the category was created
  final DateTime createdAt;
  
  /// When the category was last modified
  final DateTime updatedAt;

  /// Constructor for Category
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new Category with current timestamps
  factory Category.create({
    required String name,
    required IconData icon,
    required Color color,
    required String type,
    bool isDefault = false,
  }) {
    final now = DateTime.now();
    return Category(
      id: _generateId(),
      name: name,
      icon: icon,
      color: color,
      type: type,
      isDefault: isDefault,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a copy of this category with updated fields
  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    String? type,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Check if this category is for income transactions
  bool get isIncome => type == AppConstants.transactionTypeIncome;

  /// Check if this category is for expense transactions
  bool get isExpense => type == AppConstants.transactionTypeExpense;

  /// Check if this category is for both income and expense
  bool get isBoth => type == 'both';

  /// Check if this category can be used for a specific transaction type
  bool canBeUsedFor(String transactionType) {
    if (isBoth) return true;
    return type == transactionType;
  }

  /// Get the category type display name
  String get typeDisplayName {
    switch (type) {
      case AppConstants.transactionTypeIncome:
        return 'Income';
      case AppConstants.transactionTypeExpense:
        return 'Expense';
      case 'both':
        return 'Both';
      default:
        return 'Unknown';
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  /// Create from JSON
  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  /// Generate a unique ID for categories
  static String _generateId() {
    return 'cat_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, type: $type, isDefault: $isDefault)';
  }
}
