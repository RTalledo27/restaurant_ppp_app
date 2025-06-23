import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/order_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderListStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: ordersAsync.when(
        data: (orders) {
          final total = orders.length;
          final pending = orders.where((o) => o.status == 'pending').length;
          final inProgress = orders.where((o) => o.status == 'in_progress').length;
          final completed = orders.where((o) => o.status == 'completed').length;
          return ListView(
            children: [
              ListTile(
                title: const Text('Total de pedidos'),
                trailing: Text('$total'),
              ),
              ListTile(
                title: const Text('Pendientes'),
                trailing: Text('$pending'),
              ),
              ListTile(
                title: const Text('En progreso'),
                trailing: Text('$inProgress'),
              ),
              ListTile(
                title: const Text('Completados'),
                trailing: Text('$completed'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
