// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  id: json['id'] as String,
  name: json['name'] as String,
  icon: const IconDataConverter().fromJson(
    json['icon'] as Map<String, dynamic>,
  ),
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  balance: (json['balance'] as num).toDouble(),
  type: $enumDecode(_$AccountTypeEnumMap, json['type']),
  description: json['description'] as String?,
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': const IconDataConverter().toJson(instance.icon),
  'color': const ColorConverter().toJson(instance.color),
  'balance': instance.balance,
  'type': _$AccountTypeEnumMap[instance.type]!,
  'description': instance.description,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$AccountTypeEnumMap = {
  AccountType.savings: 'savings',
  AccountType.wallet: 'wallet',
  AccountType.creditCard: 'creditCard',
  AccountType.cash: 'cash',
  AccountType.investment: 'investment',
  AccountType.loan: 'loan',
};
