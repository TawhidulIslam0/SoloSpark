import 'package:flutter/material.dart';

import '../../../data/repositories/local_business_repository.dart';
import '../../../shared/widgets/page_heading.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.repository, required this.darkMode, required this.onThemeChanged});

  final LocalBusinessRepository repository;
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
    children: [
      const PageHeading(title: 'Settings', subtitle: 'Make SoloSpark work for you.'),
      const SizedBox(height: 18),
      Card(child: SwitchListTile(
        secondary: const Icon(Icons.dark_mode_outlined),
        title: const Text('Dark appearance'),
        subtitle: const Text('Use a darker interface at night.'),
        value: darkMode,
        onChanged: onThemeChanged,
      )),
      const SizedBox(height: 10),
      Card(child: const ListTile(
        leading: Icon(Icons.lock_outline),
        title: Text('Local-first storage'),
        subtitle: Text('Your business records are stored on this device. Cloud sync is not enabled.'),
      )),
      const SizedBox(height: 10),
      Card(child: const ListTile(
        leading: Icon(Icons.workspace_premium_outlined),
        title: Text('Solo Pro features'),
        subtitle: Text('PDF invoices, cloud backup, recurring invoices, and subscriptions are planned—not active in this build.'),
      )),
      const SizedBox(height: 22),
      Text('DEMO DATA', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.2)),
      const SizedBox(height: 8),
      Card(child: ListTile(
        leading: const Icon(Icons.restart_alt),
        title: const Text('Reset sample data'),
        subtitle: const Text('Restore example clients and invoices. This replaces current local records.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
            title: const Text('Reset sample data?'),
            content: const Text('Your current invoices, clients, and expenses will be removed and replaced with sample records.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
            ],
          ));
          if (confirmed == true) {
            await repository.resetDemoData();
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sample data restored.')));
          }
        },
      )),
      const SizedBox(height: 22),
      Center(child: Text('SoloSpark Pro · Version 1.1.0', style: Theme.of(context).textTheme.bodySmall)),
    ],
  );
}
