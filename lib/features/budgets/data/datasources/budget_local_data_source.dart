import '../../../../core/database/app_database.dart';
import '../models/budget_model.dart';

abstract class BudgetLocalDataSource {
  Future<List<BudgetModel>> getCachedBudgets();
  Future<void> cacheBudgets(List<BudgetModel> budgets);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  BudgetLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<BudgetModel>> getCachedBudgets() async {
    final rows = await _database.select(_database.budgetsTable).get();

    return rows
        .map(
          (row) => BudgetModel(
            id: row.id,
            category: row.category,
            spent: row.spent,
            limit: row.limit,
            currency: row.currency,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> cacheBudgets(List<BudgetModel> budgets) async {
    final companions = budgets
        .map(
          (item) => BudgetsTableCompanion.insert(
            id: item.id,
            category: item.category,
            spent: item.spent,
            limit: item.limit,
            currency: item.currency,
          ),
        )
        .toList(growable: false);

    await _database.replaceBudgets(companions);
  }
}
