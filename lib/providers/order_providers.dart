import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/datasources/order_remote_data_source.dart';
import '../data/repositories_impl/order_repository_impl.dart';
import '../domain/usecases/get_orders.dart';
import '../domain/usecases/get_user_orders.dart';
import '../domain/usecases/update_order_status.dart';
import 'menu_providers.dart';

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSource(ref.read(firestoreProvider));
});

final orderRepositoryProvider = Provider<OrderRepositoryImpl>((ref) {
  return OrderRepositoryImpl(ref.read(orderRemoteDataSourceProvider));
});

final getOrdersProvider = Provider<GetOrders>((ref) {
  return GetOrders(ref.read(orderRepositoryProvider));
});

final getUserOrdersProvider = Provider<GetUserOrders>((ref) {
  return GetUserOrders(ref.read(orderRepositoryProvider));
});

final updateOrderStatusProvider = Provider<UpdateOrderStatus>((ref) {
  return UpdateOrderStatus(ref.read(orderRepositoryProvider));
});

final orderListStreamProvider = StreamProvider.autoDispose((ref) {
  return ref.read(getOrdersProvider)();
});

final userOrderListStreamProvider =
StreamProvider.autoDispose.family((ref, String userId) {
  return ref.read(getUserOrdersProvider)(userId);
});
