import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/expense.dart';
import '../../../data/repositories/local_business_repository.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/page_heading.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key, required this.repository});
  final LocalBusinessRepository repository;

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  @override
  Widget build(BuildContext context) {
    final expenses = widget.repository.expenses;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense, backgroundColor: AppTheme.green, foregroundColor: Colors.white,
        icon: const Icon(Icons.add), label: const Text('Add expense'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 100),
        children: [
          const PageHeading(title: 'Expenses', subtitle: 'Know what it costs to run your business.'),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.inverseSurface, borderRadius: BorderRadius.circular(22)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TOTAL RECORDED EXPENSES', style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface.withOpacity(.7), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
              const SizedBox(height: 7),
              Text(formatCurrency(widget.repository.expenseTotal), style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface, fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text('${expenses.length} entries', style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface.withOpacity(.7))),
            ]),
          ),
          const SizedBox(height: 18),
          if (expenses.isEmpty)
            const EmptyState(icon: Icons.payments_outlined, title: 'No expenses recorded', subtitle: 'Add software, supplies, travel, and other costs.')
          else
            ...expenses.map((expense) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [
                Container(width: 43, height: 43, decoration: BoxDecoration(color: const Color(0xFFFFF2E4), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.receipt, color: Color(0xFFD1843B))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text('${expense.category} · ${formatDate(expense.date)}', style: Theme.of(context).textTheme.bodySmall),
                  if (expense.notes.isNotEmpty) Text(expense.notes, style: Theme.of(context).textTheme.bodySmall),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('-${formatCurrency(expense.amount)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  IconButton(visualDensity: VisualDensity.compact, onPressed: () => _deleteExpense(expense), icon: const Icon(Icons.delete_outline, size: 19, color: Colors.black45)),
                ]),
              ])),
            )),
        ],
      ),
    );
  }

  Future<void> _addExpense() async {
    final title = TextEditingController(); final amount = TextEditingController(); final notes = TextEditingController();
    final key = GlobalKey<FormState>(); String category = 'Supplies';
    final result = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(padding: const EdgeInsets.fromLTRB(20, 20, 20, 24), decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(26))),
          child: Form(key: key, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Add an expense', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _field(title, 'What did you pay for?', validator: _required),
            const SizedBox(height: 10),
            _field(amount, 'Amount (USD)', keyboard: const TextInputType.numberWithOptions(decimal: true), validator: _amountValidator),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: category, decoration: const InputDecoration(labelText: 'Category'),
              items: const ['Supplies', 'Software', 'Travel', 'Marketing', 'Equipment', 'Other'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (value) => setSheet(() => category = value ?? category),
            ),
            const SizedBox(height: 10), _field(notes, 'Notes (optional)', maxLines: 2),
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () async {
              if (!key.currentState!.validate()) return;
              await widget.repository.addExpense(Expense(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title.text.trim(), category: category, amount: double.parse(amount.text), date: DateTime.now(), notes: notes.text.trim()));
              if (ctx.mounted) Navigator.pop(ctx, true);
            }, child: const Text('Save expense'))),
          ])),
        ),
      )),
    );
    title.dispose(); amount.dispose(); notes.dispose();
    if (result == true && mounted) setState(() {});
  }

  Future<void> _deleteExpense(Expense expense) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete expense?'), content: Text('Remove ${expense.title}?'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete'))],
    ));
    if (confirmed == true) {
      await widget.repository.deleteExpense(expense.id);
      if (mounted) setState(() {});
    }
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'This field is required' : null;
  String? _amountValidator(String? value) {
    final parsed = double.tryParse(value ?? '');
    return parsed == null || parsed <= 0 ? 'Enter an amount greater than zero' : null;
  }

  Widget _field(TextEditingController controller, String label, {String? Function(String?)? validator, TextInputType? keyboard, int maxLines = 1}) =>
      TextFormField(controller: controller, validator: validator, keyboardType: keyboard, maxLines: maxLines, decoration: InputDecoration(labelText: label));
}
