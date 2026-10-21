import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/models/business_profile.dart';
import '../../data/models/invoice.dart';
import 'formatters.dart';

Future<void> generateAndShareInvoicePdf(
  Invoice invoice,
  BusinessProfile profile,
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.letter,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header / Business Info & Invoice Badge
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      profile.businessName.isNotEmpty
                          ? profile.businessName
                          : 'My Business',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal800,
                      ),
                    ),
                    if (profile.ownerName.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(profile.ownerName,
                          style: const pw.TextStyle(fontSize: 11)),
                    ],
                    if (profile.address.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(profile.address,
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                    ],
                    if (profile.email.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(profile.email,
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                    ],
                    if (profile.phone.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(profile.phone,
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                    ],
                    if (profile.taxId.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text('EIN: ${profile.taxId}',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      invoice.number,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Issued: ${formatDate(invoice.issueDate)}',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey700),
                    ),
                    pw.Text(
                      'Due: ${formatDate(invoice.dueDate)}',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.teal50,
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Text(
                        invoice.status.label.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 16),

            // Bill To Section
            pw.Text(
              'BILLED TO:',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey600,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              invoice.clientName,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),
            if (profile.paymentTerms.isNotEmpty)
              pw.Text('Payment terms: ${profile.paymentTerms}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            pw.SizedBox(height: 22),

            // Itemized Table Header
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Description',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.Text('Amount',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 11)),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(invoice.title,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      if (invoice.notes.isNotEmpty) ...[
                        pw.SizedBox(height: 3),
                        pw.Text(invoice.notes,
                            style: const pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ],
                  ),
                  pw.Text(formatCurrency(invoice.amount),
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 11)),
                ],
              ),
            ),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 10),

            // Total Due Summary
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Total Due:',
                        style: pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey600)),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      formatCurrency(invoice.amount),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal800,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Payment Instructions Footer
            if (invoice.paymentLink.isNotEmpty) ...[
              pw.Spacer(),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Text('Online payment link:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey700)),
              pw.SizedBox(height: 3),
              if (_isWebUrl(invoice.paymentLink))
                pw.UrlLink(destination: invoice.paymentLink, child: pw.Text(invoice.paymentLink, style: const pw.TextStyle(fontSize: 9, color: PdfColors.blue)))
              else
                pw.Text(invoice.paymentLink, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            ],
            if (profile.paymentInstructions.isNotEmpty) ...[
              pw.Spacer(),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Text(
                'Payment Instructions:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                profile.paymentInstructions,
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ],
        );
      },
    ),
  );

  // Open the native Android share sheet so the PDF can be sent or saved.
  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'Invoice-${invoice.number}.pdf',
  );
}
bool _isWebUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  return uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty;
}
