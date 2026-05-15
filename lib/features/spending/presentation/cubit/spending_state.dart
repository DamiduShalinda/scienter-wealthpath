import 'package:wealthpath/features/spending/domain/entities/spending_entity.dart';

sealed class SpendingState {
  const SpendingState();
}

final class SpendingInitial extends SpendingState {
  const SpendingInitial();
}

final class SpendingLoading extends SpendingState {
  const SpendingLoading();
}

final class SpendingLoaded extends SpendingState {
  const SpendingLoaded({
    required this.items,
    required this.total,
    required this.hasMore,
  });

  final List<SpendingEntity> items;
  final double total;
  final bool hasMore;
}

final class SpendingError extends SpendingState {
  const SpendingError(this.message);

  final String message;
}
