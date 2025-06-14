import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/navigation/bottom_nav.dart';
import '../../providers/menu_providers.dart';
import '../../providers/cart_providers.dart';
import '../../providers/branch_providers.dart';

import '../../providers/ui_providers.dart';
import '../routes/app_routes.dart';
import 'package:restaurant_ppp_app/domain/entities/menu_item.dart';

import 'dart:io';


class HomeClientScreen extends ConsumerWidget {
  static const route = '/home-client';

  const HomeClientScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartProvider).length;
    final promoDismissed = ref.watch(promoDismissedProvider);
    final branchesAsync = ref.watch(branchListStreamProvider);
    final menuAsync = ref.watch(filteredMenuProvider);


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
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (cartCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => Navigator.pushNamed(context, Routes.orders),
          ),
        ],
      ),

      body: Column(
        children: [
          if (!promoDismissed)
            Dismissible(
              key: const ValueKey('promo'),
              direction: DismissDirection.up,
              onDismissed: (_) =>
              ref.read(promoDismissedProvider.notifier).state = true,
              child: Image.asset(
                'assets/UI/Proyecto PPP_page-0001.jpg',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          if (promoDismissed)
            Padding(
              padding: const EdgeInsets.all(16),
              child: branchesAsync.when(
                data: (branches) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Sucursal'),
                  value: ref.watch(branchProvider) ??
                      (branches.isNotEmpty ? branches.first.id : null),
                  items: branches
                      .map((b) =>
                      DropdownMenuItem(value: b.id, child: Text(b.name)))
                      .toList(),
                  onChanged: (v) =>
                  ref.read(branchProvider.notifier).state = v,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
            ),
          Expanded(
            child: menuAsync.when(
            data: (items) {
    final branchId = ref.watch(branchProvider);
    final filtered = branchId == null
    ? items
        : items
        .where((e) => (e.stock[branchId] ?? 0) > 0)
        .toList();
    return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: filtered.length,
    itemBuilder: (context, i) {
    final item = filtered[i];
    return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
    leading: _buildImage(item.imageUrl),
    title: Text(item.name),
    subtitle: Text(item.description),
    trailing: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    Text('\$${item.price.toStringAsFixed(2)}'),
    IconButton(
    icon: const Icon(Icons.add_circle_outline),
    onPressed: () => _addToCart(context, ref, item),
    ),
    ],
    ),
                      ),
    );
    },
    );
            },              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),

      bottomNavigationBar: const DeliveryBottomNav(currentIndex: 0),
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref, MenuItem item) {
    int qty = 1;
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (qty > 1) setState(() => qty--);
                        },
                      ),
                      Text('$qty', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => qty++),
                      ),
                    ],
                  ),
                  TextField(
                    controller: noteController,
                    decoration:
                    const InputDecoration(labelText: 'Nota (opcional)'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(cartProvider.notifier).addItem(
                        item,
                        quantity: qty,
                        note: noteController.text,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Agregar al carrito'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Widget _buildImage(String url) {
  if (url.startsWith('http')) {
    return Image.network(url, width: 56, height: 56, fit: BoxFit.cover);
  }
  return Image.file(File(url), width: 56, height: 56, fit: BoxFit.cover);
}