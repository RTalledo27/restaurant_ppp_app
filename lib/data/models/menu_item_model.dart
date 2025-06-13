import 'package:restaurant_ppp_app/domain/entities/menu_item.dart';

class MenuItemModel extends MenuItem {
  MenuItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.price,
    super.stock = const {},
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuItemModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      stock: (map['stock'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'stock': stock,
    };
  }
}