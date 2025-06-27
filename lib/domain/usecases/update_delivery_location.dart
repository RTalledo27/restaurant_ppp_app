import '../repositories/order_repository.dart';

class UpdateDeliveryLocation {
  final OrderRepository repository;
  UpdateDeliveryLocation(this.repository);

  Future<void> call(String id, Map<String, dynamic> location) {
    return repository.updateDeliveryLocation(id, location);
  }
}
