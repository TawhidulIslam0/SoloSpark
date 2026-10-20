import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../data/models/invoice.dart';

class InvoiceTile extends StatelessWidget {
  const InvoiceTile({super.key, required this.invoice, required this.onTap});

  final Invoice invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final paid = invoice.status == InvoiceStatus.paid;
    final overdue = invoice.status == InvoiceStatus.overdue;
    final color = paid ? const Color(0xFF2F8068) : overdue ? const Color(0xFFB94141) : const Color(0xFFD1843B);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 45, height: 45,
                decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.description_outlined, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(invoice.title, style: const TextStyle(fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text('${invoice.clientName} · ${invoice.number}', style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(30)),
                      child: Text(invoice.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(formatCurrency(invoice.amount), style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
