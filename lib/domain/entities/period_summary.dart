class PeriodSummary {
  final int totalIncome;
  final int totalExpense;

  const PeriodSummary({required this.totalIncome, required this.totalExpense});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodSummary &&
          runtimeType == other.runtimeType &&
          totalIncome == other.totalIncome &&
          totalExpense == other.totalExpense;

  @override
  int get hashCode => totalIncome.hashCode ^ totalExpense.hashCode;
}
