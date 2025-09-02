// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_statement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditCardStatement _$CreditCardStatementFromJson(Map<String, dynamic> json) =>
    CreditCardStatement(
      id: json['id'] as String,
      creditCardId: json['creditCardId'] as String,
      statementNumber: json['statementNumber'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      totalDue: (json['totalDue'] as num).toDouble(),
      minimumDue: (json['minimumDue'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      previousBalance: (json['previousBalance'] as num?)?.toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: json['status'] as String? ?? 'Pending',
      interestCharges: (json['interestCharges'] as num?)?.toDouble(),
      lateFees: (json['lateFees'] as num?)?.toDouble(),
      overLimitFees: (json['overLimitFees'] as num?)?.toDouble(),
      purchases: (json['purchases'] as num?)?.toDouble(),
      cashAdvances: (json['cashAdvances'] as num?)?.toDouble(),
      balanceTransfers: (json['balanceTransfers'] as num?)?.toDouble(),
      fees: (json['fees'] as num?)?.toDouble(),
      adjustments: (json['adjustments'] as num?)?.toDouble(),
      paidDate: json['paidDate'] == null
          ? null
          : DateTime.parse(json['paidDate'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CreditCardStatementToJson(
  CreditCardStatement instance,
) => <String, dynamic>{
  'id': instance.id,
  'creditCardId': instance.creditCardId,
  'statementNumber': instance.statementNumber,
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'totalDue': instance.totalDue,
  'minimumDue': instance.minimumDue,
  'paidAmount': instance.paidAmount,
  'previousBalance': instance.previousBalance,
  'dueDate': instance.dueDate.toIso8601String(),
  'status': instance.status,
  'interestCharges': instance.interestCharges,
  'lateFees': instance.lateFees,
  'overLimitFees': instance.overLimitFees,
  'purchases': instance.purchases,
  'cashAdvances': instance.cashAdvances,
  'balanceTransfers': instance.balanceTransfers,
  'fees': instance.fees,
  'adjustments': instance.adjustments,
  'paidDate': instance.paidDate?.toIso8601String(),
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
