import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/order_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderListStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ordersAsync.when(
        data: (orders) {
          final total = orders.length;
          final pending = orders.where((o) => o.status == 'pending').length;
          final inProgress = orders.where((o) => o.status == 'in_progress').length;
          final completed = orders.where((o) => o.status == 'completed').length;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildReportCard(
                  context,
                  title: 'Total de pedidos',
                  count: total,
                  icon: Icons.receipt_long,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                _buildReportCard(
                  context,
                  title: 'Pendientes',
                  count: pending,
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildReportCard(
                  context,
                  title: 'En progreso',
                  count: inProgress,
                  icon: Icons.hourglass_bottom,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildReportCard(
                  context,
                  title: 'Completados',
                  count: completed,
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context,
      {required String title,
        required int count,
        required IconData icon,
        required Color color}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            Text(
              '$count',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
