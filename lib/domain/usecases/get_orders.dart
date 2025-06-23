import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrders {
  final OrderRepository repository;
  GetOrders(this.repository);

  Stream<List<Order>> call() => repository.watchOrders();
}