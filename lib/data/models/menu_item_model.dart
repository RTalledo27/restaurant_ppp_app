import 'package:restaurant_ppp_app/domain/entities/menu_item.dart';

class MenuItemModel extends MenuItem {
  MenuItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.price,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuItemModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
    };
  }
}