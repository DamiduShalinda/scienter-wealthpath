import '../../domain/entities/budget_page_entity.dart';
import 'budget_model.dart';

class BudgetPageModel extends BudgetPageEntity<BudgetModel> {
  const BudgetPageModel({
    required super.items,
    required super.hasMore,
  });

  factory BudgetPageModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(BudgetModel.fromJson)
        .toList(growable: false);

    return BudgetPageModel(
      items: data,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
