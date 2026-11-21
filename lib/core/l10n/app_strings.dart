/// หน้าที่หลัก: รวมข้อความ UI ที่สลับตามภาษาของแอป
library;

import '../state/app_state.dart';

class AppStrings {
  const AppStrings._();

  static String profileCaption(AppLocale locale) =>
      locale == AppLocale.th ? 'สวัสดี!' : 'Hello!';

  static String resumeTooltip(AppLocale locale) =>
      locale == AppLocale.th ? 'ดาวน์โหลด Resume PDF' : 'Download Resume PDF';

  static String backToTop(AppLocale locale) =>
      locale == AppLocale.th ? 'กลับขึ้นด้านบน' : 'Back to top';

  static String emailTooltip(AppLocale locale, String email) =>
      locale == AppLocale.th ? 'คัดลอกอีเมล: $email' : 'Copy email: $email';

  static String phoneTooltip(AppLocale locale, String phone) =>
      locale == AppLocale.th ? 'คัดลอกเบอร์โทร: $phone' : 'Copy phone: $phone';

  static String phoneCopied(AppLocale locale) =>
      locale == AppLocale.th ? 'คัดลอกเบอร์โทรแล้ว' : 'Phone number copied';

  static String phoneLabel(AppLocale locale) =>
      locale == AppLocale.th ? 'โทรศัพท์' : 'Phone';

  static List<String> navigationLabels(AppLocale locale) =>
      locale == AppLocale.th
      ? const ['หน้าแรก', 'เกี่ยวกับฉัน', 'ประวัติ', 'ผลงาน', 'ติดต่อ']
      : const ['Home', 'About', 'Timeline', 'Projects', 'Contact'];

  static String changeLanguageTooltip(AppLocale locale) =>
      locale == AppLocale.th ? 'เปลี่ยนภาษา' : 'Change language';

  static String toggleThemeTooltip(AppLocale locale) =>
      locale == AppLocale.th ? 'สลับธีม' : 'Toggle theme';

  static String contentLoadError(AppLocale locale) => locale == AppLocale.th
      ? 'ไม่สามารถโหลดข้อมูลได้'
      : 'Unable to load content';

  static String emailCopied(AppLocale locale) =>
      locale == AppLocale.th ? 'คัดลอกอีเมลแล้ว' : 'Email copied to clipboard';
}
