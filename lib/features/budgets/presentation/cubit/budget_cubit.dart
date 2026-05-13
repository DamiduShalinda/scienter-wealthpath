import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealthpath/features/budgets/domain/entities/budget_entity.dart';
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
  Timer? _searchDebounceTimer;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  static const Duration _searchDebounceDuration = Duration(milliseconds: 300);

  Future<void> loadBudgets({int page = 1, int limit = 20}) async {
    _currentPage = page;
    _isLoadingMore = false;
    final cached = await _getCachedBudgets();

    if (cached.isNotEmpty) {
      emit(
        BudgetLoaded(
          budgets: cached,
          filteredBudgets: cached,
          searchQuery: '',
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
      final currentQuery = state is BudgetLoaded
          ? (state as BudgetLoaded).searchQuery
          : '';

      emit(
        BudgetLoaded(
          budgets: remote.items,
          filteredBudgets: _filterBudgets(remote.items, currentQuery),
          searchQuery: currentQuery,
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

  Future<void> loadMoreBudgets({int limit = 20}) async {
    final currentState = state;
    if (currentState is! BudgetLoaded) return;
    if (!currentState.hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    final nextPage = _currentPage + 1;

    try {
      final remote = await _getBudgets(page: nextPage, limit: limit);
      final mergedBudgets = <BudgetEntity>[
        ...currentState.budgets,
        ...remote.items,
      ];
      await _cacheBudgets(mergedBudgets);

      emit(
        currentState.copyWith(
          budgets: mergedBudgets,
          filteredBudgets: _filterBudgets(mergedBudgets, currentState.searchQuery),
          hasMore: remote.hasMore,
          isOffline: false,
        ),
      );
      _currentPage = nextPage;
    } catch (_) {
      emit(currentState);
    } finally {
      _isLoadingMore = false;
    }
  }

  void onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounceDuration, () {
      final currentState = state;
      if (currentState is! BudgetLoaded) return;

      final normalizedQuery = query.trim();
      emit(
        currentState.copyWith(
          searchQuery: normalizedQuery,
          filteredBudgets: _filterBudgets(currentState.budgets, normalizedQuery),
        ),
      );
    });
  }

  List<BudgetEntity> budgetsToDisplay() {
    final currentState = state;
    if (currentState is! BudgetLoaded) return const <BudgetEntity>[];
    return currentState.filteredBudgets;
  }

  List<BudgetEntity> _filterBudgets(List<BudgetEntity> budgets, String query) {
    if (query.isEmpty) return budgets;
    final lowerQuery = query.toLowerCase();
    return budgets
        .where((budget) => budget.category.toLowerCase().contains(lowerQuery))
        .toList(growable: false);
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    return super.close();
  }
}
