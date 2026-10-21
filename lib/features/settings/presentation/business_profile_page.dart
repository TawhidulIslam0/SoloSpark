import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/business_profile.dart';
import '../../../data/repositories/local_business_repository.dart';

class BusinessProfilePage extends StatefulWidget {
  const BusinessProfilePage({super.key, required this.repository});
  final LocalBusinessRepository repository;

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessName;
  late final TextEditingController _ownerName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _taxId;
  late final TextEditingController _paymentInstructions;
  late final TextEditingController _paymentTerms;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.repository.businessProfile;
    _businessName = TextEditingController(text: profile.businessName);
    _ownerName = TextEditingController(text: profile.ownerName);
    _email = TextEditingController(text: profile.email);
    _phone = TextEditingController(text: profile.phone);
    _address = TextEditingController(text: profile.address);
    _taxId = TextEditingController(text: profile.taxId);
    _paymentInstructions = TextEditingController(text: profile.paymentInstructions);
    _paymentTerms = TextEditingController(text: profile.paymentTerms);
  }

  @override
  void dispose() {
    _businessName.dispose();
    _ownerName.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _taxId.dispose();
    _paymentInstructions.dispose();
    _paymentTerms.dispose();
    super.dispose();
  }

  // Strict Email Validation Regex
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional field
    final emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address (e.g. name@domain.com)';
    }
    return null;
  }

  // 10-Digit Phone Validation
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional field
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  // 9-Digit Tax ID / EIN Validation
  String? _validateTaxId(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional field
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 9) {
      return 'EIN must be 9 digits (XX-XXXXXXX)';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final updatedProfile = BusinessProfile(
      businessName: _businessName.text.trim(),
      ownerName: _ownerName.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      taxId: _taxId.text.trim(),
      paymentInstructions: _paymentInstructions.text.trim(),
      paymentTerms: _paymentTerms.text.trim().isEmpty ? 'Due on receipt' : _paymentTerms.text.trim(),
    );

    await widget.repository.updateBusinessProfile(updatedProfile);

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business profile updated successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Branding & Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'These details will appear on your generated PDF invoices.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _businessName,
                decoration: const InputDecoration(
                  labelText: 'Business / Trade Name *',
                  hintText: 'e.g., Apex Design Studio',
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Business name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ownerName,
                decoration: const InputDecoration(
                  labelText: 'Your Name (Owner)',
                  hintText: 'e.g., Alex Johnson',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Business Email',
                  hintText: 'billing@apexdesign.com',
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _USPhoneFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Business Phone',
                  hintText: '(555) 000-1234',
                ),
                validator: _validatePhone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Business Address',
                  hintText: '123 Main St, Suite 100, New York, NY 10001',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _taxId,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _EinFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Tax ID / EIN (Optional)',
                  hintText: '12-3456789',
                ),
                validator: _validateTaxId,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _paymentInstructions,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Payment Instructions / Bank Details',
                  hintText: 'Zelle: billing@apexdesign.com\nBank: Chase, Acct ending in 4321',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _paymentTerms,
                decoration: const InputDecoration(
                  labelText: 'Default Payment Terms',
                  hintText: 'Due on receipt, Net 15, or Net 30',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.green),
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom formatter that auto-formats raw numbers into (XXX) XXX-XXXX
class _USPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    final digits = text.replaceAll(RegExp(r'\D'), '');
    for (int i = 0; i < digits.length && i < 10; i++) {
      if (i == 0) buffer.write('(');
      if (i == 3) buffer.write(') ');
      if (i == 6) buffer.write('-');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Custom formatter that converts 123456789 into 12-3456789
class _EinFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final digits = text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 9; i++) {
      if (i == 2) buffer.write('-');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
