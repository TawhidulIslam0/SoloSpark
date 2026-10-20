class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.notes = '',
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String notes;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'amount': amount,
    'date': date.toIso8601String(),
    'notes': notes,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String? ?? 'Other',
    amount: (json['amount'] as num).toDouble(),
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    notes: json['notes'] as String? ?? '',
  );
}
