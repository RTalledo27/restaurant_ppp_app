import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../providers/menu_providers.dart';
import '../../providers/branch_providers.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/branch.dart';

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
              leading: _buildImage(item.imageUrl),
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

  Future<void> _showForm(BuildContext context, WidgetRef ref, {MenuItem? existing}) async {
    final branches = await ref.read(getBranchesProvider)().first;
    final idCtrl = TextEditingController(text: existing?.id);
    final nameCtrl = TextEditingController(text: existing?.name);
    final descCtrl = TextEditingController(text: existing?.description);
    final imageCtrl = TextEditingController(text: existing?.imageUrl);
    final picker = ImagePicker();
    XFile? pickedImage;
    final priceCtrl = TextEditingController(text: existing?.price.toString());
    final stockCtrls = <String, TextEditingController>{
      for (final b in branches)
        b.id: TextEditingController(text: existing?.stock[b.id]?.toString() ?? '0'),
    };

    await showDialog(
      context: context,
      builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Nuevo producto' : 'Editar producto'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'ID')),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
                  if (pickedImage != null)
                    Image.file(File(pickedImage!.path), height: 100),
                  TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'URL de imagen')),
                  ElevatedButton(
                    onPressed: () async {
                      final file = await picker.pickImage(source: ImageSource.gallery);
                      if (file != null) {
                        setState(() => pickedImage = file);
                        final refStorage = FirebaseStorage.instance.ref('menu/${idCtrl.text}');
                        await refStorage.putFile(File(file.path));
                        final url = await refStorage.getDownloadURL();
                        imageCtrl.text = url;
                      }
                    },
                    child: const Text('Subir desde galería'),
                  ),
                  TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  ...branches.map((b) => TextField(
                    controller: stockCtrls[b.id],
                    decoration: InputDecoration(
                      labelText: 'Stock ${b.name}',
                    ),
                    keyboardType: TextInputType.number,
                  )),
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
                  final stock = <String, int>{
                    for (final b in branches)
                      b.id: int.tryParse(stockCtrls[b.id]!.text) ?? 0,
                  };
                  final item = MenuItem(
                    id: idCtrl.text,
                    name: nameCtrl.text,
                    description: descCtrl.text,
                    imageUrl: imageCtrl.text,
                    price: double.tryParse(priceCtrl.text) ?? 0,
                    stock: stock,
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