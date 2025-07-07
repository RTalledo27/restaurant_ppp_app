import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_ppp_app/domain/entities/order.dart' as AppOrder;
import 'package:restaurant_ppp_app/domain/entities/order_item.dart';

// Modelo extendido que incluye información del usuario
class EnhancedOrder {
  final String id;
  final String userId;
  final String branchId;
  final List<OrderItem> items;
  final double total;
  final String status;
  final DateTime? createdAt;
  final Map<String, dynamic>? location;
  final String? deliveryId;
  final Map<String, dynamic>? deliveryLocation;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final String? customerEmail;

  const EnhancedOrder({
    required this.id,
    required this.userId,
    required this.branchId,
    required this.items,
    required this.total,
    required this.status,
    this.createdAt,
    this.location,
    this.deliveryId,
    this.deliveryLocation,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.customerEmail,
  });

  factory EnhancedOrder.fromOrderAndUser(
      Map<String, dynamic> orderData,
      String orderId,
      Map<String, dynamic>? userData,
      ) {
    return EnhancedOrder(
      id: orderId,
      userId: orderData['userId'] as String? ?? '',
      branchId: orderData['branchId'] as String? ?? '',
      items: (orderData['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem(
        id: e['id'] as String? ?? '',
        name: e['name'] as String? ?? '',
        quantity: (e['quantity'] as num?)?.toInt() ?? 0,
        note: e['note'] as String? ?? '',
        price: (e['price'] as num?)?.toDouble() ?? 0,
      ))
          .toList(),
      total: (orderData['total'] as num?)?.toDouble() ?? 0,
      status: orderData['status'] as String? ?? 'pending',
      createdAt: (orderData['createdAt'] as Timestamp?)?.toDate(),
      location: orderData['location'] as Map<String, dynamic>?,
      deliveryId: orderData['deliveryId'] as String?,
      deliveryLocation: orderData['deliveryLocation'] as Map<String, dynamic>?,
      customerName: userData?['fullName'] as String?,
      customerPhone: userData?['phone'] as String?,
      customerEmail: userData?['email'] as String?,
      // Si tienes address en users, úsalo, sino usa la dirección de location
      customerAddress: userData?['address'] as String? ??
          _formatLocationAddress(orderData['location'] as Map<String, dynamic>?),
    );
  }

  static String? _formatLocationAddress(Map<String, dynamic>? location) {
    if (location == null) return null;
    final lat = location['lat'];
    final lng = location['lng'];
    if (lat != null && lng != null) {
      return 'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
    }
    return null;
  }

  // Método para convertir a Order original si es necesario
  AppOrder.Order toOrder() {
    return AppOrder.Order(
      id: id,
      userId: userId,
      branchId: branchId,
      items: items,
      total: total,
      status: status,
      createdAt: createdAt,
      location: location,
      deliveryId: deliveryId,
      deliveryLocation: deliveryLocation,
    );
  }
}

// Provider que combina orders con users
final enhancedOrderListStreamProvider = StreamProvider<List<EnhancedOrder>>((ref) {
  return FirebaseFirestore.instance
      .collection('orders')
      .snapshots()
      .asyncMap((ordersSnapshot) async {

    List<EnhancedOrder> enhancedOrders = [];

    for (var orderDoc in ordersSnapshot.docs) {
      final orderData = orderDoc.data();
      final userId = orderData['userId'] as String?;

      Map<String, dynamic>? userData;
      if (userId != null && userId.isNotEmpty) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          userData = userDoc.exists ? userDoc.data() : null;
        } catch (e) {
          print('Error fetching user data for $userId: $e');
        }
      }

      enhancedOrders.add(
          EnhancedOrder.fromOrderAndUser(orderData, orderDoc.id, userData)
      );
    }

    return enhancedOrders;
  });
});
