// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: json['id'] as String,
  creditCardId: json['creditCardId'] as String,
  statementId: json['statementId'] as String?,
  amount: (json['amount'] as num).toDouble(),
  paymentDate: DateTime.parse(json['paymentDate'] as String),
  paymentMethod: json['paymentMethod'] as String,
  status: json['status'] as String,
  referenceNumber: json['referenceNumber'] as String?,
  notes: json['notes'] as String?,
  bankAccountId: json['bankAccountId'] as String?,
  processingFee: (json['processingFee'] as num?)?.toDouble() ?? 0.0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'creditCardId': instance.creditCardId,
  'statementId': instance.statementId,
  'amount': instance.amount,
  'paymentDate': instance.paymentDate.toIso8601String(),
  'paymentMethod': instance.paymentMethod,
  'status': instance.status,
  'referenceNumber': instance.referenceNumber,
  'notes': instance.notes,
  'bankAccountId': instance.bankAccountId,
  'processingFee': instance.processingFee,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
