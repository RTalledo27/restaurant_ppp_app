import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/order_providers.dart';
import '../../domain/entities/order.dart';

class ManageOrdersScreen extends ConsumerWidget {
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderListStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: ordersAsync.when(
        data: (orders) => ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final order = orders[i];
            return ListTile(
              title: Text('Pedido ${order.id}'),
              subtitle: Text('Sucursal: ${order.branchId}\nEstado: ${order.status}'),
              trailing: Text('\$${order.total.toStringAsFixed(2)}'),
              isThreeLine: true,
              onTap: () => _showDetail(context, ref, order),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref, Order order) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pedido ${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Sucursal: ${order.branchId}'),
              const SizedBox(height: 8),
              ...order.items.map((i) => ListTile(
                title: Text(i.name),
                subtitle: Text('Cantidad: ${i.quantity}'),
                trailing: Text('\$${i.total.toStringAsFixed(2)}'),
              )),
              const SizedBox(height: 8),
              Text('Total: \$${order.total.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: order.status,
                onChanged: (v) {
                  if (v != null) {
                    ref.read(updateOrderStatusProvider)(order.id, v);
                    Navigator.pop(context);
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pendiente')),
                  DropdownMenuItem(value: 'in_progress', child: Text('En progreso')),
                  DropdownMenuItem(value: 'completed', child: Text('Completado')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
