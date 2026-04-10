import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/import_export_service.dart';

/// Result of the preview dialog
class _ImportChoice {
  final List<dynamic> transactions;
  final bool isRestoreMode;
  _ImportChoice(this.transactions, this.isRestoreMode);
}

/// Screen for importing transaction data from CSV files.
/// Automatically discovers exported files from the known backup directory
/// so users can import with a single tap — no file-browsing required.
class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _isLoading = false;
  bool _isImporting = false;
  List<Map<String, dynamic>> _availableFiles = [];
  String? _statusMessage;
  bool _statusIsError = false;

  @override
  void initState() {
    super.initState();
    _scanForFiles();
  }

  Future<void> _scanForFiles() async {
    setState(() => _isLoading = true);
    try {
      final files = await ImportExportService.getAvailableCSVFiles();
      setState(() {
        _availableFiles = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _availableFiles = [];
      });
    }
  }

  Future<void> _importFromPath(String filePath, String fileName) async {
    // Show a preview/confirm dialog first
    final result = await _parseWithPreview(filePath, fileName);
    if (result == null) return; // User cancelled
    _performImport(result.transactions, result.isRestoreMode);
  }

  Future<void> _pickAndImport() async {
    try {
      final transactions = await ImportExportService.importFromCSV();
      if (transactions.isNotEmpty) {
        // Since we already have the transactions, we pass a dummy path but have a custom flow
        final result = await _showPreviewDialog(transactions, 'Custom CSV');
        if (result != null) {
          _performImport(result.transactions, result.isRestoreMode);
        }
      }
    } catch (e) {
      if (e.toString().contains('No file selected')) return;
      _showStatus('Failed to read file: $e', isError: true);
    }
  }

  /// Parse file and show a preview dialog before committing the import.
  Future<_ImportChoice?> _parseWithPreview(
      String filePath, String fileName) async {
    setState(() => _isImporting = true);
    List<dynamic> transactions;
    try {
      transactions = await ImportExportService.importFromFilePath(filePath);
    } catch (e) {
      setState(() => _isImporting = false);
      _showStatus('Failed to read file: $e', isError: true);
      return null;
    } finally {
      setState(() => _isImporting = false);
    }

    if (!mounted) return null;

    return _showPreviewDialog(transactions, fileName);
  }

  /// Separated dialog logic to use with both auto-discovery and manual pick
  Future<_ImportChoice?> _showPreviewDialog(List<dynamic> transactions, String fileName) async {
    bool localReplaceMode = false;

    return showDialog<_ImportChoice>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Import Preview'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('File: $fileName',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${transactions.length} transaction(s) found.'),
                const SizedBox(height: 16),
                
                // Mode Selection
                const Text('Import Mode', 
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 4),
                
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<bool>(
                        value: false,
                        groupValue: localReplaceMode,
                        onChanged: (val) => setDialogState(() => localReplaceMode = val!),
                        title: const Text('Merge (Safe)', style: TextStyle(fontSize: 14)),
                        subtitle: const Text('Add new items, skip existing ones', style: TextStyle(fontSize: 11)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const Divider(height: 1),
                      RadioListTile<bool>(
                        value: true,
                        groupValue: localReplaceMode,
                        onChanged: (val) => setDialogState(() => localReplaceMode = val!),
                        title: const Text('Restore (Advanced)', style: TextStyle(fontSize: 14, color: Colors.red)),
                        subtitle: const Text('Wipe current data & replace with backup', style: TextStyle(fontSize: 11)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Warning Logic
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: localReplaceMode ? Colors.red.shade50 : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: localReplaceMode ? Colors.red.shade300 : Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        localReplaceMode ? Icons.warning_amber : Icons.info_outline, 
                        color: localReplaceMode ? Colors.red : Colors.amber, 
                        size: 20
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          localReplaceMode 
                            ? 'CAUTION: This will permanently DELETE all current transactions and reset your account balances!'
                            : 'Duplicates (same date, description & amount) will be skipped automatically.',
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: localReplaceMode ? FontWeight.bold : FontWeight.normal,
                            color: localReplaceMode ? Colors.red.shade900 : Colors.amber.shade900
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(_ImportChoice(transactions, localReplaceMode)),
                style: localReplaceMode ? FilledButton.styleFrom(backgroundColor: Colors.red) : null,
                child: Text(localReplaceMode ? 'Wipe & Restore' : 'Import'),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _performImport(List<dynamic> transactions, bool replaceMode) async {
    setState(() => _isImporting = true);
    try {
      final provider = context.read<AppProvider>();
      int added;
      
      if (replaceMode) {
        added = await provider.restoreFromImportedTransactions(List.from(transactions));
      } else {
        added = await provider.mergeImportedTransactions(List.from(transactions));
      }
      
      _showStatus(
        replaceMode
          ? '✅ Full restore complete! $added transactions imported.'
          : (added == 0
              ? 'All transactions already exist — nothing new imported.'
              : '✅ Successfully imported $added transaction(s)!'),
        isError: false,
      );
      // Refresh file list in case user imports again
      _scanForFiles();
    } catch (e) {
      _showStatus('Import failed: $e', isError: true);
    } finally {
      setState(() => _isImporting = false);
    }
  }

  void _showStatus(String message, {required bool isError}) {
    setState(() {
      _statusMessage = message;
      _statusIsError = isError;
    });
  }

  // ─── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Data'),
        actions: [
          IconButton(
            onPressed: _scanForFiles,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh file list',
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Status banner ──────────────────────────────────────────
              if (_statusMessage != null) ...[
                _StatusBanner(
                  message: _statusMessage!,
                  isError: _statusIsError,
                  onDismiss: () => setState(() => _statusMessage = null),
                ),
                const SizedBox(height: 16),
              ],

              // ── Info card ──────────────────────────────────────────────
              _InfoCard(),

              const SizedBox(height: 20),

              // ── Available files ────────────────────────────────────────
              _SectionHeader(
                icon: Icons.folder_open,
                label: 'Exported Files',
                trailing: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_availableFiles.isEmpty)
                _EmptyFilesCard()
              else
                ..._availableFiles.map((f) => _FileCard(
                      name: f['name'] as String,
                      size: f['size'] as String,
                      date: f['date'] as DateTime,
                      onImport: _isImporting
                          ? null
                          : () => _importFromPath(
                              f['path'] as String, f['name'] as String),
                    )),

              const SizedBox(height: 24),

              // ── Manual file picker ─────────────────────────────────────
              _SectionHeader(icon: Icons.upload_file, label: 'Browse Device'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import from any location',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pick a CSV file from your device storage, cloud drive, or downloads folder.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isImporting ? null : _pickAndImport,
                          icon: const Icon(Icons.file_open),
                          label: const Text('Choose CSV File'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),

          // ── Global loading overlay ─────────────────────────────────────
          if (_isImporting)
            const _LoadingOverlay(message: 'Importing transactions…'),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How Import Works',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Exported CSV files are automatically listed below.\n'
                    '• Merge: Adds new items only (skips duplicates).\n'
                    '• Restore: Deletes all current data and replaces it.\n'
                    '• Compatible with Kora CSV exports only.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.85),
                          height: 1.6,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class _FileCard extends StatelessWidget {
  const _FileCard({
    required this.name,
    required this.size,
    required this.date,
    required this.onImport,
  });

  final String name;
  final String size;
  final DateTime date;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('MMM d, yyyy · h:mm a').format(date);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onImport,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.table_chart,
                    color: Colors.green, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$formattedDate · $size',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: onImport,
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(0, 0),
                ),
                child: const Text('Import'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFilesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.folder_off_outlined,
                size: 48,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              'No exported files found',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Export your data first from the "Export Data" screen, '
              'then come back here to import it.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red.shade600 : Colors.green.shade600;
    final bgColor = isError ? Colors.red.shade50 : Colors.green.shade50;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
              color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: TextStyle(color: color, fontSize: 13))),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close, color: color, size: 18),
          ),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(message),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
