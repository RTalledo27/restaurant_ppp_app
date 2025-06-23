import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/cart_providers.dart';
import '../routes/app_routes.dart';
import 'dart:io';


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
            leading: _buildImage(
              item.item.imageUrl,
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
          onPressed: () async {
            final location = await Navigator.pushNamed(
              context,
              Routes.selectLocation,
            ) as LatLng?;
            if (location != null && context.mounted) {
              final user = FirebaseAuth.instance.currentUser;
              await FirebaseFirestore.instance.collection('orders').add({
                'userId': user?.uid ?? '',
                'items': cart
                    .map((e) => {
                  'id': e.item.id,
                  'name': e.item.name,
                  'quantity': e.quantity,
                  'note': e.note,
                  'price': e.item.price,
                })
                    .toList(),
                'total': total,
                'status': 'pending',
                'createdAt': FieldValue.serverTimestamp(),
                'location': {
                  'lat': location.latitude,
                  'lng': location.longitude,
                },
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pedido confirmado')),
              );
              ref.read(cartProvider.notifier).clear();
            }
          },
          child: Text('Confirmar pedido - \$${total.toStringAsFixed(2)}'),

        ),
      ),
    );
  }
}
Widget _buildImage(String url) {
  if (url.startsWith('http')) {
    return Image.network(url, width: 56, height: 56, fit: BoxFit.cover);
  }
  return Image.file(File(url), width: 56, height: 56, fit: BoxFit.cover);
}