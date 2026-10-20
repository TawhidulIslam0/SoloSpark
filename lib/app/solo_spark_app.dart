import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/repositories/local_business_repository.dart';
import '../features/clients/presentation/clients_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/expenses/presentation/expenses_page.dart';
import '../features/invoices/presentation/invoices_page.dart';
import '../features/settings/presentation/settings_page.dart';

class SoloSparkApp extends StatefulWidget {
  const SoloSparkApp({super.key, required this.repository});

  final LocalBusinessRepository repository;

  @override
  State<SoloSparkApp> createState() => _SoloSparkAppState();
}

class _SoloSparkAppState extends State<SoloSparkApp> {
  int _selectedIndex = 0;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(repository: widget.repository, onNavigate: (index) {
        setState(() => _selectedIndex = index);
      }),
      InvoicesPage(repository: widget.repository),
      ClientsPage(repository: widget.repository),
      ExpensesPage(repository: widget.repository),
      SettingsPage(
        repository: widget.repository,
        darkMode: _darkMode,
        onThemeChanged: (value) => setState(() => _darkMode = value),
      ),
    ];

    return MaterialApp(
      title: 'SoloSpark Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: SafeArea(
          child: IndexedStack(index: _selectedIndex, children: pages),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Invoices'),
            NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Clients'),
            NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: 'Expenses'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
