import 'package:flutter/material.dart';

class RokosLogo extends StatelessWidget {
  const RokosLogo({super.key,
    this.cutColor  = const Color(0xFFC45525), // naranja por defecto
    this.rTextColor   = Colors.white,
    this.rokosTextColor = Colors.white,
  });

  /// Color del rectángulo que “corta” la R.
  final Color cutColor;

  /// Color de la “R”.
  final Color rTextColor;

  /// Color del texto “ROKOS”.
  final Color rokosTextColor;

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // R (Hot Restaurant)
           Positioned.fill(
            child: Text(
              'R',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'HotRestaurant',
                fontSize: 200,
                fontWeight: FontWeight.w400,
                color: rTextColor,
                height: 1,      // 100 %
                letterSpacing: 0,
              ),
            ),
          ),

          // Rectángulo que “corta” la R
          Positioned(
            top: 90,                 // ~36 % de 200 px
            left: 0,
            right: 0,
            child: ColoredBox(
              color: cutColor,
              child: SizedBox(height: 25), // un poco más alto que 16 px
            ),
          ),

          // ROKOS (White On Black 16 px)
           Positioned(
            top: 95,                 // centra sobre el corte
            left: 27,
            right: 0,
            child: Text(
              'ROKOS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'WhiteOnBlack',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: rokosTextColor,
                height: 1,
                letterSpacing: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
