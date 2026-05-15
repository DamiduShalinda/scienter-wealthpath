import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class GetCachedBudgets {
  const GetCachedBudgets(this._repository);

  final BudgetRepository _repository;

  Future<List<BudgetEntity>> call() {
    return _repository.getCachedBudgets();
  }
}
