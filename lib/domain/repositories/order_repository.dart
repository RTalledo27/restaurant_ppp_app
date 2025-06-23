import '../entities/order.dart';

abstract class OrderRepository {
  Stream<List<Order>> watchOrders();
  Future<void> updateOrderStatus(String id, String status);
}