import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/budget_page_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_data_source.dart';
import '../datasources/budget_remote_data_source.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl({
    required BudgetRemoteDataSource remoteDataSource,
    required BudgetLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final BudgetRemoteDataSource _remoteDataSource;
  final BudgetLocalDataSource _localDataSource;

  @override
  Future<BudgetPageEntity<BudgetEntity>> getBudgets({
    int page = 1,
    int limit = 20,
  }) async {
    return _remoteDataSource.getBudgets(page: page, limit: limit);
  }

  @override
  Future<BudgetEntity> updateBudgetLimit(String id, double newLimit) {
    return _remoteDataSource.updateBudgetLimit(id, newLimit);
  }

  @override
  Future<List<BudgetEntity>> getCachedBudgets() {
    return _localDataSource.getCachedBudgets();
  }

  @override
  Future<void> cacheBudgets(List<BudgetEntity> budgets) {
    final models = budgets
        .map(
          (entity) => BudgetModel(
            id: entity.id,
            category: entity.category,
            spent: entity.spent,
            limit: entity.limit,
            currency: entity.currency,
          ),
        )
        .toList(growable: false);

    return _localDataSource.cacheBudgets(models);
  }
}
