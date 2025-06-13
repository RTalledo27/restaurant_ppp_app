import 'package:restaurant_ppp_app/domain/entities/branch.dart';
import 'package:restaurant_ppp_app/domain/repositories/branch_repository.dart';
import '../datasources/branch_remote_data_source.dart';
import '../models/branch_model.dart';

class BranchRepositoryImpl implements BranchRepository {
  final BranchRemoteDataSource remote;
  BranchRepositoryImpl(this.remote);

  @override
  Stream<List<Branch>> watchBranches() {
    return remote.watchBranches();
  }

  @override
  Future<void> addBranch(Branch branch) {
    final model = BranchModel(id: branch.id, name: branch.name, address: branch.address);
    return remote.addBranch(model);
  }
}