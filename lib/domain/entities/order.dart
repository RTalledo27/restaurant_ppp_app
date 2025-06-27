import 'order_item.dart';

class Order {
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


  Order({
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
  });
}