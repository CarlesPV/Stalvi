// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transactions';

  @override
  String get budgets => 'Budgets';

  @override
  String get settings => 'Settings';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorDatabase =>
      'Database error occurred. Please contact support.';

  @override
  String get errorAuth =>
      'Authentication failed. Please check your credentials.';

  @override
  String get errorNetwork =>
      'Network error. Please check your internet connection.';
}
