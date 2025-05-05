import 'dart:async';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/logo/rokos_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: .8, end: 1).animate(_fade);

    _ctrl.forward();
    Timer(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacementNamed(context, Routes.login);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFC45525);

    return const Scaffold(
      backgroundColor: primary,

      body: SafeArea(
        child: Center(
          child: _SplashContent(),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: (context.findAncestorStateOfType<_SplashScreenState>()?._fade)!,
      child: ScaleTransition(
        scale: (context.findAncestorStateOfType<_SplashScreenState>()?._scale)!,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            RokosLogo(),            // isotipo con R + ROKOS
            //SizedBox(height: 0),   separación
            Text(
              'Restaurant',
              style: TextStyle(
                fontFamily: 'HotRestaurant',
                fontSize: 70,
                color: Colors.white,
                height: 1,
              ),
            ),
            // Desplazamos DELIVERY APP 12 px a la izquierda
            Padding(
              padding: EdgeInsets.only(left: 112),
              child: Text(
                'DELIVERY APP',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 30,
                  color: Colors.white,
                  letterSpacing: 1,
                  height: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
