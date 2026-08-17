import 'dart:convert';
import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/exchange_rate_table.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';

part 'exchange_rate_dao.g.dart';

@DriftAccessor(tables: [ExchangeRates])
class ExchangeRateDao extends DatabaseAccessor<AppDatabase>
    with _$ExchangeRateDaoMixin {
  ExchangeRateDao(super.db);

  Future<ExchangeRate?> getRates(String baseCurrency) async {
    final entity = await (select(
      exchangeRates,
    )..where((t) => t.baseCurrency.equals(baseCurrency)))
        .getSingleOrNull();

    if (entity == null) return null;

    final ratesMap = jsonDecode(entity.rates) as Map<String, dynamic>;
    return ExchangeRate(
      baseCurrency: entity.baseCurrency,
      date: entity.date,
      rates: ratesMap.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  Future<void> saveRates(ExchangeRate exchangeRate) async {
    final entity = ExchangeRateEntity(
      baseCurrency: exchangeRate.baseCurrency,
      date: exchangeRate.date,
      rates: jsonEncode(exchangeRate.rates),
    );

    await into(exchangeRates).insertOnConflictUpdate(entity);
  }
}
