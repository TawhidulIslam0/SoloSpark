class Client {
  const Client({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.notes = '',
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String notes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}
