import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealthpath/features/spending/domain/entities/create_spending_input.dart';
import 'package:wealthpath/features/spending/domain/entities/spending_entity.dart';
import 'package:wealthpath/features/spending/domain/repositories/spending_repository.dart';

import 'spending_state.dart';

class SpendingCubit extends Cubit<SpendingState> {
  SpendingCubit(this._repository) : super(const SpendingInitial());

  final SpendingRepository _repository;

  void setLoading() {
    emit(const SpendingLoading());
  }

  void setLoaded({
    required List<SpendingEntity> items,
    required double total,
    required bool hasMore,
  }) {
    emit(SpendingLoaded(items: items, total: total, hasMore: hasMore));
  }

  void setError(String message) {
    emit(SpendingError(message));
  }

  void reset() {
    emit(const SpendingInitial());
  }

  Future<void> addSpendingOptimistic(CreateSpendingInput input) async {
    final currentState = state;
    if (currentState is! SpendingLoaded) {
      emit(const SpendingError('Cannot add spending before list is loaded.'));
      return;
    }

    final optimisticItem = SpendingEntity(
      id: 'temp_${DateTime.now().microsecondsSinceEpoch}',
      merchant: input.merchant,
      amount: input.amount,
      currency: input.currency,
      category: input.category,
      date: DateTime.now().toUtc(),
    );

    final optimisticItems = <SpendingEntity>[
      optimisticItem,
      ...currentState.items,
    ];
    final optimisticTotal = currentState.total + input.amount;

    emit(
      SpendingLoaded(
        items: optimisticItems,
        total: optimisticTotal,
        hasMore: currentState.hasMore,
      ),
    );

    try {
      final created = await _repository.addSpending(input);
      final latestState = state;
      if (latestState is! SpendingLoaded) {
        return;
      }

      final reconciledItems = latestState.items
          .map((item) => item.id == optimisticItem.id ? created : item)
          .toList(growable: false);

      emit(
        SpendingLoaded(
          items: reconciledItems,
          total: latestState.total,
          hasMore: latestState.hasMore,
        ),
      );
    } catch (_) {
      final rollbackItems = currentState.items;
      final rollbackTotal = currentState.total;

      emit(
        SpendingLoaded(
          items: rollbackItems,
          total: rollbackTotal,
          hasMore: currentState.hasMore,
        ),
      );
      emit(const SpendingError('Failed to add spending. Changes rolled back.'));
    }
  }
}
