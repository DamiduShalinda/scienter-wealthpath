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
    required this.isOffline,
    required this.hasMore,
  });

  final List<BudgetEntity> budgets;
  final bool isOffline;
  final bool hasMore;
}

final class BudgetError extends BudgetState {
  const BudgetError(this.message);

  final String message;
}
