/// Domain input for creating a spending record.
class CreateSpendingInput {
  const CreateSpendingInput({
    required this.merchant,
    required this.amount,
    required this.category,
    required this.currency,
  });

  final String merchant;
  final double amount;
  final String category;
  final String currency;
}
