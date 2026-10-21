import 'dart:io';

import 'package:csv/csv.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/client.dart';
import '../models/expense.dart';
import '../models/invoice.dart';

class CsvExportService {
  Future<void> exportBusinessData({
    required List<Invoice> invoices,
    required List<Client> clients,
    required List<Expense> expenses,
  }) async {
    final rows = <List<dynamic>>[
      ['Record Type', 'ID / Invoice Number', 'Name / Title', 'Client / Category', 'Amount USD', 'Status', 'Date', 'Due Date', 'Email', 'Phone', 'Notes', 'Payment Link'],
      ...invoices.map((invoice) => [
        'Invoice', invoice.number, invoice.title, invoice.clientName,
        invoice.amount.toStringAsFixed(2), invoice.status.label,
        _date(invoice.issueDate), _date(invoice.dueDate), '', '',
        invoice.notes, invoice.paymentLink,
      ]),
      ...clients.map((client) => [
        'Client', client.id, client.name, '', '', '', _date(client.createdAt), '',
        client.email, client.phone, client.notes, '',
      ]),
      ...expenses.map((expense) => [
        'Expense', expense.id, expense.title, expense.category,
        expense.amount.toStringAsFixed(2), '', _date(expense.date), '', '', '',
        expense.notes, '',
      ]),
    ];

    final csvText = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/solospark_business_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString('\uFEFF$csvText', flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv', name: 'solospark_business_export.csv')],
      subject: 'SoloSpark Pro business data export',
      text: 'Your SoloSpark Pro invoices, clients, and expenses export.',
    );
  }

  String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
