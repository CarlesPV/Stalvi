class CategoryStatistic {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final int totalAmount;

  const CategoryStatistic({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.totalAmount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryStatistic &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          categoryIcon == other.categoryIcon &&
          categoryColor == other.categoryColor &&
          totalAmount == other.totalAmount;

  @override
  int get hashCode =>
      categoryId.hashCode ^
      categoryName.hashCode ^
      categoryIcon.hashCode ^
      categoryColor.hashCode ^
      totalAmount.hashCode;
}
