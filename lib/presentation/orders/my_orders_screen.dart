import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/order_providers.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final ordersAsync = ref.watch(userOrderListStreamProvider(uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Mis pedidos')),
      body: ordersAsync.when(
        data: (orders) => orders.isEmpty
            ? const Center(child: Text('Aún no tienes pedidos'))
            : ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final order = orders[i];
            return ListTile(
              title: Text('Pedido ${order.id}'),
              subtitle: Text('Estado: ${order.status}'),
              trailing:
              Text('\$${order.total.toStringAsFixed(2)}'),
              onTap: () => _showDetail(context, order),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showDetail(BuildContext context, order) {
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
              const SizedBox(height: 8),
              ...order.items.map((i) => ListTile(
                title: Text(i.name),
                subtitle: Text('Cantidad: ${i.quantity}'),
                trailing: Text('\$${i.total.toStringAsFixed(2)}'),
              )),
              const SizedBox(height: 8),
              Text('Total: \$${order.total.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('Estado: ${order.status}'),
            ],
          ),
        );
      },
    );
  }
}
