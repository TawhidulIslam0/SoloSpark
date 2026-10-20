import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/client.dart';
import '../../../data/repositories/local_business_repository.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/page_heading.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key, required this.repository});
  final LocalBusinessRepository repository;

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final searchController = TextEditingController();
  String search = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clients = widget.repository.clients.where((client) =>
      client.name.toLowerCase().contains(search.toLowerCase()) ||
      client.email.toLowerCase().contains(search.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addClient, backgroundColor: AppTheme.green, foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1), label: const Text('Add client'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 100),
        children: [
          PageHeading(title: 'Clients', subtitle: '${widget.repository.clients.length} people and businesses', trailing: IconButton(onPressed: _addClient, icon: const Icon(Icons.person_add_alt_1))),
          const SizedBox(height: 16),
          TextField(controller: searchController, onChanged: (value) => setState(() => search = value), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search clients')),
          const SizedBox(height: 16),
          if (clients.isEmpty)
            EmptyState(icon: Icons.people_outline, title: search.isEmpty ? 'No clients yet' : 'No matching clients', subtitle: search.isEmpty ? 'Save contact details to speed up invoicing.' : 'Try another name or email.')
          else
            ...clients.map((client) => _ClientCard(client: client, onDelete: () => _deleteClient(client))),
        ],
      ),
    );
  }

  Future<void> _addClient() async {
    final name = TextEditingController(); final email = TextEditingController(); final phone = TextEditingController(); final notes = TextEditingController();
    final key = GlobalKey<FormState>();
    final result = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(padding: const EdgeInsets.fromLTRB(20, 20, 20, 24), decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(26))),
          child: SingleChildScrollView(child: Form(key: key, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Add a client', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _field(name, 'Name or business', validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null),
            const SizedBox(height: 10), _field(email, 'Email (optional)', keyboard: TextInputType.emailAddress),
            const SizedBox(height: 10), _field(phone, 'Phone (optional)', keyboard: TextInputType.phone),
            const SizedBox(height: 10), _field(notes, 'Notes (optional)', maxLines: 2),
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () async {
              if (!key.currentState!.validate()) return;
              await widget.repository.addClient(Client(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name.text.trim(), email: email.text.trim(), phone: phone.text.trim(), notes: notes.text.trim(), createdAt: DateTime.now()));
              if (ctx.mounted) Navigator.pop(ctx, true);
            }, child: const Text('Save client'))),
          ]))),
      ),
    ));
    name.dispose(); email.dispose(); phone.dispose(); notes.dispose();
    if (result == true && mounted) setState(() {});
  }

  Future<void> _deleteClient(Client client) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete client?'), content: Text('Remove ${client.name} from your client list?'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete'))],
    ));
    if (confirmed == true) {
      await widget.repository.deleteClient(client.id);
      if (mounted) setState(() {});
    }
  }

  Widget _field(TextEditingController controller, String label, {String? Function(String?)? validator, TextInputType? keyboard, int maxLines = 1}) =>
      TextFormField(controller: controller, validator: validator, keyboardType: keyboard, maxLines: maxLines, decoration: InputDecoration(labelText: label));
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client, required this.onDelete});
  final Client client; final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [
      CircleAvatar(backgroundColor: const Color(0xFFEAF5EF), foregroundColor: AppTheme.green, child: Text(client.name.isEmpty ? '?' : client.name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800))),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(client.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        if (client.email.isNotEmpty) Text(client.email, style: Theme.of(context).textTheme.bodySmall),
        if (client.phone.isNotEmpty) Text(client.phone, style: Theme.of(context).textTheme.bodySmall),
        if (client.notes.isNotEmpty) Text(client.notes, style: Theme.of(context).textTheme.bodySmall),
      ])),
      IconButton(tooltip: 'Delete client', onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.black45)),
    ])),
  );
}
