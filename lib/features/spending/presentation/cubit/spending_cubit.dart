import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealthpath/features/spending/domain/entities/create_spending_input.dart';
import 'package:wealthpath/features/spending/domain/entities/spending_entity.dart';
import 'package:wealthpath/features/spending/domain/usecases/add_spending.dart';
import 'package:wealthpath/features/spending/domain/usecases/get_spending.dart';

import 'spending_state.dart';

class SpendingCubit extends Cubit<SpendingState> {
  SpendingCubit(this._getSpending, this._addSpending) : super(const SpendingInitial());

  final GetSpending _getSpending;
  final AddSpending _addSpending;
  int _currentPage = 1;
  bool _isLoadingMore = false;

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
    _currentPage = 1;
    _isLoadingMore = false;
    emit(const SpendingInitial());
  }

  Future<void> loadSpending({int page = 1, int limit = 20}) async {
    emit(const SpendingLoading());
    try {
      final response = await _getSpending(page: page, limit: limit);
      _currentPage = page;
      emit(
        SpendingLoaded(
          items: response.items,
          total: response.total,
          hasMore: response.hasMore,
        ),
      );
    } catch (_) {
      emit(const SpendingError('Failed to load spending records.'));
    }
  }

  Future<void> loadMoreSpending({int limit = 20}) async {
    final currentState = state;
    if (currentState is! SpendingLoaded) return;
    if (!currentState.hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    final nextPage = _currentPage + 1;

    try {
      final response = await _getSpending(page: nextPage, limit: limit);
      _currentPage = nextPage;

      emit(
        SpendingLoaded(
          items: <SpendingEntity>[...currentState.items, ...response.items],
          total: response.total,
          hasMore: response.hasMore,
        ),
      );
    } catch (_) {
      emit(const SpendingError('Failed to load more spending records.'));
      emit(currentState);
    } finally {
      _isLoadingMore = false;
    }
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
      final created = await _addSpending(input);
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
      final latestState = state;
      if (latestState is SpendingLoaded) {
        final rollbackItems = latestState.items
            .where((item) => item.id != optimisticItem.id)
            .toList(growable: false);
        final rollbackTotal = latestState.total - input.amount;
        emit(
          SpendingLoaded(
            items: rollbackItems,
            total: rollbackTotal < 0 ? 0 : rollbackTotal,
            hasMore: latestState.hasMore,
          ),
        );
      } else {
        emit(
          SpendingLoaded(
            items: currentState.items,
            total: currentState.total,
            hasMore: currentState.hasMore,
          ),
        );
      }
      emit(const SpendingError('Failed to add spending. Changes rolled back.'));
    }
  }
}
