import '../entities/app_user.dart';
import '../repositories/user_repository.dart';

class GetUsers {
  final UserRepository repository;
  GetUsers(this.repository);

  Stream<List<AppUser>> call() => repository.watchUsers();
}