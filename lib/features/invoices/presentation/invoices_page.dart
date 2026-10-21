import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/invoice_pdf_generator.dart';
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
        const PageHeading(
          title: 'Invoices & quotes',
          subtitle: 'See what is paid and what still needs a nudge.',
        ),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
            child: StatCard(
              label: 'Paid',
              value: formatCurrency(repo.paidIncome),
              icon: Icons.check_circle_outline,
              tint: const Color(0xFF2F8068),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              label: 'Pending',
              value: formatCurrency(repo.pendingIncome),
              icon: Icons.hourglass_top,
              tint: const Color(0xFFD1843B),
            ),
          ),
        ]),
        const SizedBox(height: 18),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final item in ['All', 'Paid', 'Pending', 'Draft'])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(item),
                  selected: filter == item,
                  onSelected: (_) => setState(() => filter = item),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 14),
        if (visibleInvoices.isEmpty)
          const EmptyState(
            icon: Icons.receipt_long,
            title: 'Nothing in this filter',
            subtitle: 'Try another filter or add an invoice from the dashboard.',
          )
        else
          ...visibleInvoices.map((invoice) => InvoiceTile(
                invoice: invoice,
                onTap: () => _showDetails(context, invoice),
              )),
      ],
    );
  }

  Future<void> _showDetails(BuildContext context, Invoice invoice) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invoice.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text('${invoice.clientName} · ${invoice.number}'),
            const SizedBox(height: 14),
            Text(
              formatCurrency(invoice.amount),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text('Issued ${formatDate(invoice.issueDate)}'),
            Text('Due ${formatDate(invoice.dueDate)}'),
            const SizedBox(height: 5),
            Text('Status: ${invoice.status.label}'),
            if (invoice.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(invoice.notes),
            ],
            if (invoice.paymentLink.isNotEmpty) ...[
              const SizedBox(height: 10),
              SelectableText('Payment link: ${invoice.paymentLink}'),
            ],
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.green),
                  onPressed: () async {
                    try {
                      await generateAndShareInvoicePdf(
                        invoice,
                        widget.repository.businessProfile,
                      );
                    } catch (error) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Could not export PDF: $error')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: const Text('PDF'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await widget.repository.updateInvoice(
                      invoice.copyWith(
                        status: invoice.status == InvoiceStatus.paid
                            ? InvoiceStatus.sent
                            : InvoiceStatus.paid,
                      ),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) setState(() {});
                  },
                  child: Text(invoice.status == InvoiceStatus.paid
                      ? 'Mark pending'
                      : 'Mark paid'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFB94141)),
                  onPressed: () async {
                    await widget.repository.deleteInvoice(invoice.id);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) setState(() {});
                  },
                  child: const Text('Delete'),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (invoice.status == InvoiceStatus.sent || invoice.status == InvoiceStatus.overdue)
                  OutlinedButton.icon(
                  onPressed: () async {
                    final due = formatDate(invoice.dueDate);
                    final paymentLine = invoice.paymentLink.isEmpty
                        ? ''
                        : '\nYou can pay here: ${invoice.paymentLink}';
                    final message = 'Hi ${invoice.clientName}, just a friendly reminder that invoice ${invoice.number} for ${formatCurrency(invoice.amount)} is ${invoice.status == InvoiceStatus.overdue ? 'overdue' : 'due on $due'}. Please let me know if you have any questions.$paymentLine';
                    await Share.share(message, subject: 'Payment reminder ${invoice.number}');
                  },
                  icon: const Icon(Icons.notifications_active_outlined, size: 18),
                  label: const Text('Send reminder'),
                ),
                if (invoice.paymentLink.isNotEmpty)
                  FilledButton.icon(
                    onPressed: () async {
                      final uri = Uri.tryParse(invoice.paymentLink.trim());
                      if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http') || uri.host.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('This payment link is invalid. Edit the invoice and enter a full https:// URL.')),
                        );
                        return;
                      }
                      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
                      if (!opened && ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Could not open the payment link.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Open payment link'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    if (mounted) setState(() {});
  }
}
