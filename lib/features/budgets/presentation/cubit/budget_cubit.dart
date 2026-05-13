import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealthpath/features/budgets/domain/usecases/cache_budgets.dart';
import 'package:wealthpath/features/budgets/domain/usecases/get_budgets.dart';
import 'package:wealthpath/features/budgets/domain/usecases/get_cached_budgets.dart';

import 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit({
    required GetBudgets getBudgets,
    required GetCachedBudgets getCachedBudgets,
    required CacheBudgets cacheBudgets,
  })  : _getBudgets = getBudgets,
        _getCachedBudgets = getCachedBudgets,
        _cacheBudgets = cacheBudgets,
        super(const BudgetInitial());

  final GetBudgets _getBudgets;
  final GetCachedBudgets _getCachedBudgets;
  final CacheBudgets _cacheBudgets;

  Future<void> loadBudgets({int page = 1, int limit = 20}) async {
    final cached = await _getCachedBudgets();

    if (cached.isNotEmpty) {
      emit(
        BudgetLoaded(
          budgets: cached,
          isOffline: true,
          hasMore: false,
        ),
      );
    } else {
      emit(const BudgetLoading());
    }

    try {
      final remote = await _getBudgets(page: page, limit: limit);
      await _cacheBudgets(remote.items);

      emit(
        BudgetLoaded(
          budgets: remote.items,
          isOffline: false,
          hasMore: remote.hasMore,
        ),
      );
    } catch (_) {
      if (cached.isEmpty) {
        emit(const BudgetError('Failed to load budgets.'));
      }
    }
  }
}
