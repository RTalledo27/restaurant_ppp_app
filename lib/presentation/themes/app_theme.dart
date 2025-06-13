import 'package:flutter/material.dart';

class AppTheme{
  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
    scaffoldBackgroundColor: const Color(0xFFFDFDFD),
    fontFamily: 'Nunito',
  );

  static ThemeData get dark => ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepOrange,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF303030),
    fontFamily: 'Nunito',
  );
}