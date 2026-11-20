import 'package:flutter/material.dart';

enum AppLocale { th, en }

enum AppSection { home, about, timeline, projects, contact }

class AppState {
  AppState({required AppLocale locale, required ThemeMode themeMode})
    : locale = ValueNotifier(locale),
      themeMode = ValueNotifier(themeMode);

  final ValueNotifier<AppLocale> locale;
  final ValueNotifier<ThemeMode> themeMode;
  final ValueNotifier<String> selectedCategory = ValueNotifier('all');
  final ValueNotifier<AppSection> activeSection = ValueNotifier(
    AppSection.home,
  );
  final ValueNotifier<bool> isGeneratingPdf = ValueNotifier(false);
  final ValueNotifier<bool> showBackToTop = ValueNotifier(false);
}
