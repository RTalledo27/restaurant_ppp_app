import 'order_item.dart';

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final String status;
  final DateTime? createdAt;
  final Map<String, dynamic>? location;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    this.createdAt,
    this.location,
  });
}
