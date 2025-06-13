import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/branch_providers.dart';
import '../../domain/entities/branch.dart';

class ManageBranchesScreen extends ConsumerWidget {
  const ManageBranchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchListStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sucursales')),
      body: branchesAsync.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) => ListTile(
            title: Text(items[i].name),
            subtitle: Text(items[i].address),
          ),
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

  void _showForm(BuildContext context, WidgetRef ref) {
    final idCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva sucursal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'ID')),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Dirección')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final branch = Branch(id: idCtrl.text, name: nameCtrl.text, address: addrCtrl.text);
              await ref.read(addBranchProvider)(branch);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          )
        ],
      ),
    );
  }
}
