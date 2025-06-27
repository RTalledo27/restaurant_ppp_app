import '../entities/order.dart';

abstract class OrderRepository {
  Stream<List<Order>> watchOrders();
  Stream<List<Order>> watchOrdersByUser(String userId);
  Future<void> updateOrderStatus(String id, String status);
  Future<void> assignOrder(String id, String deliveryId);
  Future<void> updateDeliveryLocation(String id, Map<String, dynamic> location);
  Stream<Order> watchOrder(String id);

}