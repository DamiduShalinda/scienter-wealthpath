import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class UpdateBudgetLimit {
  const UpdateBudgetLimit(this._repository);

  final BudgetRepository _repository;

  Future<BudgetEntity> call(String id, double newLimit) {
    return _repository.updateBudgetLimit(id, newLimit);
  }
}
