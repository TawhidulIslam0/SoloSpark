import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/client.dart';
import '../models/expense.dart';
import '../models/invoice.dart';

class LocalStorageService {
  SharedPreferences? _preferences;

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  List<T> readList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _preferences?.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> writeList<T>(String key, List<T> values, Map<String, dynamic> Function(T) toJson) async {
    await _preferences?.setString(key, jsonEncode(values.map(toJson).toList()));
  }

  List<Invoice> readInvoices() => readList(AppConstants.storageInvoicesKey, Invoice.fromJson);
  List<Client> readClients() => readList(AppConstants.storageClientsKey, Client.fromJson);
  List<Expense> readExpenses() => readList(AppConstants.storageExpensesKey, Expense.fromJson);

  Future<void> writeInvoices(List<Invoice> values) => writeList(AppConstants.storageInvoicesKey, values, (v) => v.toJson());
  Future<void> writeClients(List<Client> values) => writeList(AppConstants.storageClientsKey, values, (v) => v.toJson());
  Future<void> writeExpenses(List<Expense> values) => writeList(AppConstants.storageExpensesKey, values, (v) => v.toJson());

  Future<void> clearBusinessData() async {
    await _preferences?.remove(AppConstants.storageInvoicesKey);
    await _preferences?.remove(AppConstants.storageClientsKey);
    await _preferences?.remove(AppConstants.storageExpensesKey);
  }
}
