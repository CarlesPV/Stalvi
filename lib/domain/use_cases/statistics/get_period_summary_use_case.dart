import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/repositories/i_statistics_repository.dart';

class GetPeriodSummaryUseCase {
  final IStatisticsRepository _repository;

  GetPeriodSummaryUseCase(this._repository);

  Future<PeriodSummary> execute({
    required DateTime startDate,
    required DateTime endDate,
    String? accountId,
  }) {
    return _repository.getPeriodSummary(
      startDate: startDate,
      endDate: endDate,
      accountId: accountId,
    );
  }
}
