import '../models/client.dart';
import '../models/expense.dart';
import '../models/invoice.dart';
import '../services/local_storage_service.dart';

class LocalBusinessRepository {
  LocalBusinessRepository(this._storage);

  final LocalStorageService _storage;
  final List<Invoice> _invoices = [];
  final List<Client> _clients = [];
  final List<Expense> _expenses = [];

  List<Invoice> get invoices => List.unmodifiable(_invoices);
  List<Client> get clients => List.unmodifiable(_clients);
  List<Expense> get expenses => List.unmodifiable(_expenses);

  double get paidIncome => _invoices
      .where((invoice) => invoice.status == InvoiceStatus.paid)
      .fold(0, (sum, invoice) => sum + invoice.amount);

  double get pendingIncome => _invoices
      .where((invoice) => invoice.status == InvoiceStatus.sent || invoice.status == InvoiceStatus.overdue)
      .fold(0, (sum, invoice) => sum + invoice.amount);

  double get expenseTotal => _expenses.fold(0, (sum, expense) => sum + expense.amount);
  double get netTracked => paidIncome - expenseTotal;

  Future<void> initializeDemoData() async {
    _invoices
      ..clear()
      ..addAll(_storage.readInvoices());
    _clients
      ..clear()
      ..addAll(_storage.readClients());
    _expenses
      ..clear()
      ..addAll(_storage.readExpenses());

    if (_invoices.isEmpty && _clients.isEmpty && _expenses.isEmpty) {
      final now = DateTime.now();
      _clients.addAll([
        Client(id: 'client-northstar', name: 'Northstar Studio', email: 'hello@northstar.example', createdAt: now),
        Client(id: 'client-jordan', name: 'Jordan Lee', email: 'jordan@example.com', createdAt: now),
      ]);
      _invoices.addAll([
        Invoice(id: 'invoice-1001', number: 'SS-1001', title: 'Website refresh', clientName: 'Northstar Studio', amount: 850, issueDate: now.subtract(const Duration(days: 5)), dueDate: now.add(const Duration(days: 9)), status: InvoiceStatus.paid, notes: 'Homepage and mobile layout'),
        Invoice(id: 'invoice-1002', number: 'SS-1002', title: 'Brand consultation', clientName: 'Jordan Lee', amount: 240, issueDate: now, dueDate: now.add(const Duration(days: 7)), status: InvoiceStatus.sent, notes: 'Two-hour consultation'),
      ]);
      await _persistAll();
    }
  }

  Future<void> addInvoice(Invoice invoice) async {
    _invoices.insert(0, invoice);
    await _storage.writeInvoices(_invoices);
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final index = _invoices.indexWhere((item) => item.id == invoice.id);
    if (index >= 0) _invoices[index] = invoice;
    await _storage.writeInvoices(_invoices);
  }

  Future<void> deleteInvoice(String id) async {
    _invoices.removeWhere((item) => item.id == id);
    await _storage.writeInvoices(_invoices);
  }

  Future<void> addClient(Client client) async {
    _clients.insert(0, client);
    await _storage.writeClients(_clients);
  }

  Future<void> deleteClient(String id) async {
    _clients.removeWhere((item) => item.id == id);
    await _storage.writeClients(_clients);
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.insert(0, expense);
    await _storage.writeExpenses(_expenses);
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((item) => item.id == id);
    await _storage.writeExpenses(_expenses);
  }

  Future<void> resetDemoData() async {
    await _storage.clearBusinessData();
    _invoices.clear();
    _clients.clear();
    _expenses.clear();
    await initializeDemoData();
  }

  Future<void> _persistAll() async {
    await _storage.writeInvoices(_invoices);
    await _storage.writeClients(_clients);
    await _storage.writeExpenses(_expenses);
  }
}
