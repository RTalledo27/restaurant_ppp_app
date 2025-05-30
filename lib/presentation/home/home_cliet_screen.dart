import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../widgets/navigation/bottom_nav.dart';

class HomeClientScreen extends StatelessWidget {
  static const route = '/home-client';

  const HomeClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Inicio'),
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {/* TODO: abrir perfil */},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {/* TODO: abrir carrito */},
          ),
        ],
      ),

      // —— cuerpo —— //
      body: Center(
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/home_promo_placeholder.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),

      // —— navegación inferior —— //
      bottomNavigationBar: const DeliveryBottomNav(currentIndex: 0),
    );
  }
}
