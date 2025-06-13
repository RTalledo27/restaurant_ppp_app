import '../entities/branch.dart';
import '../repositories/branch_repository.dart';

class AddBranch {
  final BranchRepository repository;
  AddBranch(this.repository);

  Future<void> call(Branch branch) => repository.addBranch(branch);
}
