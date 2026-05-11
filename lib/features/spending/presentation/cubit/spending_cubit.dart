import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealthpath/features/spending/domain/entities/spending_entity.dart';

import 'spending_state.dart';

class SpendingCubit extends Cubit<SpendingState> {
  SpendingCubit() : super(const SpendingInitial());

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
}
