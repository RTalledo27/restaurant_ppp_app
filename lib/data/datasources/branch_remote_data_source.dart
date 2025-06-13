import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/branch_model.dart';

class BranchRemoteDataSource {
  final FirebaseFirestore firestore;
  BranchRemoteDataSource(this.firestore);

  Stream<List<BranchModel>> watchBranches() {
    return firestore.collection('branches').snapshots().map(
            (s) => s.docs.map((d) => BranchModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addBranch(BranchModel branch) {
    return firestore.collection('branches').doc(branch.id).set(branch.toMap());
  }
}