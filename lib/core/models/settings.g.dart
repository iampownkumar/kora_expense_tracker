// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
  themeMode: json['themeMode'] as String,
  currency: json['currency'] as String,
  locale: json['locale'] as String,
  showNotifications: json['showNotifications'] as bool,
  showBalanceInAppBar: json['showBalanceInAppBar'] as bool,
  showCategoryIcons: json['showCategoryIcons'] as bool,
  showAccountIcons: json['showAccountIcons'] as bool,
  defaultTransactionType: json['defaultTransactionType'] as String,
  autoCategorize: json['autoCategorize'] as bool,
  showTransfersSeparately: json['showTransfersSeparately'] as bool,
  recentTransactionsCount: (json['recentTransactionsCount'] as num).toInt(),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
  'themeMode': instance.themeMode,
  'currency': instance.currency,
  'locale': instance.locale,
  'showNotifications': instance.showNotifications,
  'showBalanceInAppBar': instance.showBalanceInAppBar,
  'showCategoryIcons': instance.showCategoryIcons,
  'showAccountIcons': instance.showAccountIcons,
  'defaultTransactionType': instance.defaultTransactionType,
  'autoCategorize': instance.autoCategorize,
  'showTransfersSeparately': instance.showTransfersSeparately,
  'recentTransactionsCount': instance.recentTransactionsCount,
  'updatedAt': instance.updatedAt.toIso8601String(),
};
