import '../repositories/order_repository.dart';

class AssignOrderToDelivery {
  final OrderRepository repository;
  AssignOrderToDelivery(this.repository);

  Future<void> call(String id, String deliveryId) {
    return repository.assignOrder(id, deliveryId);
  }
}
