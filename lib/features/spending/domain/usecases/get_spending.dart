import '../entities/spending_page_entity.dart';
import '../repositories/spending_repository.dart';

class GetSpending {
  const GetSpending(this._repository);

  final SpendingRepository _repository;

  Future<SpendingPageEntity> call({int page = 1, int limit = 20}) {
    return _repository.getSpending(page: page, limit: limit);
  }
}
