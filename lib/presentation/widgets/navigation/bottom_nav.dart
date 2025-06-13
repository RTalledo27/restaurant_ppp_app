import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
class DeliveryBottomNav extends StatelessWidget {
  final int currentIndex;
  const DeliveryBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        switch (i) {
          case 0:
            if (currentIndex != 0) {
              Navigator.pushReplacementNamed(context, Routes.homeUser);
            }
            break;
          case 1:
            if (currentIndex != 1) {
              Navigator.pushReplacementNamed(context, Routes.orders);
            }
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.pedal_bike_outlined), label: 'Pedidos'),
      ],
    );
  }
}
