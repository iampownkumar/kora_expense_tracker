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
      previousBalance: (json['previousBalance'] as num).toDouble(),
      paymentsAndCredits: (json['paymentsAndCredits'] as num).toDouble(),
      purchases: (json['purchases'] as num).toDouble(),
      cashAdvances: (json['cashAdvances'] as num).toDouble(),
      interestCharges: (json['interestCharges'] as num).toDouble(),
      feesAndCharges: (json['feesAndCharges'] as num).toDouble(),
      newBalance: (json['newBalance'] as num).toDouble(),
      minimumPaymentDue: (json['minimumPaymentDue'] as num).toDouble(),
      paymentDueDate: DateTime.parse(json['paymentDueDate'] as String),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      lateFees: (json['lateFees'] as num?)?.toDouble() ?? 0.0,
      overLimitFees: (json['overLimitFees'] as num?)?.toDouble() ?? 0.0,
      balanceTransfers: (json['balanceTransfers'] as num?)?.toDouble() ?? 0.0,
      fees: (json['fees'] as num?)?.toDouble() ?? 0.0,
      adjustments: (json['adjustments'] as num?)?.toDouble() ?? 0.0,
      paidDate: json['paidDate'] == null
          ? null
          : DateTime.parse(json['paidDate'] as String),
      notes: json['notes'] as String?,
      generatedDate: DateTime.parse(json['generatedDate'] as String),
      status: $enumDecode(_$StatementStatusEnumMap, json['status']),
      isViewed: json['isViewed'] as bool? ?? false,
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
  'previousBalance': instance.previousBalance,
  'paymentsAndCredits': instance.paymentsAndCredits,
  'purchases': instance.purchases,
  'cashAdvances': instance.cashAdvances,
  'interestCharges': instance.interestCharges,
  'feesAndCharges': instance.feesAndCharges,
  'newBalance': instance.newBalance,
  'minimumPaymentDue': instance.minimumPaymentDue,
  'paymentDueDate': instance.paymentDueDate.toIso8601String(),
  'paidAmount': instance.paidAmount,
  'lateFees': instance.lateFees,
  'overLimitFees': instance.overLimitFees,
  'balanceTransfers': instance.balanceTransfers,
  'fees': instance.fees,
  'adjustments': instance.adjustments,
  'paidDate': instance.paidDate?.toIso8601String(),
  'notes': instance.notes,
  'generatedDate': instance.generatedDate.toIso8601String(),
  'status': _$StatementStatusEnumMap[instance.status]!,
  'isViewed': instance.isViewed,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$StatementStatusEnumMap = {
  StatementStatus.generated: 'generated',
  StatementStatus.viewed: 'viewed',
  StatementStatus.paid: 'paid',
  StatementStatus.overdue: 'overdue',
};
