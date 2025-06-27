import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/navigation/bottom_nav.dart';
import '../../providers/menu_providers.dart';
import '../../providers/cart_providers.dart';
import '../../providers/branch_providers.dart';
import '../../providers/ui_providers.dart';
import '../routes/app_routes.dart';
import 'package:restaurant_ppp_app/domain/entities/menu_item.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:async';


class HomeClientScreen extends ConsumerWidget {
  static const route = '/home-client';

  const HomeClientScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartProvider).length;
    final promoDismissed = ref.watch(promoDismissedProvider);
    final branchesAsync = ref.watch(branchListStreamProvider);
    final menuAsync = ref.watch(filteredMenuProvider);
    final selectedBranch = ref.watch(branchProvider);

    branchesAsync.whenData((branches) {
      if (selectedBranch == null && branches.isNotEmpty) {
        Future.microtask(() =>
        ref.read(branchProvider.notifier).state = branches.first.id);
      }
    });




    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 2,
        title: const Text('Inicio', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.receipt_long),
          tooltip: 'Mis pedidos',
          onPressed: () => Navigator.pushNamed(context, Routes.myOrders),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: 'Carrito',
                onPressed: () => Navigator.pushNamed(context, Routes.orders),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
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
      body: Column(
        children: [
          if (!promoDismissed)
            Dismissible(
              key: const ValueKey('promo'),
              direction: DismissDirection.up,
              onDismissed: (_) =>
              ref.read(promoDismissedProvider.notifier).state = true,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/UI/Historia de Instagram Restaurante a Domicilio.jpg',
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          if (promoDismissed)
            Padding(
              padding: const EdgeInsets.all(16),
              child: branchesAsync.when(
                data: (branches) => DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Sucursal',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
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
                    : items.where((e) => (e.stock[branchId] ?? 0) > 0).toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final item = filtered[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildImage(item.imageUrl),
                        ),
                        title: Text(item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(item.description,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${item.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () => _addToCart(context, ref, item),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                          fontWeight: FontWeight.bold, fontSize: 18)),
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration:
                    const InputDecoration(labelText: 'Nota (opcional)'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Agregar al carrito'),
                    onPressed: () {
                      ref.read(cartProvider.notifier).addItem(
                        item,
                        quantity: qty,
                        note: noteController.text,
                      );
                      Navigator.pop(context);
                    },
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