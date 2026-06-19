enum TrashItemType {
  transaction,
  category,
  account,
  budget,
  savingsGoal,
}

class TrashItem {
  final String id;
  final String name;
  final TrashItemType type;
  final int daysRemaining;

  final Map<String, dynamic>? metadata;

  const TrashItem({
    required this.id,
    required this.name,
    required this.type,
    required this.daysRemaining,
    this.metadata,
  });
}
