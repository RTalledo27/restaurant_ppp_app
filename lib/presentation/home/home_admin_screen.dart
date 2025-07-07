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
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(orderListStreamProvider);
          ref.invalidate(userListStreamProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildWelcomeHeader(),
              _buildStatsSection(context, ordersToday, userCount),
              _buildManagementSection(context),
              const SizedBox(height: 16), // Reducido de 20 a 16
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Panel de Administración',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.logout, color: Colors.red[600]),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true) {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }
            },
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18), // Reducido de 20 a 18
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.orange[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Bienvenido, Admin! 👋',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gestiona tu restaurante desde aquí',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 14), // Reducido de 16 a 14
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Panel de Control',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14), // Reducido de 16 a 14
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 36, // Reducido de 40 a 36
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, int ordersToday, int userCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas de Hoy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14), // Reducido de 16 a 14
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Pedidos Hoy',
                  value: '$ordersToday',
                  icon: Icons.shopping_basket_outlined,
                  color: Colors.blue,
                  trend: '+12%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Usuarios',
                  value: '$userCount',
                  icon: Icons.people_outline,
                  color: Colors.green,
                  trend: '+5%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // Reducido de 12 a 10
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Ingresos',
                  value: 'S/.2,450',
                  icon: Icons.attach_money,
                  color: Colors.purple,
                  trend: '+8%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Promedio',
                  value: '4.8⭐',
                  icon: Icons.star_outline,
                  color: Colors.orange,
                  trend: '+0.2',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(12), // Reducido de 14 a 12
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7), // Reducido de 8 a 7
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18), // Reducido de 20 a 18
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 9, // Reducido de 10 a 9
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Reducido de 10 a 8
          Text(
            value,
            style: const TextStyle(
              fontSize: 16, // Reducido de 18 a 16
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 3), // Reducido de 4 a 3
          Text(
            title,
            style: TextStyle(
              fontSize: 11, // Reducido de 12 a 11
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18), // Reducido de 20 a 18
          const Text(
            'Gestión del Restaurante',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14), // Reducido de 16 a 14
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 10, // Reducido de 12 a 10
            childAspectRatio: 1.2, // Aumentado de 1.15 a 1.2 para más espacio
            children: [
              _buildFeatureCard(
                context,
                title: 'Menú',
                subtitle: 'Gestionar productos',
                icon: Icons.restaurant_menu,
                color: Colors.green,
                onTap: () => Navigator.pushNamed(context, Routes.manageMenu),
              ),
              _buildFeatureCard(
                context,
                title: 'Pedidos',
                subtitle: 'Ver y gestionar',
                icon: Icons.shopping_cart_outlined,
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, Routes.manageOrders),
              ),
              _buildFeatureCard(
                context,
                title: 'Sucursales',
                subtitle: 'Administrar tiendas',
                icon: Icons.store_outlined,
                color: Colors.orange,
                onTap: () => Navigator.pushNamed(context, Routes.manageBranches),
              ),
              _buildFeatureCard(
                context,
                title: 'Usuarios',
                subtitle: 'Gestionar clientes',
                icon: Icons.people_outline,
                color: Colors.purple,
                onTap: () => Navigator.pushNamed(context, Routes.manageUsers),
              ),
              _buildFeatureCard(
                context,
                title: 'Reportes',
                subtitle: 'Análisis y datos',
                icon: Icons.bar_chart_outlined,
                color: Colors.red,
                onTap: () => Navigator.pushNamed(context, Routes.reports),
              ),
              _buildFeatureCard(
                context,
                title: 'Configuración',
                subtitle: 'Ajustes del sistema',
                icon: Icons.settings_outlined,
                color: Colors.teal,
                onTap: () => Navigator.pushNamed(context, Routes.settings),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14), // Reducido de 16 a 14
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12), // Reducido de 14 a 12
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 26, // Reducido de 28 a 26
                    color: color,
                  ),
                ),
                const SizedBox(height: 10), // Reducido de 12 a 10
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14, // Reducido de 15 a 14
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3), // Reducido de 4 a 3
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10, // Reducido de 11 a 10
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
