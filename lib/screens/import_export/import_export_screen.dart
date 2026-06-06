import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/features/transactions/transaction_controller.dart';
import 'package:kora_expense_tracker/features/accounts/account_controller.dart';
import 'package:kora_expense_tracker/features/credit_cards/credit_card_controller.dart';
import '../../core/utils/storage_service.dart';
import '../../core/utils/import_export_service.dart';

/// Import/Export Screen for data backup and restore
class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({super.key});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Data')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Database Backup/Restore
            _buildDatabaseBackupSection(),
            const SizedBox(height: 24),

            // CSV Export Section
            _buildExportSection(),
            const SizedBox(height: 24),

            // Export Directory Info
            _buildExportDirectoryInfo(),
            const SizedBox(height: 24),
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
                  'Export to CSV',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Export all your transactions to a CSV spreadsheet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isExporting
                    ? null
                    : () => _handleExportCSV(context),
                icon: const Icon(Icons.table_chart),
                label: Text(_isExporting ? 'Exporting...' : 'Export CSV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
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
                Icon(Icons.folder_open, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Export Location',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.red),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Root Directory:',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exportPath,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontFamily: 'monospace',
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          const Divider(height: 20),
                          Text(
                            'Export Subdirectories:',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          _exportDirRow(
                            context,
                            Icons.table_chart,
                            Colors.green,
                            'CSV',
                            '$exportPath/Exports/CSV/',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '💡 Open your file manager → Downloads → KoraExpenseTracker → Exports',
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

  Future<void> _exportAllData() async {
    final accountCtrl = context.read<AccountController>();
    final transactionCtrl = context.read<TransactionController>();
    final creditCardCtrl = context.read<CreditCardController>();
    
    setState(() => _isExporting = true);

    try {
      // Check permission
      if (!await ImportExportService.hasStoragePermission()) {
        final granted = await ImportExportService.requestStoragePermission(context);
        if (!granted) {
          _showErrorSnackBar('Storage permission is required for export');
          return;
        }
      }

      // Show export path before exporting
      final exportDir = await ImportExportService.getExportDirectoryPath();
      if (exportDir != null) {
        _showInfoSnackBar(
          'Exporting to: $exportDir/KoraExpenseTracker/Exports/CSV/',
        );
      }

      final filePath = await ImportExportService.exportData(
        accounts: accountCtrl.accounts,
        transactions: transactionCtrl.transactions,
        creditCards: creditCardCtrl.creditCards,
        statements: creditCardCtrl.statements,
        payments: creditCardCtrl.payments,
        categories: transactionCtrl.categories,
        settings: null,
      );

      if (filePath != null) {
        final fileName = filePath.split('/').last;
        final exportDir = await ImportExportService.getExportDirectoryPath();
        _showSuccessSnackBar(
          '✅ Backup exported successfully!\n📁 Location: $exportDir/KoraExpenseTracker/Exports/CSV/\n📄 File: $fileName',
        );
      } else {
        _showErrorSnackBar('Failed to export data');
      }
    } catch (e) {
      _showErrorSnackBar('Export failed: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  // ignore: unused_element
  Future<void> _exportTransactionsCSV() async {
    final transactionCtrl = context.read<TransactionController>();
    
    setState(() => _isExporting = true);

    try {
      // Check permission
      if (!await ImportExportService.hasStoragePermission()) {
        final granted = await ImportExportService.requestStoragePermission(context);
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

      final filePath = await ImportExportService.exportToCSV(
        transactions: transactionCtrl.transactions,
      );

      if (filePath != null) {
        final fileName = filePath.split('/').last;
        final exportDir = await ImportExportService.getExportDirectoryPath();
        _showSuccessSnackBar(
          '✅ CSV exported successfully!\n📁 Location: $exportDir/Exports/\n📄 File: $fileName',
        );
      } else {
        _showErrorSnackBar('Failed to export CSV');
      }
    } catch (e) {
      _showErrorSnackBar('CSV export failed: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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

  Future<void> _handleExportCSV(BuildContext context) async {
    final provider = context.read<TransactionController>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    setState(() => _isExporting = true);
    final hasPermission = await ImportExportService.requestStoragePermission(context);
    if (!hasPermission) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Storage permission denied.')),
        );
      }
      setState(() => _isExporting = false);
      return;
    }
    final path = await ImportExportService.exportToCSV(
      transactions: provider.transactions,
    );
    setState(() => _isExporting = false);
    if (path != null && mounted) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Exported CSV to: $path')));
    } else if (mounted) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('CSV export failed.')));
    }
  }

  Widget _buildDatabaseBackupSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.backup_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Full Database Backup',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Backup or restore your complete Kora database (Accounts, Transactions, Cards, Categories) as a JSON file.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : () => _exportAllData(),
                    icon: const Icon(Icons.cloud_download_outlined),
                    label: Text(_isExporting ? 'Creating...' : 'Backup (.json)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isExporting ? null : () => _handleImportJSON(context),
                    icon: const Icon(Icons.settings_backup_restore_outlined),
                    label: const Text('Restore (.json)'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImportJSON(BuildContext context) async {
    final transactionCtrl = context.read<TransactionController>();
    final accountCtrl = context.read<AccountController>();
    final creditCardCtrl = context.read<CreditCardController>();
    
    // 1. Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Database?'),
        content: const Text(
            'This will completely overwrite all your current data (accounts, transactions, cards) with the backup file. This action cannot be undone.\n\nAre you sure you want to proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isExporting = true);

    try {
      final Map<String, dynamic>? backupData = await ImportExportService.importData(context);

      if (backupData == null) {
        // User cancelled picker
        setState(() => _isExporting = false);
        return;
      }

      // Restore to database
      final success = await StorageService.importData(backupData);

      if (success) {
        // Refresh controllers so UI updates
        await transactionCtrl.refresh();
        await accountCtrl.refresh();
        await creditCardCtrl.refresh();

        if (mounted) {
          _showSuccessSnackBar('✅ Database restored successfully!');
        }
      } else {
        if (mounted) _showErrorSnackBar('Failed to restore database from backup file.');
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Restore failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /// Helper widget to display an export directory row in the location info box.
  Widget _exportDirRow(
    BuildContext context,
    IconData icon,
    Color color,
    String label,
    String path,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Expanded(
          child: Text(
            path,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
