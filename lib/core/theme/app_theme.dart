import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF2563EB);
  static const sky = Color(0xFF38BDF8);

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    fontFamily: 'Sarabun',
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: const Color(0xFFFFFFFF),
    ),
    scaffoldBackgroundColor: const Color(0xFFF7FAFF),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    fontFamily: 'Sarabun',
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: sky,
      brightness: Brightness.dark,
      surface: const Color(0xFF0F172A),
    ),
    scaffoldBackgroundColor: const Color(0xFF07111F),
  );
}
