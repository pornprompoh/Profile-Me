// หน้าที่หลัก: Model และการแปลงข้อมูล JSON สำหรับข้อมูลโฟลิโอ
import 'localized_text.dart';

class ProfileLanguage {
  ProfileLanguage(this.name, this.level);
  final LocalizedText name;
  final LocalizedText level;

  factory ProfileLanguage.fromJson(Map<String, dynamic> json) =>
      ProfileLanguage(
        LocalizedText.fromJson(json['name']),
        LocalizedText.fromJson(json['level']),
      );
}
