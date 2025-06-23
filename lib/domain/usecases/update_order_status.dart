import '../repositories/order_repository.dart';

class UpdateOrderStatus {
  final OrderRepository repository;
  UpdateOrderStatus(this.repository);

  Future<void> call(String id, String status) {
    return repository.updateOrderStatus(id, status);
  }
}