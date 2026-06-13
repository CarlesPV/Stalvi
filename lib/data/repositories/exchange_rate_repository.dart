import 'package:konta/data/network/exchange_rate_remote_data_source.dart';
import 'package:konta/domain/entities/exchange_rate.dart';
import 'package:konta/domain/repositories/i_exchange_rate_repository.dart';

/// Concrete implementation of [IExchangeRateRepository].
///
/// This repository is intentionally thin — its sole responsibility is to
/// delegate to [IExchangeRateRemoteDataSource] and map the result to the
/// domain entity. Any [AppException] thrown by the data source propagates
/// transparently to the caller (use case / presentation layer).
///
/// Caching (e.g., TTL-based local storage of rates) is deferred to a future
/// phase and will be added here without changing the interface contract.
class ExchangeRateRepository implements IExchangeRateRepository {
  final IExchangeRateRemoteDataSource _remoteDataSource;

  ExchangeRateRepository({
    required IExchangeRateRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<ExchangeRate> getLatestRates({required String baseCurrency}) async {
    final model = await _remoteDataSource.fetchLatestRates(
      baseCurrency: baseCurrency,
    );
    return model.toDomain();
  }
}
