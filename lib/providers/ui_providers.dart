import 'package:flutter_riverpod/flutter_riverpod.dart';

final promoDismissedProvider = StateProvider<bool>((ref) => false);
final branchProvider = StateProvider<String?>((ref) => null);