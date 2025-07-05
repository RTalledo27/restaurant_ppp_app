import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/datasources/branch_remote_data_source.dart';
import '../data/repositories_impl/branch_repository_impl.dart';
import '../domain/usecases/get_branches.dart';
import '../domain/usecases/add_branch.dart';
import 'menu_providers.dart';

final branchInitProvider = StateProvider<bool>((ref) => false);


final branchRemoteDataSourceProvider = Provider<BranchRemoteDataSource>((ref) {
  return BranchRemoteDataSource(ref.read(firestoreProvider));
});

final branchRepositoryProvider = Provider<BranchRepositoryImpl>((ref) {
  return BranchRepositoryImpl(ref.read(branchRemoteDataSourceProvider));
});

final getBranchesProvider = Provider<GetBranches>((ref) {
  return GetBranches(ref.read(branchRepositoryProvider));
});

final addBranchProvider = Provider<AddBranch>((ref) {
  return AddBranch(ref.read(branchRepositoryProvider));
});

final branchListStreamProvider = StreamProvider.autoDispose((ref) {
  return ref.read(getBranchesProvider)();
});
