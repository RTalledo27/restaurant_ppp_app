import 'package:flutter/material.dart';
import 'package:restaurant_ppp_app/presentation/auth/recover_screen.dart';
import 'firebase_options.dart'; // 👈 Agregado (lo genera `flutterfire configure`)
import 'package:firebase_core/firebase_core.dart'; // 👈 Agregado

import 'presentation/routes/app_routes.dart';
import 'presentation/themes/app_theme.dart';
import 'presentation/splash/splash_screen.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/auth/register_screen.dart';
import 'presentation/home/home_client_screen.dart';
import 'presentation/home/home_admin_screen.dart';
import 'presentation/orders/orders_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rokos Restaurant',
      theme: AppTheme.light,               // 🎨 Tema claro
      darkTheme: AppTheme.dark,            // 🌙 Tema oscuro
      themeMode: ThemeMode.dark,      initialRoute: Routes.splash,         // 🏁 Pantalla inicial
      routes: {
        Routes.splash   : (_) => const SplashScreen(),
        Routes.login    : (_) => const LoginScreen(),
        Routes.register : (_) => const RegisterScreen(),
        Routes.recover  : (_) => const RecoverScreen(),
        Routes.homeUser : (_) => const HomeClientScreen(),
        Routes.homeAdmin: (_) => const HomeAdminScreen(),
        Routes.orders   : (_) => const OrdersScreen(),

      },
    );
  }
}
