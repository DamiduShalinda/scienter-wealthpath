class BudgetEntity {
  const BudgetEntity({
    required this.id,
    required this.category,
    required this.spent,
    required this.limit,
    required this.currency,
  });

  final String id;
  final String category;
  final double spent;
  final double limit;
  final String currency;

  double get spendPercentage {
    if (limit <= 0) return 0;
    return (spent / limit).clamp(0, 1);
  }
}
