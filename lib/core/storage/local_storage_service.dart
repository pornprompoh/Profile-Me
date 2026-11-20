// หน้าที่หลัก: อ่านและเขียนการตั้งค่าแอปผ่าน browser localStorage
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../state/app_state.dart';

class LocalStorageService {
  const LocalStorageService._();

  static String? read(String key) {
    try {
      return web.window.localStorage.getItem(key);
    } catch (_) {
      return null;
    }
  }

  static void write(String key, String value) {
    try {
      web.window.localStorage.setItem(key, value);
    } catch (_) {}
  }

  static AppLocale initialLocale() {
    final saved = read('profile_locale');
    if (saved == 'th') return AppLocale.th;
    if (saved == 'en') return AppLocale.en;
    final browserLanguage = web.window.navigator.language.toLowerCase();
    final platformLanguage =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final language = browserLanguage.isNotEmpty
        ? browserLanguage
        : platformLanguage;
    return language.startsWith('th') ? AppLocale.th : AppLocale.en;
  }

  static ThemeMode initialThemeMode() {
    final saved = read('profile_theme');
    if (saved == 'dark') return ThemeMode.dark;
    if (saved == 'light') return ThemeMode.light;
    final darkPreferred = web.window
        .matchMedia('(prefers-color-scheme: dark)')
        .matches;
    final platformDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
    return darkPreferred || platformDark ? ThemeMode.dark : ThemeMode.light;
  }
}
