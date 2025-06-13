import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/menu_providers.dart';
import '../../domain/entities/menu_item.dart';

class ManageMenuScreen extends ConsumerWidget {
  const ManageMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(menuListStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Menú')),
      body: menuAsync.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            return ListTile(
              leading: Image.network(item.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
              title: Text(item.name),
              subtitle: Text(item.description),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showForm(context, ref, existing: item),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, {MenuItem? existing}) {
    final idCtrl = TextEditingController(text: existing?.id);
    final nameCtrl = TextEditingController(text: existing?.name);
    final descCtrl = TextEditingController(text: existing?.description);
    final imageCtrl = TextEditingController(text: existing?.imageUrl);
    final priceCtrl = TextEditingController(text: existing?.price.toString());

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(existing == null ? 'Nuevo producto' : 'Editar producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'ID')),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
                TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'URL de imagen')),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final item = MenuItem(
                  id: idCtrl.text,
                  name: nameCtrl.text,
                  description: descCtrl.text,
                  imageUrl: imageCtrl.text,
                  price: double.tryParse(priceCtrl.text) ?? 0,
                );
                if (existing == null) {
                  await ref.read(addMenuItemProvider)(item);
                } else {
                  await ref.read(updateMenuItemProvider)(item);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
