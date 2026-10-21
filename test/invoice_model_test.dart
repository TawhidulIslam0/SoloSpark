import 'package:flutter_test/flutter_test.dart';
import 'package:solospark_pro/data/models/invoice.dart';

void main() {
  test('invoice serializes and restores status, amount, and payment link', () {
    final original = Invoice(
      id: 'i1',
      number: 'SS-1001',
      title: 'Logo design',
      clientName: 'Example Client',
      amount: 325.50,
      issueDate: DateTime(2026, 10, 20),
      dueDate: DateTime(2026, 11, 3),
      status: InvoiceStatus.paid,
      notes: 'Final delivery',
      paymentLink: 'https://paypal.me/example/325',
    );

    final restored = Invoice.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.amount, 325.50);
    expect(restored.status, InvoiceStatus.paid);
    expect(restored.notes, 'Final delivery');
    expect(restored.paymentLink, 'https://paypal.me/example/325');
  });

  test('old invoice data remains compatible when payment link is missing', () {
    final restored = Invoice.fromJson({
      'id': 'legacy',
      'number': 'SS-OLD',
      'title': 'Legacy service',
      'clientName': 'Old Client',
      'amount': 50,
      'issueDate': '2026-10-01T00:00:00.000',
      'dueDate': '2026-10-15T00:00:00.000',
      'status': 'sent',
      'notes': '',
    });

    expect(restored.paymentLink, isEmpty);
  });
}
