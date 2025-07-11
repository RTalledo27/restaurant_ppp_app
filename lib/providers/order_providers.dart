import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/datasources/order_remote_data_source.dart';
import '../data/repositories_impl/order_repository_impl.dart';
import '../domain/usecases/get_orders.dart';
import '../domain/usecases/get_user_orders.dart';
import '../domain/usecases/update_order_status.dart';
import '../domain/usecases/assign_order_to_delivery.dart';
import '../domain/usecases/update_delivery_location.dart';
import 'menu_providers.dart';
import '../domain/usecases/get_order.dart';


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



final assignOrderProvider = Provider<AssignOrderToDelivery>((ref) {
  return AssignOrderToDelivery(ref.read(orderRepositoryProvider));
});

final updateDeliveryLocationProvider = Provider<UpdateDeliveryLocation>((ref) {
  return UpdateDeliveryLocation(ref.read(orderRepositoryProvider));
});


final getOrderProvider = Provider<GetOrder>((ref) {
  return GetOrder(ref.read(orderRepositoryProvider));
});

final orderStreamProvider = StreamProvider.family.autoDispose((ref, String id) {
  return ref.read(getOrderProvider)(id);
});