import '../entities/create_spending_input.dart';
import '../entities/spending_entity.dart';
import '../entities/spending_page_entity.dart';

abstract class SpendingRepository {
  Future<SpendingPageEntity> getSpending({int page = 1, int limit = 20});
  Future<SpendingEntity> addSpending(CreateSpendingInput input);
}
