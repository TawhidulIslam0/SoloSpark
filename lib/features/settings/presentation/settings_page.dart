import 'package:flutter/material.dart';

import '../../../data/repositories/local_business_repository.dart';
import '../../../data/services/csv_export_service.dart';
import '../../../shared/widgets/page_heading.dart';
import 'business_profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.repository,
    required this.darkMode,
    required this.onThemeChanged,
  });

  final LocalBusinessRepository repository;
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        children: [
          const PageHeading(
            title: 'Settings',
            subtitle: 'Make SoloSpark work for you.',
          ),
          const SizedBox(height: 18),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark appearance'),
              subtitle: const Text('Use a darker interface at night.'),
              value: darkMode,
              onChanged: onThemeChanged,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.business_outlined),
              title: const Text('Business profile'),
              subtitle: Text(
                repository.businessProfile.businessName.isNotEmpty
                    ? repository.businessProfile.businessName
                    : 'Add business name, address, tax ID, & payment terms.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => BusinessProfilePage(repository: repository),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: const ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Local-first storage'),
              subtitle: Text(
                'Your business records are stored on this device. Cloud sync is not enabled.',
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: const ListTile(
              leading: Icon(Icons.workspace_premium_outlined),
              title: Text('Solo Pro features'),
              subtitle: Text(
                'PDF sharing, CSV export, payment links, and payment-reminder drafts are available. Cloud backup and subscriptions are not enabled.',
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Export invoices, clients & expenses'),
              subtitle: const Text('Create a CSV file for Excel, Google Sheets, or your accountant.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                try {
                  await CsvExportService().exportBusinessData(
                    invoices: repository.invoices,
                    clients: repository.clients,
                    expenses: repository.expenses,
                  );
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not export CSV: $error')),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'DATA MANAGEMENT',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              title: const Text(
                'Clear all records',
                style: TextStyle(color: Colors.redAccent),
              ),
              subtitle: const Text('Wipe all local records to start with a blank app.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear all records?'),
                    content: const Text(
                      'All invoices, clients, expenses, and your saved business profile will be permanently deleted from this device.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await repository.clearAllData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All records cleared.')),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: Text(
              'SoloSpark Pro · Version 1.2.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      );
}
