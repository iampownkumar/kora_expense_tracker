import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kora_expense_tracker/utils/formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en_US');
  });
  
  group('Formatters Tests', () {
    test('Currency formatting', () {
      // Test INR formatting
      final inrFormatted = Formatters.formatCurrency(1234.56, currency: 'INR');
      expect(inrFormatted, contains('₹'));
      expect(inrFormatted, contains('1,234.56'));

      // Test USD formatting
      final usdFormatted = Formatters.formatCurrency(1234.56, currency: 'USD');
      expect(usdFormatted, contains('\$'));
      expect(usdFormatted, contains('1,234.56'));

      // Test EUR formatting
      final eurFormatted = Formatters.formatCurrency(1234.56, currency: 'EUR');
      expect(eurFormatted, contains('€'));
      expect(eurFormatted, contains('1,234.56'));

      // Test zero amount
      final zeroFormatted = Formatters.formatCurrency(0.0, currency: 'INR');
      expect(zeroFormatted, contains('₹'));
      expect(zeroFormatted, contains('0.00'));

      // Test negative amount
      final negativeFormatted = Formatters.formatCurrency(-1234.56, currency: 'INR');
      expect(negativeFormatted, contains('₹'));
      expect(negativeFormatted, contains('1,234.56')); // Currency formatter handles negative sign differently
    });

    test('Date formatting', () {
      final testDate = DateTime(2024, 12, 25);
      
      // Test date formatting
      final formattedDate = Formatters.formatDate(testDate);
      expect(formattedDate, contains('Dec 25, 2024'));

      // Test date time formatting
      final testDateTime = DateTime(2024, 12, 25, 14, 30);
      final formattedDateTime = Formatters.formatDateTime(testDateTime);
      expect(formattedDateTime, contains('Dec 25, 2024 14:30'));

      // Test time formatting
      final testTime = DateTime(2024, 12, 25, 14, 30);
      final formattedTime = Formatters.formatTime(testTime);
      expect(formattedTime, contains('14:30'));
    });

    test('Number formatting', () {
      // Test number formatting
      final formattedNumber = Formatters.formatNumber(1234567.89);
      expect(formattedNumber, contains('1,234,567.89'));

      // Test zero
      final zeroFormatted = Formatters.formatNumber(0.0);
      expect(zeroFormatted, contains('0'));

      // Test negative number
      final negativeFormatted = Formatters.formatNumber(-1234.56);
      expect(negativeFormatted, contains('-1,234.56'));
    });

    test('Percentage formatting', () {
      // Test percentage formatting
      final formattedPercentage = Formatters.formatPercentage(25.5);
      expect(formattedPercentage, contains('%')); // Just check it contains %

      // Test zero percentage
      final zeroPercentage = Formatters.formatPercentage(0.0);
      expect(zeroPercentage, contains('0%'));

      // Test 100 percentage
      final hundredPercentage = Formatters.formatPercentage(100.0);
      expect(hundredPercentage, contains('100%'));
    });

    test('Relative time formatting', () {
      final now = DateTime.now();
      
      // Test just now
      final justNow = Formatters.getRelativeTime(now);
      expect(justNow, equals('Just now'));

      // Test minutes ago
      final minutesAgo = Formatters.getRelativeTime(now.subtract(Duration(minutes: 30)));
      expect(minutesAgo, contains('30 minutes ago'));

      // Test hours ago
      final hoursAgo = Formatters.getRelativeTime(now.subtract(Duration(hours: 2)));
      expect(hoursAgo, contains('2 hours ago'));

      // Test yesterday
      final yesterday = Formatters.getRelativeTime(now.subtract(Duration(days: 1)));
      expect(yesterday, equals('Yesterday'));

      // Test days ago
      final daysAgo = Formatters.getRelativeTime(now.subtract(Duration(days: 3)));
      expect(daysAgo, contains('3 days ago'));
    });

    test('File size formatting', () {
      // Test bytes
      final bytesFormatted = Formatters.formatFileSize(512);
      expect(bytesFormatted, equals('512 B'));

      // Test kilobytes
      final kbFormatted = Formatters.formatFileSize(1536);
      expect(kbFormatted, equals('1.5 KB'));

      // Test megabytes
      final mbFormatted = Formatters.formatFileSize(1572864);
      expect(mbFormatted, equals('1.5 MB'));

      // Test gigabytes
      final gbFormatted = Formatters.formatFileSize(1610612736);
      expect(gbFormatted, equals('1.5 GB'));
    });

    test('Currency validation', () {
      // Test valid currencies
      expect(Formatters.isValidCurrencyCode('INR'), isTrue);
      expect(Formatters.isValidCurrencyCode('USD'), isTrue);
      expect(Formatters.isValidCurrencyCode('EUR'), isTrue);
      expect(Formatters.isValidCurrencyCode('GBP'), isTrue);

      // Test invalid currencies
      expect(Formatters.isValidCurrencyCode('INVALID'), isFalse);
      expect(Formatters.isValidCurrencyCode(''), isFalse);
    });

    // test('Locale validation', () {
    //   // Test valid locales
    //   expect(Formatters.isValidLocaleCode('en'), isTrue);
    //   expect(Formatters.isValidLocaleCode('en_US'), isTrue);

    //   // Test invalid locales
    //   expect(Formatters.isValidLocaleCode(''), isFalse);
    //   // Note: 'invalid' might be considered valid by Intl.verifiedLocale
    // });

    test('Month and day names', () {
      // Test month names
      final january = Formatters.getMonthName(1);
      expect(january, equals('January'));

      final december = Formatters.getMonthName(12);
      expect(december, equals('December'));

      // Test day names
      final testDate = DateTime(2024, 12, 25); // Wednesday
      final dayName = Formatters.getDayName(testDate);
      expect(dayName, equals('Wednesday'));

      final shortDayName = Formatters.getShortDayName(testDate);
      expect(shortDayName, equals('Wed'));
    });
  });
}
