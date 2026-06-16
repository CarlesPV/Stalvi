import 'package:intl/intl.dart';

void main() {
  final f1 = NumberFormat.currency(locale: 'en_US', name: 'EUR');
  print(f1.format(1234));
  final f2 = NumberFormat.simpleCurrency(locale: 'en_US', name: 'EUR');
  print(f2.format(1234));
  final f3 = NumberFormat.compactCurrency(locale: 'en_US', name: 'EUR');
  print(f3.format(1234));
  final f4 = NumberFormat.compactSimpleCurrency(locale: 'en_US', name: 'EUR');
  print(f4.format(1234));
}
