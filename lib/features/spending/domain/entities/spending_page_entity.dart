import 'spending_entity.dart';

/// Domain entity for a paginated spending response.
class SpendingPageEntity {
  const SpendingPageEntity({
    required this.items,
    required this.total,
    required this.hasMore,
  });

  final List<SpendingEntity> items;
  final double total;
  final bool hasMore;
}
