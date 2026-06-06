import 'package:flutter/material.dart';

class PermissionDisclosureDialog extends StatelessWidget {
  final String title;
  final String reason;
  final IconData icon;

  const PermissionDisclosureDialog({
    super.key,
    required this.title,
    required this.reason,
    required this.icon,
  });

  /// Shows the dialog and returns true if the user clicks "Continue", false otherwise.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String reason,
    required IconData icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PermissionDisclosureDialog(
        title: title,
        reason: reason,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ],
      ),
      content: Text(
        reason,
        style: const TextStyle(fontSize: 15, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Not Now'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
