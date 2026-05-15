import '../../domain/entities/create_spending_input.dart';
import '../../domain/entities/spending_entity.dart';
import '../../domain/entities/spending_page_entity.dart';
import '../../domain/repositories/spending_repository.dart';
import '../datasources/spending_remote_data_source.dart';

class SpendingRepositoryImpl implements SpendingRepository {
  SpendingRepositoryImpl(this._remoteDataSource);

  final SpendingRemoteDataSource _remoteDataSource;

  @override
  Future<SpendingPageEntity> getSpending({int page = 1, int limit = 20}) {
    return _remoteDataSource.getSpending(page: page, limit: limit);
  }

  @override
  Future<SpendingEntity> addSpending(CreateSpendingInput input) {
    return _remoteDataSource.addSpending(input);
  }
}
