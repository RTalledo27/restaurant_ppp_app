import 'package:restaurant_ppp_app/domain/entities/menu_item.dart';
import 'package:restaurant_ppp_app/domain/repositories/menu_repository.dart';

class GetMenu {
  final MenuRepository repository;

  GetMenu(this.repository);

  Stream<List<MenuItem>> call() {
    return repository.watchMenu();
  }
}