import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/datasources/user_remote_data_source.dart';
import '../data/repositories_impl/user_repository_impl.dart';
import '../domain/usecases/get_users.dart';
import '../domain/usecases/update_user_role.dart';
import 'menu_providers.dart';

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource(ref.read(firestoreProvider));
});

final userRepositoryProvider = Provider<UserRepositoryImpl>((ref) {
  return UserRepositoryImpl(ref.read(userRemoteDataSourceProvider));
});

final getUsersProvider = Provider<GetUsers>((ref) {
  return GetUsers(ref.read(userRepositoryProvider));
});

final updateUserRoleProvider = Provider<UpdateUserRole>((ref) {
  return UpdateUserRole(ref.read(userRepositoryProvider));
});

final userListStreamProvider = StreamProvider.autoDispose((ref) {
  return ref.read(getUsersProvider)();
});
