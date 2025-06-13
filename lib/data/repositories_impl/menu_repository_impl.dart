import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_data_source.dart';
import '../models/menu_item_model.dart';

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
    );
    return remote.addMenuItem(model);
  }
}