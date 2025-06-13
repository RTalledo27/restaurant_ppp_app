import '../entities/branch.dart';

abstract class BranchRepository {
Stream<List<Branch>> watchBranches();
Future<void> addBranch(Branch branch);
}
