/// Domain entity for a spending record.
class SpendingEntity {
  const SpendingEntity({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
  });

  final String id;
  final String merchant;
  final double amount;
  final String currency;
  final String category;
  final DateTime date;
}
