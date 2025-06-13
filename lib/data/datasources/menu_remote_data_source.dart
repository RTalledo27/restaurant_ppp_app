import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/menu_item_model.dart';

class MenuRemoteDataSource {
  final FirebaseFirestore firestore;

  MenuRemoteDataSource(this.firestore);

  Stream<List<MenuItemModel>> watchMenu() {
    return firestore.collection('menu').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => MenuItemModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Future<void> addMenuItem(MenuItemModel item) {
    return firestore.collection('menu').doc(item.id).set(item.toMap());
  }
}