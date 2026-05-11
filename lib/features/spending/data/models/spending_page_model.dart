import '../../domain/entities/spending_page_entity.dart';
import 'spending_model.dart';

class SpendingPageModel extends SpendingPageEntity {
  const SpendingPageModel({
    required super.items,
    required super.total,
    required super.hasMore,
  });

  factory SpendingPageModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(SpendingModel.fromJson)
        .toList();

    return SpendingPageModel(
      items: data,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
