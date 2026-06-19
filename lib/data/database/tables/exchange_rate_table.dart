import 'package:drift/drift.dart';

@DataClassName('ExchangeRateEntity')
class ExchangeRates extends Table {
  TextColumn get baseCurrency => text().named('base_currency')();
  DateTimeColumn get date => dateTime()();
  TextColumn get rates => text()(); // Stores the JSON map as string

  @override
  Set<Column> get primaryKey => {baseCurrency};
}
