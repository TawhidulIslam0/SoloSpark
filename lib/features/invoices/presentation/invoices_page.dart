import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/invoice.dart';
import '../../../data/repositories/local_business_repository.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/invoice_tile.dart';
import '../../../shared/widgets/page_heading.dart';
import '../../../shared/widgets/stat_card.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key, required this.repository});
  final LocalBusinessRepository repository;

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  String filter = 'All';

  List<Invoice> get visibleInvoices {
    final all = widget.repository.invoices;
    if (filter == 'All') return all;
    if (filter == 'Paid') return all.where((i) => i.status == InvoiceStatus.paid).toList();
    if (filter == 'Pending') return all.where((i) => i.status == InvoiceStatus.sent || i.status == InvoiceStatus.overdue).toList();
    return all.where((i) => i.status == InvoiceStatus.draft).toList();
  }

  @override
  Widget build(BuildContext context) {
    final repo = widget.repository;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      children: [
        const PageHeading(title: 'Invoices & quotes', subtitle: 'See what is paid and what still needs a nudge.'),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: StatCard(label: 'Paid', value: formatCurrency(repo.paidIncome), icon: Icons.check_circle_outline, tint: const Color(0xFF2F8068))),
          const SizedBox(width: 10),
          Expanded(child: StatCard(label: 'Pending', value: formatCurrency(repo.pendingIncome), icon: Icons.hourglass_top, tint: const Color(0xFFD1843B))),
        ]),
        const SizedBox(height: 18),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          for (final item in ['All', 'Paid', 'Pending', 'Draft'])
            Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(item), selected: filter == item, onSelected: (_) => setState(() => filter = item))),
        ])),
        const SizedBox(height: 14),
        if (visibleInvoices.isEmpty)
          const EmptyState(icon: Icons.receipt_long, title: 'Nothing in this filter', subtitle: 'Try another filter or add an invoice from the dashboard.')
        else
          ...visibleInvoices.map((invoice) => InvoiceTile(invoice: invoice, onTap: () => _showDetails(context, invoice))),
      ],
    );
  }

  Future<void> _showDetails(BuildContext context, Invoice invoice) async {
    await showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(26))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(invoice.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 5), Text('${invoice.clientName} · ${invoice.number}'),
          const SizedBox(height: 14), Text(formatCurrency(invoice.amount), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6), Text('Issued ${formatDate(invoice.issueDate)}'),
          Text('Due ${formatDate(invoice.dueDate)}'),
          const SizedBox(height: 5), Text('Status: ${invoice.status.label}'),
          if (invoice.notes.isNotEmpty) ...[const SizedBox(height: 8), Text(invoice.notes)],
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () async {
              await widget.repository.updateInvoice(invoice.copyWith(status: invoice.status == InvoiceStatus.paid ? InvoiceStatus.sent : InvoiceStatus.paid));
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) setState(() {});
            }, child: Text(invoice.status == InvoiceStatus.paid ? 'Mark pending' : 'Mark paid'))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB94141)), onPressed: () async {
              await widget.repository.deleteInvoice(invoice.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) setState(() {});
            }, child: const Text('Delete'))),
          ]),
        ]),
      ),
    );
    if (mounted) setState(() {});
  }
}
