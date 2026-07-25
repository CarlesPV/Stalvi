import 'dart:developer';

import '../entities/exchange_rate.dart';
import '../repositories/i_exchange_rate_repository.dart';

/// Use case responsible for synchronizing local currency exchange rates
/// with remote APIs or offline fallbacks.
class SyncExchangeRatesUseCase {
  final IExchangeRateRepository _repository;

  SyncExchangeRatesUseCase(this._repository);

  /// Synchronizes the exchange rates in the background if they haven't been
  /// updated in the last 24 hours.
  /// Does not throw exceptions to ensure silent failure.
  Future<void> execute({required String baseCurrency}) async {
    try {
      final ExchangeRate? localRates =
          await _repository.getLocalRates(baseCurrency: baseCurrency);

      final now = DateTime.now();

      // If rates don't exist or are older than 24 hours, sync them.
      if (localRates == null || now.difference(localRates.date).inHours >= 24) {
        await _repository.syncRates(baseCurrency: baseCurrency);
      }
    } catch (e, st) {
      log(
        'Background sync of exchange rates failed: $e',
        error: e,
        stackTrace: st,
      );
    }
  }
}
