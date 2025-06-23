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
      appBar: AppBar(
        title: const Text('Gestionar Menú'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: menuAsync.when(
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final item = items[i];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImage(item.imageUrl),
                ),
                title: Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('\$${item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showForm(context, ref, existing: item),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showForm(BuildContext context, WidgetRef ref, {MenuItem? existing}) async {
    final branches = await ref.read(getBranchesProvider)().first;

    final isEditing = existing != null;

    final idCtrl = TextEditingController(text: existing?.id);
    final nameCtrl = TextEditingController(text: existing?.name);
    final descCtrl = TextEditingController(text: existing?.description);
    final imageCtrl = TextEditingController(text: existing?.imageUrl);
    final priceCtrl = TextEditingController(text: existing?.price.toString());
    final stockCtrls = {
      for (final b in branches)
        b.id: TextEditingController(text: existing?.stock[b.id]?.toString() ?? '0'),
    };

    final picker = ImagePicker();
    XFile? pickedImage;
    bool isUploading = false;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(isEditing ? 'Editar producto' : 'Nuevo producto'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isEditing)
                    _inputField(controller: idCtrl, label: 'ID'),
                  _inputField(controller: nameCtrl, label: 'Nombre'),
                  _inputField(controller: descCtrl, label: 'Descripción'),
                  const SizedBox(height: 8),
                  if (pickedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(pickedImage!.path), height: 100),
                    )
                  else if (imageCtrl.text.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(imageCtrl.text, height: 100),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload),
                    label: const Text('Seleccionar desde galería'),
                    onPressed: isUploading
                        ? null
                        : () async {
                      final file = await picker.pickImage(source: ImageSource.gallery);
                      if (file != null) {
                        setState(() {
                          pickedImage = file;
                          isUploading = true;
                        });
                        final refStorage =
                        FirebaseStorage.instance.ref('menu/${idCtrl.text}');
                        await refStorage.putFile(File(file.path));
                        final url = await refStorage.getDownloadURL();
                        imageCtrl.text = url;
                        setState(() => isUploading = false);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: imageCtrl,
                    label: 'URL de imagen',
                  ),
                  _inputField(
                    controller: priceCtrl,
                    label: 'Precio',
                    type: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  ...branches.map((b) => _inputField(
                    controller: stockCtrls[b.id]!,
                    label: 'Stock ${b.name}',
                    type: TextInputType.number,
                  )),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  final stock = {
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

                  if (isEditing) {
                    await ref.read(updateMenuItemProvider)(item);
                  } else {
                    await ref.read(addMenuItemProvider)(item);
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    TextInputType? type,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
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
