// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditCard _$CreditCardFromJson(Map<String, dynamic> json) => CreditCard(
  id: json['id'] as String,
  name: json['name'] as String,
  network: json['network'] as String,
  type: json['type'] as String,
  lastFourDigits: json['lastFourDigits'] as String,
  cardholderName: json['cardholderName'] as String?,
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
  creditLimit: (json['creditLimit'] as num).toDouble(),
  outstandingBalance: (json['outstandingBalance'] as num).toDouble(),
  availableCredit: (json['availableCredit'] as num).toDouble(),
  interestRate: (json['interestRate'] as num).toDouble(),
  minimumPaymentPercentage: (json['minimumPaymentPercentage'] as num)
      .toDouble(),
  gracePeriodDays: (json['gracePeriodDays'] as num).toInt(),
  billingCycleDay: (json['billingCycleDay'] as num).toInt(),
  nextBillingDate: json['nextBillingDate'] == null
      ? null
      : DateTime.parse(json['nextBillingDate'] as String),
  nextDueDate: json['nextDueDate'] == null
      ? null
      : DateTime.parse(json['nextDueDate'] as String),
  lastPaymentDate: json['lastPaymentDate'] == null
      ? null
      : DateTime.parse(json['lastPaymentDate'] as String),
  lastPaymentAmount: (json['lastPaymentAmount'] as num?)?.toDouble(),
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  icon: const IconDataConverter().fromJson(
    json['icon'] as Map<String, dynamic>,
  ),
  bankName: json['bankName'] as String?,
  isActive: json['isActive'] as bool,
  autoGenerateStatements: json['autoGenerateStatements'] as bool,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CreditCardToJson(CreditCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'network': instance.network,
      'type': instance.type,
      'lastFourDigits': instance.lastFourDigits,
      'cardholderName': instance.cardholderName,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'creditLimit': instance.creditLimit,
      'outstandingBalance': instance.outstandingBalance,
      'availableCredit': instance.availableCredit,
      'interestRate': instance.interestRate,
      'minimumPaymentPercentage': instance.minimumPaymentPercentage,
      'gracePeriodDays': instance.gracePeriodDays,
      'billingCycleDay': instance.billingCycleDay,
      'nextBillingDate': instance.nextBillingDate?.toIso8601String(),
      'nextDueDate': instance.nextDueDate?.toIso8601String(),
      'lastPaymentDate': instance.lastPaymentDate?.toIso8601String(),
      'lastPaymentAmount': instance.lastPaymentAmount,
      'color': const ColorConverter().toJson(instance.color),
      'icon': const IconDataConverter().toJson(instance.icon),
      'bankName': instance.bankName,
      'isActive': instance.isActive,
      'autoGenerateStatements': instance.autoGenerateStatements,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
