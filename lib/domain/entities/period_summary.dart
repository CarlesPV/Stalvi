class PeriodSummary {
  final int totalIncome;
  final int totalExpense;
  final int totalTransfersIn;
  final int totalTransfersOut;

  const PeriodSummary({
    required this.totalIncome,
    required this.totalExpense,
    this.totalTransfersIn = 0,
    this.totalTransfersOut = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodSummary &&
          runtimeType == other.runtimeType &&
          totalIncome == other.totalIncome &&
          totalExpense == other.totalExpense &&
          totalTransfersIn == other.totalTransfersIn &&
          totalTransfersOut == other.totalTransfersOut;

  @override
  int get hashCode =>
      totalIncome.hashCode ^
      totalExpense.hashCode ^
      totalTransfersIn.hashCode ^
      totalTransfersOut.hashCode;
}
