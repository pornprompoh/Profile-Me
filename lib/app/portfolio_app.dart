// หน้าที่หลัก: UI และตรรกะสำหรับส่วนนี้ของ Portfolio
part of '../main.dart';

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppBootstrap.createState();
    return _StateScope(
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

class _StateScope extends InheritedWidget {
  const _StateScope({required this.state, required super.child});
  final AppState state;

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_StateScope>()!.state;

  @override
  bool updateShouldNotify(_StateScope oldWidget) => state != oldWidget.state;
}

