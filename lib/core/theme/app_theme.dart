import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF2563EB);
  static const sky = Color(0xFF38BDF8);
  static const darkAccent = Color(0xFF7DD3FC);
  static const lightNavbarSurface = Color(0xFFE7F1FF);
  static const darkNavbarSurface = Color(0xFF10263F);

  static Color navbarSurface(Brightness brightness) =>
      brightness == Brightness.dark ? darkNavbarSurface : lightNavbarSurface;

  static Color navbarAccent(Brightness brightness) =>
      brightness == Brightness.dark ? darkAccent : primary;

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
    ).copyWith(primary: darkAccent),
    scaffoldBackgroundColor: const Color(0xFF07111F),
  );
}
