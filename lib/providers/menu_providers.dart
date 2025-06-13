import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/datasources/menu_remote_data_source.dart';
import '../data/repositories_impl/menu_repository_impl.dart';
import '../domain/usecases/get_menu.dart';
import '../domain/usecases/add_menu_item.dart';
import '../domain/usecases/update_menu_item.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final menuRemoteDataSourceProvider = Provider<MenuRemoteDataSource>((ref) {
  return MenuRemoteDataSource(ref.read(firestoreProvider));
});

final menuRepositoryProvider = Provider<MenuRepositoryImpl>((ref) {
  return MenuRepositoryImpl(ref.read(menuRemoteDataSourceProvider));
});

final getMenuProvider = Provider<GetMenu>((ref) {
  return GetMenu(ref.read(menuRepositoryProvider));
});

final addMenuItemProvider = Provider<AddMenuItem>((ref) {
  return AddMenuItem(ref.read(menuRepositoryProvider));
});

final updateMenuItemProvider = Provider<UpdateMenuItem>((ref) {
  return UpdateMenuItem(ref.read(menuRepositoryProvider));
});

final menuListStreamProvider = StreamProvider.autoDispose((ref) {
  return ref.read(getMenuProvider)();
});
