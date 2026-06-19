import 'package:stalvi/data/network/exchange_rate_remote_data_source.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';

/// Concrete implementation of [IExchangeRateRepository].
///
/// This repository is intentionally thin — its sole responsibility is to
/// delegate to [IExchangeRateRemoteDataSource] and map the result to the
/// domain entity. Any [AppException] thrown by the data source propagates
/// transparently to the caller (use case / presentation layer).
///
/// Caching (e.g., TTL-based local storage of rates) is deferred to a future
/// phase and will be added here without changing the interface contract.
import 'package:stalvi/data/database/daos/exchange_rate_dao.dart';

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
    // Return local rates if available, otherwise fetch remote
    final localRates = await getLocalRates(baseCurrency: baseCurrency);
    if (localRates != null) {
      return localRates;
    }

    final model = await _remoteDataSource.fetchLatestRates(
      baseCurrency: baseCurrency,
    );
    final domainRates = model.toDomain();
    await _exchangeRateDao.saveRates(domainRates);
    return domainRates;
  }

  @override
  Future<ExchangeRate?> getLocalRates({required String baseCurrency}) async {
    return _exchangeRateDao.getRates(baseCurrency);
  }

  @override
  Future<void> syncRates({required String baseCurrency}) async {
    final model = await _remoteDataSource.fetchLatestRates(
      baseCurrency: baseCurrency,
    );
    await _exchangeRateDao.saveRates(model.toDomain());
  }
}
