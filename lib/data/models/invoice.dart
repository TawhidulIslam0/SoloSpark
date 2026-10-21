enum InvoiceStatus { draft, sent, paid, overdue }

extension InvoiceStatusLabel on InvoiceStatus {
  String get label => switch (this) {
    InvoiceStatus.draft => 'Draft',
    InvoiceStatus.sent => 'Awaiting payment',
    InvoiceStatus.paid => 'Paid',
    InvoiceStatus.overdue => 'Overdue',
  };

  static InvoiceStatus parse(String? value) => InvoiceStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => InvoiceStatus.sent,
  );
}

class Invoice {
  const Invoice({
    required this.id,
    required this.number,
    required this.title,
    required this.clientName,
    required this.amount,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    this.notes = '',
    this.paymentLink = '',
  });

  final String id;
  final String number;
  final String title;
  final String clientName;
  final double amount;
  final DateTime issueDate;
  final DateTime dueDate;
  final InvoiceStatus status;
  final String notes;
  final String paymentLink;

  Invoice copyWith({InvoiceStatus? status, String? paymentLink}) => Invoice(
    id: id,
    number: number,
    title: title,
    clientName: clientName,
    amount: amount,
    issueDate: issueDate,
    dueDate: dueDate,
    status: status ?? this.status,
    notes: notes,
    paymentLink: paymentLink ?? this.paymentLink,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'title': title,
    'clientName': clientName,
    'amount': amount,
    'issueDate': issueDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'status': status.name,
    'notes': notes,
    'paymentLink': paymentLink,
  };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    id: json['id'] as String,
    number: json['number'] as String? ?? '',
    title: json['title'] as String,
    clientName: json['clientName'] as String,
    amount: (json['amount'] as num).toDouble(),
    issueDate: DateTime.tryParse(json['issueDate'] as String? ?? '') ?? DateTime.now(),
    dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
    status: InvoiceStatusLabel.parse(json['status'] as String?),
    notes: json['notes'] as String? ?? '',
    paymentLink: json['paymentLink'] as String? ?? '',
  );
}
