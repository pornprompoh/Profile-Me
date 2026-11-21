/// หน้าที่หลัก: ประกอบ MaterialApp พร้อม State Scope และ Theme
library;

import 'package:flutter/material.dart';

import '../core/state/app_state_scope.dart';
import '../core/theme/app_theme.dart';
import '../presentation/portfolio_ui.dart';
import 'app_bootstrap.dart';

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppBootstrap.createState();
    return AppStateScope(
      state: state,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: state.themeMode,
        builder: (context, mode, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Profile Portfolio',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: const PortfolioPage(),
        ),
      ),
    );
  }
}
