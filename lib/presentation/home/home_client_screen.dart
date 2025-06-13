import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/navigation/bottom_nav.dart';
import '../../providers/menu_providers.dart';

class HomeClientScreen extends StatelessWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Inicio'),
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {/* TODO: abrir perfil */},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {/* TODO: abrir carrito */},
          ),
        ],
      ),

      // —— cuerpo —— //
      body: Consumer(
        builder: (context, ref, _) {
          final menuAsync = ref.watch(menuListStreamProvider);
          return menuAsync.when(
            data: (items) => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Image.network(
                      item.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.name),
                    subtitle: Text(item.description),
                    trailing: Text('\$${item.price.toStringAsFixed(2)}'),
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: \$e')),
          );
        },
      ),

      // —— navegación inferior —— //
      bottomNavigationBar: const DeliveryBottomNav(currentIndex: 0),
    );
  }
}
