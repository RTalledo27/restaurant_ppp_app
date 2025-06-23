import '../entities/app_user.dart';

abstract class UserRepository {
  Stream<List<AppUser>> watchUsers();
  Future<void> updateUserRole(String id, String role);
}
