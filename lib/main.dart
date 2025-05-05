import 'package:flutter/material.dart';
import 'package:restaurant_ppp_app/presentation/auth/recover_screen.dart';

import 'presentation/routes/app_routes.dart';
import 'presentation/themes/app_theme.dart';
import 'presentation/splash/splash_screen.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/auth/register_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rokos Restaurant',
      theme: AppTheme.light,               // 🎨 Tema global
      initialRoute: Routes.splash,         // 🏁 Pantalla inicial
      routes: {
        Routes.splash   : (_) => const SplashScreen(),
        Routes.login    : (_) => const LoginScreen(),
        Routes.register : (_) => const RegisterScreen(),
        Routes.recover  : (_) => const RecoverScreen(),
      },
    );
  }
}
