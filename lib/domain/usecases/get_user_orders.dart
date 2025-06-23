import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetUserOrders {
  final OrderRepository repository;
  GetUserOrders(this.repository);

  Stream<List<Order>> call(String userId) => repository.watchOrdersByUser(userId);
}
