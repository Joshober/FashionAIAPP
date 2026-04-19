import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Modal / sheet editor for generation preferences (PreferenciasModal parity).
Future<void> showPreferencesEditor(
  BuildContext context, {
  required TextEditingController style,
  required TextEditingController formality,
  required TextEditingController palette,
  required TextEditingController climate,
  required TextEditingController notes,
  required TextEditingController avoid,
  required VoidCallback onSave,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: SwColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.92,
          minChildSize: 0.45,
          maxChildSize: 0.96,
          builder: (context, scroll) {
            return ListView(
              controller: scroll,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'OUTFIT PREFERENCES',
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(controller: style, decoration: const InputDecoration(labelText: 'Style preference')),
                TextField(controller: formality, decoration: const InputDecoration(labelText: 'Formality')),
                TextField(controller: palette, decoration: const InputDecoration(labelText: 'Palette / colors')),
                TextField(controller: climate, decoration: const InputDecoration(labelText: 'Climate')),
                TextField(controller: notes, decoration: const InputDecoration(labelText: 'Notes')),
                TextField(controller: avoid, decoration: const InputDecoration(labelText: 'Avoid')),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    onSave();
                    Navigator.pop(ctx);
                  },
                  child: const Text('SAVE PREFERENCES'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
