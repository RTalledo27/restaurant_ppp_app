import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/order_providers.dart';
import '../routes/app_routes.dart';
import '../../domain/entities/order.dart';

class DeliveryOrdersScreen extends ConsumerWidget {
  const DeliveryOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderListStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login,
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final order = orders[i];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                title: Text(
                  'Pedido #${order.id}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Sucursal: ${order.branchId}'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Estado: '),
                        _buildStatusChip(order.status),
                      ],
                    ),
                  ],
                ),
                trailing: Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                onTap: () => _showDetail(context, ref, order),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pendiente';
        break;
      case 'in_progress':
        color = Colors.blue;
        label = 'En progreso';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Completado';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref, Order order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Wrap(
            runSpacing: 12,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Text(
                'Pedido #${order.id}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text('Sucursal: ${order.branchId}'),
              const Divider(),
              ...order.items.map(
                    (i) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(i.name),
                  subtitle: Text('Cantidad: ${i.quantity}'),
                  trailing: Text('\$${i.total.toStringAsFixed(2)}'),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Cambiar estado:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              DropdownButtonFormField<String>(
                value: order.status,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
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
