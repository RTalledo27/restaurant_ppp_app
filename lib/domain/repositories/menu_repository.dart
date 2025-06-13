import 'package:restaurant_ppp_app/domain/entities/menu_item.dart';

abstract class MenuRepository {
  Stream<List<MenuItem>> watchMenu();
  Future<void> addMenuItem(MenuItem item);
  Future<void> updateMenuItem(MenuItem item);
}