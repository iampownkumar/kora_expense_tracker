import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/credit_card_provider.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/settings.dart';
import '../models/credit_card.dart';
import '../models/credit_card_statement.dart';
import '../models/payment_record.dart';
import '../utils/import_export_service.dart';
import '../utils/formatters.dart';

/// Import/Export Screen for data backup and restore
class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({super.key});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
  List<FileSystemEntity> _backupFiles = [];

  @override
  void initState() {
    super.initState();
    _loadBackupFiles();
  }

  Future<void> _loadBackupFiles() async {
    final files = await ImportExportService.getBackupFiles();
    setState(() {
      _backupFiles = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import/Export'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBackupFiles,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Export Section
            _buildExportSection(),
            const SizedBox(height: 24),
            
            // Export Directory Info
            _buildExportDirectoryInfo(),
            const SizedBox(height: 24),
            
            // Import Section
            _buildImportSection(),
            const SizedBox(height: 24),
            
            // Backup Files Section
            _buildBackupFilesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.upload,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Export Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Create a backup of all your data including accounts, transactions, credit cards, and settings.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _exportAllData,
                    icon: _isExporting 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.backup),
                    label: Text(_isExporting ? 'Exporting...' : 'Export All Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isExporting ? null : _exportTransactionsCSV,
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Export CSV'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.download,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Import Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Restore your data from a previously created backup file.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isImporting ? null : _importData,
                icon: _isImporting 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.restore),
                label: Text(_isImporting ? 'Importing...' : 'Import from File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportDirectoryInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_open,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Export Location',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<String?>(
              future: ImportExportService.getExportDirectoryPath(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                
                if (snapshot.hasError || !snapshot.hasData) {
                  return Text(
                    'Unable to determine export location',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
                  );
                }
                
                final exportPath = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Main Directory:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exportPath,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Subdirectories:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• $exportPath/Backups/ (for JSON backups)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            '• $exportPath/Exports/ (for CSV exports)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '💡 Tip: Open your file manager and go to "Downloads" folder, then look for "KoraExpenseTracker" folder. It\'s much easier to find now!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupFilesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Backup Files',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_backupFiles.length} files',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_backupFiles.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No backup files found',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create your first backup using the export feature above.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ..._backupFiles.map((file) => _buildBackupFileItem(file)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupFileItem(FileSystemEntity file) {
    final fileName = file.path.split('/').last;
    final fileSize = ImportExportService.getFileSize(file);
    final fileDate = ImportExportService.getFileDate(file);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.backup,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${Formatters.formatDate(fileDate)} • $fileSize',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleBackupFileAction(value, file),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    Icon(Icons.restore, size: 16),
                    SizedBox(width: 8),
                    Text('Restore'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportAllData() async {
    setState(() => _isExporting = true);

    try {
      // Check permission
      if (!await ImportExportService.hasStoragePermission()) {
        final granted = await ImportExportService.requestStoragePermission();
        if (!granted) {
          _showErrorSnackBar('Storage permission is required for export');
          return;
        }
      }

      // Show export path before exporting
      final exportDir = await ImportExportService.getExportDirectoryPath();
      if (exportDir != null) {
        _showInfoSnackBar('Exporting to: $exportDir/Backups/');
      }

      final appProvider = context.read<AppProvider>();
      final creditCardProvider = context.read<CreditCardProvider>();

      final filePath = await ImportExportService.exportData(
        accounts: appProvider.accounts,
        transactions: appProvider.transactions,
        creditCards: creditCardProvider.creditCards,
        statements: creditCardProvider.statements,
        payments: creditCardProvider.payments,
        categories: appProvider.categories,
        settings: appProvider.settings,
      );

      if (filePath != null) {
        final fileName = filePath.split('/').last;
        final exportDir = await ImportExportService.getExportDirectoryPath();
        _showSuccessSnackBar('✅ Backup exported successfully!\n📁 Location: $exportDir/Backups/\n📄 File: $fileName');
        _loadBackupFiles(); // Refresh backup files list
      } else {
        _showErrorSnackBar('Failed to export data');
      }
    } catch (e) {
      _showErrorSnackBar('Export failed: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportTransactionsCSV() async {
    setState(() => _isExporting = true);

    try {
      // Check permission
      if (!await ImportExportService.hasStoragePermission()) {
        final granted = await ImportExportService.requestStoragePermission();
        if (!granted) {
          _showErrorSnackBar('Storage permission is required for export');
          return;
        }
      }

      // Show export path before exporting
      final exportDir = await ImportExportService.getExportDirectoryPath();
      if (exportDir != null) {
        _showInfoSnackBar('Exporting to: $exportDir/Exports/');
      }

      final appProvider = context.read<AppProvider>();

      final filePath = await ImportExportService.exportToCSV(
        transactions: appProvider.transactions,
      );

      if (filePath != null) {
        final fileName = filePath.split('/').last;
        final exportDir = await ImportExportService.getExportDirectoryPath();
        _showSuccessSnackBar('✅ CSV exported successfully!\n📁 Location: $exportDir/Exports/\n📄 File: $fileName');
      } else {
        _showErrorSnackBar('Failed to export CSV');
      }
    } catch (e) {
      _showErrorSnackBar('CSV export failed: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _importData() async {
    setState(() => _isImporting = true);

    try {
      // Check permission
      if (!await ImportExportService.hasStoragePermission()) {
        final granted = await ImportExportService.requestStoragePermission();
        if (!granted) {
          _showErrorSnackBar('Storage permission is required for import');
          return;
        }
      }

      final importedData = await ImportExportService.importData();
      
      if (importedData == null) {
        // User cancelled
        return;
      }

      // Show confirmation dialog
      final shouldImport = await _showImportConfirmationDialog();
      if (!shouldImport) return;

      final appProvider = context.read<AppProvider>();
      final creditCardProvider = context.read<CreditCardProvider>();

      // Import data
      await _performDataImport(importedData, appProvider, creditCardProvider);

      _showSuccessSnackBar('Data imported successfully!');
    } catch (e) {
      _showErrorSnackBar('Import failed: $e');
    } finally {
      setState(() => _isImporting = false);
    }
  }

  Future<bool> _showImportConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Import'),
        content: const Text(
          'This will replace all your current data with the imported data. '
          'This action cannot be undone. Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Import'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _performDataImport(
    Map<String, dynamic> data,
    AppProvider appProvider,
    CreditCardProvider creditCardProvider,
  ) async {
    try {
      // Import accounts
      final accountsJson = data['accounts'] as List<dynamic>;
      final accounts = accountsJson.map((json) => Account.fromJson(json)).toList();
      await appProvider.importAccounts(accounts);

      // Import transactions
      final transactionsJson = data['transactions'] as List<dynamic>;
      final transactions = transactionsJson.map((json) => Transaction.fromJson(json)).toList();
      await appProvider.importTransactions(transactions);

      // Import categories
      final categoriesJson = data['categories'] as List<dynamic>;
      final categories = categoriesJson.map((json) => Category.fromJson(json)).toList();
      await appProvider.importCategories(categories);

      // Import settings
      final settingsJson = data['settings'] as Map<String, dynamic>;
      final settings = Settings.fromJson(settingsJson);
      await appProvider.importSettings(settings);

      // Import credit cards
      final creditCardsJson = data['creditCards'] as List<dynamic>;
      final creditCards = creditCardsJson.map((json) => CreditCard.fromJson(json)).toList();
      await creditCardProvider.importCreditCards(creditCards);

      // Import statements
      final statementsJson = data['statements'] as List<dynamic>;
      final statements = statementsJson.map((json) => CreditCardStatement.fromJson(json)).toList();
      await creditCardProvider.importStatements(statements);

      // Import payments
      final paymentsJson = data['payments'] as List<dynamic>;
      final payments = paymentsJson.map((json) => PaymentRecord.fromJson(json)).toList();
      await creditCardProvider.importPayments(payments);
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  void _handleBackupFileAction(String action, FileSystemEntity file) {
    switch (action) {
      case 'restore':
        _restoreFromBackup(file);
        break;
      case 'delete':
        _deleteBackupFile(file);
        break;
    }
  }

  Future<void> _restoreFromBackup(FileSystemEntity file) async {
    try {
      // Read and parse backup file
      final fileContent = await File(file.path).readAsString();
      final Map<String, dynamic> jsonData = json.decode(fileContent);
      
      if (!ImportExportService.validateImportData(jsonData)) {
        _showErrorSnackBar('Invalid backup file format');
        return;
      }

      final importedData = jsonData['data'] as Map<String, dynamic>;

      // Show confirmation dialog
      final shouldImport = await _showImportConfirmationDialog();
      if (!shouldImport) return;

      final appProvider = context.read<AppProvider>();
      final creditCardProvider = context.read<CreditCardProvider>();

      // Import data
      await _performDataImport(importedData, appProvider, creditCardProvider);

      _showSuccessSnackBar('Data restored successfully!');
    } catch (e) {
      _showErrorSnackBar('Restore failed: $e');
    }
  }

  Future<void> _deleteBackupFile(FileSystemEntity file) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: Text('Are you sure you want to delete ${file.path.split('/').last}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final success = await ImportExportService.deleteBackupFile(file.path);
      if (success) {
        _showSuccessSnackBar('Backup file deleted');
        _loadBackupFiles();
      } else {
        _showErrorSnackBar('Failed to delete backup file');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
