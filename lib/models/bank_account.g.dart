// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankAccount _$BankAccountFromJson(Map<String, dynamic> json) => BankAccount(
  id: json['id'] as String,
  accountHolderName: json['accountHolderName'] as String,
  bankName: json['bankName'] as String,
  accountNumber: json['accountNumber'] as String,
  ifscCode: json['ifscCode'] as String,
  accountType: json['accountType'] as String,
  currentBalance: (json['currentBalance'] as num).toDouble(),
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  icon: const IconDataConverter().fromJson(
    json['icon'] as Map<String, dynamic>,
  ),
  isActive: json['isActive'] as bool? ?? true,
  isVerified: json['isVerified'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BankAccountToJson(BankAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountHolderName': instance.accountHolderName,
      'bankName': instance.bankName,
      'accountNumber': instance.accountNumber,
      'ifscCode': instance.ifscCode,
      'accountType': instance.accountType,
      'currentBalance': instance.currentBalance,
      'color': const ColorConverter().toJson(instance.color),
      'icon': const IconDataConverter().toJson(instance.icon),
      'isActive': instance.isActive,
      'isVerified': instance.isVerified,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
