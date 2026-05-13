import '../entities/budget_entity.dart';
import '../entities/budget_page_entity.dart';
import '../repositories/budget_repository.dart';

class GetBudgets {
  const GetBudgets(this._repository);

  final BudgetRepository _repository;

  Future<BudgetPageEntity<BudgetEntity>> call({int page = 1, int limit = 20}) {
    return _repository.getBudgets(page: page, limit: limit);
  }
}
