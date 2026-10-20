import 'package:intl/intl.dart';

final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: r'$', decimalDigits: 2);
final shortDateFormatter = DateFormat('MMM d, yyyy');

String formatCurrency(double value) => currencyFormatter.format(value);
String formatDate(DateTime value) => shortDateFormatter.format(value);
