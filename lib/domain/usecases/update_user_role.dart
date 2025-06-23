import '../repositories/user_repository.dart';

class UpdateUserRole {
  final UserRepository repository;
  UpdateUserRole(this.repository);

  Future<void> call(String id, String role) {
    return repository.updateUserRole(id, role);
  }
}