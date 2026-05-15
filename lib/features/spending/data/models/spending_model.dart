import '../../domain/entities/spending_entity.dart';

class SpendingModel extends SpendingEntity {
  const SpendingModel({
    required super.id,
    required super.merchant,
    required super.amount,
    required super.currency,
    required super.category,
    required super.date,
  });

  factory SpendingModel.fromJson(Map<String, dynamic> json) {
    return SpendingModel(
      id: json['id'] as String,
      merchant: json['merchant'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
