/// หน้าที่หลัก: ให้ UI เข้าถึง AppState ผ่าน InheritedWidget
library;

import 'package:flutter/widgets.dart';

import 'app_state.dart';

class AppStateScope extends InheritedWidget {
  const AppStateScope({required this.state, required super.child, super.key});

  final AppState state;

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.state;

  @override
  bool updateShouldNotify(AppStateScope oldWidget) => state != oldWidget.state;
}
