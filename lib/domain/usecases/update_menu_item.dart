import '../entities/menu_item.dart';
import '../repositories/menu_repository.dart';

class UpdateMenuItem {
  final MenuRepository repository;
  UpdateMenuItem(this.repository);

  Future<void> call(MenuItem item) => repository.updateMenuItem(item);
}