import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrder {
  final OrderRepository repository;
  GetOrder(this.repository);

  Stream<Order> call(String id) => repository.watchOrder(id);
}