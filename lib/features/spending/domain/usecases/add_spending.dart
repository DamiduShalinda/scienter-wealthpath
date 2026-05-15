import '../entities/create_spending_input.dart';
import '../entities/spending_entity.dart';
import '../repositories/spending_repository.dart';

class AddSpending {
  const AddSpending(this._repository);

  final SpendingRepository _repository;

  Future<SpendingEntity> call(CreateSpendingInput input) {
    return _repository.addSpending(input);
  }
}
