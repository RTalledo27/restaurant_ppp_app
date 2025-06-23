import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/cart_providers.dart';
import '../../providers/order_providers.dart';
import '../../providers/branch_providers.dart';
import '../routes/app_routes.dart';
import '../../domain/entities/order.dart' as domain;
import '../../domain/entities/order_item.dart';
import 'dart:io';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = cart.fold<double>(0, (p, c) => p + c.total);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 2,
        title: const Text('Carrito', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cart.isEmpty
          ? const Center(child: Text('No hay productos en el carrito'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cart.length,
        itemBuilder: (context, i) {
          final item = cart[i];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImage(item.item.imageUrl),
              ),
              title: Text(item.item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cantidad: ${item.quantity}'),
                  if (item.note.isNotEmpty)
                    Text('Nota: ${item.note}',
                        style:
                        const TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
              trailing: Text('\$${item.total.toStringAsFixed(2)}'),
            ),
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
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  String paymentMethod = 'efectivo';
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 24,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Método de pago',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: paymentMethod,
                              items: const [
                                DropdownMenuItem(
                                  value: 'efectivo',
                                  child: Text('Efectivo'),
                                ),
                                DropdownMenuItem(
                                  value: 'tarjeta',
                                  child:
                                  Text('Tarjeta (no disponible)'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() =>
                                paymentMethod = value ?? 'efectivo');
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: Text(
                                  'Confirmar pedido - \$${total.toStringAsFixed(2)}'),
                              onPressed: () async {
                                final user = FirebaseAuth
                                    .instance.currentUser;
                                final branchId = ref.read(branchProvider);
                                final order = domain.Order(
                                  id: '',
                                  userId: user?.uid ?? '',
                                  branchId: branchId ?? '',
                                  items: cart
                                      .map((e) => OrderItem(
                                    id: e.item.id,
                                    name: e.item.name,
                                    quantity: e.quantity,
                                    note: e.note,
                                    price: e.item.price,
                                  ))
                                      .toList(),
                                  total: total,
                                  status: 'pending',
                                  location: {
                                    'lat': location.latitude,
                                    'lng': location.longitude,
                                  },
                                  paymentMethod: paymentMethod,
                                );
                                await ref
                                    .read(createOrderProvider)(order);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                      content: Text(
                                          'Pedido confirmado')));
                                  ref
                                      .read(cartProvider.notifier)
                                      .clear();
                                }
                              },
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              );
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