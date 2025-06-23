import 'package:restaurant_ppp_app/domain/entities/order.dart';
import 'package:restaurant_ppp_app/domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remote;

  OrderRepositoryImpl(this.remote);

  @override
  Stream<List<Order>> watchOrders() {
    return remote.watchOrders().map((orders) => orders.cast<Order>());
  }

  @override
  Stream<List<Order>> watchOrdersByUser(String userId) {
    return remote
        .watchOrdersByUser(userId)
        .map((orders) => orders.cast<Order>());
  }

  @override
  Future<void> updateOrderStatus(String id, String status) {
    return remote.updateOrderStatus(id, status);
  }

  @override
  Future<void> createOrder(Order order) async {
    final model = OrderModel(
      id: '',
      userId: order.userId,
      branchId: order.branchId,
      items: order.items,
      total: order.total,
      status: order.status,
      createdAt: order.createdAt,
      location: order.location,
      paymentMethod: order.paymentMethod,
    );
    await remote.createOrder(model);
  }
}