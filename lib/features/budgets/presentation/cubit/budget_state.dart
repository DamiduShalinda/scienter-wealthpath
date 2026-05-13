import 'package:wealthpath/features/budgets/domain/entities/budget_entity.dart';

sealed class BudgetState {
  const BudgetState();
}

final class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

final class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

final class BudgetLoaded extends BudgetState {
  const BudgetLoaded({
    required this.budgets,
    required this.filteredBudgets,
    required this.searchQuery,
    required this.isOffline,
    required this.hasMore,
  });

  final List<BudgetEntity> budgets;
  final List<BudgetEntity> filteredBudgets;
  final String searchQuery;
  final bool isOffline;
  final bool hasMore;

  BudgetLoaded copyWith({
    List<BudgetEntity>? budgets,
    List<BudgetEntity>? filteredBudgets,
    String? searchQuery,
    bool? isOffline,
    bool? hasMore,
  }) {
    return BudgetLoaded(
      budgets: budgets ?? this.budgets,
      filteredBudgets: filteredBudgets ?? this.filteredBudgets,
      searchQuery: searchQuery ?? this.searchQuery,
      isOffline: isOffline ?? this.isOffline,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

final class BudgetError extends BudgetState {
  const BudgetError(this.message);

  final String message;
}
