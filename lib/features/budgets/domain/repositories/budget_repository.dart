import '../entities/budget_entity.dart';
import '../entities/budget_page_entity.dart';

abstract class BudgetRepository {
  Future<BudgetPageEntity<BudgetEntity>> getBudgets({int page = 1, int limit = 20});
  Future<BudgetEntity> updateBudgetLimit(
    String id,
    double newLimit, {
    bool forceFail = false,
  });
  Future<List<BudgetEntity>> getCachedBudgets();
  Future<void> cacheBudgets(List<BudgetEntity> budgets);
}
