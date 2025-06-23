import '../entities/order.dart';

abstract class OrderRepository {
  Stream<List<Order>> watchOrders();
  Stream<List<Order>> watchOrdersByUser(String userId);
  Future<void> updateOrderStatus(String id, String status);
}