import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/client.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/invoice.dart';
import '../../../data/repositories/local_business_repository.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/invoice_tile.dart';
import '../../../shared/widgets/page_heading.dart';
import '../../../shared/widgets/stat_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.repository, required this.onNavigate});

  final LocalBusinessRepository repository;
  final ValueChanged<int> onNavigate;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<void> _refresh() async => setState(() {});

  @override
  Widget build(BuildContext context) {
    final repo = widget.repository;
    final recent = repo.invoices.take(3).toList();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: AppTheme.green, borderRadius: BorderRadius.circular(15)),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('SoloSpark Pro', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                Text('Your business, in good shape.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ])),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF246B58), Color(0xFF3F9A7D)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('PAID INCOME', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.4)),
              const SizedBox(height: 8),
              Text(formatCurrency(repo.paidIncome), style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(child: _HeroMetric(label: 'Awaiting payment', value: formatCurrency(repo.pendingIncome), icon: Icons.hourglass_top_rounded)),
                Container(height: 42, width: 1, color: Colors.white24),
                const SizedBox(width: 16),
                Expanded(child: _HeroMetric(label: 'Net tracked', value: formatCurrency(repo.netTracked), icon: Icons.trending_up_rounded)),
              ]),
            ]),
          ),
          const SizedBox(height: 22),
          const PageHeading(title: 'Business snapshot', subtitle: 'A quick look at your activity.'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.45,
            children: [
              StatCard(label: 'Clients', value: '${repo.clients.length}', icon: Icons.people_outline),
              StatCard(label: 'Invoices', value: '${repo.invoices.length}', icon: Icons.receipt_long_outlined, tint: const Color(0xFF6B64B5)),
              StatCard(label: 'Expenses', value: formatCurrency(repo.expenseTotal), icon: Icons.payments_outlined, tint: const Color(0xFFD1843B)),
              StatCard(label: 'Overdue', value: '${repo.invoices.where((i) => i.status == InvoiceStatus.overdue).length}', icon: Icons.warning_amber_rounded, tint: const Color(0xFFB94141)),
            ],
          ),
          const SizedBox(height: 22),
          const Text('Quick actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _QuickAction(icon: Icons.add_card_rounded, title: 'New invoice', onTap: () => _createInvoice(context))),
            const SizedBox(width: 10),
            Expanded(child: _QuickAction(icon: Icons.person_add_alt_1_rounded, title: 'Add client', onTap: () => _createClient(context))),
            const SizedBox(width: 10),
            Expanded(child: _QuickAction(icon: Icons.add_chart_rounded, title: 'Add expense', onTap: () => _createExpense(context))),
          ]),
          const SizedBox(height: 24),
          Row(children: [
            const Expanded(child: Text('Recent invoices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
            TextButton(onPressed: () => widget.onNavigate(1), child: const Text('View all')),
          ]),
          if (recent.isEmpty)
            const EmptyState(icon: Icons.receipt_long, title: 'No invoices yet', subtitle: 'Create your first invoice to track a job.')
          else
            ...recent.map((invoice) => InvoiceTile(invoice: invoice, onTap: () => _showInvoice(context, invoice))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20)),
            child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.lightbulb_outline_rounded, color: AppTheme.green, size: 25),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Small-business tip', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Track expenses as you go. Knowing your costs makes it easier to price work confidently.'),
              ])),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _createInvoice(BuildContext context) async {
    final title = TextEditingController();
    final clientName = TextEditingController(text: widget.repository.clients.isNotEmpty ? widget.repository.clients.first.name : '');
    final amount = TextEditingController();
    final notes = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ok = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: _FormSheet(title: 'New invoice', formKey: formKey, children: [
          _input(title, 'Job or service name', validator: _required),
          const SizedBox(height: 10),
          _input(clientName, 'Client name', validator: _required),
          const SizedBox(height: 10),
          _input(amount, 'Amount (USD)', keyboard: const TextInputType.numberWithOptions(decimal: true), validator: _positiveNumber),
          const SizedBox(height: 10),
          _input(notes, 'Notes (optional)', maxLines: 2),
        ], onSave: () async {
          final now = DateTime.now();
          final invoice = Invoice(
            id: now.microsecondsSinceEpoch.toString(),
            number: 'SS-${now.millisecondsSinceEpoch.toString().substring(6)}',
            title: title.text.trim(), clientName: clientName.text.trim(),
            amount: double.parse(amount.text), issueDate: now,
            dueDate: now.add(const Duration(days: 14)), status: InvoiceStatus.sent,
            notes: notes.text.trim(),
          );
          await widget.repository.addInvoice(invoice);
          if (sheetContext.mounted) Navigator.pop(sheetContext, true);
        }),
      ),
    );
    title.dispose(); clientName.dispose(); amount.dispose(); notes.dispose();
    if (ok == true && mounted) setState(() {});
  }

  Future<void> _createClient(BuildContext context) async {
    final name = TextEditingController(); final email = TextEditingController(); final phone = TextEditingController();
    final key = GlobalKey<FormState>();
    final ok = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: _FormSheet(title: 'Add a client', formKey: key, children: [
          _input(name, 'Name or business', validator: _required),
          const SizedBox(height: 10), _input(email, 'Email (optional)', keyboard: TextInputType.emailAddress),
          const SizedBox(height: 10), _input(phone, 'Phone (optional)', keyboard: TextInputType.phone),
        ], onSave: () async {
          await widget.repository.addClient(Client(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name.text.trim(), email: email.text.trim(), phone: phone.text.trim(), createdAt: DateTime.now()));
          if (sheetContext.mounted) Navigator.pop(sheetContext, true);
        }),
      ),
    );
    name.dispose(); email.dispose(); phone.dispose();
    if (ok == true && mounted) setState(() {});
  }

  Future<void> _createExpense(BuildContext context) async {
    final title = TextEditingController(); final amount = TextEditingController();
    final key = GlobalKey<FormState>(); String category = 'Supplies';
    final ok = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(builder: (sheetContext, setSheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: _FormSheet(title: 'Add an expense', formKey: key, children: [
          _input(title, 'What did you pay for?', validator: _required),
          const SizedBox(height: 10),
          _input(amount, 'Amount (USD)', keyboard: const TextInputType.numberWithOptions(decimal: true), validator: _positiveNumber),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: category, decoration: const InputDecoration(labelText: 'Category'),
            items: const ['Supplies', 'Software', 'Travel', 'Marketing', 'Equipment', 'Other'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
            onChanged: (value) => setSheet(() => category = value ?? category),
          ),
        ], onSave: () async {
          await widget.repository.addExpense(Expense(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title.text.trim(), category: category, amount: double.parse(amount.text), date: DateTime.now()));
          if (sheetContext.mounted) Navigator.pop(sheetContext, true);
        }),
      )),
    );
    title.dispose(); amount.dispose();
    if (ok == true && mounted) setState(() {});
  }

  Future<void> _showInvoice(BuildContext context, Invoice invoice) async {
    await showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(26))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(invoice.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 5), Text('${invoice.clientName} · ${invoice.number}'),
          const SizedBox(height: 15), Text(formatCurrency(invoice.amount), style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w800, color: AppTheme.green)),
          const SizedBox(height: 5), Text('Due ${formatDate(invoice.dueDate)}'),
          if (invoice.notes.isNotEmpty) ...[const SizedBox(height: 8), Text(invoice.notes)],
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () async {
              final next = invoice.status == InvoiceStatus.paid ? InvoiceStatus.sent : InvoiceStatus.paid;
              await widget.repository.updateInvoice(invoice.copyWith(status: next));
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              if (mounted) setState(() {});
            }, child: Text(invoice.status == InvoiceStatus.paid ? 'Mark unpaid' : 'Mark paid'))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB94141)),
              onPressed: () async {
                await widget.repository.deleteInvoice(invoice.id);
                if (sheetContext.mounted) Navigator.pop(sheetContext);
                if (mounted) setState(() {});
              },
              child: const Text('Delete'),
            )),
          ]),
        ]),
      ),
    );
    if (mounted) setState(() {});
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'This field is required' : null;
  String? _positiveNumber(String? value) {
    final parsed = double.tryParse(value ?? '');
    return parsed == null || parsed <= 0 ? 'Enter an amount greater than zero' : null;
  }

  Widget _input(TextEditingController controller, String label, {String? Function(String?)? validator, TextInputType? keyboard, int maxLines = 1}) =>
      TextFormField(controller: controller, validator: validator, keyboardType: keyboard, maxLines: maxLines, decoration: InputDecoration(labelText: label));
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value, required this.icon});
  final String label; final String value; final IconData icon;

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: Colors.white70, size: 19),
    const SizedBox(width: 8),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      const SizedBox(height: 3),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15), overflow: TextOverflow.ellipsis),
    ])),
  ]);
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.title, required this.onTap});
  final IconData icon; final String title; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 7),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.2))),
      child: Column(children: [
        Icon(icon, color: AppTheme.green, size: 28),
        const SizedBox(height: 8),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    ),
  );
}

class _FormSheet extends StatelessWidget {
  const _FormSheet({required this.title, required this.formKey, required this.children, required this.onSave});
  final String title; final GlobalKey<FormState> formKey; final List<Widget> children; final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
    decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(26))),
    child: SingleChildScrollView(child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 17),
      ...children,
      const SizedBox(height: 18),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: () async {
        if (formKey.currentState!.validate()) await onSave();
      }, child: const Text('Save'))),
    ]))),
  );
}
