import 'package:restaurant_ppp_app/domain/entities/app_user.dart';
import 'package:restaurant_ppp_app/domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;
  UserRepositoryImpl(this.remote);

  @override
  Stream<List<AppUser>> watchUsers() => remote.watchUsers();

  @override
  Future<void> updateUserRole(String id, String role) {
    return remote.updateUserRole(id, role);
  }
}
