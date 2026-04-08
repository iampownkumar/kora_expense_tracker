import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/credit_card.dart';
import '../models/credit_card_statement.dart';
import '../models/payment_record.dart';
import '../models/category.dart';
import '../models/settings.dart';

/// Service for handling data import and export operations
class ImportExportService {
  static const String _exportFileName = 'kora_expense_tracker_backup';

  /// Export all app data to a JSON file
  static Future<String?> exportData({
    required List<Account> accounts,
    required List<Transaction> transactions,
    required List<CreditCard> creditCards,
    required List<CreditCardStatement> statements,
    required List<PaymentRecord> payments,
    required List<Category> categories,
    required Settings settings,
  }) async {
    try {
      // Request storage permissions removed for Android 11+ compliance. All operations use app-scoped storage.

      // Create export data structure
      final exportData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'appName': 'Kora Expense Tracker',
        'data': {
          'accounts': accounts.map((account) => account.toJson()).toList(),
          'transactions': transactions
              .map((transaction) => transaction.toJson())
              .toList(),
          'creditCards': creditCards.map((card) => card.toJson()).toList(),
          'statements': statements
              .map((statement) => statement.toJson())
              .toList(),
          'payments': payments.map((payment) => payment.toJson()).toList(),
          'categories': categories
              .map((category) => category.toJson())
              .toList(),
          'settings': settings.toJson(),
        },
      };

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Get external storage directory (App-scoped, avoids permission issues on Android 11+)
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      debugPrint('Using directory: ${directory.path}');

      // Create main KoraExpenseTracker directory
      final mainDir = Directory('${directory.path}/KoraExpenseTracker');
      debugPrint('Creating main directory: ${mainDir.path}');

      if (!await mainDir.exists()) {
        await mainDir.create(recursive: true);
        debugPrint('Main directory created successfully');
      } else {
        debugPrint('Main directory already exists');
      }

      // Create organized export subdirectory: Exports/JSON/
      final backupDir = Directory('${mainDir.path}/Exports/JSON');
      debugPrint('Creating JSON export directory: ${backupDir.path}');

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
        debugPrint('JSON export directory created successfully');
      } else {
        debugPrint('JSON export directory already exists');
      }

      // Generate filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${_exportFileName}_$timestamp.json';
      final file = File('${backupDir.path}/$fileName');

      debugPrint('Writing file: ${file.path}');
      debugPrint('File size: ${jsonString.length} characters');

      // Write file
      await file.writeAsString(jsonString);

      // Verify file was created
      if (await file.exists()) {
        final fileSize = await file.length();
        debugPrint('File created successfully! Size: $fileSize bytes');
        return file.path;
      } else {
        throw Exception('File was not created successfully');
      }
    } catch (e) {
      debugPrint('Export error: $e');
      return null;
    }
  }

  /// Import data from a JSON file
  static Future<Map<String, dynamic>?> importData() async {
    try {
      // Request storage permission
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        throw Exception('Storage permission denied');
      }

      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null; // User cancelled
      }

      // Read file
      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();

      // Parse JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Validate file format
      if (!validateImportData(jsonData)) {
        throw Exception('Invalid backup file format');
      }

      return jsonData['data'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Import error: $e');
      rethrow;
    }
  }

  /// Validate imported data structure
  static bool validateImportData(Map<String, dynamic> data) {
    try {
      // Check required fields
      if (!data.containsKey('version') ||
          !data.containsKey('exportDate') ||
          !data.containsKey('data')) {
        return false;
      }

      final appData = data['data'] as Map<String, dynamic>;

      // Check required data sections
      final requiredSections = [
        'accounts',
        'transactions',
        'creditCards',
        'statements',
        'payments',
        'categories',
        'settings',
      ];

      for (final section in requiredSections) {
        if (!appData.containsKey(section)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Export data to CSV format
  static Future<String?> exportToCSV({
    required List<Transaction> transactions,
    String? fileName,
  }) async {
    try {
      // Request storage permissions removed for Android 11+ compliance. All operations use app-scoped storage.

      // Create CSV content
      final csvContent = StringBuffer();

      // Add header
      csvContent.writeln('Date,Description,Amount,Type,Category,Account,Notes');

      // Add transaction data
      for (final transaction in transactions) {
        csvContent.writeln(
          [
            transaction.date.toIso8601String().split('T')[0], // Date only
            '"${transaction.description.replaceAll('"', '""')}"', // Escape quotes
            transaction.amount.toStringAsFixed(2),
            transaction.type,
            transaction.categoryId, // Use categoryId instead of categoryName
            transaction.accountId, // Use accountId instead of accountName
            '"${(transaction.notes ?? '').replaceAll('"', '""')}"',
          ].join(','),
        );
      }

      // Get external storage directory (Downloads folder for easy access)
      Directory? directory;
      if (Platform.isAndroid) {
        // Use Downloads directory for easy access
        directory = Directory('/storage/emulated/0/Download');
        // Fallback to external storage directory if Downloads doesn't work
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      debugPrint('Using directory for CSV: ${directory.path}');

      // Create main KoraExpenseTracker directory
      final mainDir = Directory('${directory.path}/KoraExpenseTracker');
      debugPrint('Creating main directory for CSV: ${mainDir.path}');

      if (!await mainDir.exists()) {
        await mainDir.create(recursive: true);
        debugPrint('Main directory created successfully for CSV');
      } else {
        debugPrint('Main directory already exists for CSV');
      }

      // Create organized export subdirectory: Exports/CSV/
      final exportsDir = Directory('${mainDir.path}/Exports/CSV');
      debugPrint('Creating CSV exports directory: ${exportsDir.path}');

      if (!await exportsDir.exists()) {
        await exportsDir.create(recursive: true);
        debugPrint('CSV exports directory created successfully');
      } else {
        debugPrint('CSV exports directory already exists');
      }

      // Generate filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final csvFileName = fileName ?? 'transactions_$timestamp.csv';
      final file = File('${exportsDir.path}/$csvFileName');

      debugPrint('Writing CSV file: ${file.path}');
      debugPrint('CSV content size: ${csvContent.length} characters');

      // Write file
      await file.writeAsString(csvContent.toString());

      // Verify file was created
      if (await file.exists()) {
        final fileSize = await file.length();
        debugPrint('CSV file created successfully! Size: $fileSize bytes');
        return file.path;
      } else {
        throw Exception('CSV file was not created successfully');
      }
    } catch (e) {
      debugPrint('CSV Export error: $e');
      return null;
    }
  }

  /// Export data to PDF format
  static Future<String?> exportToPDF({
    required List<Transaction> transactions,
    String? fileName,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Transactions Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['Date', 'Description', 'Amount', 'Type', 'Category'],
                border: pw.TableBorder.all(width: 1, color: PdfColors.grey300),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blue800,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                data: transactions
                    .map(
                      (t) => [
                        t.date.toIso8601String().split('T')[0],
                        t.description,
                        t.amount.toStringAsFixed(2),
                        t.type,
                        t.categoryId,
                      ],
                    )
                    .toList(),
              ),
            ];
          },
        ),
      );

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final mainDir = Directory(
        '${directory?.path}/KoraExpenseTracker/Exports/PDF',
      );
      if (!await mainDir.exists()) await mainDir.create(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final pdfFileName = fileName ?? 'transactions_$timestamp.pdf';
      final file = File('${mainDir.path}/$pdfFileName');

      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      debugPrint('PDF Export error: $e');
      return null;
    }
  }

  /// Get list of available backup files
  static Future<List<FileSystemEntity>> getBackupFiles() async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) return [];

      final mainDir = Directory('${directory.path}/KoraExpenseTracker');
      if (!await mainDir.exists()) return [];

      final backupDir = Directory('${mainDir.path}/Exports/CSV');
      if (!await backupDir.exists()) {
        // Also look in Download directory as backup
        final downloadDir = Directory('/storage/emulated/0/Download/KoraExpenseTracker/Exports/CSV');
        if (await downloadDir.exists()) {
          final files = await downloadDir.list().toList();
          files.sort((a, b) => b.path.compareTo(a.path));
          return files.where((file) => file.path.toLowerCase().endsWith('.csv')).toList();
        }
        return [];
      }

      final files = await backupDir.list().toList();
      files.sort((a, b) => b.path.compareTo(a.path)); // Sort by newest first

      return files.where((file) => file.path.toLowerCase().endsWith('.csv')).toList();
    } catch (e) {
      debugPrint('Get backup files error: $e');
      return [];
    }
  }

  /// Delete a backup file
  static Future<bool> deleteBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Delete backup file error: $e');
      return false;
    }
  }

  /// Get the export directory path for display
  static Future<String?> getExportDirectoryPath() async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) return null;

      return '${directory.path}/KoraExpenseTracker';
    } catch (e) {
      debugPrint('Get export directory error: $e');
      return null;
    }
  }

  /// Get file size in human readable format
  static String getFileSize(FileSystemEntity file) {
    try {
      if (file is File) {
        final bytes = file.lengthSync();
        if (bytes < 1024) return '$bytes B';
        if (bytes < 1024 * 1024) {
          return '${(bytes / 1024).toStringAsFixed(1)} KB';
        }
        if (bytes < 1024 * 1024 * 1024) {
          return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
        return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get file modification date
  static DateTime getFileDate(FileSystemEntity file) {
    try {
      if (file is File) {
        return file.lastModifiedSync();
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    // App-scoped directories don't require external storage permissions on Android 11+
    return true;
  }

  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    // We use app-scoped directories (getExternalStorageDirectory on Android)
    // which do not require any permissions on Android 11+.
    return true; // iOS doesn't need explicit storage permission for documents dir
  }
}
