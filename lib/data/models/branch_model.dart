import 'package:restaurant_ppp_app/domain/entities/branch.dart';

class BranchModel extends Branch {
  BranchModel({required super.id, required super.name, required super.address});

  factory BranchModel.fromMap(Map<String, dynamic> map, String id) {
    return BranchModel(
      id: id,
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'address': address};
  }
}