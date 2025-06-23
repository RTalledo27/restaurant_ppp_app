import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderRemoteDataSource {
  final FirebaseFirestore firestore;
  OrderRemoteDataSource(this.firestore);

  Stream<List<OrderModel>> watchOrders() {
    return firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> updateOrderStatus(String id, String status) {
    return firestore.collection('orders').doc(id).update({'status': status});
  }
}