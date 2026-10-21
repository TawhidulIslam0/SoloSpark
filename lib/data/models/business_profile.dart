class BusinessProfile {
  const BusinessProfile({
    this.businessName = '',
    this.ownerName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.taxId = '',
    this.paymentInstructions = '',
    this.paymentTerms = 'Due on receipt',
  });

  final String businessName;
  final String ownerName;
  final String email;
  final String phone;
  final String address;
  final String taxId;
  final String paymentInstructions;
  final String paymentTerms;

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        'ownerName': ownerName,
        'email': email,
        'phone': phone,
        'address': address,
        'taxId': taxId,
        'paymentInstructions': paymentInstructions,
        'paymentTerms': paymentTerms,
      };

  factory BusinessProfile.fromJson(Map<String, dynamic> json) => BusinessProfile(
        businessName: json['businessName'] as String? ?? '',
        ownerName: json['ownerName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String? ?? '',
        taxId: json['taxId'] as String? ?? '',
        paymentInstructions: json['paymentInstructions'] as String? ?? '',
        paymentTerms: json['paymentTerms'] as String? ?? 'Due on receipt',
      );

  BusinessProfile copyWith({
    String? businessName,
    String? ownerName,
    String? email,
    String? phone,
    String? address,
    String? taxId,
    String? paymentInstructions,
    String? paymentTerms,
  }) {
    return BusinessProfile(
      businessName: businessName ?? this.businessName,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      taxId: taxId ?? this.taxId,
      paymentInstructions: paymentInstructions ?? this.paymentInstructions,
      paymentTerms: paymentTerms ?? this.paymentTerms,
    );
  }
}
