import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/cart_providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = cart.fold<double>(0, (p, c) => p + c.total);

    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: cart.isEmpty
          ? const Center(child: Text('No hay productos en el carrito'))
          : ListView.builder(
        itemCount: cart.length,
        itemBuilder: (context, i) {
          final item = cart[i];
          return ListTile(
            leading: Image.network(
              item.item.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
            title: Text(item.item.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cantidad: ${item.quantity}'),
                if (item.note.isNotEmpty)
                  Text('Nota: ${item.note}',
                      style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
            trailing:
            Text('\$${item.total.toStringAsFixed(2)}'),
          );
        },
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            // TODO: proceed to checkout / location
          },
          child:
          Text('Confirmar pedido - \$${total.toStringAsFixed(2)}'),
        ),
      ),
    );
  }
}