import 'package:flutter/material.dart';
import 'import_export_screen.dart';
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
          // Settings Section
          _buildSectionCard(
            context,
            title: 'Settings',
            subtitle: 'App preferences and configuration',
            icon: Icons.settings,
            onTap: () {
              // TODO: Navigate to settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings screen coming soon!')),
              );
            },
          ),
          const SizedBox(height: 16),

          // Release Notes Section
          _buildSectionCard(
            context,
            title: 'Release Notes & Updates',
            subtitle: 'View recent updates and bug fixes',
            icon: Icons.update,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ReleaseNotesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Import/Export Section
          _buildSectionCard(
            context,
            title: 'Import/Export',
            subtitle: 'Backup and restore your data',
            icon: Icons.backup,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ImportExportScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // About Section
          _buildSectionCard(
            context,
            title: 'About',
            subtitle: 'App information and version',
            icon: Icons.info,
            onTap: () {
              showAboutDialog(
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
                    'Kora Expense Tracker is designed to help you take full financial control of your life.\n\n'
                    'By simply logging your transactions and tracking your accounts, you gain deep insights into your spending habits. '
                    'Our goal is to make personal finance management accessible, insightful, and empowering for everyone.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              );
            },
          ),
        ],
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
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
