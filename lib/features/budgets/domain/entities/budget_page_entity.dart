class BudgetPageEntity<T> {
  const BudgetPageEntity({
    required this.items,
    required this.hasMore,
  });

  final List<T> items;
  final bool hasMore;
}
