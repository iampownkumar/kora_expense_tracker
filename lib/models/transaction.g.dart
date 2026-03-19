// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: json['id'] as String,
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String,
  categoryId: json['categoryId'] as String,
  accountId: json['accountId'] as String,
  toAccountId: json['toAccountId'] as String?,
  notes: json['notes'] as String?,
  imagePath: json['imagePath'] as String?,
  date: DateTime.parse(json['date'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'description': instance.description,
      'categoryId': instance.categoryId,
      'accountId': instance.accountId,
      'toAccountId': instance.toAccountId,
      'notes': instance.notes,
      'imagePath': instance.imagePath,
      'date': instance.date.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
