import 'package:restaurant_ppp_app/domain/entities/order_item.dart';

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

  // Nuevos campos para información del cliente
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;

  const Order({
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
  });

  Order copyWith({
    String? id,
    String? userId,
    String? branchId,
    List<OrderItem>? items,
    double? total,
    String? status,
    DateTime? createdAt,
    Map<String, dynamic>? location,
    String? deliveryId,
    Map<String, dynamic>? deliveryLocation,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      branchId: branchId ?? this.branchId,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      deliveryId: deliveryId ?? this.deliveryId,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
    );
  }
}