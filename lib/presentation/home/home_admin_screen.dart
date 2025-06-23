import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routes/app_routes.dart';
import '../../providers/order_providers.dart';
import '../../providers/user_providers.dart';

class HomeAdminScreen extends ConsumerWidget {
  const HomeAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderListStreamProvider);
    final usersAsync = ref.watch(userListStreamProvider);

    final orders = ordersAsync.asData?.value ?? [];
    final users = usersAsync.asData?.value ?? [];

    final ordersToday = orders.where((o) => _isToday(o.createdAt)).length;
    final userCount = users.length;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFFC45525),
        title: const Text('Panel de Administración',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
        elevation: 2,
      ),
      body: Column(
        children: [
          _buildBanner(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('ESTADÍSTICAS RÁPIDAS'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard(context, 'Pedidos hoy', '$ordersToday', Icons.shopping_basket),
                    _buildStatCard(context, 'Reservas', '0', Icons.calendar_today),
                    _buildStatCard(context, 'Usuarios', '$userCount', Icons.people),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('GESTIÓN DEL RESTAURANTE'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                      ),
                      children: [
                        _buildFeatureCard(
                          context,
                          title: 'Menú',
                          icon: Icons.restaurant_menu,
                          color: const Color(0xFF4CAF50),
                          onTap: () => Navigator.pushNamed(context, Routes.manageMenu),
                        ),
                        _buildFeatureCard(
                          context,
                          title: 'Pedidos',
                          icon: Icons.shopping_cart,
                          color: const Color(0xFF2196F3),
                          onTap: () => Navigator.pushNamed(context, Routes.manageOrders),
                        ),
                        _buildFeatureCard(
                          context,
                          title: 'Sucursales',
                          icon: Icons.store,
                          color: const Color(0xFFFF9800),
                          onTap: () => Navigator.pushNamed(context, Routes.manageBranches),
                        ),
                        _buildFeatureCard(
                          context,
                          title: 'Usuarios',
                          icon: Icons.people,
                          color: const Color(0xFF9C27B0),
                          onTap: () => Navigator.pushNamed(context, Routes.manageUsers),
                        ),
                        _buildFeatureCard(
                          context,
                          title: 'Reportes',
                          icon: Icons.bar_chart,
                          color: const Color(0xFFF44336),
                          onTap: () => Navigator.pushNamed(context, Routes.reports),
                        ),
                        _buildFeatureCard(
                          context,
                          title: 'Configuración',
                          icon: Icons.settings,
                          color: const Color(0xFF607D8B),
                          onTap: () => Navigator.pushNamed(context, Routes.settings),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 150,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/admin_banner.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'BIENVENIDO, ADMINISTRADOR',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 5,
                    color: Colors.black,
                    offset: Offset(1, 1),
                  )
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Gestión completa del restaurante',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Color(0xFF333333),
    ),
  );

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: const Color(0xFFC45525)),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isToday(DateTime? date) {
  if (date == null) return false;
  final now = DateTime.now();
  return date.year == now.year && date.month == now.month && date.day == now.day;
}
