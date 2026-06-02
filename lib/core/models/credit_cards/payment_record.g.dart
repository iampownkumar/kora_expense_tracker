// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRecord _$PaymentRecordFromJson(Map<String, dynamic> json) =>
    PaymentRecord(
      id: json['id'] as String,
      creditCardId: json['creditCardId'] as String,
      statementId: json['statementId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      paymentMethod: json['paymentMethod'] as String,
      sourceAccountId: json['sourceAccountId'] as String?,
      status: json['status'] as String? ?? 'Completed',
      transactionReference: json['transactionReference'] as String?,
      notes: json['notes'] as String?,
      isMinimumPayment: json['isMinimumPayment'] as bool? ?? false,
      isFullPayment: json['isFullPayment'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PaymentRecordToJson(PaymentRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creditCardId': instance.creditCardId,
      'statementId': instance.statementId,
      'amount': instance.amount,
      'paymentDate': instance.paymentDate.toIso8601String(),
      'paymentMethod': instance.paymentMethod,
      'sourceAccountId': instance.sourceAccountId,
      'status': instance.status,
      'transactionReference': instance.transactionReference,
      'notes': instance.notes,
      'isMinimumPayment': instance.isMinimumPayment,
      'isFullPayment': instance.isFullPayment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
