import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ReleaseNotesScreen extends StatelessWidget {
  const ReleaseNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Release Notes'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReleaseCard(
            context,
            version: '1.0.0+1 (Beta Update)',
            date: 'March 2026',
            features: [
              'Custom Categories: You can now create unlimited custom categories with personalized icons and colors.',
              'Receipt Attachments: Snap or upload receipts and images for any transaction.',
              'Interactive Image Viewer: Tap an attached image to view it full-screen with zooming and panning capabilities.',
              'App Icon & Branding: Updated our app icon and splash screen to fit the premium aesthetic of Kora.',
            ],
            bugFixes: [
              'Fixed Home Screen Gestures: Resolved conflicts with system navigation and transaction swiping.',
              'Sticky Navigation: The filter chips on the Accounts page now remain visible when scrolling.',
              'Credit Cards Padding Safe Area: Corrected layout issues on empty credit card lists to prevent clipping.',
              'Improved Storage Cleanup: Deleting transactions or overwriting images now properly deletes cache images to save space.',
            ],
          ),
          const SizedBox(height: 16),
          _buildReleaseCard(
            context,
            version: '1.0.0 (Initial Beta)',
            date: 'March 2026',
            features: [
              'Core expense tracking functionality.',
              'Account management (Asset and Liability separation).',
              'Initial Credit Card tracking module (Beta).',
              'PDF receipt exporter and JSON data import/restore.',
            ],
            bugFixes: [],
          ),
        ],
      ),
    );
  }

  Widget _buildReleaseCard(
    BuildContext context, {
    required String version,
    required String date,
    required List<String> features,
    required List<String> bugFixes,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'v$version',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            if (features.isNotEmpty) ...[
              Text(
                'What\'s New',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(f, style: const TextStyle(height: 1.4))),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],
            if (bugFixes.isNotEmpty) ...[
              Text(
                'Bug Fixes & Improvements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...bugFixes.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(f, style: const TextStyle(height: 1.4))),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
