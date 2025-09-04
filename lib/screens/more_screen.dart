import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'import_export_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
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
                const SnackBar(
                  content: Text('Settings screen coming soon!'),
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
              // TODO: Show about dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('About dialog coming soon!'),
                ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
