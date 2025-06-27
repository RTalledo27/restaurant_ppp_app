import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/order_providers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final ordersAsync = ref.watch(userOrderListStreamProvider(uid));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 2,
        title: const Text('Mis pedidos', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ordersAsync.when(
        data: (orders) => orders.isEmpty
            ? const Center(child: Text('Aún no tienes pedidos'))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final order = orders[i];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text('Pedido #${order.id}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Estado: ${order.status}'),
                    const SizedBox(height: 4),
                    Text('Total: \$${order.total.toStringAsFixed(2)}'),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showDetail(context, order),
              ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detalle del Pedido #${order.id}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              ...order.items.map((i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500)),
                          Text('Cantidad: ${i.quantity}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Text('\$${i.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
              const Divider(height: 24),
              Text('Total: \$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Estado: ${order.status}',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              if (order.deliveryLocation != null)
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        (order.deliveryLocation['lat'] as num).toDouble(),
                        (order.deliveryLocation['lng'] as num).toDouble(),
                      ),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('delivery'),
                        position: LatLng(
                          (order.deliveryLocation['lat'] as num).toDouble(),
                          (order.deliveryLocation['lng'] as num).toDouble(),
                        ),
                      ),
                      if (order.location != null)
                        Marker(
                          markerId: const MarkerId('dest'),
                          position: LatLng(
                            (order.location['lat'] as num).toDouble(),
                            (order.location['lng'] as num).toDouble(),
                          ),
                        ),
                    },
                  ),
                ),

            ],
          ),
        );
      },
    );
  }
}