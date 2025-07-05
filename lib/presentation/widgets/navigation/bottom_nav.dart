import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class DeliveryBottomNav extends StatelessWidget {
  final int currentIndex;

  const DeliveryBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Inicio',
                route: Routes.homeUser,
              ),
              _buildNavItem(
                context: context,
                index: 1,
                icon: Icons.delivery_dining_outlined,
                activeIcon: Icons.delivery_dining,
                label: 'Pedidos',
                route: Routes.orders,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
  }) {
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleNavigation(context, index, route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.blue[600]
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? Colors.white
                      : Colors.grey[600],
                  size: 24,
                ),
              ),

              const SizedBox(height: 4),

              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: isActive
                      ? Colors.blue[600]
                      : Colors.grey[600],
                ),
                child: Text(label),
              ),

              // Active Indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(top: 2),
                width: isActive ? 20 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index, String route) {
    if (currentIndex != index) {
      // Add haptic feedback
      _triggerHapticFeedback();

      // Navigate with custom transition
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _triggerHapticFeedback() {
    // You can add haptic feedback here if needed
    // HapticFeedback.lightImpact();
  }
}

// Alternative version with more delivery-specific options
class DeliveryBottomNavExtended extends StatelessWidget {
  final int currentIndex;

  const DeliveryBottomNavExtended({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 85,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildExtendedNavItem(
                context: context,
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Inicio',
                route: Routes.homeUser,
                color: Colors.blue,
              ),
              _buildExtendedNavItem(
                context: context,
                index: 1,
                icon: Icons.delivery_dining_outlined,
                activeIcon: Icons.delivery_dining,
                label: 'Entregas',
                route: Routes.orders,
                color: Colors.orange,
              ),
              _buildExtendedNavItem(
                context: context,
                index: 2,
                icon: Icons.location_on_outlined,
                activeIcon: Icons.location_on,
                label: 'Mapa',
                route: Routes.orders, // Replace with actual map route
                color: Colors.green,
              ),
              _buildExtendedNavItem(
                context: context,
                index: 3,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Perfil',
                route: Routes.orders, // Replace with actual profile route
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtendedNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
    required Color color,
  }) {
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleNavigation(context, index, route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with background
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isActive
                      ? color
                      : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? Colors.white
                      : color,
                  size: 22,
                ),
              ),

              const SizedBox(height: 6),

              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: isActive
                      ? color
                      : Colors.grey[600],
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index, String route) {
    if (currentIndex != index) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}

// Simple modern version
class DeliveryBottomNavSimple extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DeliveryBottomNavSimple({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining_outlined),
            activeIcon: Icon(Icons.delivery_dining),
            label: 'Entregas',
          ),
        ],
      ),
    );
  }
}