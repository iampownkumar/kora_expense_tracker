import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility class for formatting various data types
class Formatters {
  /// Format currency amount with proper symbol and locale
  static String formatCurrency(double amount, {String? currency, String? locale}) {
    final currencyCode = currency ?? AppConstants.defaultCurrency;
    final localeCode = locale ?? AppConstants.defaultLocale;
    
    final formatter = NumberFormat.currency(
      locale: localeCode,
      symbol: _getCurrencySymbol(currencyCode),
      decimalDigits: 2,
    );
    
    return formatter.format(amount);
  }

  /// Format date for display
  static String formatDate(DateTime date, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = DateFormat(AppConstants.displayDateFormat, localeCode);
    return formatter.format(date);
  }

  /// Format date and time for display
  static String formatDateTime(DateTime dateTime, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = DateFormat(AppConstants.dateTimeFormat, localeCode);
    return formatter.format(dateTime);
  }

  /// Format time for display
  static String formatTime(DateTime time, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = DateFormat(AppConstants.timeFormat, localeCode);
    return formatter.format(time);
  }

  /// Format number with proper locale
  static String formatNumber(double number, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = NumberFormat.decimalPattern(localeCode);
    return formatter.format(number);
  }

  /// Format percentage
  static String formatPercentage(double percentage, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = NumberFormat.percentPattern(localeCode);
    return formatter.format(percentage / 100);
  }

  /// Get relative time (e.g., "2 hours ago", "yesterday")
  static String getRelativeTime(DateTime dateTime, {String? locale}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return formatDate(dateTime, locale: locale);
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get currency symbol for given currency code
  static String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      case 'CHF':
        return 'CHF';
      case 'CNY':
        return '¥';
      case 'KRW':
        return '₩';
      default:
        return currencyCode;
    }
  }

  /// Validate currency code
  static bool isValidCurrencyCode(String currencyCode) {
    final validCurrencies = [
      'INR', 'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'KRW'
    ];
    return validCurrencies.contains(currencyCode.toUpperCase());
  }

  /// Validate locale code
  static bool isValidLocaleCode(String localeCode) {
    try {
      Intl.verifiedLocale(localeCode, (locale) => true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get month name
  static String getMonthName(int month, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = DateFormat('MMMM', localeCode);
    final date = DateTime(2024, month);
    return formatter.format(date);
  }

  /// Get day name
  static String getDayName(DateTime date, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = DateFormat('EEEE', localeCode);
    return formatter.format(date);
  }

  /// Get short day name
  static String getShortDayName(DateTime date, {String? locale}) {
    final localeCode = locale ?? AppConstants.defaultLocale;
    final formatter = DateFormat('EEE', localeCode);
    return formatter.format(date);
  }
}
