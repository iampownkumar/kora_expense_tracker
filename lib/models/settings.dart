import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

part 'settings.g.dart';

/// Settings model representing user preferences and app configuration
@JsonSerializable()
class Settings {
  /// Theme mode: light, dark, or system
  final String themeMode;
  
  /// Currency code (e.g., 'INR', 'USD')
  final String currency;
  
  /// Locale code (e.g., 'en', 'hi', 'ta')
  final String locale;
  
  /// Whether to show notifications
  final bool showNotifications;
  
  /// Whether to show balance in app bar
  final bool showBalanceInAppBar;
  
  /// Whether to show category icons in transaction list
  final bool showCategoryIcons;
  
  /// Whether to show account icons in transaction list
  final bool showAccountIcons;
  
  /// Default transaction type for new transactions
  final String defaultTransactionType;
  
  /// Whether to auto-categorize transactions
  final bool autoCategorize;
  
  /// Whether to show transfer transactions separately
  final bool showTransfersSeparately;
  
  /// Number of recent transactions to show on home screen
  final int recentTransactionsCount;
  
  /// When the settings were last modified
  final DateTime updatedAt;

  /// Constructor for Settings
  const Settings({
    required this.themeMode,
    required this.currency,
    required this.locale,
    required this.showNotifications,
    required this.showBalanceInAppBar,
    required this.showCategoryIcons,
    required this.showAccountIcons,
    required this.defaultTransactionType,
    required this.autoCategorize,
    required this.showTransfersSeparately,
    required this.recentTransactionsCount,
    required this.updatedAt,
  });

  /// Create default settings
  factory Settings.defaults() {
    return Settings(
      themeMode: 'system',
      currency: AppConstants.defaultCurrency,
      locale: AppConstants.defaultLocale,
      showNotifications: true,
      showBalanceInAppBar: true,
      showCategoryIcons: true,
      showAccountIcons: true,
      defaultTransactionType: AppConstants.transactionTypeExpense,
      autoCategorize: false,
      showTransfersSeparately: true,
      recentTransactionsCount: 10,
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy of this settings with updated fields
  Settings copyWith({
    String? themeMode,
    String? currency,
    String? locale,
    bool? showNotifications,
    bool? showBalanceInAppBar,
    bool? showCategoryIcons,
    bool? showAccountIcons,
    String? defaultTransactionType,
    bool? autoCategorize,
    bool? showTransfersSeparately,
    int? recentTransactionsCount,
    DateTime? updatedAt,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      showNotifications: showNotifications ?? this.showNotifications,
      showBalanceInAppBar: showBalanceInAppBar ?? this.showBalanceInAppBar,
      showCategoryIcons: showCategoryIcons ?? this.showCategoryIcons,
      showAccountIcons: showAccountIcons ?? this.showAccountIcons,
      defaultTransactionType: defaultTransactionType ?? this.defaultTransactionType,
      autoCategorize: autoCategorize ?? this.autoCategorize,
      showTransfersSeparately: showTransfersSeparately ?? this.showTransfersSeparately,
      recentTransactionsCount: recentTransactionsCount ?? this.recentTransactionsCount,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Get the theme mode as ThemeMode enum
  ThemeMode get themeModeEnum {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Get the currency symbol
  String get currencySymbol {
    switch (currency) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currency;
    }
  }

  /// Get the locale as Locale object
  Locale get localeObject {
    return Locale(locale);
  }

  /// Check if dark mode is enabled
  bool get isDarkMode {
    return themeMode == 'dark';
  }

  /// Check if light mode is enabled
  bool get isLightMode {
    return themeMode == 'light';
  }

  /// Check if system theme is enabled
  bool get isSystemTheme {
    return themeMode == 'system';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  /// Create from JSON
  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings && other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => updatedAt.hashCode;

  @override
  String toString() {
    return 'Settings(themeMode: $themeMode, currency: $currency, locale: $locale)';
  }
}
