// หน้าที่หลัก: สร้างสถานะเริ่มต้นจาก localStorage สำหรับแอป
import '../core/state/app_state.dart';
import '../core/storage/local_storage_service.dart';

class AppBootstrap {
  const AppBootstrap._();

  static AppState createState() => AppState(
    locale: LocalStorageService.initialLocale(),
    themeMode: LocalStorageService.initialThemeMode(),
  );
}
