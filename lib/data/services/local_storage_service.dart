import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/business_profile.dart';
import '../models/client.dart';
import '../models/expense.dart';
import '../models/invoice.dart';

class LocalStorageService {
  SharedPreferences? _preferences;

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Safely reads a JSON list string from SharedPreferences and decodes it.
  /// Returns an empty list [] if no data exists or if parsing fails.
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

  /// Serializes a list of items to JSON and saves it to SharedPreferences.
  Future<void> writeList<T>(
    String key,
    List<T> values,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    await _preferences?.setString(
      key,
      jsonEncode(values.map(toJson).toList()),
    );
  }

  // --- Entity Readers ---
  List<Invoice> readInvoices() =>
      readList(AppConstants.storageInvoicesKey, Invoice.fromJson);

  List<Client> readClients() =>
      readList(AppConstants.storageClientsKey, Client.fromJson);

  List<Expense> readExpenses() =>
      readList(AppConstants.storageExpensesKey, Expense.fromJson);

  BusinessProfile readBusinessProfile() {
    final raw = _preferences?.getString(AppConstants.storageBusinessProfileKey);
    if (raw == null || raw.isEmpty) return const BusinessProfile();
    try {
      return BusinessProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return const BusinessProfile();
    }
  }

  // --- Entity Writers ---
  Future<void> writeInvoices(List<Invoice> values) =>
      writeList(AppConstants.storageInvoicesKey, values, (v) => v.toJson());

  Future<void> writeClients(List<Client> values) =>
      writeList(AppConstants.storageClientsKey, values, (v) => v.toJson());

  Future<void> writeExpenses(List<Expense> values) =>
      writeList(AppConstants.storageExpensesKey, values, (v) => v.toJson());

  Future<void> writeBusinessProfile(BusinessProfile profile) async {
    await _preferences?.setString(
      AppConstants.storageBusinessProfileKey,
      jsonEncode(profile.toJson()),
    );
  }

  /// Completely wipes all invoice, client, expense, and business profile storage keys.
  Future<void> clearBusinessData() async {
    await _preferences?.remove(AppConstants.storageInvoicesKey);
    await _preferences?.remove(AppConstants.storageClientsKey);
    await _preferences?.remove(AppConstants.storageExpensesKey);
    await _preferences?.remove(AppConstants.storageBusinessProfileKey);
  }
}