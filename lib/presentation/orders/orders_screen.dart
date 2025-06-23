import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

import '../../providers/cart_providers.dart';
import '../../providers/ui_providers.dart';
import '../../providers/branch_providers.dart';
import '../routes/app_routes.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = cart.fold<double>(0, (p, c) => p + c.total);
    final branchesAsync = ref.watch(branchListStreamProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
            : null,
        title: const Text('Carrito'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: cart.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No hay productos en el carrito',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Seguir comprando'),
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                Routes.homeUser,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: branchesAsync.when(
              data: (branches) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Sucursal'),
                value: ref.watch(branchProvider) ??
                    (branches.isNotEmpty ? branches.first.id : null),
                items: branches
                    .map((b) => DropdownMenuItem(
                  value: b.id,
                  child: Text(b.name),
                ))
                    .toList(),
                onChanged: (v) =>
                ref.read(branchProvider.notifier).state = v,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: cart.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final item = cart[i];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImage(item.item.imageUrl),
                  ),
                  title: Text(
                    item.item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cantidad: ${item.quantity}'),
                      if (item.note.isNotEmpty)
                        Text(
                          'Nota: ${item.note}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color:
                            Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                    ],
                  ),
                  trailing: Text(
                    '\$${item.total.toStringAsFixed(2)}',
                    style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.check_circle_outline),
          onPressed: () async {
            final branchId = ref.read(branchProvider);
            if (branchId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Seleccione una sucursal')),
              );
              return;
            }

            final location = await Navigator.pushNamed(
              context,
              Routes.selectLocation,
            ) as LatLng?;

            if (location != null && context.mounted) {
              final user = FirebaseAuth.instance.currentUser;
              final firestore = FirebaseFirestore.instance;

              try {
                await firestore.runTransaction((tx) async {
                  for (final cartItem in cart) {
                    final menuRef = firestore
                        .collection('menu')
                        .doc(cartItem.item.id);
                    final menuSnap = await tx.get(menuRef);
                    final data =
                        menuSnap.data() as Map<String, dynamic>? ?? {};
                    final stockMap =
                    Map<String, dynamic>.from(data['stock'] ?? {});
                    final current =
                    (stockMap[branchId] ?? 0) as int;

                    if (current < cartItem.quantity) {
                      throw Exception(
                          'Stock insuficiente de ${cartItem.item.name}');
                    }

                    tx.update(menuRef, {
                      'stock.$branchId':
                      FieldValue.increment(-cartItem.quantity),
                    });
                  }

                  final orderRef = firestore.collection('orders').doc();
                  tx.set(orderRef, {
                    'userId': user?.uid ?? '',
                    'branchId': branchId,
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
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pedido confirmado')),
                );
                ref.read(cartProvider.notifier).clear();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            }
          },
          label: Text('Confirmar pedido - \$${total.toStringAsFixed(2)}'),
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
