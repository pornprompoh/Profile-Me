import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static const primary = AppColors.lightPrimary;
  static const sky = AppColors.oceanSky;
  static const darkAccent = AppColors.darkPrimary;
  static const lightNavbarSurface = AppColors.lightSurfaceSoft;
  static const darkNavbarSurface = AppColors.darkOceanDeep;

  static Color navbarSurface(Brightness brightness) =>
      brightness == Brightness.dark ? darkNavbarSurface : lightNavbarSurface;

  static Color navbarAccent(Brightness brightness) =>
      brightness == Brightness.dark ? darkAccent : primary;

  static Color cardSurface(Brightness brightness) =>
      brightness == Brightness.dark
      ? AppColors.darkSurface
      : AppColors.lightSurface;

  static Color cardBorder(Brightness brightness) =>
      brightness == Brightness.dark
      ? AppColors.darkCardBorder
      : AppColors.lightCardBorder;

  static Color cardShadow(Brightness brightness) =>
      brightness == Brightness.dark
      ? AppColors.darkCardShadow
      : AppColors.lightCardShadow;

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    fontFamily: 'Sarabun',
    brightness: Brightness.light,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.oceanBlue,
          brightness: Brightness.light,
          surface: AppColors.lightSurface,
        ).copyWith(
          primary: primary,
          onPrimary: Colors.white,
          secondary: AppColors.oceanBlue,
          onSecondary: Colors.white,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightOceanDeep,
          surfaceContainerHighest: AppColors.lightSurfaceSoft,
          outlineVariant: AppColors.lightBorder,
        ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    dividerColor: AppColors.lightBorder,
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      shadowColor: AppColors.lightCardShadow,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.lightCardBorder),
      ),
    ),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    fontFamily: 'Sarabun',
    brightness: Brightness.dark,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.oceanSky,
          brightness: Brightness.dark,
          surface: AppColors.darkSurface,
        ).copyWith(
          primary: darkAccent,
          onPrimary: AppColors.darkBackground,
          secondary: AppColors.oceanSky,
          onSecondary: AppColors.darkBackground,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkText,
          surfaceContainerHighest: AppColors.darkSurfaceRaised,
          outlineVariant: AppColors.darkBorder,
        ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    dividerColor: AppColors.darkBorder,
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      shadowColor: AppColors.darkCardShadow,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.darkCardBorder),
      ),
    ),
  );
}
