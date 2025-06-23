import 'package:restaurant_ppp_app/domain/entities/order.dart';
import 'package:restaurant_ppp_app/domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remote;
  OrderRepositoryImpl(this.remote);

  @override
  Stream<List<Order>> watchOrders() => remote.watchOrders();

  @override
  Future<void> updateOrderStatus(String id, String status) {
    return remote.updateOrderStatus(id, status);
  }
}
