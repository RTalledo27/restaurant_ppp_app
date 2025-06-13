import 'package:flutter/material.dart';

class AppTheme{
  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
    scaffoldBackgroundColor: const Color(0xFFFDFDFD),
    fontFamily: 'Nunito',
  );
}