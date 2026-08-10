import 'package:stalvi/infrastructure/services/fallback_exchange_rates.dart';
import '../network/exchange_rate_remote_data_source.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import '../database/daos/exchange_rate_dao.dart';

/// Concrete implementation of [IExchangeRateRepository].
///
/// Responsible for fetching and syncing exchange rates, automatically falling
/// back to local storage and hardcoded infrastructure fallback rates when
/// offline or network errors occur.
class ExchangeRateRepository implements IExchangeRateRepository {
  final IExchangeRateRemoteDataSource _remoteDataSource;
  final ExchangeRateDao _exchangeRateDao;

  ExchangeRateRepository({
    required IExchangeRateRemoteDataSource remoteDataSource,
    required ExchangeRateDao exchangeRateDao,
  })  : _remoteDataSource = remoteDataSource,
        _exchangeRateDao = exchangeRateDao;

  @override
  Future<ExchangeRate> getLatestRates({required String baseCurrency}) async {
    // Return local rates if available
    final localRates = await _exchangeRateDao.getRates(baseCurrency);
    if (localRates != null) {
      return localRates;
    }

    try {
      final model = await _remoteDataSource.fetchLatestRates(
        baseCurrency: baseCurrency,
      );
      final domainRates = model.toDomain().copyWith(date: DateTime.now());
      await _exchangeRateDao.saveRates(domainRates);
      return domainRates;
    } catch (_) {
      final fallback = FallbackExchangeRates.getExchangeRate(baseCurrency);
      await _exchangeRateDao.saveRates(fallback);
      return fallback;
    }
  }

  @override
  Future<ExchangeRate?> getLocalRates({required String baseCurrency}) async {
    final local = await _exchangeRateDao.getRates(baseCurrency);
    if (local != null) {
      return local;
    }
    return FallbackExchangeRates.getExchangeRate(baseCurrency);
  }

  @override
  Future<void> syncRates({required String baseCurrency}) async {
    try {
      final model = await _remoteDataSource.fetchLatestRates(
        baseCurrency: baseCurrency,
      );
      await _exchangeRateDao.saveRates(
        model.toDomain().copyWith(date: DateTime.now()),
      );
    } catch (e) {
      // Offline fallback: ensure local database has fallback rates
      final local = await _exchangeRateDao.getRates(baseCurrency);
      if (local == null) {
        final fallback = FallbackExchangeRates.getExchangeRate(baseCurrency);
        await _exchangeRateDao.saveRates(fallback);
      }
      rethrow;
    }
  }
}
