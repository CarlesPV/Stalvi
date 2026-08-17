enum TrashItemType {
  transaction,
  category,
  account,
  budget,
  savingsGoal,
  automaticTransaction,
  tag,
}

class TrashItem {
  final String id;
  final String name;
  final TrashItemType type;
  final int daysRemaining;
  final DateTime deletedAt;

  final Map<String, dynamic>? metadata;

  const TrashItem({
    required this.id,
    required this.name,
    required this.type,
    required this.daysRemaining,
    required this.deletedAt,
    this.metadata,
  });
}
