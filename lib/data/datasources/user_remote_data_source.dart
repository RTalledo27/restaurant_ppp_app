import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user_model.dart';

class UserRemoteDataSource {
  final FirebaseFirestore firestore;
  UserRemoteDataSource(this.firestore);

  Stream<List<AppUserModel>> watchUsers() {
    return firestore.collection('users').snapshots().map(
            (s) => s.docs.map((d) => AppUserModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> updateUserRole(String id, String role) {
    return firestore.collection('users').doc(id).update({'role': role});
  }
}