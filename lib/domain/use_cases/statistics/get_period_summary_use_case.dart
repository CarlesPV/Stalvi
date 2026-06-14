import 'package:konta/domain/entities/period_summary.dart';
import 'package:konta/domain/repositories/i_statistics_repository.dart';

class GetPeriodSummaryUseCase {
  final IStatisticsRepository _repository;

  GetPeriodSummaryUseCase(this._repository);

  Future<PeriodSummary> execute({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _repository.getPeriodSummary(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
