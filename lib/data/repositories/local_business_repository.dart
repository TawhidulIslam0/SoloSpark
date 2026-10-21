import '../models/business_profile.dart';
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
  BusinessProfile _businessProfile = const BusinessProfile();

  List<Invoice> get invoices => List.unmodifiable(_invoices);
  List<Client> get clients => List.unmodifiable(_clients);
  List<Expense> get expenses => List.unmodifiable(_expenses);
  BusinessProfile get businessProfile => _businessProfile;

  double get paidIncome => _invoices
      .where((invoice) => invoice.status == InvoiceStatus.paid)
      .fold(0, (sum, invoice) => sum + invoice.amount);

  double get pendingIncome => _invoices
      .where((invoice) => invoice.status == InvoiceStatus.sent || invoice.status == InvoiceStatus.overdue)
      .fold(0, (sum, invoice) => sum + invoice.amount);

  double get expenseTotal => _expenses.fold(0, (sum, expense) => sum + expense.amount);
  double get netTracked => paidIncome - expenseTotal;

  /// Loads saved user data from storage without any demo seeding.
  Future<void> initializeData() async {
    _invoices
      ..clear()
      ..addAll(_storage.readInvoices());
    _clients
      ..clear()
      ..addAll(_storage.readClients());
    _expenses
      ..clear()
      ..addAll(_storage.readExpenses());
    _businessProfile = _storage.readBusinessProfile();
    await refreshOverdueStatuses();

    // Automatically wipe out old cached demo data if it's still sitting in storage
    final hasLegacyDemoData = _clients.any((c) => c.id == 'client-northstar') ||
        _invoices.any((i) => i.id == 'invoice-1001');

    if (hasLegacyDemoData) {
      await clearAllData();
    }
  }

  /// Automatically flags unpaid invoices as overdue after their due date.
  Future<void> refreshOverdueStatuses() async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    var changed = false;
    for (var index = 0; index < _invoices.length; index++) {
      final invoice = _invoices[index];
      if (invoice.status == InvoiceStatus.sent && invoice.dueDate.isBefore(startOfToday)) {
        _invoices[index] = invoice.copyWith(status: InvoiceStatus.overdue);
        changed = true;
      }
    }
    if (changed) await _storage.writeInvoices(_invoices);
  }

  /// Clears all local storage records so the app becomes completely empty.
  Future<void> clearAllData() async {
    await _storage.clearBusinessData();
    _invoices.clear();
    _clients.clear();
    _expenses.clear();
    _businessProfile = const BusinessProfile();
  }

  Future<void> updateBusinessProfile(BusinessProfile profile) async {
    _businessProfile = profile;
    await _storage.writeBusinessProfile(profile);
  }

  Future<void> addInvoice(Invoice invoice) async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final savedInvoice = invoice.status == InvoiceStatus.sent && invoice.dueDate.isBefore(startOfToday)
        ? invoice.copyWith(status: InvoiceStatus.overdue)
        : invoice;
    _invoices.insert(0, savedInvoice);
    await _storage.writeInvoices(_invoices);
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final savedInvoice = invoice.status == InvoiceStatus.sent && invoice.dueDate.isBefore(startOfToday)
        ? invoice.copyWith(status: InvoiceStatus.overdue)
        : invoice;
    final index = _invoices.indexWhere((item) => item.id == invoice.id);
    if (index >= 0) _invoices[index] = savedInvoice;
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
}
