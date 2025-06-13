import 'package:restaurant_ppp_app/domain/entities/menu_item.dart';
import 'package:restaurant_ppp_app/domain/repositories/menu_repository.dart';
import 'package:restaurant_ppp_app/data/datasources/menu_remote_data_source.dart';
import 'package:restaurant_ppp_app/data/models/menu_item_model.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remote;

  MenuRepositoryImpl(this.remote);

  @override
  Stream<List<MenuItem>> watchMenu() {
    return remote.watchMenu();
  }

  @override
  Future<void> addMenuItem(MenuItem item) {
    final model = MenuItemModel(
      id: item.id,
      name: item.name,
      description: item.description,
      imageUrl: item.imageUrl,
      price: item.price,
      stock: item.stock,
    );
    return remote.addMenuItem(model);
  }

  @override
  Future<void> updateMenuItem(MenuItem item) {
    final model = MenuItemModel(
      id: item.id,
      name: item.name,
      description: item.description,
      imageUrl: item.imageUrl,
      price: item.price,
      stock: item.stock,
    );
    return remote.updateMenuItem(model);
  }
}
