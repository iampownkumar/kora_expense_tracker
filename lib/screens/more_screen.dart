import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/features/transactions/transaction_controller.dart';
import 'categories_screen.dart';
import 'import_export_screen.dart';
import 'import_screen.dart';
import 'release_notes_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Manage Section ────────────────────────────────────────────────
          _buildSectionHeader('Manage'),
          const SizedBox(height: 8),

          // Categories
          Consumer<TransactionController>(
            builder: (context, txnCtrl, _) {
              final catCount = txnCtrl.topLevelCategories.length;
              final subCount = txnCtrl.subCategoryCount;
              final subtitle = subCount > 0
                  ? '$catCount categories · $subCount sub-categories'
                  : '$catCount categories';
              return _buildSectionCard(
                context,
                title: 'Categories',
                subtitle: subtitle,
                icon: Icons.category_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CategoriesScreen(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // ── Data Section ───────────────────────────────────────────────────
          _buildSectionHeader('Data'),
          const SizedBox(height: 8),

          _buildSectionCard(
            context,
            title: 'Import Data',
            subtitle: 'Restore transactions from a CSV backup',
            icon: Icons.download_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ImportScreen()),
            ),
          ),
          const SizedBox(height: 12),

          _buildSectionCard(
            context,
            title: 'Export Data',
            subtitle: 'Export your data to CSV / JSON',
            icon: Icons.upload_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ImportExportScreen()),
            ),
          ),
          const SizedBox(height: 12),

          // ── App Section ────────────────────────────────────────────────────
          _buildSectionHeader('App'),
          const SizedBox(height: 8),

          _buildSectionCard(
            context,
            title: 'Release Notes',
            subtitle: 'View recent updates and bug fixes',
            icon: Icons.update_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReleaseNotesScreen()),
            ),
          ),
          const SizedBox(height: 12),

          _buildSectionCard(
            context,
            title: 'About',
            subtitle: 'App information and version',
            icon: Icons.info_outline,
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Kora Expense Tracker',
              applicationVersion: '1.0.0+2 Beta',
              applicationIcon: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 48,
                  height: 48,
                ),
              ),
              applicationLegalese: '© 2026 Kora. All rights reserved.',
              children: const [
                SizedBox(height: 16),
                Text(
                  'Kora Expense Tracker is designed to help you take full '
                  'financial control of your life.\n\n'
                  'By simply logging your transactions and tracking your accounts, '
                  'you gain deep insights into your spending habits. Our goal is '
                  'to make personal finance management accessible, insightful, '
                  'and empowering for everyone.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
