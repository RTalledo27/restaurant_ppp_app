import 'package:flutter/material.dart';
import 'package:restaurant_ppp_app/presentation/auth/recover_screen.dart';
import 'firebase_options.dart'; // 👈 Agregado (lo genera `flutterfire configure`)
import 'package:firebase_core/firebase_core.dart'; // 👈 Agregado
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/routes/app_routes.dart';
import 'presentation/themes/app_theme.dart';
import 'presentation/splash/splash_screen.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/auth/register_screen.dart';
import 'presentation/home/home_client_screen.dart';
import 'presentation/home/home_admin_screen.dart';
import 'presentation/orders/orders_screen.dart';
import 'presentation/admin/manage_menu_screen.dart';
import 'presentation/admin/manage_branches_screen.dart';

import 'presentation/admin/manage_orders_screen.dart';
import 'presentation/admin/manage_users_screen.dart';
import 'presentation/admin/reports_screen.dart';
import 'presentation/admin/settings_screen.dart';

import 'presentation/orders/select_location_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rokos Restaurant',
      theme: AppTheme.light,               // 🎨 Tema claro

      initialRoute: Routes.splash,         // 🏁 Pantalla inicial
      routes: {
        Routes.splash   : (_) => const SplashScreen(),
        Routes.login    : (_) => const LoginScreen(),
        Routes.register : (_) => const RegisterScreen(),
        Routes.recover  : (_) => const RecoverScreen(),
        Routes.homeUser : (_) => const HomeClientScreen(),
        Routes.homeAdmin: (_) => const HomeAdminScreen(),
        Routes.selectLocation: (_) => const SelectLocationScreen(),

        Routes.orders   : (_) => const OrdersScreen(),
        Routes.manageMenu: (_) => const ManageMenuScreen(),
        Routes.manageBranches: (_) => const ManageBranchesScreen(),


        Routes.manageOrders: (_) => const ManageOrdersScreen(),
        Routes.manageUsers: (_) => const ManageUsersScreen(),
        Routes.reports: (_) => const ReportsScreen(),
        Routes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}
