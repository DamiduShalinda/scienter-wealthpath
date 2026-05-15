import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class CacheBudgets {
  const CacheBudgets(this._repository);

  final BudgetRepository _repository;

  Future<void> call(List<BudgetEntity> budgets) {
    return _repository.cacheBudgets(budgets);
  }
}
