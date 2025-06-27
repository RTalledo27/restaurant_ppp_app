import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:restaurant_ppp_app/domain/entities/order.dart';
import 'package:restaurant_ppp_app/domain/entities/order_item.dart';

class OrderModel extends Order {
  OrderModel({
    required super.id,
    required super.userId,
    required super.branchId,

    required super.items,
    required super.total,
    required super.status,
    super.createdAt,
    super.location,
    super.deliveryId,
    super.deliveryLocation,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      branchId: map['branchId'] as String? ?? '',

      items: (map['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem(
        id: e['id'] as String? ?? '',
        name: e['name'] as String? ?? '',
        quantity: (e['quantity'] as num?)?.toInt() ?? 0,
        note: e['note'] as String? ?? '',
        price: (e['price'] as num?)?.toDouble() ?? 0,
      ))
          .toList(),
      total: (map['total'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String? ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      location: map['location'] as Map<String, dynamic>?,
      deliveryId: map['deliveryId'] as String?,
      deliveryLocation: map['deliveryLocation'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'branchId': branchId,

      'items': items
          .map((e) => {
        'id': e.id,
        'name': e.name,
        'quantity': e.quantity,
        'note': e.note,
        'price': e.price,
      })
          .toList(),
      'total': total,
      'status': status,
      'createdAt': createdAt,
      'location': location,
      'deliveryId': deliveryId,
      'deliveryLocation': deliveryLocation,
    };
  }
}