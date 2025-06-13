import '../entities/menu_item.dart';

abstract class MenuRepository {
  Stream<List<MenuItem>> watchMenu();
  Future<void> addMenuItem(MenuItem item);
}