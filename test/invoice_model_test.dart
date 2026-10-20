import 'package:flutter_test/flutter_test.dart';
import 'package:solospark_pro/data/models/invoice.dart';

void main() {
  test('invoice serializes and restores its status and amount', () {
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
    );

    final restored = Invoice.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.amount, 325.50);
    expect(restored.status, InvoiceStatus.paid);
    expect(restored.notes, 'Final delivery');
  });
}
