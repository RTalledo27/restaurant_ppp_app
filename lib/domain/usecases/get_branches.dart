import '../entities/branch.dart';
import '../repositories/branch_repository.dart';

class GetBranches {
  final BranchRepository repository;
  GetBranches(this.repository);

  Stream<List<Branch>> call() => repository.watchBranches();
}